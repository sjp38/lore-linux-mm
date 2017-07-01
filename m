Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0ED142802FE
	for <linux-mm@kvack.org>; Sat,  1 Jul 2017 00:49:33 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id v76so61902895qka.5
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 21:49:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 66si9399693qkz.120.2017.06.30.21.49.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Jun 2017 21:49:31 -0700 (PDT)
Date: Sat, 1 Jul 2017 00:49:21 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] vmalloc: respect the GFP_NOIO and GFP_NOFS flags
In-Reply-To: <884F0682-1AF6-4C23-806F-480C86A2A036@dilger.ca>
Message-ID: <alpine.LRH.2.02.1707010048180.27681@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1706292221250.21823@file01.intranet.prod.int.rdu2.redhat.com> <884F0682-1AF6-4C23-806F-480C86A2A036@dilger.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Michal Hocko <mhocko@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>, John Hubbard <jhubbard@nvidia.com>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org



On Fri, 30 Jun 2017, Andreas Dilger wrote:

> On Jun 29, 2017, at 8:25 PM, Mikulas Patocka <mpatocka@redhat.com> wrote:
> > 
> > The __vmalloc function has a parameter gfp_mask with the allocation flags,
> > however it doesn't fully respect the GFP_NOIO and GFP_NOFS flags. The
> > pages are allocated with the specified gfp flags, but the pagetables are
> > always allocated with GFP_KERNEL. This allocation can cause unexpected
> > recursion into the filesystem or I/O subsystem.
> > 
> > It is not practical to extend page table allocation routines with gfp
> > flags because it would require modification of architecture-specific code
> > in all architecturs. However, the process can temporarily request that all
> > allocations are done with GFP_NOFS or GFP_NOIO with with the functions
> > memalloc_nofs_save and memalloc_noio_save.
> > 
> > This patch makes the vmalloc code use memalloc_nofs_save or
> > memalloc_noio_save if the supplied gfp flags do not contain __GFP_FS or
> > __GFP_IO. It fixes some possible deadlocks in drivers/mtd/ubi/io.c,
> > fs/gfs2/, fs/btrfs/free-space-tree.c, fs/ubifs/,
> > fs/nfs/blocklayout/extent_tree.c where __vmalloc is used with the GFP_NOFS
> > flag.
> > 
> > The patch also simplifies code in dm-bufio.c, dm-ioctl.c and fs/xfs/kmem.c
> > by removing explicit calls to memalloc_nofs_save and memalloc_noio_save
> > before the call to __vmalloc.
> > 
> > Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> > 
> > ---
> > drivers/md/dm-bufio.c |   24 +-----------------------
> > drivers/md/dm-ioctl.c |    6 +-----
> > fs/xfs/kmem.c         |   14 --------------
> > mm/util.c             |    6 +++---
> > mm/vmalloc.c          |   18 +++++++++++++++++-
> > 5 files changed, 22 insertions(+), 46 deletions(-)
> > 
> > Index: linux-2.6/mm/vmalloc.c
> > ===================================================================
> > --- linux-2.6.orig/mm/vmalloc.c
> > +++ linux-2.6/mm/vmalloc.c
> > @@ -31,6 +31,7 @@
> > #include <linux/compiler.h>
> > #include <linux/llist.h>
> > #include <linux/bitops.h>
> > +#include <linux/sched/mm.h>
> > 
> > #include <linux/uaccess.h>
> > #include <asm/tlbflush.h>
> > @@ -1670,6 +1671,8 @@ static void *__vmalloc_area_node(struct
> > 	unsigned int nr_pages, array_size, i;
> > 	const gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
> > 	const gfp_t alloc_mask = gfp_mask | __GFP_HIGHMEM | __GFP_NOWARN;
> > +	unsigned noio_flag;
> > +	int r;
> > 
> > 	nr_pages = get_vm_area_size(area) >> PAGE_SHIFT;
> > 	array_size = (nr_pages * sizeof(struct page *));
> > @@ -1712,8 +1715,21 @@ static void *__vmalloc_area_node(struct
> > 			cond_resched();
> > 	}
> > 
> > -	if (map_vm_area(area, prot, pages))
> > +	if (unlikely(!(gfp_mask & __GFP_IO)))
> > +		noio_flag = memalloc_noio_save();
> > +	else if (unlikely(!(gfp_mask & __GFP_FS)))
> > +		noio_flag = memalloc_nofs_save();
> > +
> > +	r = map_vm_area(area, prot, pages);
> > +
> > +	if (unlikely(!(gfp_mask & __GFP_IO)))
> > +		memalloc_noio_restore(noio_flag);
> > +	else if (unlikely(!(gfp_mask & __GFP_FS)))
> > +		memalloc_nofs_restore(noio_flag);
> 
> Is this really an "else if"?  I think it should just a separate "if".
> 
> Cheers, Andreas

It is meant to be "else if". memalloc_noio_save() implies 
memalloc_nofs_save(). If we call memalloc_noio_save(), there's no need to 
call memalloc_nofs_save().

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

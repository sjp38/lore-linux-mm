Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B66166B0279
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 02:31:23 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u23so9200015wma.14
        for <linux-mm@kvack.org>; Sun, 02 Jul 2017 23:31:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t18si10868324wrb.195.2017.07.02.23.31.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 02 Jul 2017 23:31:22 -0700 (PDT)
Date: Mon, 3 Jul 2017 08:31:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmalloc: respect the GFP_NOIO and GFP_NOFS flags
Message-ID: <20170703062905.GB3217@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1706292221250.21823@file01.intranet.prod.int.rdu2.redhat.com>
 <20170630081245.GA22917@dhcp22.suse.cz>
 <alpine.LRH.2.02.1706301410160.8272@file01.intranet.prod.int.rdu2.redhat.com>
 <20170630204059.GA17255@dhcp22.suse.cz>
 <alpine.LRH.2.02.1706302033230.13879@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1706302033230.13879@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>, Andreas Dilger <adilger@dilger.ca>, John Hubbard <jhubbard@nvidia.com>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org

On Fri 30-06-17 20:36:12, Mikulas Patocka wrote:
> 
> 
> On Fri, 30 Jun 2017, Michal Hocko wrote:
> 
> > On Fri 30-06-17 14:11:57, Mikulas Patocka wrote:
> > > 
> > > 
> > > On Fri, 30 Jun 2017, Michal Hocko wrote:
> > > 
> > > > On Thu 29-06-17 22:25:09, Mikulas Patocka wrote:
> > > > > The __vmalloc function has a parameter gfp_mask with the allocation flags,
> > > > > however it doesn't fully respect the GFP_NOIO and GFP_NOFS flags. The
> > > > > pages are allocated with the specified gfp flags, but the pagetables are
> > > > > always allocated with GFP_KERNEL. This allocation can cause unexpected
> > > > > recursion into the filesystem or I/O subsystem.
> > > > > 
> > > > > It is not practical to extend page table allocation routines with gfp
> > > > > flags because it would require modification of architecture-specific code
> > > > > in all architecturs. However, the process can temporarily request that all
> > > > > allocations are done with GFP_NOFS or GFP_NOIO with with the functions
> > > > > memalloc_nofs_save and memalloc_noio_save.
> > > > > 
> > > > > This patch makes the vmalloc code use memalloc_nofs_save or
> > > > > memalloc_noio_save if the supplied gfp flags do not contain __GFP_FS or
> > > > > __GFP_IO. It fixes some possible deadlocks in drivers/mtd/ubi/io.c,
> > > > > fs/gfs2/, fs/btrfs/free-space-tree.c, fs/ubifs/,
> > > > > fs/nfs/blocklayout/extent_tree.c where __vmalloc is used with the GFP_NOFS
> > > > > flag.
> > > > 
> > > > I strongly believe this is a step in the _wrong_ direction. Why? Because
> > > 
> > > What do you think __vmalloc with GFP_NOIO should do? Print a warning? 
> > > Silently ignore the GFP_NOIO flag?
> > 
> > I think noio users are not that much different from nofs users. Simply
> > use the scope API at the place where the scope starts and document why
> > it is needed. vmalloc calls do not have to be any special then and they
> > do not even have to think about proper gfp flags and they can use
> > whatever is the default.
> > -- 
> > Michal Hocko
> > SUSE Labs
> 
> But you didn't answer the question - what should __vmalloc with GFP_NOIO 
> (or GFP_NOFS) do? Silently drop the flag? Print a warning? Or respect the 
> flag?

We can add a warning (or move it from kvmalloc) and hope that the
respective maintainers will fix those places properly. The reason I
didn't add the warning to vmalloc and kept it in kvmalloc was to catch
only new users rather than suddenly splat on existing ones. Note that
there are users with panic_on_warn enabled.

Considering how many NOFS users we have in tree I would rather work with
maintainers to fix them.
 
> Currently, it silently drops the GFP_NOIO or GFP_NOFS flag, but some 
> programmers don't know it and use these flags. You can't blame those 
> programmers for not knowing it.

At least __vmalloc_node is documented to not support all gfp flags.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

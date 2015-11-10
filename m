Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3B95B6B0038
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 03:07:22 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so203032068pac.3
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 00:07:22 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id x8si3523619pbt.238.2015.11.10.00.07.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 00:07:21 -0800 (PST)
Date: Tue, 10 Nov 2015 11:07:09 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 5/5] Account certain kmem allocations to memcg
Message-ID: <20151110080709.GR31308@esperanza>
References: <cover.1446924358.git.vdavydov@virtuozzo.com>
 <60b4d1631e3a302246859d6a39ac7c6d6cbf3af3.1446924358.git.vdavydov@virtuozzo.com>
 <20151109143955.GF8916@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151109143955.GF8916@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Nov 09, 2015 at 03:39:55PM +0100, Michal Hocko wrote:
> On Sat 07-11-15 23:07:09, Vladimir Davydov wrote:
> > This patch marks those kmem allocations that are known to be easily
> > triggered from userspace as __GFP_ACCOUNT, which makes them accounted to
> > memcg. For the list, see below:
> > 
> >  - threadinfo
> >  - task_struct
> >  - task_delay_info
> >  - pid
> >  - cred
> >  - mm_struct
> >  - vm_area_struct and vm_region (nommu)
> >  - anon_vma and anon_vma_chain
> >  - signal_struct
> >  - sighand_struct
> >  - fs_struct
> >  - files_struct
> >  - fdtable and fdtable->full_fds_bits
> >  - dentry and external_name
> >  - inode for all filesystems. This is the most tedious part, because
> >    most filesystems overwrite the alloc_inode method. Looks like using
> >    __GFP_ACCOUNT in alloc_inode is going to become a new rule, like
> >    passing SLAB_RECLAIM_ACCOUNT on inode cache creation.
> 
> I am wondering whether using a helper function to allocate an inode
> cache would help in that regards. It would limit __GFP_ACCOUNT
> penetration into fs code.

I'm afraid that wouldn't free fs code from the need to use
__GFP_ACCOUNT, because there are other things that we might want to
account AFAICS, e.g. ext4_crypt_info_cachep or ext4_es_cachep.

> 
> pipe buffers are trivial to abuse (e.g. via fd passing) so we want to

You might also mention allocations caused by select/poll, page tables,
radix_tree_node, etc. They all might be abused, but the primary purpose
of this patch set is not catching abusers, but providing reasonable
level of isolation for most normal workloads. Let's add everything above
that in separate patches.

> cap those as well. The following should do the trick AFAICS.

Actually, no - you only account pipe metadata while anon pipe buffer
pages, which usually constitute most of memory consumed by a pipe, still
go unaccounted. I'm planning to make pipe accountable later.

> ---
> diff --git a/fs/pipe.c b/fs/pipe.c
> index 8865f7963700..c4b7e8c08362 100644
> --- a/fs/pipe.c
> +++ b/fs/pipe.c
> @@ -590,7 +590,7 @@ struct pipe_inode_info *alloc_pipe_info(void)
>  
>  	pipe = kzalloc(sizeof(struct pipe_inode_info), GFP_KERNEL);
>  	if (pipe) {
> -		pipe->bufs = kzalloc(sizeof(struct pipe_buffer) * PIPE_DEF_BUFFERS, GFP_KERNEL);
> +		pipe->bufs = kzalloc(sizeof(struct pipe_buffer) * PIPE_DEF_BUFFERS, GFP_KERNEL | __GFP_ACCOUNT);

GFP_KERNEL | __GFP_ACCOUNT are used really often, that's why I
introduced GFP_KERNEL_ACCOUNT.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

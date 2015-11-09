Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9BCCE6B0253
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 09:39:58 -0500 (EST)
Received: by wmnn186 with SMTP id n186so107391446wmn.1
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 06:39:58 -0800 (PST)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id k204si17004536wmg.116.2015.11.09.06.39.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 06:39:57 -0800 (PST)
Received: by wmec201 with SMTP id c201so72799699wme.1
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 06:39:57 -0800 (PST)
Date: Mon, 9 Nov 2015 15:39:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/5] Account certain kmem allocations to memcg
Message-ID: <20151109143955.GF8916@dhcp22.suse.cz>
References: <cover.1446924358.git.vdavydov@virtuozzo.com>
 <60b4d1631e3a302246859d6a39ac7c6d6cbf3af3.1446924358.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <60b4d1631e3a302246859d6a39ac7c6d6cbf3af3.1446924358.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat 07-11-15 23:07:09, Vladimir Davydov wrote:
> This patch marks those kmem allocations that are known to be easily
> triggered from userspace as __GFP_ACCOUNT, which makes them accounted to
> memcg. For the list, see below:
> 
>  - threadinfo
>  - task_struct
>  - task_delay_info
>  - pid
>  - cred
>  - mm_struct
>  - vm_area_struct and vm_region (nommu)
>  - anon_vma and anon_vma_chain
>  - signal_struct
>  - sighand_struct
>  - fs_struct
>  - files_struct
>  - fdtable and fdtable->full_fds_bits
>  - dentry and external_name
>  - inode for all filesystems. This is the most tedious part, because
>    most filesystems overwrite the alloc_inode method. Looks like using
>    __GFP_ACCOUNT in alloc_inode is going to become a new rule, like
>    passing SLAB_RECLAIM_ACCOUNT on inode cache creation.

I am wondering whether using a helper function to allocate an inode
cache would help in that regards. It would limit __GFP_ACCOUNT
penetration into fs code.

pipe buffers are trivial to abuse (e.g. via fd passing) so we want to
cap those as well. The following should do the trick AFAICS.
---
diff --git a/fs/pipe.c b/fs/pipe.c
index 8865f7963700..c4b7e8c08362 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -590,7 +590,7 @@ struct pipe_inode_info *alloc_pipe_info(void)
 
 	pipe = kzalloc(sizeof(struct pipe_inode_info), GFP_KERNEL);
 	if (pipe) {
-		pipe->bufs = kzalloc(sizeof(struct pipe_buffer) * PIPE_DEF_BUFFERS, GFP_KERNEL);
+		pipe->bufs = kzalloc(sizeof(struct pipe_buffer) * PIPE_DEF_BUFFERS, GFP_KERNEL | __GFP_ACCOUNT);
 		if (pipe->bufs) {
 			init_waitqueue_head(&pipe->wait);
 			pipe->r_counter = pipe->w_counter = 1;
@@ -971,7 +971,7 @@ static long pipe_set_size(struct pipe_inode_info *pipe, unsigned long nr_pages)
 	if (nr_pages < pipe->nrbufs)
 		return -EBUSY;
 
-	bufs = kcalloc(nr_pages, sizeof(*bufs), GFP_KERNEL | __GFP_NOWARN);
+	bufs = kcalloc(nr_pages, sizeof(*bufs), GFP_KERNEL | __GFP_NOWARN | __GFP_ACCOUNT);
 	if (unlikely(!bufs))
 		return -ENOMEM;
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5FE6B0038
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 08:23:22 -0500 (EST)
Received: by wmec201 with SMTP id c201so405405wme.1
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 05:23:21 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id 3si4450712wju.26.2015.11.10.05.23.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 05:23:21 -0800 (PST)
Received: by wmww144 with SMTP id w144so117444560wmw.1
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 05:23:20 -0800 (PST)
Date: Tue, 10 Nov 2015 14:23:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/5] Account certain kmem allocations to memcg
Message-ID: <20151110132319.GI8058@dhcp22.suse.cz>
References: <cover.1446924358.git.vdavydov@virtuozzo.com>
 <60b4d1631e3a302246859d6a39ac7c6d6cbf3af3.1446924358.git.vdavydov@virtuozzo.com>
 <20151109143955.GF8916@dhcp22.suse.cz>
 <20151110080709.GR31308@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151110080709.GR31308@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 10-11-15 11:07:09, Vladimir Davydov wrote:
> On Mon, Nov 09, 2015 at 03:39:55PM +0100, Michal Hocko wrote:
[...]
> > pipe buffers are trivial to abuse (e.g. via fd passing) so we want to
> 
> You might also mention allocations caused by select/poll, page tables,
> radix_tree_node, etc. They all might be abused, but the primary purpose
> of this patch set is not catching abusers, but providing reasonable
> level of isolation for most normal workloads. Let's add everything above
> that in separate patches.

Sure I do not have any objections against step by step approach.
 
> > cap those as well. The following should do the trick AFAICS.
> 
> Actually, no - you only account pipe metadata while anon pipe buffer
> pages, which usually constitute most of memory consumed by a pipe, still
> go unaccounted. I'm planning to make pipe accountable later.

You are right! I have missed pipe_write allocates the real page.

> > ---
> > diff --git a/fs/pipe.c b/fs/pipe.c
> > index 8865f7963700..c4b7e8c08362 100644
> > --- a/fs/pipe.c
> > +++ b/fs/pipe.c
> > @@ -590,7 +590,7 @@ struct pipe_inode_info *alloc_pipe_info(void)
> >  
> >  	pipe = kzalloc(sizeof(struct pipe_inode_info), GFP_KERNEL);
> >  	if (pipe) {
> > -		pipe->bufs = kzalloc(sizeof(struct pipe_buffer) * PIPE_DEF_BUFFERS, GFP_KERNEL);
> > +		pipe->bufs = kzalloc(sizeof(struct pipe_buffer) * PIPE_DEF_BUFFERS, GFP_KERNEL | __GFP_ACCOUNT);
> 
> GFP_KERNEL | __GFP_ACCOUNT are used really often, that's why I
> introduced GFP_KERNEL_ACCOUNT.

Sure that is better.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

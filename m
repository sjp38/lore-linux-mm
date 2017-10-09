Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9186B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 08:28:24 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z80so16472359pff.1
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 05:28:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j185si6217437pgc.543.2017.10.09.05.28.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Oct 2017 05:28:22 -0700 (PDT)
Date: Mon, 9 Oct 2017 14:28:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] [PATCH] mm,oom: Offload OOM notify callback to a kernel
 thread.
Message-ID: <20171009122817.t2kd7pcqmh3xaay5@dhcp22.suse.cz>
References: <201710022252.DDJ51535.JFQSLFHFVOtOOM@I-love.SAKURA.ne.jp>
 <20171002171641-mutt-send-email-mst@kernel.org>
 <201710022344.JII17368.HQtLOMJOOSFFVF@I-love.SAKURA.ne.jp>
 <201710072030.HGE12424.HFFMVLJOOStFQO@I-love.SAKURA.ne.jp>
 <20171009074625.b7qztlyoa4u7lyy7@dhcp22.suse.cz>
 <201710091706.FAG81243.MOFLSJVtQFOFOH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201710091706.FAG81243.MOFLSJVtQFOFOH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mst@redhat.com, linux-mm@kvack.org

On Mon 09-10-17 17:06:51, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sat 07-10-17 20:30:19, Tetsuo Handa wrote:
> > [...]
> > > >From 6a0fd8a5e013ac63a6bcd06bd2ae6fdb25a4f3de Mon Sep 17 00:00:00 2001
> > > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > Date: Sat, 7 Oct 2017 19:29:21 +0900
> > > Subject: [PATCH] virtio: avoid possible OOM lockup at virtballoon_oom_notify()
> > > 
> > > In leak_balloon(), mutex_lock(&vb->balloon_lock) is called in order to
> > > serialize against fill_balloon(). But in fill_balloon(),
> > > alloc_page(GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY) is
> > > called with vb->balloon_lock mutex held. Since GFP_HIGHUSER[_MOVABLE]
> > > implies __GFP_DIRECT_RECLAIM | __GFP_IO | __GFP_FS, despite __GFP_NORETRY
> > > is specified, this allocation attempt might depend on somebody else's
> > > __GFP_DIRECT_RECLAIM memory allocation.
> > 
> > How would that dependency look like? Is the holder of the lock doing
> > only __GFP_NORETRY?
> 
> __GFP_NORETRY makes difference only after reclaim attempt failed.
> 
> Reclaim attempt of __GFP_DIRECT_RECLAIM | __GFP_IO | __GFP_FS request can
> indirectly wait for somebody else's GFP_NOFS and/or GFP_NOIO request (e.g.
> blocked on filesystem's fs lock). And such indirect GFP_NOFS and/or
> GFP_NOIO request can reach __alloc_pages_may_oom() unless they also have
> __GFP_NORETRY. And such indirect GFP_NOFS and/or GFP_NOIO request can call
> OOM notifier callback and try to hold balloon_lock at leak_balloon() which
> fill_balloon() has already held before doing
> GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY request.

OK, so let me decipher.
 Thread1				Thread2						Thread3
 alloc_pages(GFP_KERNEL)		  fill_balloon					fs_lock #1	
   out_of_memory			    balloon_lock #2				alloc_page(GFP_NOFS)
     blocking_notifier_call_chain	    balloon_page_enqueue			  # keep retrying
       leak_balloon			      alloc_page(GFP_HIGHUSER_MOVABLE)
         balloon_lock #2		        direct_reclaim (__GFP_FS context)
	 				          fs_lock #1

in other words, let's make the description understandable even for
somebody not really familiar with the allocation&reclaim internals.
The whole point is that the dependency is indirect and it requires
more actors and an example call grapg should be easier to follow.

One more nit. If there is a way to estimate how much memory could be
freed by the notifier when the trylock would succeed I would print that
value for debugging purposes.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DE096280256
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 04:48:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l138so66732310wmg.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 01:48:17 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id gj2si9597844wjb.25.2016.09.29.01.48.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 01:48:16 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id w72so960748wmf.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 01:48:16 -0700 (PDT)
Date: Thu, 29 Sep 2016 10:48:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: warn about allocations which stall for too long
Message-ID: <20160929084815.GD408@dhcp22.suse.cz>
References: <20160923081555.14645-1-mhocko@kernel.org>
 <201609232336.FIH57364.FOVHtMFQLFSJOO@I-love.SAKURA.ne.jp>
 <20160923150234.GV4478@dhcp22.suse.cz>
 <201609241200.AEE21807.OSOtQVOLHMFJFF@I-love.SAKURA.ne.jp>
 <20160926081751.GD27030@dhcp22.suse.cz>
 <201609272157.DHI95301.HOFFFOVJLtSMQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201609272157.DHI95301.HOFFFOVJLtSMQO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, linux-kernel@vger.kernel.org

On Tue 27-09-16 21:57:26, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > > > ) rather than by line number, and surround __warn_memalloc_stall() call with
> > > > > mutex in order to serialize warning messages because it is possible that
> > > > > multiple allocation requests are stalling?
> > > > 
> > > > we do not use any lock in warn_alloc_failed so why this should be any
> > > > different?
> > > 
> > > warn_alloc_failed() is called for both __GFP_DIRECT_RECLAIM and
> > > !__GFP_DIRECT_RECLAIM allocation requests, and it is not allowed
> > > to sleep if !__GFP_DIRECT_RECLAIM. Thus, we have to tolerate that
> > > concurrent memory allocation failure messages make dmesg output
> > > unreadable. But __warn_memalloc_stall() is called for only
> > > __GFP_DIRECT_RECLAIM allocation requests. Thus, we are allowed to
> > > sleep in order to serialize concurrent memory allocation stall
> > > messages.
> > 
> > I still do not see a point. A single line about the warning and locked
> > dump_stack sounds sufficient to me.
> 
> printk() is slow operation. It is possible that two allocation requests
> start within time period needed for completing warn_alloc_failed().
> It is possible that multiple concurrent allocations are stalling when
> one of them cannot be satisfied. The consequence is multiple concurrent
> timeouts corrupting dmesg.
> http://I-love.SAKURA.ne.jp/tmp/serial-20160927-nolock.txt.xz
> (Please ignore Oops at do_task_stat(); it is irrelevant to this topic.)
> 
> If we guard it with mutex_lock(&oom_lock)/mutex_unlock(&oom_lock),
> no corruption.
> http://I-love.SAKURA.ne.jp/tmp/serial-20160927-lock.txt.xz

I have just posted v2 which reuses warn_alloc_failed infrastructure. If
we want to have a lock there then it should be a separate patch imho.
Ideally with and example from your above kernel log.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

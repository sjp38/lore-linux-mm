Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id DDEBB28027B
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 08:57:42 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 20so32918473ioj.0
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 05:57:42 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l13si1389945otb.230.2016.09.27.05.57.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 05:57:41 -0700 (PDT)
Subject: Re: [PATCH] mm: warn about allocations which stall for too long
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160923081555.14645-1-mhocko@kernel.org>
	<201609232336.FIH57364.FOVHtMFQLFSJOO@I-love.SAKURA.ne.jp>
	<20160923150234.GV4478@dhcp22.suse.cz>
	<201609241200.AEE21807.OSOtQVOLHMFJFF@I-love.SAKURA.ne.jp>
	<20160926081751.GD27030@dhcp22.suse.cz>
In-Reply-To: <20160926081751.GD27030@dhcp22.suse.cz>
Message-Id: <201609272157.DHI95301.HOFFFOVJLtSMQO@I-love.SAKURA.ne.jp>
Date: Tue, 27 Sep 2016 21:57:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > > > ) rather than by line number, and surround __warn_memalloc_stall() call with
> > > > mutex in order to serialize warning messages because it is possible that
> > > > multiple allocation requests are stalling?
> > > 
> > > we do not use any lock in warn_alloc_failed so why this should be any
> > > different?
> > 
> > warn_alloc_failed() is called for both __GFP_DIRECT_RECLAIM and
> > !__GFP_DIRECT_RECLAIM allocation requests, and it is not allowed
> > to sleep if !__GFP_DIRECT_RECLAIM. Thus, we have to tolerate that
> > concurrent memory allocation failure messages make dmesg output
> > unreadable. But __warn_memalloc_stall() is called for only
> > __GFP_DIRECT_RECLAIM allocation requests. Thus, we are allowed to
> > sleep in order to serialize concurrent memory allocation stall
> > messages.
> 
> I still do not see a point. A single line about the warning and locked
> dump_stack sounds sufficient to me.

printk() is slow operation. It is possible that two allocation requests
start within time period needed for completing warn_alloc_failed().
It is possible that multiple concurrent allocations are stalling when
one of them cannot be satisfied. The consequence is multiple concurrent
timeouts corrupting dmesg.
http://I-love.SAKURA.ne.jp/tmp/serial-20160927-nolock.txt.xz
(Please ignore Oops at do_task_stat(); it is irrelevant to this topic.)

If we guard it with mutex_lock(&oom_lock)/mutex_unlock(&oom_lock),
no corruption.
http://I-love.SAKURA.ne.jp/tmp/serial-20160927-lock.txt.xz

Deferring it when trylock() failed will be also possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

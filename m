Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id DDC826B04AA
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 14:12:18 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id s20so20116970qki.12
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 11:12:18 -0700 (PDT)
Received: from mail-qk0-x22d.google.com (mail-qk0-x22d.google.com. [2607:f8b0:400d:c09::22d])
        by mx.google.com with ESMTPS id w40si11739809qth.8.2017.07.10.11.12.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 11:12:18 -0700 (PDT)
Received: by mail-qk0-x22d.google.com with SMTP id p21so80894732qke.3
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 11:12:18 -0700 (PDT)
Date: Mon, 10 Jul 2017 14:12:14 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: mm: Why WQ_MEM_RECLAIM workqueue remains pending?
Message-ID: <20170710181214.GD1305447@devbig577.frc2.facebook.com>
References: <201706291957.JGH39511.tQMOFSLOFJVHOF@I-love.SAKURA.ne.jp>
 <201707071927.IGG34813.tSQOMJFOHOFVLF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707071927.IGG34813.tSQOMJFOHOFVLF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mgorman@techsingularity.net, vbabka@suse.cz, linux-mm@kvack.org, hillf.zj@alibaba-inc.com, brouer@redhat.com

Hello, Tetsuo.

I went through the logs and it doesn't look like the mm workqueue
actually stalled, it was just slow to make progress.  Please see
below.

On Fri, Jul 07, 2017 at 07:27:06PM +0900, Tetsuo Handa wrote:
> Since drain_local_pages_wq work was stalling for 144 seconds as of uptime = 541,
> drain_local_pages_wq work was queued around uptime = 397 (which is about 6 seconds
> since the OOM killer/reaper reclaimed some memory for the last time). 
> 
> But as far as I can see from traces, the mm_percpu_wq thread as of uptime = 444 was
> idle, while drain_local_pages_wq work was pending from uptime = 541 to uptime = 605.
> This means that the mm_percpu_wq thread did not start processing drain_local_pages_wq
> work immediately. (I don't know what made drain_local_pages_wq work be processed.)
> 
> Why? Is this a workqueue implementation bug? Is this a workqueue usage bug?

So, rescuer doesn't kick as soon as the workqueue becomes slow.  It
kicks in if the worker pool that the workqueue is associated with
hangs.  That is, if you have other work items actively running, e.g.,
for reclaim on the pool, the pool isn't stalled and rescuers won't be
woken up.  IOW, having a rescuer prevents a workqueue from deadlocking
due to resource starvation but it doesn't necessarily make it go
faster.  It's a deadlock prevention mechanism, not a priority raising
one.  If the work items need preferential execution, it should use
WQ_HIGHPRI.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

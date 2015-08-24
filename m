Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C6DB36B0253
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 17:10:12 -0400 (EDT)
Received: by pacti10 with SMTP id ti10so32274684pac.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 14:10:12 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id s3si29386737pdh.219.2015.08.24.14.10.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 14:10:12 -0700 (PDT)
Received: by pacti10 with SMTP id ti10so32274384pac.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 14:10:11 -0700 (PDT)
Date: Mon, 24 Aug 2015 14:10:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] mm, oom: add global access to memory reserves on
 livelock
In-Reply-To: <201508212229.GIC00036.tVFMQLOOFJOFSH@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1508241404380.32561@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1508201358490.607@chino.kir.corp.google.com> <20150821081745.GG23723@dhcp22.suse.cz> <201508212229.GIC00036.tVFMQLOOFJOFSH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, oleg@redhat.com, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 21 Aug 2015, Tetsuo Handa wrote:

> Why can't we think about choosing more OOM victims instead of granting access
> to memory reserves?
> 

We have no indication of which thread is holding a mutex that would need 
to be killed, so we'd be randomly killing processes waiting for forward 
progress.  A worst-case scenario would be the thread is OOM_DISABLE and we 
kill every process on the system needlessly.  This problem obviously 
occurs often enough that killing all userspace isnt going to be a viable 
solution.

> Also, SysRq might not be usable under OOM because workqueues can get stuck.
> The panic_on_oom_timeout was first proposed using a workqueue but was
> updated to use a timer because there is no guarantee that workqueues work
> as expected under OOM.
> 

I don't know anything about a panic_on_oom_timeout, but panicking would 
only be a reasonable action if memory reserves were fully depleted.  That 
could easily be dealt with in the page allocator so there's no timeout 
involved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

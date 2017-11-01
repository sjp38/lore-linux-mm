Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EAB1D6B025F
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 04:30:10 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id m82so956252wmd.19
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 01:30:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o11si274823edh.327.2017.11.01.01.30.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 01:30:08 -0700 (PDT)
Subject: Re: [PATCH] mm: don't warn about allocations which stall for too long
References: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171031153225.218234b4@gandalf.local.home>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <187a38c6-f964-ed60-932d-b7e0bee03316@suse.cz>
Date: Wed, 1 Nov 2017 09:30:05 +0100
MIME-Version: 1.0
In-Reply-To: <20171031153225.218234b4@gandalf.local.home>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>

On 10/31/2017 08:32 PM, Steven Rostedt wrote:
> 
> Thank you for the perfect timing. You posted this the day after I
> proposed a new solution at Kernel Summit in Prague for the printk lock
> loop that you experienced here.
> 
> I attached the pdf that I used for that discussion (ignore the last
> slide, it was left over and I never went there).
> 
> My proposal is to do something like this with printk:
> 
> Three types of printk usages:
> 
> 1) Active printer (actively writing to the console).
> 2) Waiter (active printer, first user)
> 3) Sees active printer and a waiter, and just adds to the log buffer
>    and leaves.
> 
> (new globals)
> static DEFINE_SPIN_LOCK(console_owner_lock);
> static struct task_struct console_owner;
> static bool waiter;
> 
> console_unlock() {
> 
> [ Assumes this part can not preempt ]
> 
> 	spin_lock(console_owner_lock);
> 	console_owner = current;
> 	spin_unlock(console_owner_lock);
> 
> 	for each message
> 		write message out to console
> 
> 		if (READ_ONCE(waiter))
> 			break;

Ah, these two lines clarified for me what I didn't get from your talk,
so I got the wrong impression that the new scheme is just postponing the
problem.

But still, it seems to me that the scheme only works as long as there
are printk()'s coming with some reasonable frequency. There's still a
corner case when a storm of printk()'s can come that will fill the ring
buffers, and while during the storm the printing will be distributed
between CPUs nicely, the last unfortunate CPU after the storm subsides
will be left with a large accumulated buffer to print, and there will be
no waiters to take over if there are no more printk()'s coming. What
then, should it detect such situation and defer the flushing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

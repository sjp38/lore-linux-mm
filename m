Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DF9166B0069
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 20:57:17 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id o128so11776117pfg.6
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 17:57:17 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id s7si5616843plp.57.2018.01.17.17.57.16
        for <linux-mm@kvack.org>;
        Wed, 17 Jan 2018 17:57:16 -0800 (PST)
Subject: Re: [PATCH v5 1/2] printk: Add console owner and waiter logic to load
 balance console writes
From: Byungchul Park <byungchul.park@lge.com>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110132418.7080-2-pmladek@suse.com>
 <f4ea1404-404d-11d2-550c-7367add3f5fa@lge.com>
 <20180117120446.44ewafav7epaibde@pathway.suse.cz>
 <4a24ce1d-a606-3add-ec30-91ce9a1a1281@lge.com>
Message-ID: <7a107b1e-f99f-186b-f5db-504b7691993d@lge.com>
Date: Thu, 18 Jan 2018 10:57:13 +0900
MIME-Version: 1.0
In-Reply-To: <4a24ce1d-a606-3add-ec30-91ce9a1a1281@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, kernel-team@lge.com

On 1/18/2018 10:53 AM, Byungchul Park wrote:
> Hello,
> 
> This is a thing simulating a wait for an event e.g.
> wait_for_completion() doing spinning instead of sleep, rather
> than a spinlock. I mean:
> 
>  A A  This context
>  A A  ------------
>  A A  while (READ_ONCE(console_waiter)) /* Wait for the event */
>  A A A A A  cpu_relax();
> 
>  A A  Another context
>  A A  ---------------
>  A A  WRITE_ONCE(console_waiter, false); /* Event */
> 
> That's why I said this's the exact case of cross-release. Anyway
> without cross-release, we usually use typical acquire/release
> pairs to cover a wait for an event in the following way:
> 
>  A A  A context
>  A A  ---------
>  A A  lock_map_acquire(wait); /* Or lock_map_acquire_read(wait) */
>  A A A A A A A A A A A A A A A A A A A A A A A A A A  /* Read one is better though..A A A  */
> 
>  A A  /* A section, we suspect, a wait for an event might happen. */
>  A A  ...
>  A A  lock_map_release(wait);
> 
> 
>  A A  The place actually doing the wait
>  A A  ---------------------------------
>  A A  lock_map_acquire(wait);
>  A A  lock_map_acquire(wait);
       ^
       lock_map_release(wait);

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

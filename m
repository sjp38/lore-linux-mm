Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C37FA6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 13:11:03 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s2so177296pge.19
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 10:11:03 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j71si4030580pgc.290.2017.11.02.10.11.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 10:11:02 -0700 (PDT)
Date: Thu, 2 Nov 2017 13:10:59 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171102131059.4d8935a9@gandalf.local.home>
In-Reply-To: <20171102130605.05e987e8@gandalf.local.home>
References: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171102115625.13892e18@gandalf.local.home>
	<20171102130605.05e987e8@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>

On Thu, 2 Nov 2017 13:06:05 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:

> +		raw_spin_lock(&console_owner_lock);
> +		waiter = console_waiter;
> +		console_owner = NULL;
> +		raw_spin_unlock(&console_owner_lock);
> +
> +		/*
> +		 * If there is a waiter waiting for us, then pass the
> +		 * rest of the work load over to that waiter.
> +		 */
> +		if (waiter)
> +			break;
> +

Hmm, do I need a READ_ONCE() here?

Can gcc do the load of console_waiter outside the spin lock where 
if (waiter) is done?

Although it doesn't really matter, but it just makes the code more
fragile if it can. Should this be:

		raw_spin_lock(&console_owner_lock);
		waiter = READ_ONCE(console_waiter);
		console_owner = NULL;
		raw_spin_unlock(&console_owner_lock);

		/*
		 * If there is a waiter waiting for us, then pass the
		 * rest of the work load over to that waiter.
		 */
		if (waiter)
			break;

 ?

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

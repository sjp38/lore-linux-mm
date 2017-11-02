Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id ACB1F6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 13:38:41 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z80so239233pff.11
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 10:38:41 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j1si4071819pgc.771.2017.11.02.10.38.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 10:38:40 -0700 (PDT)
Date: Thu, 2 Nov 2017 13:38:36 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171102133836.01208f60@gandalf.local.home>
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

OK, the spin_unlock() wont let the load leak. Thus it is fine as is.


> +			raw_spin_lock(&console_owner_lock);
> +			owner = console_owner;
> +			waiter = console_waiter;
> +			if (!waiter && owner && owner != current) {

But Mathieu Desnoyers pointed out that usage of variables within a
spinlock may be an issue. Although, it shouldn't affect the code as is,
I think I'll add back READ/WRITE_ONCE() just to be on the safe side.

I may add the waiter = READ_ONCE(console_waiter) to the first one too,
more as documentation. It should cause any issues to add it.

-- Steve



> +				console_waiter = true;
> +				spin = true;
> +			}
> +			raw_spin_unlock(&console_owner_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

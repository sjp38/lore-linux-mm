Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C7959440417
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 10:11:01 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id k190so1280591pga.10
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 07:11:01 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o88si4436859pfk.294.2017.11.08.07.11.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 07:11:00 -0800 (PST)
Date: Wed, 8 Nov 2017 10:10:57 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v4] printk: Add console owner and waiter logic to load
  balance console writes
Message-ID: <20171108101057.4e97247d@gandalf.local.home>
In-Reply-To: <20171108100321.5f3e05c8@gandalf.local.home>
References: <20171108100321.5f3e05c8@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, "yuwang.yuwang\"    <yuwang.yuwang@alibaba-inc.com>, Peter Zijlstra  <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan  Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,  Tetsuo Handa   <penguin-kernel@I-love.SAKURA.ne.jp>,  rostedt@home.goodmis.org"@kvack.org

On Wed, 8 Nov 2017 10:03:21 -0500
Steven Rostedt <rostedt@goodmis.org> wrote:

> +		/*
> +		 * If there is a waiter waiting for us, then pass the
> +		 * rest of the work load over to that waiter.
> +		 */
> +		if (waiter)
> +			break;
> +

And if we are worried about flushing on crashes, we could change this
to:

	if (waiter) {
		if (oops_in_progress)
			waiter = false;
		else
			break;
	}

And keep whoever is printing printing if a crash is happening.

-- Steve

			

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

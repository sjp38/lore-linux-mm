Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B2A16B0286
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 17:43:19 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id x5-v6so4432289pfn.22
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 14:43:19 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a5si10972980pgg.120.2018.11.10.14.43.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 10 Nov 2018 14:43:18 -0800 (PST)
Date: Sat, 10 Nov 2018 15:17:34 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH 02/12] locking/lockdep: Add a new terminal lock type
Message-ID: <20181110141734.GF3339@worktop.programming.kicks-ass.net>
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
 <1541709268-3766-3-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1541709268-3766-3-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Nov 08, 2018 at 03:34:18PM -0500, Waiman Long wrote:
> A terminal lock is a lock where further locking or unlocking on another
> lock is not allowed. IOW, no forward dependency is permitted.
> 
> With such a restriction in place, we don't really need to do a full
> validation of the lock chain involving a terminal lock.  Instead,
> we just check if there is any further locking or unlocking on another
> lock when a terminal lock is being held.

> @@ -263,6 +270,7 @@ struct held_lock {
>  	unsigned int hardirqs_off:1;
>  	unsigned int references:12;					/* 32 bits */
>  	unsigned int pin_count;
> +	unsigned int flags;
>  };

I'm thinking we can easily steal some bits off of the pin_count field if
we have to.

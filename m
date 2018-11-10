Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 240526B0759
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 17:43:23 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id t201so1840107wmd.5
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 14:43:23 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id m64-v6si4215160wmm.185.2018.11.10.14.43.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 10 Nov 2018 14:43:21 -0800 (PST)
Date: Sat, 10 Nov 2018 15:14:58 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH 01/12] locking/lockdep: Rework
 lockdep_set_novalidate_class()
Message-ID: <20181110141458.GE3339@worktop.programming.kicks-ass.net>
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
 <1541709268-3766-2-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1541709268-3766-2-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Nov 08, 2018 at 03:34:17PM -0500, Waiman Long wrote:
> The current lockdep_set_novalidate_class() implementation is like
> a hack. It assigns a special class key for that lock and calls
> lockdep_init_map() twice.

Ideally it would go away.. it is not thing that should be used.

> This patch changes the implementation to make it more general so that
> it can be used by other special lock class types. A new "type" field
> is added to both the lockdep_map and lock_class structures.
> 
> The new field can now be used to designate a lock and a class object
> as novalidate. The lockdep_set_novalidate_class() call, however, should
> be called before lock initialization which calls lockdep_init_map().

I don't really feel like this is something that should be made easier or
better.

> @@ -102,6 +100,8 @@ struct lock_class {
>  	int				name_version;
>  	const char			*name;
>  
> +	unsigned int			flags;
> +
>  #ifdef CONFIG_LOCK_STAT
>  	unsigned long			contention_point[LOCKSTAT_POINTS];
>  	unsigned long			contending_point[LOCKSTAT_POINTS];

Esp. not at the cost of growing the data structures.

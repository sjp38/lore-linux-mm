Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id C53E76B0009
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 12:06:02 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 185so17238440iox.21
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 09:06:02 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id i197-v6si11892496ite.127.2018.03.26.09.06.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 26 Mar 2018 09:06:00 -0700 (PDT)
Date: Mon, 26 Mar 2018 18:05:49 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] lockdep: Show address of "struct lockdep_map" at
 print_lock().
Message-ID: <20180326160549.GL4043@hirez.programming.kicks-ass.net>
References: <1522059513-5461-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522059513-5461-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Borislav Petkov <bp@suse.de>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Mar 26, 2018 at 07:18:33PM +0900, Tetsuo Handa wrote:
> [  628.863629] 2 locks held by a.out/1165:
> [  628.867533]  #0: [ffffa3b438472e48] (&mm->mmap_sem){++++}, at: __do_page_fault+0x16f/0x4d0
> [  628.873570]  #1: [ffffa3b4f2c52ac0] (&mapping->i_mmap_rwsem){++++}, at: rmap_walk_file+0x1d9/0x2a0

Maybe change the string a little, because from the above it's not at all
effident that the [] thing is the lock instance.

> diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> index 12a2805..7835233 100644
> --- a/kernel/locking/lockdep.c
> +++ b/kernel/locking/lockdep.c
> @@ -556,9 +556,9 @@ static void print_lock(struct held_lock *hlock)
>  		return;
>  	}
>  
> +	printk(KERN_CONT "[%px]", hlock->instance);

And yeah, what Michal said, that wants to be %p, we're fine with the
thing being hashed, all we want to do is equivalience, which can be done
with hashed pinters too.

>  	print_lock_name(lock_classes + class_idx - 1);
> -	printk(KERN_CONT ", at: [<%px>] %pS\n",
> -		(void *)hlock->acquire_ip, (void *)hlock->acquire_ip);
> +	printk(KERN_CONT ", at: %pS\n", (void *)hlock->acquire_ip);
>  }

Otherwise no real objection to the patch.

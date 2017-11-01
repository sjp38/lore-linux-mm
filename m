Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 65CE56B0273
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 10:04:56 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id b192so2627729pga.14
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 07:04:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e4si1175301pgv.360.2017.11.01.07.04.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 07:04:55 -0700 (PDT)
Date: Wed, 1 Nov 2017 07:04:54 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC] EPOLL_KILLME: New flag to epoll_wait() that subscribes
 process to death row (new syscall)
Message-ID: <20171101140454.GA28205@bombadil.infradead.org>
References: <20171101053244.5218-1-slandden@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171101053244.5218-1-slandden@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Landden <slandden@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 31, 2017 at 10:32:44PM -0700, Shawn Landden wrote:
> It is common for services to be stateless around their main event loop.
> If a process passes the EPOLL_KILLME flag to epoll_wait5() then it
> signals to the kernel that epoll_wait5() may not complete, and the kernel
> may send SIGKILL if resources get tight.
> 
> See my systemd patch: https://github.com/shawnl/systemd/tree/killme
> 
> Android uses this memory model for all programs, and having it in the
> kernel will enable integration with the page cache (not in this
> series).

I'm not taking a position on whether this is a good feature to have, but
your implementation could do with some improvement.

> +static LIST_HEAD(deathrow_q);
> +static long deathrow_len __read_mostly;

In what sense is this __read_mostly when it's modified by every call that
has EPOLL_KILLME set?  Also, why do you think this is a useful statistic
to gather in the kernel and expose to userspace?

> +/* TODO: Can this lock be removed by using atomic instructions to update
> + * queue?
> + */
> +static DEFINE_MUTEX(deathrow_mutex);

This doesn't need to be a mutex; you don't do anything that sleeps while
holding it.  It should be a spinlock instead (but see below).

> @@ -380,6 +380,9 @@ struct sched_entity {
>  	struct list_head		group_node;
>  	unsigned int			on_rq;
>  
> +	unsigned			on_deathrow:1;
> +	struct list_head		deathrow;
> +
>  	u64				exec_start;
>  	u64				sum_exec_runtime;
>  	u64				vruntime;

You're adding an extra 16 bytes to each task to implement this feature.  I
don't like that, and I think you can avoid it.

Turn 'deathrow' into a wait_queue_head_t.  Declare the wait_queue_entry
on the stack.

While you're at it, I don't think 'deathrow' is an epoll concept.
I think it's an OOM killer concept which happens to be only accessible
through epoll today (but we could consider allowing other system calls
to place tasks on it in the future).  So the central place for all this is
in oom_kill.c and epoll only calls into it.  Maybe we have 'deathrow_enroll()'
and 'deathrow_remove()' APIs in oom_killer.

And I don't like the name 'deathrow'.  How about oom_target?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

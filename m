Date: Fri, 13 Apr 2007 12:25:18 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] generic rwsems
Message-ID: <20070413102518.GD31487@wotan.suse.de>
References: <20070413100416.GC31487@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070413100416.GC31487@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, David Howells <dhowells@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 13, 2007 at 12:04:16PM +0200, Nick Piggin wrote:
> OK, this patch is against 2.6.21-rc6 + Mathieu's atomic_long patches.
> 
> Last time this came up I was asked to get some numbers, so here are
> some in the changelog, captured with a simple kernel module tester.
> I got motivated again because of the MySQL/glibc/mmap_sem issue.
> 
> This patch converts all architectures to a generic rwsem implementation,
> which will compile down to the same code for i386, or powerpc, for
> example, and will allow some (eg. x86-64) to move away from spinlock
> based rwsems.

Oh, and it also converts powerpc and sparc64 to 64-bit counters, so
they can handle more than 32K tasks waiting (which was apparently a
real problem for SGI, and is probably a good thing).

But that reminds me:
> +/*
> + * the semaphore definition
> + */
> +struct rw_semaphore {
> +	atomic_long_t		count;
> +	spinlock_t		wait_lock;
> +	struct list_head	wait_list;
> +#ifdef CONFIG_DEBUG_LOCK_ALLOC
> +	struct lockdep_map dep_map;
> +#endif
> +};

I think I should put wait_lock after wait_list, so as to get a better
packing on most 64-bit architectures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

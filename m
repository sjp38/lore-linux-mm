Date: Sun, 23 Nov 2008 10:18:44 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC v1][PATCH]page_fault retry with NOPAGE_RETRY
Message-ID: <20081123091843.GK30453@elte.hu>
References: <604427e00811212247k1fe6b63u9efe8cfe37bddfb5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <604427e00811212247k1fe6b63u9efe8cfe37bddfb5@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, Mike Waychison <mikew@google.com>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

* Ying Han <yinghan@google.com> wrote:

> page fault retry with NOPAGE_RETRY

Interesting patch.

> Allow major faults to drop the mmap_sem read lock while waitting for
> synchronous disk read. This allows another thread which wishes to grab
> down_read(mmap_sem) to proceed while the current is waitting the disk IO.

Do you mean down_write()? down_read() can already be nested 
arbitrarily.

> The patch flags current->flags to PF_FAULT_MAYRETRY as identify that 
> the caller can tolerate the retry in the filemap_fault call patch.
> 
> Benchmark is done by mmap in huge file and spaw 64 thread each 
> faulting in pages in reverse order, the the result shows 8% 
> porformance hit with the patch.

I suspect we also want to see the cases where this change helps?

Also, constructs like this are pretty ugly:

> +#ifdef CONFIG_X86_64
> +asmlinkage
> +#endif
> +void do_page_fault(struct pt_regs *regs, unsigned long error_code)
> +{
> +     current->flags |= PF_FAULT_MAYRETRY;
> +     __do_page_fault(regs, error_code);
> +     current->flags &= ~PF_FAULT_MAYRETRY;
> +}

This seems to be unnecessary runtime overhead to pass in a flag to 
handle_mm_fault(). Why not extend the 'write' flag of 
handle_mm_fault() to also signal "arch is able to retry"?

Also, _if_ we decide that from-scratch pagefault retries are good, i 
see no reason why this should not be extended to all architectures:

The retry should happen purely in the MM layer - all information is 
available already, and much of do_page_fault() could generally be 
moved into mm/memory.c, with one or two arch-provided standard 
callbacks to express certain page fault quirks. (such as vm86 mode on 
x86)

(Such a design would allow more nice cleanups - handle_mm_fault() 
could inline inside the pagefault handler, etc.)

Also, a few small details. Please use this proper multi-line comment 
style:

> +			/*
> +			 * Page is already locked by someone else.
> +			 *
> +			 * We don't want to be holding down_read(mmap_sem)
> +			 * inside lock_page(). We use wait_on_page_lock here
> +			 * to just wait until the page is unlocked, but we
> +			 * don't really need
> +			 * to lock it.
> +			 */

Not this one:

> +	/* page may be available, but we have to restart the process
> +	 * because mmap_sem was dropped during the ->fault */

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

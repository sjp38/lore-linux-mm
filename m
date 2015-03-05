Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id E0CB16B0096
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 12:58:20 -0500 (EST)
Received: by yhab6 with SMTP id b6so26534210yha.6
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 09:58:20 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id f8si4073214yhf.124.2015.03.05.09.58.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 09:58:19 -0800 (PST)
Message-ID: <54F89927.2090409@parallels.com>
Date: Thu, 5 Mar 2015 20:57:59 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/21] userfaultfd: add new syscall to provide memory
 externalization
References: <1425575884-2574-1-git-send-email-aarcange@redhat.com> <1425575884-2574-11-git-send-email-aarcange@redhat.com>
In-Reply-To: <1425575884-2574-11-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Android Kernel Team <kernel-team@android.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>


> +int handle_userfault(struct vm_area_struct *vma, unsigned long address,
> +		     unsigned int flags, unsigned long reason)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	struct userfaultfd_ctx *ctx;
> +	struct userfaultfd_wait_queue uwq;
> +
> +	BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
> +
> +	ctx = vma->vm_userfaultfd_ctx.ctx;
> +	if (!ctx)
> +		return VM_FAULT_SIGBUS;
> +
> +	BUG_ON(ctx->mm != mm);
> +
> +	VM_BUG_ON(reason & ~(VM_UFFD_MISSING|VM_UFFD_WP));
> +	VM_BUG_ON(!(reason & VM_UFFD_MISSING) ^ !!(reason & VM_UFFD_WP));
> +
> +	/*
> +	 * If it's already released don't get it. This avoids to loop
> +	 * in __get_user_pages if userfaultfd_release waits on the
> +	 * caller of handle_userfault to release the mmap_sem.
> +	 */
> +	if (unlikely(ACCESS_ONCE(ctx->released)))
> +		return VM_FAULT_SIGBUS;
> +
> +	/* check that we can return VM_FAULT_RETRY */
> +	if (unlikely(!(flags & FAULT_FLAG_ALLOW_RETRY))) {
> +		/*
> +		 * Validate the invariant that nowait must allow retry
> +		 * to be sure not to return SIGBUS erroneously on
> +		 * nowait invocations.
> +		 */
> +		BUG_ON(flags & FAULT_FLAG_RETRY_NOWAIT);
> +#ifdef CONFIG_DEBUG_VM
> +		if (printk_ratelimit()) {
> +			printk(KERN_WARNING
> +			       "FAULT_FLAG_ALLOW_RETRY missing %x\n", flags);
> +			dump_stack();
> +		}
> +#endif
> +		return VM_FAULT_SIGBUS;
> +	}
> +
> +	/*
> +	 * Handle nowait, not much to do other than tell it to retry
> +	 * and wait.
> +	 */
> +	if (flags & FAULT_FLAG_RETRY_NOWAIT)
> +		return VM_FAULT_RETRY;
> +
> +	/* take the reference before dropping the mmap_sem */
> +	userfaultfd_ctx_get(ctx);
> +
> +	/* be gentle and immediately relinquish the mmap_sem */
> +	up_read(&mm->mmap_sem);
> +
> +	init_waitqueue_func_entry(&uwq.wq, userfaultfd_wake_function);
> +	uwq.wq.private = current;
> +	uwq.address = userfault_address(address, flags, reason);

Since we report only the virtual address of the fault, this will make difficulties
for task monitoring the address space of some other task. Like this:

Let's assume a task creates a userfaultfd, activates one, registers several VMAs 
in it and then sends the ufd descriptor to other task. If later the first task will
remap those VMAs and will start touching pages, the monitor will start receiving 
fault addresses using which it will not be able to guess the exact vma the
requests come from.

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

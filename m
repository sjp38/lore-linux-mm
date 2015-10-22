Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 53C7B6B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 08:11:08 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so89593627pac.3
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 05:11:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id sc6si20747044pac.7.2015.10.22.05.11.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 05:11:07 -0700 (PDT)
Date: Thu, 22 Oct 2015 14:10:56 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 14/23] userfaultfd: wake pending userfaults
Message-ID: <20151022121056.GB7520@twins.programming.kicks-ass.net>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
 <1431624680-20153-15-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1431624680-20153-15-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

On Thu, May 14, 2015 at 07:31:11PM +0200, Andrea Arcangeli wrote:
> @@ -255,21 +259,23 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
>  	 * through poll/read().
>  	 */
>  	__add_wait_queue(&ctx->fault_wqh, &uwq.wq);
> -	for (;;) {
> -		set_current_state(TASK_KILLABLE);
> -		if (!uwq.pending || ACCESS_ONCE(ctx->released) ||
> -		    fatal_signal_pending(current))
> -			break;
> -		spin_unlock(&ctx->fault_wqh.lock);
> +	set_current_state(TASK_KILLABLE);
> +	spin_unlock(&ctx->fault_wqh.lock);
>  
> +	if (likely(!ACCESS_ONCE(ctx->released) &&
> +		   !fatal_signal_pending(current))) {
>  		wake_up_poll(&ctx->fd_wqh, POLLIN);
>  		schedule();
> +		ret |= VM_FAULT_MAJOR;
> +	}

So what happens here if schedule() spontaneously wakes for no reason?

I'm not sure enough of userfaultfd semantics to say if that would be
bad, but the code looks suspiciously like it relies on schedule() not to
do that; which is wrong.

> +	__set_current_state(TASK_RUNNING);
> +	/* see finish_wait() comment for why list_empty_careful() */
> +	if (!list_empty_careful(&uwq.wq.task_list)) {
>  		spin_lock(&ctx->fault_wqh.lock);
> +		list_del_init(&uwq.wq.task_list);
> +		spin_unlock(&ctx->fault_wqh.lock);
>  	}
> -	__remove_wait_queue(&ctx->fault_wqh, &uwq.wq);
> -	__set_current_state(TASK_RUNNING);
> -	spin_unlock(&ctx->fault_wqh.lock);
>  
>  	/*
>  	 * ctx may go away after this if the userfault pseudo fd is

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

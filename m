Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A3C136B0260
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 00:10:04 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 136so25068883wmu.3
        for <linux-mm@kvack.org>; Sun, 08 Oct 2017 21:10:04 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j62sor3850815edd.2.2017.10.08.21.10.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 08 Oct 2017 21:10:03 -0700 (PDT)
Date: Mon, 9 Oct 2017 07:10:01 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [BUG] mm/vmalloc: ___might_sleep is called under a spinlock in
 __purge_vmap_area_lazy
Message-ID: <20171009041001.p47yc6r7f3borhba@node.shutemov.name>
References: <70f9850a-b24c-8595-8a22-9b47e96d6338@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <70f9850a-b24c-8595-8a22-9b47e96d6338@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia-Ju Bai <baijiaju1990@163.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, catalin.marinas@arm.com, labbott@redhat.com, thgarnie@google.com, kirill.shutemov@linux.intel.com, aryabinin@virtuozzo.com, ard.biesheuvel@linaro.org, zijun_hu@htc.com, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Oct 09, 2017 at 12:00:33PM +0800, Jia-Ju Bai wrote:
> The ___might_sleep is called under a spinlock, and the function call graph
> is:
> __purge_vmap_area_lazy (acquire the spinlock)
>   cond_resched_lock
>     ___might_sleep
> 
> In this situation, ___might_sleep may prints error log message because a
> spinlock is held.
> A possible fix is to remove ___might_sleep in cond_resched_lock.
> 
> This bug is found by my static analysis tool and my code review.

This analysis doesn't makes sense.

The point of cond_resched_lock() is that it drops the lock, if resched is
required.

___might_sleep() is called with preempt_offset equal to
PREEMPT_LOCK_OFFSET, so it won't report error if it's the only lock we
hold.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

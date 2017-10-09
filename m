Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 846626B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 00:48:37 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t63so17377414pfi.5
        for <linux-mm@kvack.org>; Sun, 08 Oct 2017 21:48:37 -0700 (PDT)
Received: from m50-138.163.com (m50-138.163.com. [123.125.50.138])
        by mx.google.com with ESMTP id k86si6115089pfg.536.2017.10.08.21.48.35
        for <linux-mm@kvack.org>;
        Sun, 08 Oct 2017 21:48:36 -0700 (PDT)
Subject: Re: [BUG] mm/vmalloc: ___might_sleep is called under a spinlock in
 __purge_vmap_area_lazy
References: <70f9850a-b24c-8595-8a22-9b47e96d6338@163.com>
 <20171009041001.p47yc6r7f3borhba@node.shutemov.name>
From: Jia-Ju Bai <baijiaju1990@163.com>
Message-ID: <56ef9c88-ba54-ce01-15dc-7b661b64ab8b@163.com>
Date: Mon, 9 Oct 2017 12:48:22 +0800
MIME-Version: 1.0
In-Reply-To: <20171009041001.p47yc6r7f3borhba@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, catalin.marinas@arm.com, labbott@redhat.com, thgarnie@google.com, kirill.shutemov@linux.intel.com, aryabinin@virtuozzo.com, ard.biesheuvel@linaro.org, zijun_hu@htc.com, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Thanks for your reply and explanation :)
I will improve my analysis.

Thanks,
Jia-Ju Bai

On 2017/10/9 12:10, Kirill A. Shutemov wrote:
> On Mon, Oct 09, 2017 at 12:00:33PM +0800, Jia-Ju Bai wrote:
>> The ___might_sleep is called under a spinlock, and the function call graph
>> is:
>> __purge_vmap_area_lazy (acquire the spinlock)
>>    cond_resched_lock
>>      ___might_sleep
>>
>> In this situation, ___might_sleep may prints error log message because a
>> spinlock is held.
>> A possible fix is to remove ___might_sleep in cond_resched_lock.
>>
>> This bug is found by my static analysis tool and my code review.
> This analysis doesn't makes sense.
>
> The point of cond_resched_lock() is that it drops the lock, if resched is
> required.
>
> ___might_sleep() is called with preempt_offset equal to
> PREEMPT_LOCK_OFFSET, so it won't report error if it's the only lock we
> hold.
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

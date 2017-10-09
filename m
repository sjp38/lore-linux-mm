Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4C8F86B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 00:01:15 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e26so40630042pfd.4
        for <linux-mm@kvack.org>; Sun, 08 Oct 2017 21:01:15 -0700 (PDT)
Received: from m12-13.163.com (m12-13.163.com. [220.181.12.13])
        by mx.google.com with ESMTP id b11si5491098pgq.114.2017.10.08.21.01.13
        for <linux-mm@kvack.org>;
        Sun, 08 Oct 2017 21:01:14 -0700 (PDT)
From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [BUG] mm/vmalloc: ___might_sleep is called under a spinlock in
 __purge_vmap_area_lazy
Message-ID: <70f9850a-b24c-8595-8a22-9b47e96d6338@163.com>
Date: Mon, 9 Oct 2017 12:00:33 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, catalin.marinas@arm.com, labbott@redhat.com, thgarnie@google.com, kirill.shutemov@linux.intel.com, aryabinin@virtuozzo.com, ard.biesheuvel@linaro.org, zijun_hu@htc.com
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

The ___might_sleep is called under a spinlock, and the function call 
graph is:
__purge_vmap_area_lazy (acquire the spinlock)
   cond_resched_lock
     ___might_sleep

In this situation, ___might_sleep may prints error log message because a 
spinlock is held.
A possible fix is to remove ___might_sleep in cond_resched_lock.

This bug is found by my static analysis tool and my code review.


Thanks,
Jia-Ju Bai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0B6E96B0003
	for <linux-mm@kvack.org>; Sat, 17 Feb 2018 03:14:16 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id a76so1465972lfb.3
        for <linux-mm@kvack.org>; Sat, 17 Feb 2018 00:14:15 -0800 (PST)
Received: from forwardcorp1o.cmail.yandex.net (forwardcorp1o.cmail.yandex.net. [2a02:6b8:0:1a72::290])
        by mx.google.com with ESMTPS id i192si7293574lfg.363.2018.02.17.00.14.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Feb 2018 00:14:14 -0800 (PST)
Subject: Re: [PATCH] proc/kpageflags: add KPF_WAITERS
References: <151834540184.176427.12174649162560874101.stgit@buzz>
 <20180216155752.4a17cfd41875911c79807585@linux-foundation.org>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <cd7b5099-0575-81ce-9f48-2efd664f2fc2@yandex-team.ru>
Date: Sat, 17 Feb 2018 11:14:10 +0300
MIME-Version: 1.0
In-Reply-To: <20180216155752.4a17cfd41875911c79807585@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>

On 17.02.2018 02:57, Andrew Morton wrote:
> On Sun, 11 Feb 2018 13:36:41 +0300 Konstantin Khlebnikov <khlebnikov@yandex-team.ru> wrote:
> 
>> KPF_WAITERS indicates tasks are waiting for a page lock or writeback.
>> This might be false-positive, in this case next unlock will clear it.
> 
> Well, kpageflags is full of potential false-positives.  Or do you think
> this flag is especially vulnerable?
> 
> In other words, under what circumstances will we have KPF_WAITERS set
> when PG_locked and PG-writeback are clear?

Looks like lock_page() - unlock_page() shouldn't leave longstanding
false-positive: last unlock_page() must clear PG_waiters.

But I've seen them. Probably that was from  wait_on_page_writeback():
it test PG_writeback, set PG_waiters under queue lock unconditionally
and then test PG_writeback again before sleep - and might exit
without wakeup i.e. without clearing PG_waiters.

This could be fixed with extra check for in wait_on_page_bit_common()
under queue lock.

--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1087,6 +1087,10 @@ static inline int wait_on_page_bit_common(wait_queue_head_t *q,
                 spin_lock_irq(&q->lock);

                 if (likely(list_empty(&wait->entry))) {
+                       if (unlikely(!test_bit(bit_nr, &page->flags))) {
+                               spin_unlock_irq(&q->lock);
+                               goto try;
+                       }
                         __add_wait_queue_entry_tail(q, wait);
                         SetPageWaiters(page);
                 }
@@ -1098,7 +1102,7 @@ static inline int wait_on_page_bit_common(wait_queue_head_t *q,
                 if (likely(test_bit(bit_nr, &page->flags))) {
                         io_schedule();
                 }
-
+try:
                 if (lock) {
                         if (!test_and_set_bit_lock(bit_nr, &page->flags))
                                 break;

But this seems redundant.

> 
>> This looks like worth information not only for kernel hacking.
> 
> Why?  What are the use-cases, in detail?  How are we to justify this
> modification?

This bit tells which page or D 3/4 ffset in file is actually wanted
by somebody in the system. That's another way to track where major
faults or writeback blocks something. We don't have to record flow
of events - snapshot of page-flags will show where contention is.

> 
>> In tool page-types in non-raw mode treat KPF_WAITERS without
>> KPF_LOCKED and KPF_WRITEBACK as false-positive and hide it.
> 
>>   fs/proc/page.c                         |    1 +
>>   include/uapi/linux/kernel-page-flags.h |    1 +
>>   tools/vm/page-types.c                  |    7 +++++++
> 
> Please update Documentation/vm/pagemap.txt.
> 

ok

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

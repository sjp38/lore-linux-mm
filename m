Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 97E6F6B0038
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 08:48:23 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id b186so20732697iof.21
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 05:48:23 -0700 (PDT)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id l125si141056ita.112.2017.10.24.05.48.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 05:48:22 -0700 (PDT)
From: gengdongjiu <gengdongjiu@huawei.com>
Subject: consult a question about action_result() in memory_failure()
Message-ID: <566fb926-6aba-844e-c777-8c81b4670e7b@huawei.com>
Date: Tue, 24 Oct 2017 20:47:41 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi Naoya,
   very sorry to disturb you, I want to consult you about the handing to error page type in memory_failure().
If the error page is the current task's page table, will the memory_failure not handling that?
>From my test, I found the memory_failure() consider the error page table physical address as unknown page.
why it does not handling the page table page error? Thanks a lot.

commit 64d37a2baf5e5c0f1009c0ef290a9027de721d66
Author: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date:   Wed Apr 15 16:13:05 2015 -0700

    mm/memory-failure.c: define page types for action_result() in one place

    This cleanup patch moves all strings passed to action_result() into a
    singl= e array action_page_type so that a reader can easily find which
    kind of actio= n results are possible.  And this patch also fixes the
    odd lines to be printed out, like "unknown page state page" or "free
    buddy, 2nd try page".

    [akpm@linux-foundation.org: rename messages, per David]
    [akpm@linux-foundation.org: s/DIRTY_UNEVICTABLE_LRU/CLEAN_UNEVICTABLE_LRU', per Andi]
    Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
    Reviewed-by: Andi Kleen <ak@linux.intel.com>
    Cc: Tony Luck <tony.luck@intel.com>
    Cc: "Xie XiuQi" <xiexiuqi@huawei.com>
    Cc: Steven Rostedt <rostedt@goodmis.org>
    Cc: Chen Gong <gong.chen@linux.intel.com>
    Cc: David Rientjes <rientjes@google.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index d487f8d..5fd8931 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -521,6 +521,52 @@ static const char *action_name[] = {
        [RECOVERED] = "Recovered",
 };

+enum action_page_type {
+       MSG_KERNEL,
+       MSG_KERNEL_HIGH_ORDER,
+       MSG_SLAB,
+       MSG_DIFFERENT_COMPOUND,
+       MSG_POISONED_HUGE,
+       MSG_HUGE,
+       MSG_FREE_HUGE,
+       MSG_UNMAP_FAILED,
+       MSG_DIRTY_SWAPCACHE,
+       MSG_CLEAN_SWAPCACHE,
+       MSG_DIRTY_MLOCKED_LRU,
+       MSG_CLEAN_MLOCKED_LRU,
+       MSG_DIRTY_UNEVICTABLE_LRU,
+       MSG_CLEAN_UNEVICTABLE_LRU,
+       MSG_DIRTY_LRU,
+       MSG_CLEAN_LRU,
+       MSG_TRUNCATED_LRU,
+       MSG_BUDDY,
+       MSG_BUDDY_2ND,
+       MSG_UNKNOWN,
+};
+
+static const char * const action_page_types[] = {
+       [MSG_KERNEL]                    = "reserved kernel page",
+       [MSG_KERNEL_HIGH_ORDER]         = "high-order kernel page",
+       [MSG_SLAB]                      = "kernel slab page",
+       [MSG_DIFFERENT_COMPOUND]        = "different compound page after locking",
+       [MSG_POISONED_HUGE]             = "huge page already hardware poisoned",
+       [MSG_HUGE]                      = "huge page",
+       [MSG_FREE_HUGE]                 = "free huge page",
+       [MSG_UNMAP_FAILED]              = "unmapping failed page",
+       [MSG_DIRTY_SWAPCACHE]           = "dirty swapcache page",
+       [MSG_CLEAN_SWAPCACHE]           = "clean swapcache page",
+       [MSG_DIRTY_MLOCKED_LRU]         = "dirty mlocked LRU page",
+       [MSG_CLEAN_MLOCKED_LRU]         = "clean mlocked LRU page",
+       [MSG_DIRTY_UNEVICTABLE_LRU]     = "dirty unevictable LRU page",
+       [MSG_CLEAN_UNEVICTABLE_LRU]     = "clean unevictable LRU page",
+       [MSG_DIRTY_LRU]                 = "dirty LRU page",
+       [MSG_CLEAN_LRU]                 = "clean LRU page",
+       [MSG_TRUNCATED_LRU]             = "already truncated LRU page",
+       [MSG_BUDDY]                     = "free buddy page",
+       [MSG_BUDDY_2ND]                 = "free buddy page (2nd try)",
+       [MSG_UNKNOWN]                   = "unknown page",
+};

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

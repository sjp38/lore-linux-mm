Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61A32C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 21:46:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC75A218D4
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 21:46:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC75A218D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85E016B0006; Thu, 25 Jul 2019 17:46:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80E858E0003; Thu, 25 Jul 2019 17:46:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FE3E8E0002; Thu, 25 Jul 2019 17:46:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 39E976B0006
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 17:46:33 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id j12so27020371pll.14
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:46:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=cXe3s42ABlQLmCr6Itah8z1/eNBAHrA2vIQsNEwxgZE=;
        b=rsu7VLQcxGNyas73DCdty9zumf6RpJvb18VqXk2mdhWL8migIkbii2izlsOBZfnYuZ
         IVW/MpOryuW0uZeLclAlP9tTYXwg9X+AXMgq3FP+Rokz2RkhyKW2RgS/GobZ2vrSrxdt
         /apmr4m+y+nGR2/lwy9FZ+eNvUhDgvwYpHV4ktK3BCT/zUPhkJCwkM7yy49COKUEnzMF
         DAX7hkV0bjrJ5l2y1AN8flEzJwtXVTOoNrrs364gb3MHHgPaXDTTlN0z1sCYSNvnRGIy
         rmlq2Z0dCstVnUZr/LHyyQlDquGRkaXtAUQ5YujqvtkFVfnDfQDStXyQzP1oWkvA2pE7
         onzA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUO0VQKqNoWRV6nIswzjThZrN1mTClJNw4clt2krSsA3YMrplmV
	85iIxGV74aJ55Xj2o26tOvglKVttml5vWfL01SulSOnorgjMtycG207E0F15yc4UkihXUarhfSA
	6XwYFM+8RCwxJb529O9Q7CunSv7//R9ZReEaGu7cU9U2UXgjB34tnkE4M1Ufi5h3Afw==
X-Received: by 2002:a63:5945:: with SMTP id j5mr87723449pgm.452.1564091192725;
        Thu, 25 Jul 2019 14:46:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqya8TQGxfjOJPA514ilbvMjhltRRDqgPoQLLyutMWYVCWr/NpsoejjREUw8sBh9cmkSuull
X-Received: by 2002:a63:5945:: with SMTP id j5mr87723406pgm.452.1564091191587;
        Thu, 25 Jul 2019 14:46:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564091191; cv=none;
        d=google.com; s=arc-20160816;
        b=MTrZ1vLo26Jf4AwGF8kOU/912eges/CtisDzR0BFI9a4kHTJv6joLr7mBPKQgk4xil
         RyMjJosla8DKncDqgYytaWgs9302FtrATxooaa+Wp8jYtr9/4IDkZo9bwT13RgcBoOP4
         IRqLnqF4RiWwLszXNd4K8PvIOWaimBg35QR2bqH5nWDWetisxZKxwj0Qml2Jec3HZ8P+
         w2DNDXxYw6dAEf2qTwMYQ0Q5OWzTiZJu3DUXNIvllr6MeWda0f8t6gLiW6L6T5N4qpgZ
         DpYBBgpo2GfXVfafFW2vQMETpBDrfs+JuzVArIwcmLQ6S4Bf2fiwoEw6PkyhwKWUAUNB
         T40g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=cXe3s42ABlQLmCr6Itah8z1/eNBAHrA2vIQsNEwxgZE=;
        b=ADdzAgWkXBvdYIMjfDFyeQNqi5e7E+W5Ofnl32qyCL7OZ0CmV0PIzqvoMFKIY10jwS
         E8r3tpX45320lFPRaBAFDno53FLBXHKyc04VP+u4Hhkxv6nKHBA5EcG5Kj/A9fJHtXpl
         Q3w61vGXfqxh312pjIdKQoPZITqbDqkSfeornS7IVNb8mv4+jKQZiJYG4WT47A3wpR2M
         dIdvJ4OHF/ViPp6iJU/3c3oEZ4P4luDcgIFch0R4puEouZDlhwoyxTcCe6ekUZI8q+nI
         IYQVxpYTu7O4391SZdBE0wBzDs47FZvSnN0HdJ+UcTsj7mIohhsTtUUMqYaYASx+KT8R
         AYhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id x9si16904109pgp.421.2019.07.25.14.46.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 14:46:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) client-ip=115.124.30.131;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01422;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=5;SR=0;TI=SMTPD_---0TXnk7fc_1564091186;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TXnk7fc_1564091186)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 26 Jul 2019 05:46:28 +0800
Subject: Re: list corruption in deferred_split_scan()
To: Qian Cai <cai@lca.pw>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1562795006.8510.19.camel@lca.pw>
 <1564002826.11067.17.camel@lca.pw>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <db71dacc-5074-65ef-d018-df695e25c769@linux.alibaba.com>
Date: Thu, 25 Jul 2019 14:46:22 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <1564002826.11067.17.camel@lca.pw>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/24/19 2:13 PM, Qian Cai wrote:
> On Wed, 2019-07-10 at 17:43 -0400, Qian Cai wrote:
>> Running LTP oom01 test case with swap triggers a crash below. Revert the
>> series
>> "Make deferred split shrinker memcg aware" [1] seems fix the issue.
> You might want to look harder on this commit, as reverted it alone on the top of
>   5.2.0-next-20190711 fixed the issue.
>
> aefde94195ca mm: thp: make deferred split shrinker memcg aware [1]
>
> [1] https://lore.kernel.org/linux-mm/1561507361-59349-5-git-send-email-yang.shi@
> linux.alibaba.com/

This is the real meat of the patch series, which converted to memcg 
deferred split queue actually.

>
>
> list_del corruption. prev->next should be ffffea0022b10098, but was
> 0000000000000000

Finally I could reproduce the list corruption issue on my machine with 
THP swap (swap device is fast device). I should checked this with you at 
the first place. The problem can't be reproduced with rotate swap 
device. So, I'm supposed you were using THP swap too.

Actually, I found two issues with THP swap:
1. free_transhuge_page() is called in reclaim path instead of put_page. 
The mem_cgroup_uncharge() is called before free_transhuge_page() in 
reclaim path, which causes page->mem_cgroup is NULL so the wrong 
deferred_split_queue would be used, so the THP was not deleted from the 
memcg's list at all. Then the page might be split or reused later, 
page->mapping would be override.

2. There is a race condition caused by try_to_unmap() with THP swap. The 
try_to_unmap() just calls page_remove_rmap() to add THP to deferred 
split queue in reclaim path. This might cause the below race condition 
to corrupt the list:

                   A                                      B
deferred_split_scan
     list_move
                                                try_to_unmap
                                                       list_add_tail

list_splice <-- The list might get corrupted here

                                                free_transhuge_page
                                                       list_del <-- 
kernel bug triggered

I hope the below patch would solve your problem (tested locally).


diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b7f709d..d6612ec 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2830,6 +2830,19 @@ void deferred_split_huge_page(struct page *page)

         VM_BUG_ON_PAGE(!PageTransHuge(page), page);

+       /*
+        * The try_to_unmap() in page reclaim path might reach here too,
+        * this may cause a race condition to corrupt deferred split queue.
+        * And, if page reclaim is already handling the same page, it is
+        * unnecessary to handle it again in shrinker.
+        *
+        * Check PageSwapCache to determine if the page is being
+        * handled by page reclaim since THP swap would add the page into
+        * swap cache before reaching try_to_unmap().
+        */
+       if (PageSwapCache(page))
+               return;
+
         spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
         if (list_empty(page_deferred_list(page))) {
                 count_vm_event(THP_DEFERRED_SPLIT_PAGE);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a0301ed..40c684a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1485,10 +1485,9 @@ static unsigned long shrink_page_list(struct 
list_head *page_list,
                  * Is there need to periodically free_page_list? It would
                  * appear not as the counts should be low
                  */
-               if (unlikely(PageTransHuge(page))) {
-                       mem_cgroup_uncharge(page);
+               if (unlikely(PageTransHuge(page)))
                         (*get_compound_page_dtor(page))(page);
-               } else
+               else
                         list_add(&page->lru, &free_pages);
                 continue;

@@ -1909,7 +1908,6 @@ static unsigned noinline_for_stack 
move_pages_to_lru(struct lruvec *lruvec,

                         if (unlikely(PageCompound(page))) {
spin_unlock_irq(&pgdat->lru_lock);
-                               mem_cgroup_uncharge(page);
(*get_compound_page_dtor(page))(page);
spin_lock_irq(&pgdat->lru_lock);
                         } else

> [  685.284254][ T3456] ------------[ cut here ]------------
> [  685.289616][ T3456] kernel BUG at lib/list_debug.c:53!
> [  685.294808][ T3456] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN NOPTI
> [  685.301998][ T3456] CPU: 5 PID: 3456 Comm: oom01 Tainted:
> G        W         5.2.0-next-20190711+ #3
> [  685.311193][ T3456] Hardware name: HPE ProLiant DL385 Gen10/ProLiant DL385
> Gen10, BIOS A40 06/24/2019
> [  685.320485][ T3456] RIP: 0010:__list_del_entry_valid+0x8b/0xb6
> [  685.326364][ T3456] Code: f1 e0 ff 49 8b 55 08 4c 39 e2 75 2c 5b b8 01 00 00
> 00 41 5c 41 5d 5d c3 4c 89 e2 48 89 de 48 c7 c7 c0 5a 73 a3 e8 d9 fa bc ff <0f>
> 0b 48 c7 c7 60 a0 e1 a3 e8 13 52 01 00 4c 89 e6 48 c7 c7 20 5b
> [  685.345956][ T3456] RSP: 0018:ffff888e0c8a73c0 EFLAGS: 00010082
> [  685.351920][ T3456] RAX: 0000000000000054 RBX: ffffea0022b10098 RCX:
> ffffffffa2d5d708
> [  685.359807][ T3456] RDX: 0000000000000000 RSI: 0000000000000008 RDI:
> ffff8888442bd380
> [  685.367693][ T3456] RBP: ffff888e0c8a73d8 R08: ffffed1108857a71 R09:
> ffffed1108857a70
> [  685.375577][ T3456] R10: ffffed1108857a70 R11: ffff8888442bd387 R12:
> 0000000000000000
> [  685.383462][ T3456] R13: 0000000000000000 R14: ffffea0022b10034 R15:
> ffffea0022b10098
> [  685.391348][ T3456] FS:  00007fbe26db4700(0000) GS:ffff888844280000(0000)
> knlGS:0000000000000000
> [  685.400194][ T3456] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  685.406681][ T3456] CR2: 00007fbcabb3f000 CR3: 0000001012e44000 CR4:
> 00000000001406a0
> [  685.414563][ T3456] Call Trace:
> [  685.417736][ T3456]  deferred_split_scan+0x337/0x740
> [  685.422741][ T3456]  ? split_huge_page_to_list+0xe10/0xe10
> [  685.428272][ T3456]  ? __radix_tree_lookup+0x12d/0x1e0
> [  685.433453][ T3456]  ? node_tag_get.part.0.constprop.6+0x40/0x40
> [  685.439505][ T3456]  do_shrink_slab+0x244/0x5a0
> [  685.444071][ T3456]  shrink_slab+0x253/0x440
> [  685.448375][ T3456]  ? unregister_shrinker+0x110/0x110
> [  685.453551][ T3456]  ? kasan_check_read+0x11/0x20
> [  685.458291][ T3456]  ? mem_cgroup_protected+0x20f/0x260
> [  685.463555][ T3456]  shrink_node+0x31e/0xa30
> [  685.467858][ T3456]  ? shrink_node_memcg+0x1560/0x1560
> [  685.473036][ T3456]  ? ktime_get+0x93/0x110
> [  685.477250][ T3456]  do_try_to_free_pages+0x22f/0x820
> [  685.482338][ T3456]  ? shrink_node+0xa30/0xa30
> [  685.486815][ T3456]  ? kasan_check_read+0x11/0x20
> [  685.491556][ T3456]  ? check_chain_key+0x1df/0x2e0
> [  685.496383][ T3456]  try_to_free_pages+0x242/0x4d0
> [  685.501209][ T3456]  ? do_try_to_free_pages+0x820/0x820
> [  685.506476][ T3456]  __alloc_pages_nodemask+0x9ce/0x1bc0
> [  685.511826][ T3456]  ? gfp_pfmemalloc_allowed+0xc0/0xc0
> [  685.517089][ T3456]  ? kasan_check_read+0x11/0x20
> [  685.521826][ T3456]  ? check_chain_key+0x1df/0x2e0
> [  685.526657][ T3456]  ? do_anonymous_page+0x343/0xe30
> [  685.531658][ T3456]  ? lock_downgrade+0x390/0x390
> [  685.536399][ T3456]  ? get_kernel_page+0xa0/0xa0
> [  685.541050][ T3456]  ? __lru_cache_add+0x108/0x160
> [  685.545879][ T3456]  alloc_pages_vma+0x89/0x2c0
> [  685.550444][ T3456]  do_anonymous_page+0x3e1/0xe30
> [  685.555271][ T3456]  ? __update_load_avg_cfs_rq+0x2c/0x490
> [  685.560796][ T3456]  ? finish_fault+0x120/0x120
> [  685.565361][ T3456]  ? alloc_pages_vma+0x21e/0x2c0
> [  685.570187][ T3456]  handle_pte_fault+0x457/0x12c0
> [  685.575014][ T3456]  __handle_mm_fault+0x79a/0xa50
> [  685.579841][ T3456]  ? vmf_insert_mixed_mkwrite+0x20/0x20
> [  685.585280][ T3456]  ? kasan_check_read+0x11/0x20
> [  685.590021][ T3456]  ? __count_memcg_events+0x8b/0x1c0
> [  685.595196][ T3456]  handle_mm_fault+0x17f/0x370
> [  685.599850][ T3456]  __do_page_fault+0x25b/0x5d0
> [  685.604501][ T3456]  do_page_fault+0x4c/0x2cf
> [  685.608892][ T3456]  ? page_fault+0x5/0x20
> [  685.613019][ T3456]  page_fault+0x1b/0x20
> [  685.617058][ T3456] RIP: 0033:0x410be0
> [  685.620840][ T3456] Code: 89 de e8 e3 23 ff ff 48 83 f8 ff 0f 84 86 00 00 00
> 48 89 c5 41 83 fc 02 74 28 41 83 fc 03 74 62 e8 95 29 ff ff 31 d2 48 98 90 <c6>
> 44 15 00 07 48 01 c2 48 39 d3 7f f3 31 c0 5b 5d 41 5c c3 0f 1f
> [  68[  687.120156][ T3456] Shutting down cpus with NMI
> [  687.124731][ T3456] Kernel Offset: 0x21800000 from 0xffffffff81000000
> (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
> [  687.136389][ T3456] ---[ end Kernel panic - not syncing: Fatal exception ]---


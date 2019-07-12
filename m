Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 395B1C742D7
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 19:13:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D328A2064A
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 19:13:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D328A2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E55E8E0166; Fri, 12 Jul 2019 15:13:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 697348E0003; Fri, 12 Jul 2019 15:13:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 537F28E0166; Fri, 12 Jul 2019 15:13:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1FDAF8E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 15:13:20 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id a198so4575079oii.15
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 12:13:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=l1u0haLYwGuNI04D5Xv098WeBW9St3qTYDxTYpekb5k=;
        b=ormhqPyh2X/JcAdxJunrPDYyAZkjjhpRSupz5xC3Ct+Kz6Ymci9Degrk6lBeB+e1P5
         EWrAuLMx6OmI95eefPOcVCy8bSOZ7nYsNe1ffJNbqEFA2V/+pXLEPYef82AqcmALe/PT
         OjWLgm4ohX4XD5JGoRQ09CEMOEWeW33LIKnx5oISO7C89W0h/h75TLwedRGpcff4Y7jc
         q2jBA6jdGQNdErew1PK+EuvKtIT467CGbLAeBshb0z6HO14h9xn9h+7jbSVN9dX61Zya
         2AqfvXHL9tXkY5tSFry6E9JQlxceMU6UVOCmvl+hhxxguX0rTNURG6MP8AMYz8rc8FN1
         tk2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUUUkf5xEXrJPA1BXLri0zEzxjza4VR3uuWQlw0oX334dl4TzAF
	iASaAKD/2ZJAbFrmtzi4ut48EVGIPjpKOIgNxneiDD8ISObuLtRNIeqkvjDY/BrEMBH8SmBt2jj
	8wvEW/9XCFHxUPrgehdwvcONo8XMaTGHN2CzV1mknkYyry8lAk46tp7s21hEyooF8GA==
X-Received: by 2002:a05:6808:144:: with SMTP id h4mr6223500oie.20.1562958799665;
        Fri, 12 Jul 2019 12:13:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqVutNy2pk4D4A9/EHPia+aG8CC31NFWZ7ogLuz/m1E8QUPh/njOOgjHh6lueM+slr+wst
X-Received: by 2002:a05:6808:144:: with SMTP id h4mr6223442oie.20.1562958798011;
        Fri, 12 Jul 2019 12:13:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562958798; cv=none;
        d=google.com; s=arc-20160816;
        b=MqtZvfQATJIjVDAaemOMeLU10ozxcghgOiq3rzNXLDiXo6CtJqr6u+OXt2zYctOXYZ
         VD+KRZpXIQdIH7gc1zzNlHxpRn0eVCjlQbHniO0HU3fWPf52ir/ODaYfK+gPMXNQqCrB
         ucQ+yHhB4MeF/IQGsKVAnmTyrqUnS9xdq3EnPPpDczn/HxqUkzoRCLf76oeEOddcWm7v
         WP1U+hrd/aBsiKQqAARekZhn2P9EULma7GgN0XS7S1NR9yjjb38LIqz8HFy223ECtYoJ
         ULxwYNdMNeqwUGHTQFj5xP8+ExrBedXsvFpUbInk5uK32fZNPMYktz9DlkVZdeGHHrhT
         N1lA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=l1u0haLYwGuNI04D5Xv098WeBW9St3qTYDxTYpekb5k=;
        b=FrLqYTpm/5btTAAc/HYEScNZBiUyzU/K4IrAIsZSqFGK23sCLE7dtQLp383yP1sCiZ
         mBbkXdNcKvZPxrUous6Q4ULe8o/YMtsAvvcFAjlQ8FEs1ApDHCyTjtPsU8Yc2uI/VrH6
         ItGjNE8N/9goBCxYtJ4Lu0YL/J65NLK8OH12FuDQQ62ErgD6UrjuGz0waqbVZPmB8IPW
         vxLxQsnNT3ofzpayjK2hYCHn3vS4mloIKth3tZDpUCzxkVBpnrhdaAdy5Kh5REChy/YD
         3LGcbhj4G2L1OPLeaeI24d3yh58RogyMkm0oFU7LObxjrpvLkXXi6XWvrqYncK2HO4LC
         eOtg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com. [115.124.30.42])
        by mx.google.com with ESMTPS id z91si5639303otb.313.2019.07.12.12.13.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 12:13:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) client-ip=115.124.30.42;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R641e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=5;SR=0;TI=SMTPD_---0TWj5fJh_1562958781;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TWj5fJh_1562958781)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 13 Jul 2019 03:13:03 +0800
Subject: Re: list corruption in deferred_split_scan()
To: Qian Cai <cai@lca.pw>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1562795006.8510.19.camel@lca.pw>
 <cd6e10bc-cb79-65c5-ff2b-4c244ae5eb1c@linux.alibaba.com>
 <1562879229.8510.24.camel@lca.pw>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <b38ee633-f8e0-00ee-55ee-2f0aaea9ed6b@linux.alibaba.com>
Date: Fri, 12 Jul 2019 12:12:58 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <1562879229.8510.24.camel@lca.pw>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/11/19 2:07 PM, Qian Cai wrote:
> On Wed, 2019-07-10 at 17:16 -0700, Yang Shi wrote:
>> Hi Qian,
>>
>>
>> Thanks for reporting the issue. But, I can't reproduce it on my machine.
>> Could you please share more details about your test? How often did you
>> run into this problem?
> I can almost reproduce it every time on a HPE ProLiant DL385 Gen10 server. Here
> is some more information.
>
> # cat .config
>
> https://raw.githubusercontent.com/cailca/linux-mm/master/x86.config

I tried your kernel config, but I still can't reproduce it. My compiler 
doesn't have retpoline support, so CONFIG_RETPOLINE is disabled in my 
test, but I don't think this would make any difference for this case.

According to the bug call trace in the earlier email, it looks deferred 
_split_scan lost race with put_compound_page. The put_compound_page 
would call free_transhuge_page() which delete the page from the deferred 
split queue, but it may still appear on the deferred list due to some 
reason.

Would you please try the below patch?

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b7f709d..66bd9db 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2765,7 +2765,7 @@ int split_huge_page_to_list(struct page *page, 
struct list_head *list)
         if (!mapcount && page_ref_freeze(head, 1 + extra_pins)) {
                 if (!list_empty(page_deferred_list(head))) {
                         ds_queue->split_queue_len--;
-                       list_del(page_deferred_list(head));
+                       list_del_init(page_deferred_list(head));
                 }
                 if (mapping)
                         __dec_node_page_state(page, NR_SHMEM_THPS);
@@ -2814,7 +2814,7 @@ void free_transhuge_page(struct page *page)
         spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
         if (!list_empty(page_deferred_list(page))) {
                 ds_queue->split_queue_len--;
-               list_del(page_deferred_list(page));
+               list_del_init(page_deferred_list(page));
         }
         spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
         free_compound_page(page);

>
> # numactl -H
> available: 8 nodes (0-7)
> node 0 cpus: 0 1 2 3 4 5 6 7 64 65 66 67 68 69 70 71
> node 0 size: 19984 MB
> node 0 free: 7251 MB
> node 1 cpus: 8 9 10 11 12 13 14 15 72 73 74 75 76 77 78 79
> node 1 size: 0 MB
> node 1 free: 0 MB
> node 2 cpus: 16 17 18 19 20 21 22 23 80 81 82 83 84 85 86 87
> node 2 size: 0 MB
> node 2 free: 0 MB
> node 3 cpus: 24 25 26 27 28 29 30 31 88 89 90 91 92 93 94 95
> node 3 size: 0 MB
> node 3 free: 0 MB
> node 4 cpus: 32 33 34 35 36 37 38 39 96 97 98 99 100 101 102 103
> node 4 size: 31524 MB
> node 4 free: 25165 MB
> node 5 cpus: 40 41 42 43 44 45 46 47 104 105 106 107 108 109 110 111
> node 5 size: 0 MB
> node 5 free: 0 MB
> node 6 cpus: 48 49 50 51 52 53 54 55 112 113 114 115 116 117 118 119
> node 6 size: 0 MB
> node 6 free: 0 MB
> node 7 cpus: 56 57 58 59 60 61 62 63 120 121 122 123 124 125 126 127
> node 7 size: 0 MB
> node 7 free: 0 MB
> node distances:
> node   0   1   2   3   4   5   6   7
>    0:  10  16  16  16  32  32  32  32
>    1:  16  10  16  16  32  32  32  32
>    2:  16  16  10  16  32  32  32  32
>    3:  16  16  16  10  32  32  32  32
>    4:  32  32  32  32  10  16  16  16
>    5:  32  32  32  32  16  10  16  16
>    6:  32  32  32  32  16  16  10  16
>    7:  32  32  32  32  16  16  16  10
>
> # lscpu
> Architecture:        x86_64
> CPU op-mode(s):      32-bit, 64-bit
> Byte Order:          Little Endian
> CPU(s):              128
> On-line CPU(s) list: 0-127
> Thread(s) per core:  2
> Core(s) per socket:  32
> Socket(s):           2
> NUMA node(s):        8
> Vendor ID:           AuthenticAMD
> CPU family:          23
> Model:               1
> Model name:          AMD EPYC 7601 32-Core Processor
> Stepping:            2
> CPU MHz:             2713.551
> BogoMIPS:            4391.39
> Virtualization:      AMD-V
> L1d cache:           32K
> L1i cache:           64K
> L2 cache:            512K
> L3 cache:            8192K
> NUMA node0 CPU(s):   0-7,64-71
> NUMA node1 CPU(s):   8-15,72-79
> NUMA node2 CPU(s):   16-23,80-87
> NUMA node3 CPU(s):   24-31,88-95
> NUMA node4 CPU(s):   32-39,96-103
> NUMA node5 CPU(s):   40-47,104-111
> NUMA node6 CPU(s):   48-55,112-119
> NUMA node7 CPU(s):   56-63,120-127
>
> Another possible lead is that without reverting the those commits below, kdump
> kernel would always also crash in shrink_slab_memcg() at this line,
>
> map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map, true);

This looks a little bit weird. It seems nodeinfo[nid] is NULL? I didn't 
think of where nodeinfo was freed but memcg was still online. Maybe a 
check is needed:

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a0301ed..bacda49 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -602,6 +602,9 @@ static unsigned long shrink_slab_memcg(gfp_t 
gfp_mask, int nid,
         if (!mem_cgroup_online(memcg))
                 return 0;

+       if (!memcg->nodeinfo[nid])
+               return 0;
+
         if (!down_read_trylock(&shrinker_rwsem))
                 return 0;

>
> [    9.072036][    T1] BUG: KASAN: null-ptr-deref in shrink_slab+0x111/0x440
> [    9.072036][    T1] Read of size 8 at addr 0000000000000dc8 by task
> swapper/0/1
> [    9.072036][    T1]
> [    9.072036][    T1] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 5.2.0-next-
> 20190711+ #10
> [    9.072036][    T1] Hardware name: HPE ProLiant DL385 Gen10/ProLiant DL385
> Gen10, BIOS A40 01/25/2019
> [    9.072036][    T1] Call Trace:
> [    9.072036][    T1]  dump_stack+0x62/0x9a
> [    9.072036][    T1]  __kasan_report.cold.4+0xb0/0xb4
> [    9.072036][    T1]  ? unwind_get_return_address+0x40/0x50
> [    9.072036][    T1]  ? shrink_slab+0x111/0x440
> [    9.072036][    T1]  kasan_report+0xc/0xe
> [    9.072036][    T1]  __asan_load8+0x71/0xa0
> [    9.072036][    T1]  shrink_slab+0x111/0x440
> [    9.072036][    T1]  ? mem_cgroup_iter+0x98/0x840
> [    9.072036][    T1]  ? unregister_shrinker+0x110/0x110
> [    9.072036][    T1]  ? kasan_check_read+0x11/0x20
> [    9.072036][    T1]  ? mem_cgroup_protected+0x39/0x260
> [    9.072036][    T1]  shrink_node+0x31e/0xa30
> [    9.072036][    T1]  ? shrink_node_memcg+0x1560/0x1560
> [    9.072036][    T1]  ? ktime_get+0x93/0x110
> [    9.072036][    T1]  do_try_to_free_pages+0x22f/0x820
> [    9.072036][    T1]  ? shrink_node+0xa30/0xa30
> [    9.072036][    T1]  ? kasan_check_read+0x11/0x20
> [    9.072036][    T1]  ? check_chain_key+0x1df/0x2e0
> [    9.072036][    T1]  try_to_free_pages+0x242/0x4d0
> [    9.072036][    T1]  ? do_try_to_free_pages+0x820/0x820
> [    9.072036][    T1]  __alloc_pages_nodemask+0x9ce/0x1bc0
> [    9.072036][    T1]  ? gfp_pfmemalloc_allowed+0xc0/0xc0
> [    9.072036][    T1]  ? unwind_dump+0x260/0x260
> [    9.072036][    T1]  ? kernel_text_address+0x33/0xc0
> [    9.072036][    T1]  ? arch_stack_walk+0x8f/0xf0
> [    9.072036][    T1]  ? ret_from_fork+0x22/0x40
> [    9.072036][    T1]  alloc_page_interleave+0x18/0x130
> [    9.072036][    T1]  alloc_pages_current+0xf6/0x110
> [    9.072036][    T1]  allocate_slab+0x600/0x11f0
> [    9.072036][    T1]  new_slab+0x46/0x70
> [    9.072036][    T1]  ___slab_alloc+0x5d4/0x9c0
> [    9.072036][    T1]  ? create_object+0x3a/0x3e0
> [    9.072036][    T1]  ? fs_reclaim_acquire.part.15+0x5/0x30
> [    9.072036][    T1]  ? ___might_sleep+0xab/0xc0
> [    9.072036][    T1]  ? create_object+0x3a/0x3e0
> [    9.072036][    T1]  __slab_alloc+0x12/0x20
> [    9.072036][    T1]  ? __slab_alloc+0x12/0x20
> [    9.072036][    T1]  kmem_cache_alloc+0x32a/0x400
> [    9.072036][    T1]  create_object+0x3a/0x3e0
> [    9.072036][    T1]  kmemleak_alloc+0x71/0xa0
> [    9.072036][    T1]  kmem_cache_alloc+0x272/0x400
> [    9.072036][    T1]  ? kasan_check_read+0x11/0x20
> [    9.072036][    T1]  ? do_raw_spin_unlock+0xa8/0x140
> [    9.072036][    T1]  acpi_ps_alloc_op+0x76/0x122
> [    9.072036][    T1]  acpi_ds_execute_arguments+0x2f/0x18d
> [    9.072036][    T1]  acpi_ds_get_package_arguments+0x7d/0x84
> [    9.072036][    T1]  acpi_ns_init_one_package+0x33/0x61
> [    9.072036][    T1]  acpi_ns_init_one_object+0xfc/0x189
> [    9.072036][    T1]  acpi_ns_walk_namespace+0x114/0x1f2
> [    9.072036][    T1]  ? acpi_ns_init_one_package+0x61/0x61
> [    9.072036][    T1]  ? acpi_ns_init_one_package+0x61/0x61
> [    9.072036][    T1]  acpi_walk_namespace+0x9e/0xcb
> [    9.072036][    T1]  ? acpi_sleep_proc_init+0x36/0x36
> [    9.072036][    T1]  acpi_ns_initialize_objects+0x99/0xed
> [    9.072036][    T1]  ? acpi_ns_find_ini_methods+0xa2/0xa2
> [    9.072036][    T1]  ? acpi_tb_load_namespace+0x2dc/0x2eb
> [    9.072036][    T1]  acpi_load_tables+0x61/0x80
> [    9.072036][    T1]  acpi_init+0x10d/0x44b
> [    9.072036][    T1]  ? acpi_sleep_proc_init+0x36/0x36
> [    9.072036][    T1]  ? bus_uevent_filter+0x16/0x30
> [    9.072036][    T1]  ? kobject_uevent_env+0x109/0x980
> [    9.072036][    T1]  ? kernfs_get+0x13/0x20
> [    9.072036][    T1]  ? kobject_uevent+0xb/0x10
> [    9.072036][    T1]  ? kset_register+0x31/0x50
> [    9.072036][    T1]  ? kset_create_and_add+0x9f/0xd0
> [    9.072036][    T1]  ? acpi_sleep_proc_init+0x36/0x36
> [    9.072036][    T1]  do_one_initcall+0xfe/0x45a
> [    9.072036][    T1]  ? initcall_blacklisted+0x150/0x150
> [    9.072036][    T1]  ? rwsem_down_read_slowpath+0x930/0x930
> [    9.072036][    T1]  ? kasan_check_write+0x14/0x20
> [    9.072036][    T1]  ? up_write+0x6b/0x190
> [    9.072036][    T1]  kernel_init_freeable+0x614/0x6a7
> [    9.072036][    T1]  ? rest_init+0x188/0x188
> [    9.072036][    T1]  kernel_init+0x11/0x138
> [    9.072036][    T1]  ? rest_init+0x188/0x188
> [    9.072036][    T1]  ret_from_fork+0x22/0x40
> [    9.072036][    T1]
> ==================================================================
> [    9.072036][    T1] Disabling lock debugging due to kernel taint
> [    9.145712][    T1] BUG: kernel NULL pointer dereference, address:
> 0000000000000dc8
> [    9.152036][    T1] #PF: supervisor read access in kernel mode
> [    9.152036][    T1] #PF: error_code(0x0000) - not-present page
> [    9.152036][    T1] PGD 0 P4D 0
> [    9.152036][    T1] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN NOPTI
> [    9.152036][    T1] CPU: 0 PID: 1 Comm: swapper/0 Tainted:
> G    B             5.2.0-next-20190711+ #10
> [    9.152036][    T1] Hardware name: HPE ProLiant DL385 Gen10/ProLiant DL385
> Gen10, BIOS A40 01/25/2019
> [    9.152036][    T1] RIP: 0010:shrink_slab+0x111/0x440
> [    9.152036][    T1] Code: c7 20 8d 44 82 e8 7f 8b e8 ff 85 c0 0f 84 e2 02 00
> 00 4c 63 a5 4c ff ff ff 49 81 c4 b8 01 00 00 4b 8d 7c e6 08 e8 3f 07 0e 00 <4f>
> 8b 64 e6 08 49 8d bc 24 20 03 00 00 e8 2d 07 0e 00 49 8b 84 24
> [    9.152036][    T1] RSP: 0018:ffff88905757f100 EFLAGS: 00010282
> [    9.152036][    T1] RAX: 0000000000000000 RBX: ffff88905757f1b0 RCX:
> ffffffff8112f288
> [    9.152036][    T1] RDX: 1ffffffff049c088 RSI: dffffc0000000000 RDI:
> ffffffff824e0440
> [    9.152036][    T1] RBP: ffff88905757f1d8 R08: fffffbfff049c089 R09:
> fffffbfff049c088
> [    9.152036][    T1] R10: fffffbfff049c088 R11: ffffffff824e0443 R12:
> 00000000000001b8
> [    9.152036][    T1] R13: 0000000000000000 R14: 0000000000000000 R15:
> ffff88905757f440
> [    9.152036][    T1] FS:  0000000000000000(0000) GS:ffff889062800000(0000)
> knlGS:0000000000000000
> [    9.152036][    T1] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    9.152036][    T1] CR2: 0000000000000dc8 CR3: 0000001070212000 CR4:
> 00000000001406b0
> [    9.152036][    T1] Call Trace:
> [    9.152036][    T1]  ? mem_cgroup_iter+0x98/0x840
> [    9.152036][    T1]  ? unregister_shrinker+0x110/0x110
> [    9.152036][    T1]  ? kasan_check_read+0x11/0x20
> [    9.152036][    T1]  ? mem_cgroup_protected+0x39/0x260
> [    9.152036][    T1]  shrink_node+0x31e/0xa30
> [    9.152036][    T1]  ? shrink_node_memcg+0x1560/0x1560
> [    9.152036][    T1]  ? ktime_get+0x93/0x110
> [    9.152036][    T1]  do_try_to_free_pages+0x22f/0x820
> [    9.152036][    T1]  ? shrink_node+0xa30/0xa30
> [    9.152036][    T1]  ? kasan_check_read+0x11/0x20
> [    9.152036][    T1]  ? check_chain_key+0x1df/0x2e0
> [    9.152036][    T1]  try_to_free_pages+0x242/0x4d0
> [    9.152036][    T1]  ? do_try_to_free_pages+0x820/0x820
> [    9.152036][    T1]  __alloc_pages_nodemask+0x9ce/0x1bc0
> [    9.152036][    T1]  ? gfp_pfmemalloc_allowed+0xc0/0xc0
> [    9.152036][    T1]  ? unwind_dump+0x260/0x260
> [    9.152036][    T1]  ? kernel_text_address+0x33/0xc0
> [    9.152036][    T1]  ? arch_stack_walk+0x8f/0xf0
> [    9.152036][    T1]  ? ret_from_fork+0x22/0x40
> [    9.152036][    T1]  alloc_page_interleave+0x18/0x130
> [    9.152036][    T1]  alloc_pages_current+0xf6/0x110
> [    9.152036][    T1]  allocate_slab+0x600/0x11f0
> [    9.152036][    T1]  new_slab+0x46/0x70
> [    9.152036][    T1]  ___slab_alloc+0x5d4/0x9c0
> [    9.152036][    T1]  ? create_object+0x3a/0x3e0
> [    9.152036][    T1]  ? fs_reclaim_acquire.part.15+0x5/0x30
> [    9.152036][    T1]  ? ___might_sleep+0xab/0xc0
> [    9.152036][    T1]  ? create_object+0x3a/0x3e0
> [    9.152036][    T1]  __slab_alloc+0x12/0x20
> [    9.152036][    T1]  ? __slab_alloc+0x12/0x20
> [    9.152036][    T1]  kmem_cache_alloc+0x32a/0x400
> [    9.152036][    T1]  create_object+0x3a/0x3e0
> [    9.152036][    T1]  kmemleak_alloc+0x71/0xa0
> [    9.152036][    T1]  kmem_cache_alloc+0x272/0x400
> [    9.152036][    T1]  ? kasan_check_read+0x11/0x20
> [    9.152036][    T1]  ? do_raw_spin_unlock+0xa8/0x140
> [    9.152036][    T1]  acpi_ps_alloc_op+0x76/0x122
> [    9.152036][    T1]  acpi_ds_execute_arguments+0x2f/0x18d
> [    9.152036][    T1]  acpi_ds_get_package_arguments+0x7d/0x84
> [    9.152036][    T1]  acpi_ns_init_one_package+0x33/0x61
> [    9.152036][    T1]  acpi_ns_init_one_object+0xfc/0x189
> [    9.152036][    T1]  acpi_ns_walk_namespace+0x114/0x1f2
> [    9.152036][    T1]  ? acpi_ns_init_one_package+0x61/0x61
> [    9.152036][    T1]  ? acpi_ns_init_one_package+0x61/0x61
> [    9.152036][    T1]  acpi_walk_namespace+0x9e/0xcb
> [    9.152036][    T1]  ? acpi_sleep_proc_init+0x36/0x36
> [    9.152036][    T1]  acpi_ns_initialize_objects+0x99/0xed
> [    9.152036][    T1]  ? acpi_ns_find_ini_methods+0xa2/0xa2
> [    9.152036][    T1]  ? acpi_tb_load_namespace+0x2dc/0x2eb
> [    9.152036][    T1]  acpi_load_tables+0x61/0x80
> [    9.152036][    T1]  acpi_init+0x10d/0x44b
> [    9.152036][    T1]  ? acpi_sleep_proc_init+0x36/0x36
> [    9.152036][    T1]  ? bus_uevent_filter+0x16/0x30
> [    9.152036][    T1]  ? kobject_uevent_env+0x109/0x980
> [    9.152036][    T1]  ? kernfs_get+0x13/0x20
> [    9.152036][    T1]  ? kobject_uevent+0xb/0x10
> [    9.152036][    T1]  ? kset_register+0x31/0x50
> [    9.152036][    T1]  ? kset_create_and_add+0x9f/0xd0
> [    9.152036][    T1]  ? acpi_sleep_proc_init+0x36/0x36
> [    9.152036][    T1]  do_one_initcall+0xfe/0x45a
> [    9.152036][    T1]  ? initcall_blacklisted+0x150/0x150
> [    9.152036][    T1]  ? rwsem_down_read_slowpath+0x930/0x930
> [    9.152036][    T1]  ? kasan_check_write+0x14/0x20
> [    9.152036][    T1]  ? up_write+0x6b/0x190
> [    9.152036][    T1]  kernel_init_freeable+0x614/0x6a7
> [    9.152036][    T1]  ? rest_init+0x188/0x188
> [    9.152036][    T1]  kernel_init+0x11/0x138
> [    9.152036][    T1]  ? rest_init+0x188/0x188
> [    9.152036][    T1]  ret_from_fork+0x22/0x40
> [    9.152036][    T1] Modules linked in:
> [    9.152036][    T1] CR2: 0000000000000dc8
> [    9.152036][    T1] ---[ end trace 568acce4eca01945 ]---
> [    9.152036][    T1] RIP: 0010:shrink_slab+0x111/0x440
> [    9.152036][    T1] Code: c7 20 8d 44 82 e8 7f 8b e8 ff 85 c0 0f 84 e2 02 00
> 00 4c 63 a5 4c ff ff ff 49 81 c4 b8 01 00 00 4b 8d 7c e6 08 e8 3f 07 0e 00 <4f>
> 8b 64 e6 08 49 8d bc 24 20 03 00 00 e8 2d 07 0e 00 49 8b 84 24
> [    9.152036][    T1] RSP: 0018:ffff88905757f100 EFLAGS: 00010282
> [    9.152036][    T1] RAX: 0000000000000000 RBX: ffff88905757f1b0 RCX:
> ffffffff8112f288
> [    9.152036][    T1] RDX: 1ffffffff049c088 RSI: dffffc0000000000 RDI:
> ffffffff824e0440
> [    9.152036][    T1] RBP: ffff88905757f1d8 R08: fffffbfff049c089 R09:
> fffffbfff049c088
> [    9.152036][    T1] R10: fffffbfff049c088 R11: ffffffff824e0443 R12:
> 00000000000001b8
> [    9.152036][    T1] R13: 0000000000000000 R14: 0000000000000000 R15:
> ffff88905757f440
> [    9.152036][    T1] FS:  0000000000000000(0000) GS:ffff889062800000(0000)
> knlGS:00000000
>
>>
>> Regards,
>>
>> Yang
>>
>>
>>
>> On 7/10/19 2:43 PM, Qian Cai wrote:
>>> Running LTP oom01 test case with swap triggers a crash below. Revert the
>>> series
>>> "Make deferred split shrinker memcg aware" [1] seems fix the issue.
>>>
>>> aefde94195ca mm: thp: make deferred split shrinker memcg aware
>>> cf402211cacc mm-shrinker-make-shrinker-not-depend-on-memcg-kmem-fix-2-fix
>>> ca37e9e5f18d mm-shrinker-make-shrinker-not-depend-on-memcg-kmem-fix-2
>>> 5f419d89cab4 mm-shrinker-make-shrinker-not-depend-on-memcg-kmem-fix
>>> c9d49e69e887 mm: shrinker: make shrinker not depend on memcg kmem
>>> 1c0af4b86bcf mm: move mem_cgroup_uncharge out of __page_cache_release()
>>> 4e050f2df876 mm: thp: extract split_queue_* into a struct
>>>
>>> [1] https://lore.kernel.org/linux-mm/1561507361-59349-1-git-send-email-yang.
>>> shi@
>>> linux.alibaba.com/
>>>
>>> [ 1145.730682][ T5764] list_del corruption, ffffea00251c8098->next is
>>> LIST_POISON1 (dead000000000100)
>>> [ 1145.739763][ T5764] ------------[ cut here ]------------
>>> [ 1145.745126][ T5764] kernel BUG at lib/list_debug.c:47!
>>> [ 1145.750320][ T5764] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
>>> NOPTI
>>> [ 1145.757513][ T5764] CPU: 1 PID: 5764 Comm: oom01 Tainted:
>>> G        W         5.2.0-next-20190710+ #7
>>> [ 1145.766709][ T5764] Hardware name: HPE ProLiant DL385 Gen10/ProLiant
>>> DL385
>>> Gen10, BIOS A40 01/25/2019
>>> [ 1145.776000][ T5764] RIP: 0010:__list_del_entry_valid.cold.0+0x12/0x4a
>>> [ 1145.782491][ T5764] Code: c7 40 5a 33 af e8 ac fe bc ff 0f 0b 48 c7 c7 80
>>> 9e
>>> a1 af e8 f6 4c 01 00 4c 89 ea 48 89 de 48 c7 c7 20 59 33 af e8 8c fe bc ff
>>> <0f>
>>> 0b 48 c7 c7 40 9f a1 af e8 d6 4c 01 00 4c 89 e2 48 89 de 48 c7
>>> [ 1145.802078][ T5764] RSP: 0018:ffff888514d773c0 EFLAGS: 00010082
>>> [ 1145.808042][ T5764] RAX: 000000000000004e RBX: ffffea00251c8098 RCX:
>>> ffffffffae95d318
>>> [ 1145.815923][ T5764] RDX: 0000000000000000 RSI: 0000000000000008 RDI:
>>> ffff8888440bd380
>>> [ 1145.823806][ T5764] RBP: ffff888514d773d8 R08: ffffed1108817a71 R09:
>>> ffffed1108817a70
>>> [ 1145.831689][ T5764] R10: ffffed1108817a70 R11: ffff8888440bd387 R12:
>>> dead000000000122
>>> [ 1145.839571][ T5764] R13: dead000000000100 R14: ffffea00251c8034 R15:
>>> dead000000000100
>>> [ 1145.847455][ T5764] FS:  00007f765ad4d700(0000) GS:ffff888844080000(0000)
>>> knlGS:0000000000000000
>>> [ 1145.856299][ T5764] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>> [ 1145.862784][ T5764] CR2: 00007f8cebec7000 CR3: 0000000459338000 CR4:
>>> 00000000001406a0
>>> [ 1145.870664][ T5764] Call Trace:
>>> [ 1145.873835][ T5764]  deferred_split_scan+0x337/0x740
>>> [ 1145.878835][ T5764]  ? split_huge_page_to_list+0xe30/0xe30
>>> [ 1145.884364][ T5764]  ? __radix_tree_lookup+0x12d/0x1e0
>>> [ 1145.889539][ T5764]  ? node_tag_get.part.0.constprop.6+0x40/0x40
>>> [ 1145.895592][ T5764]  do_shrink_slab+0x244/0x5a0
>>> [ 1145.900159][ T5764]  shrink_slab+0x253/0x440
>>> [ 1145.904462][ T5764]  ? unregister_shrinker+0x110/0x110
>>> [ 1145.909641][ T5764]  ? kasan_check_read+0x11/0x20
>>> [ 1145.914383][ T5764]  ? mem_cgroup_protected+0x20f/0x260
>>> [ 1145.919645][ T5764]  shrink_node+0x31e/0xa30
>>> [ 1145.923949][ T5764]  ? shrink_node_memcg+0x1560/0x1560
>>> [ 1145.929126][ T5764]  ? ktime_get+0x93/0x110
>>> [ 1145.933340][ T5764]  do_try_to_free_pages+0x22f/0x820
>>> [ 1145.938429][ T5764]  ? shrink_node+0xa30/0xa30
>>> [ 1145.942906][ T5764]  ? kasan_check_read+0x11/0x20
>>> [ 1145.947647][ T5764]  ? check_chain_key+0x1df/0x2e0
>>> [ 1145.952474][ T5764]  try_to_free_pages+0x242/0x4d0
>>> [ 1145.957299][ T5764]  ? do_try_to_free_pages+0x820/0x820
>>> [ 1145.962566][ T5764]  __alloc_pages_nodemask+0x9ce/0x1bc0
>>> [ 1145.967917][ T5764]  ? kasan_check_read+0x11/0x20
>>> [ 1145.972657][ T5764]  ? gfp_pfmemalloc_allowed+0xc0/0xc0
>>> [ 1145.977920][ T5764]  ? kasan_check_read+0x11/0x20
>>> [ 1145.982659][ T5764]  ? check_chain_key+0x1df/0x2e0
>>> [ 1145.987487][ T5764]  ? do_anonymous_page+0x343/0xe30
>>> [ 1145.992489][ T5764]  ? lock_downgrade+0x390/0x390
>>> [ 1145.997230][ T5764]  ? __count_memcg_events+0x8b/0x1c0
>>> [ 1146.002404][ T5764]  ? kasan_check_read+0x11/0x20
>>> [ 1146.007145][ T5764]  ? __lru_cache_add+0x122/0x160
>>> [ 1146.011974][ T5764]  alloc_pages_vma+0x89/0x2c0
>>> [ 1146.016538][ T5764]  do_anonymous_page+0x3e1/0xe30
>>> [ 1146.021367][ T5764]  ? __update_load_avg_cfs_rq+0x2c/0x490
>>> [ 1146.026893][ T5764]  ? finish_fault+0x120/0x120
>>> [ 1146.031461][ T5764]  ? call_function_interrupt+0xa/0x20
>>> [ 1146.036724][ T5764]  handle_pte_fault+0x457/0x12c0
>>> [ 1146.041552][ T5764]  __handle_mm_fault+0x79a/0xa50
>>> [ 1146.046378][ T5764]  ? vmf_insert_mixed_mkwrite+0x20/0x20
>>> [ 1146.051817][ T5764]  ? kasan_check_read+0x11/0x20
>>> [ 1146.056557][ T5764]  ? __count_memcg_events+0x8b/0x1c0
>>> [ 1146.061732][ T5764]  handle_mm_fault+0x17f/0x370
>>> [ 1146.066386][ T5764]  __do_page_fault+0x25b/0x5d0
>>> [ 1146.071037][ T5764]  do_page_fault+0x4c/0x2cf
>>> [ 1146.075426][ T5764]  ? page_fault+0x5/0x20
>>> [ 1146.079553][ T5764]  page_fault+0x1b/0x20
>>> [ 1146.083594][ T5764] RIP: 0033:0x410be0
>>> [ 1146.087373][ T5764] Code: 89 de e8 e3 23 ff ff 48 83 f8 ff 0f 84 86 00 00
>>> 00
>>> 48 89 c5 41 83 fc 02 74 28 41 83 fc 03 74 62 e8 95 29 ff ff 31 d2 48 98 90
>>> <c6>
>>> 44 15 00 07 48 01 c2 48 39 d3 7f f3 31 c0 5b 5d 41 5c c3 0f 1f
>>> [ 1146.106959][ T5764] RSP: 002b:00007f765ad4cec0 EFLAGS: 00010206
>>> [ 1146.112921][ T5764] RAX: 0000000000001000 RBX: 00000000c0000000 RCX:
>>> 00007f98f2674497
>>> [ 1146.120804][ T5764] RDX: 0000000001d95000 RSI: 00000000c0000000 RDI:
>>> 0000000000000000
>>> [ 1146.128687][ T5764] RBP: 00007f74d9d4c000 R08: 00000000ffffffff R09:
>>> 0000000000000000
>>> [ 1146.136569][ T5764] R10: 0000000000000022 R11: 000000000[ 1147.588181][
>>> T5764] Shutting down cpus with NMI
>>> [ 1147.592756][ T5764] Kernel Offset: 0x2d400000 from 0xffffffff81000000
>>> (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
>>> [ 1147.604414][ T5764] ---[ end Kernel panic - not syncing: Fatal exception
>>> ]---
>>


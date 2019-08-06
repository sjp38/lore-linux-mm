Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5B6DC0650F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 01:05:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CBE52075B
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 01:05:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="mzB6AdEV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CBE52075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF7E36B0003; Mon,  5 Aug 2019 21:05:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA8446B0006; Mon,  5 Aug 2019 21:05:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 998206B0007; Mon,  5 Aug 2019 21:05:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9AF6B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 21:05:11 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id k31so77558912qte.13
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 18:05:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=Ze4jXorbQcbyiTviWAuUecQWQSJW6wnww0pz5GcYx3c=;
        b=mY1DAU3uGP6hj+aqNnjEw1BNNxKjfHV7duqecJBELl/NnBW1xr+g5vQGm4kOGgVjsB
         sMYKxMpIW8E6PJffBUGN2c/OvJ8XOx0pNQtp9OgcJFmFGn48WfR8ate0UE92+hfgkJA5
         bhHpL3jWFccDLP93kuIpGAUOzukMOhMQ9piv4ao05Y95Y+mdgMTkLwRD+jUbVZHDkpXM
         xdyMvK2XF6K0Vss5RxNm+ItHAwXi+0Rv+tZThFSDV/N4a0MkCWDHgeY7+XIsVLaB/jZw
         chvQd3sIQCbba5kh9+70ph4ypvPB7iwYGIF9WCkFciZ30x6CqwRNnBPrl2+v4+mkH9vi
         8JXw==
X-Gm-Message-State: APjAAAX1iV1y6uLhneLGJw3eYga04+354q9hgUVsit8sWH2qtabtKQCA
	rMkc5pR42DUzmWn33n1lY3dcpeBOK78Sr0mnN80mTYxdXAei02g0DqXSitWGk/l5vKbB+kQ4SvW
	ykA8U/cPcR9g8I69uERLcWN6VUYnOHt/Az/LRvqCGyKaAyKqaIbzkiHpwE9Tlu+hR0g==
X-Received: by 2002:ae9:f809:: with SMTP id x9mr1073024qkh.86.1565053511179;
        Mon, 05 Aug 2019 18:05:11 -0700 (PDT)
X-Received: by 2002:ae9:f809:: with SMTP id x9mr1072944qkh.86.1565053509777;
        Mon, 05 Aug 2019 18:05:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565053509; cv=none;
        d=google.com; s=arc-20160816;
        b=E5Bq4L23lK9p7pzrcZ1nvSNtXZwxBzDxWzpf+t2yf3fjGq29XASpzFIuMuC0xa4GOf
         7fWfvdn0kyjSgQO2km79CXd4GLG8qZk9IXn5+xW27h4rINhMrQXyq0/wwIyD1QJbqJEA
         1Akq4O0okGd7ePyxzoS394M8mrxpaiyxgi3VlPKaL/s6yA/gjM9LCYveUYx2DskAEHt6
         btpJFy3eVYG7AhJHZQ1qjPtkDJhknKz1hXxZ4o5Ha7mKAcoHkJ0WIBHmKoK98Mtc4jPY
         IrP3B3hUdGU1lDN4oSySg/+KcMBNbHg/UMtTvZrrlRxRGiBt+gMtY+5gPHC2gsImNT6k
         jc/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=Ze4jXorbQcbyiTviWAuUecQWQSJW6wnww0pz5GcYx3c=;
        b=Ytvbe6VdDmXqWDz/QoUk3PffBbFtwF6uARyI8pWcC3hiyi39c10uZTw1t2TR1n7cHZ
         zBazpOesqxAJY7koLbCpHWfDCk1bQkCExFv6UvCAEF/hEvz5G6IP3gQjQ+0RWTITYKwq
         1GEuNgVSAXMfU7MZHnau2zdt+70zVao9VJbBS+CfUoUR6OO1THtchOzEaV+QhCOrG06p
         IM1IM/41giyEH2naGDLnUG07HPfS/BYNA7gen7RlpZSQEDxYaYWSceg4qETJh8vRTgpR
         55B43cdz2lTuj5oZpY8o7OmyNrQlMWaFen0Dt5Jeqi8ES49sKNcoeZGLTLRXPp5bDzmW
         K6Lg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=mzB6AdEV;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p23sor70725552qve.39.2019.08.05.18.05.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 18:05:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=mzB6AdEV;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=Ze4jXorbQcbyiTviWAuUecQWQSJW6wnww0pz5GcYx3c=;
        b=mzB6AdEVjir5AoAzd4rkjWyZGK5Xejii9o9gEYsBH5j6bktf50F4als1XZKA6ODUig
         X9QkEMBVECCL/wFDCnpNLIXtC3VvtFX2sDCfny4IqztThR8SJ0ikMpEGGnOFasDxUiU9
         QGFiAIKQHJxltQZlOUmqQMmCueC/SGhEx6BAj/nDFlkYIJZwWjBEKUdFVYfmxFCeNG47
         J5gwQpVh+VJruT6JHVbP3T2bxQ8gt3HfQ4r5pH6SchUnT31Xp2k6zvg+lW2p4CTWWI6A
         apBMt+iGLi2yvDXki0q37bnbjd/Agn43ZKoQU5rggl+5RI3aQMlY4jS/OcGzA+DcIMe3
         cpBA==
X-Google-Smtp-Source: APXvYqxfLwu5nGOBBS6j+3EAfoxvuHMOzVz2Vcoj3uDz9YWN6YUzKPstt3eiVGPzLJvllpSBTy2xrQ==
X-Received: by 2002:a0c:99e9:: with SMTP id y41mr746597qve.186.1565053509255;
        Mon, 05 Aug 2019 18:05:09 -0700 (PDT)
Received: from [192.168.1.153] (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id q9sm34415265qkm.63.2019.08.05.18.05.07
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 18:05:08 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: list corruption in deferred_split_scan()
From: Qian Cai <cai@lca.pw>
In-Reply-To: <13487e44-273e-819d-89be-8b7823c2f936@linux.alibaba.com>
Date: Mon, 5 Aug 2019 21:05:06 -0400
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Linux-MM <linux-mm@kvack.org>,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <DC199A92-616B-4BE9-A293-5E674C20F8D1@lca.pw>
References: <1562795006.8510.19.camel@lca.pw>
 <1564002826.11067.17.camel@lca.pw>
 <db71dacc-5074-65ef-d018-df695e25c769@linux.alibaba.com>
 <13487e44-273e-819d-89be-8b7823c2f936@linux.alibaba.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Aug 5, 2019, at 6:15 PM, Yang Shi <yang.shi@linux.alibaba.com> =
wrote:
>=20
>=20
>=20
> On 7/25/19 2:46 PM, Yang Shi wrote:
>>=20
>>=20
>> On 7/24/19 2:13 PM, Qian Cai wrote:
>>> On Wed, 2019-07-10 at 17:43 -0400, Qian Cai wrote:
>>>> Running LTP oom01 test case with swap triggers a crash below. =
Revert the
>>>> series
>>>> "Make deferred split shrinker memcg aware" [1] seems fix the issue.
>>> You might want to look harder on this commit, as reverted it alone =
on the top of
>>>   5.2.0-next-20190711 fixed the issue.
>>>=20
>>> aefde94195ca mm: thp: make deferred split shrinker memcg aware [1]
>>>=20
>>> [1] =
https://lore.kernel.org/linux-mm/1561507361-59349-5-git-send-email-yang.sh=
i@
>>> linux.alibaba.com/
>>=20
>> This is the real meat of the patch series, which converted to memcg =
deferred split queue actually.
>>=20
>>>=20
>>>=20
>>> list_del corruption. prev->next should be ffffea0022b10098, but was
>>> 0000000000000000
>>=20
>> Finally I could reproduce the list corruption issue on my machine =
with THP swap (swap device is fast device). I should checked this with =
you at the first place. The problem can't be reproduced with rotate swap =
device. So, I'm supposed you were using THP swap too.
>>=20
>> Actually, I found two issues with THP swap:
>> 1. free_transhuge_page() is called in reclaim path instead of =
put_page. The mem_cgroup_uncharge() is called before =
free_transhuge_page() in reclaim path, which causes page->mem_cgroup is =
NULL so the wrong deferred_split_queue would be used, so the THP was not =
deleted from the memcg's list at all. Then the page might be split or =
reused later, page->mapping would be override.
>>=20
>> 2. There is a race condition caused by try_to_unmap() with THP swap. =
The try_to_unmap() just calls page_remove_rmap() to add THP to deferred =
split queue in reclaim path. This might cause the below race condition =
to corrupt the list:
>>=20
>>                   A                                      B
>> deferred_split_scan
>>     list_move
>>                                                try_to_unmap
>> list_add_tail
>>=20
>> list_splice <-- The list might get corrupted here
>>=20
>>                                                free_transhuge_page
>>                                                       list_del <-- =
kernel bug triggered
>>=20
>> I hope the below patch would solve your problem (tested locally).
>=20
> Hi Qian,
>=20
> Did the below patch solve your problem? I would like the fold the fix =
into the series then target to 5.4 release.

It is going to take a while before I would be able to access that system =
again. Since you can reproduce this and
test yourself now, I=E2=80=99d say go ahead posting the patch.


>=20
> Thanks,
> Yang
>=20
>>=20
>>=20
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index b7f709d..d6612ec 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -2830,6 +2830,19 @@ void deferred_split_huge_page(struct page =
*page)
>>=20
>>         VM_BUG_ON_PAGE(!PageTransHuge(page), page);
>>=20
>> +       /*
>> +        * The try_to_unmap() in page reclaim path might reach here =
too,
>> +        * this may cause a race condition to corrupt deferred split =
queue.
>> +        * And, if page reclaim is already handling the same page, it =
is
>> +        * unnecessary to handle it again in shrinker.
>> +        *
>> +        * Check PageSwapCache to determine if the page is being
>> +        * handled by page reclaim since THP swap would add the page =
into
>> +        * swap cache before reaching try_to_unmap().
>> +        */
>> +       if (PageSwapCache(page))
>> +               return;
>> +
>>         spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
>>         if (list_empty(page_deferred_list(page))) {
>>                 count_vm_event(THP_DEFERRED_SPLIT_PAGE);
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index a0301ed..40c684a 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1485,10 +1485,9 @@ static unsigned long shrink_page_list(struct =
list_head *page_list,
>>                  * Is there need to periodically free_page_list? It =
would
>>                  * appear not as the counts should be low
>>                  */
>> -               if (unlikely(PageTransHuge(page))) {
>> -                       mem_cgroup_uncharge(page);
>> +               if (unlikely(PageTransHuge(page)))
>>                         (*get_compound_page_dtor(page))(page);
>> -               } else
>> +               else
>>                         list_add(&page->lru, &free_pages);
>>                 continue;
>>=20
>> @@ -1909,7 +1908,6 @@ static unsigned noinline_for_stack =
move_pages_to_lru(struct lruvec *lruvec,
>>=20
>>                         if (unlikely(PageCompound(page))) {
>> spin_unlock_irq(&pgdat->lru_lock);
>> -                               mem_cgroup_uncharge(page);
>> (*get_compound_page_dtor(page))(page);
>> spin_lock_irq(&pgdat->lru_lock);
>>                         } else
>>=20
>>> [  685.284254][ T3456] ------------[ cut here ]------------
>>> [  685.289616][ T3456] kernel BUG at lib/list_debug.c:53!
>>> [  685.294808][ T3456] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC =
KASAN NOPTI
>>> [  685.301998][ T3456] CPU: 5 PID: 3456 Comm: oom01 Tainted:
>>> G        W         5.2.0-next-20190711+ #3
>>> [  685.311193][ T3456] Hardware name: HPE ProLiant DL385 =
Gen10/ProLiant DL385
>>> Gen10, BIOS A40 06/24/2019
>>> [  685.320485][ T3456] RIP: 0010:__list_del_entry_valid+0x8b/0xb6
>>> [  685.326364][ T3456] Code: f1 e0 ff 49 8b 55 08 4c 39 e2 75 2c 5b =
b8 01 00 00
>>> 00 41 5c 41 5d 5d c3 4c 89 e2 48 89 de 48 c7 c7 c0 5a 73 a3 e8 d9 fa =
bc ff <0f>
>>> 0b 48 c7 c7 60 a0 e1 a3 e8 13 52 01 00 4c 89 e6 48 c7 c7 20 5b
>>> [  685.345956][ T3456] RSP: 0018:ffff888e0c8a73c0 EFLAGS: 00010082
>>> [  685.351920][ T3456] RAX: 0000000000000054 RBX: ffffea0022b10098 =
RCX:
>>> ffffffffa2d5d708
>>> [  685.359807][ T3456] RDX: 0000000000000000 RSI: 0000000000000008 =
RDI:
>>> ffff8888442bd380
>>> [  685.367693][ T3456] RBP: ffff888e0c8a73d8 R08: ffffed1108857a71 =
R09:
>>> ffffed1108857a70
>>> [  685.375577][ T3456] R10: ffffed1108857a70 R11: ffff8888442bd387 =
R12:
>>> 0000000000000000
>>> [  685.383462][ T3456] R13: 0000000000000000 R14: ffffea0022b10034 =
R15:
>>> ffffea0022b10098
>>> [  685.391348][ T3456] FS:  00007fbe26db4700(0000) =
GS:ffff888844280000(0000)
>>> knlGS:0000000000000000
>>> [  685.400194][ T3456] CS:  0010 DS: 0000 ES: 0000 CR0: =
0000000080050033
>>> [  685.406681][ T3456] CR2: 00007fbcabb3f000 CR3: 0000001012e44000 =
CR4:
>>> 00000000001406a0
>>> [  685.414563][ T3456] Call Trace:
>>> [  685.417736][ T3456]  deferred_split_scan+0x337/0x740
>>> [  685.422741][ T3456]  ? split_huge_page_to_list+0xe10/0xe10
>>> [  685.428272][ T3456]  ? __radix_tree_lookup+0x12d/0x1e0
>>> [  685.433453][ T3456]  ? node_tag_get.part.0.constprop.6+0x40/0x40
>>> [  685.439505][ T3456]  do_shrink_slab+0x244/0x5a0
>>> [  685.444071][ T3456]  shrink_slab+0x253/0x440
>>> [  685.448375][ T3456]  ? unregister_shrinker+0x110/0x110
>>> [  685.453551][ T3456]  ? kasan_check_read+0x11/0x20
>>> [  685.458291][ T3456]  ? mem_cgroup_protected+0x20f/0x260
>>> [  685.463555][ T3456]  shrink_node+0x31e/0xa30
>>> [  685.467858][ T3456]  ? shrink_node_memcg+0x1560/0x1560
>>> [  685.473036][ T3456]  ? ktime_get+0x93/0x110
>>> [  685.477250][ T3456]  do_try_to_free_pages+0x22f/0x820
>>> [  685.482338][ T3456]  ? shrink_node+0xa30/0xa30
>>> [  685.486815][ T3456]  ? kasan_check_read+0x11/0x20
>>> [  685.491556][ T3456]  ? check_chain_key+0x1df/0x2e0
>>> [  685.496383][ T3456]  try_to_free_pages+0x242/0x4d0
>>> [  685.501209][ T3456]  ? do_try_to_free_pages+0x820/0x820
>>> [  685.506476][ T3456]  __alloc_pages_nodemask+0x9ce/0x1bc0
>>> [  685.511826][ T3456]  ? gfp_pfmemalloc_allowed+0xc0/0xc0
>>> [  685.517089][ T3456]  ? kasan_check_read+0x11/0x20
>>> [  685.521826][ T3456]  ? check_chain_key+0x1df/0x2e0
>>> [  685.526657][ T3456]  ? do_anonymous_page+0x343/0xe30
>>> [  685.531658][ T3456]  ? lock_downgrade+0x390/0x390
>>> [  685.536399][ T3456]  ? get_kernel_page+0xa0/0xa0
>>> [  685.541050][ T3456]  ? __lru_cache_add+0x108/0x160
>>> [  685.545879][ T3456]  alloc_pages_vma+0x89/0x2c0
>>> [  685.550444][ T3456]  do_anonymous_page+0x3e1/0xe30
>>> [  685.555271][ T3456]  ? __update_load_avg_cfs_rq+0x2c/0x490
>>> [  685.560796][ T3456]  ? finish_fault+0x120/0x120
>>> [  685.565361][ T3456]  ? alloc_pages_vma+0x21e/0x2c0
>>> [  685.570187][ T3456]  handle_pte_fault+0x457/0x12c0
>>> [  685.575014][ T3456]  __handle_mm_fault+0x79a/0xa50
>>> [  685.579841][ T3456]  ? vmf_insert_mixed_mkwrite+0x20/0x20
>>> [  685.585280][ T3456]  ? kasan_check_read+0x11/0x20
>>> [  685.590021][ T3456]  ? __count_memcg_events+0x8b/0x1c0
>>> [  685.595196][ T3456]  handle_mm_fault+0x17f/0x370
>>> [  685.599850][ T3456]  __do_page_fault+0x25b/0x5d0
>>> [  685.604501][ T3456]  do_page_fault+0x4c/0x2cf
>>> [  685.608892][ T3456]  ? page_fault+0x5/0x20
>>> [  685.613019][ T3456]  page_fault+0x1b/0x20
>>> [  685.617058][ T3456] RIP: 0033:0x410be0
>>> [  685.620840][ T3456] Code: 89 de e8 e3 23 ff ff 48 83 f8 ff 0f 84 =
86 00 00 00
>>> 48 89 c5 41 83 fc 02 74 28 41 83 fc 03 74 62 e8 95 29 ff ff 31 d2 48 =
98 90 <c6>
>>> 44 15 00 07 48 01 c2 48 39 d3 7f f3 31 c0 5b 5d 41 5c c3 0f 1f
>>> [  68[  687.120156][ T3456] Shutting down cpus with NMI
>>> [  687.124731][ T3456] Kernel Offset: 0x21800000 from =
0xffffffff81000000
>>> (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
>>> [  687.136389][ T3456] ---[ end Kernel panic - not syncing: Fatal =
exception ]---
>>=20
>=20


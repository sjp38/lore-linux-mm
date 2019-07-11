Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AF1CC74A5B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 17:59:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B28C420872
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 17:59:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B28C420872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22C368E00F1; Thu, 11 Jul 2019 13:59:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DD608E00DB; Thu, 11 Jul 2019 13:59:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A4688E00F1; Thu, 11 Jul 2019 13:59:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id CE1728E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 13:58:59 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id m186so1334061vsm.2
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:58:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=mjwqZb+qK8ZL0kZXSR8f7F0PwOmQk/3EHisv8ej6piM=;
        b=lwZMUl0YMY9cYrDxhybtXwsOVTfm2BwMLgyvUDoz7MYsjw3QEnTGkN7z8xvTiPLKzp
         89vfuIh4kxdlb3OSpgbQwQKJhL2xhP9H9yb6D/ixNBR4GueZN9vyjXf+GGwHBdEoIAEv
         P0lCymPxjLbV543/dOH4AYZSVA5JDka/noBvsFabZZVQiKybNei331/+W/pQEtwqiEyK
         +NI+1wNhn0je1pDVA+4Df16rID5bxRocbZH3reKAj+eJ7/irri/tBDfX9/Krda/+0bqo
         o3OzMU7ezHvTNN1+tIsi6pVMlBtGL+ozQ2bDClHWWnIPcJQ8y1nLn8LGmE8thXM9pUq2
         eOBw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUuKwfdGoPUzqz7fe/WjLroBIFI/D7ujt4fCU8qjPiFh7hmvbDC
	RnL4YXKwVUFqLIuQ6YTMUK7Uw0tVcsBPF21e/ko4LQJ/UoJCGzuGGId8h/bypX9aTHXiC7S8gkN
	fCs2Mi7k739ofsA1UHc1/byiT4E2fgj2YjPOVWPwz7/j9KGW24RZWAles5i6ABsvc9Q==
X-Received: by 2002:ab0:4993:: with SMTP id e19mr5947430uad.2.1562867939503;
        Thu, 11 Jul 2019 10:58:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8sjSvou/iPBJBSA/jKXzl3cYo0HJhxzpPKqCSoNuod1qDP6XnUc1KhSOab/wzy1yqn6tC
X-Received: by 2002:ab0:4993:: with SMTP id e19mr5947336uad.2.1562867938026;
        Thu, 11 Jul 2019 10:58:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562867938; cv=none;
        d=google.com; s=arc-20160816;
        b=PPxgOUnbw2+QroOoyKbrcPJv5ikx8FhVsWu7Y2ZhAaG49cEVsbDv93ZKbXzUxdu8fE
         DjYmbIV1mOt3Q62XGb4V/Ox/qnkyi5Jiya202YbR/opY64hB/w5o+Iihd0PKhq8bm3FR
         NHag526GLY9tvhTxnTws/IY52OwJVLW/4U2vorMVgo/boFEbmULx+4HdeosG1AaNttab
         BbgW7Etrmkt9NuZ/j7IPTe7sxNPJjtp9h+2tiZh+lviU8dajEKHyrzh/euoo3qnCowhY
         nA5wwHEfU6bNznB7vimP+E4O0faDkBjkFvtUdzN/nGPOSiXvpFJ0ca9kPgZNga/Tg73H
         4pxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=mjwqZb+qK8ZL0kZXSR8f7F0PwOmQk/3EHisv8ej6piM=;
        b=MPpEFZWKbIy1HNEHbHBX8bE96nH8X5O42dPwdG84LJ7pfbhMqTcDSseEbuSmzPk9V8
         gjLYnSI3GVmzmFbOevKlUnRUHxJfNQlgw2gu8RvFbHBhJUDdW5Qe8oxgJ9FSxZO2wPnC
         T8gHOGOz3+ryRdX/IRxacYh73yn1iM+Jlf3yh0qKl8aSPbXlpjP5m/AZpSD+sIeCJ4+1
         8SIHSeFJ6gVPgKv7FGagGRmDP5wVuFEu9OdtnbfGWYkV+zwMxocdMm38n6s3QZolnnoH
         XzOF3O6SNNDQ61lIFmMAvyuqSTJWw5Eo32rE9Mhl4tuGsLFbST5qUoi7fmtbwANFYDJy
         S1NQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p20si2222788vsj.6.2019.07.11.10.58.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 10:58:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E53EC4ACDF;
	Thu, 11 Jul 2019 17:58:56 +0000 (UTC)
Received: from [10.18.17.163] (dhcp-17-163.bos.redhat.com [10.18.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 399A01001B10;
	Thu, 11 Jul 2019 17:58:48 +0000 (UTC)
Subject: Re: [RFC][Patch v11 1/2] mm: page_hinting: core infrastructure
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>,
 john.starks@microsoft.com, Dave Hansen <dave.hansen@intel.com>,
 Michal Hocko <mhocko@suse.com>
References: <20190710195158.19640-1-nitesh@redhat.com>
 <20190710195158.19640-2-nitesh@redhat.com>
 <CAKgT0Ue3mVZ_J0GgMUP4PBW4SUD1=L9ixD5nUZybw9_vmBAT0A@mail.gmail.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <3c6c6b93-eb21-a04c-d0db-6f1b134540db@redhat.com>
Date: Thu, 11 Jul 2019 13:58:47 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAKgT0Ue3mVZ_J0GgMUP4PBW4SUD1=L9ixD5nUZybw9_vmBAT0A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 11 Jul 2019 17:58:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/10/19 5:56 PM, Alexander Duyck wrote:
> On Wed, Jul 10, 2019 at 12:52 PM Nitesh Narayan Lal <nitesh@redhat.com>=
 wrote:
>> This patch introduces the core infrastructure for free page hinting in=

>> virtual environments. It enables the kernel to track the free pages wh=
ich
>> can be reported to its hypervisor so that the hypervisor could
>> free and reuse that memory as per its requirement.
>>
>> While the pages are getting processed in the hypervisor (e.g.,
>> via MADV_FREE), the guest must not use them, otherwise, data loss
>> would be possible. To avoid such a situation, these pages are
>> temporarily removed from the buddy. The amount of pages removed
>> temporarily from the buddy is governed by the backend(virtio-balloon
>> in our case).
>>
>> To efficiently identify free pages that can to be hinted to the
>> hypervisor, bitmaps in a coarse granularity are used. Only fairly big
>> chunks are reported to the hypervisor - especially, to not break up TH=
P
>> in the hypervisor - "MAX_ORDER - 2" on x86, and to save space. The bit=
s
>> in the bitmap are an indication whether a page *might* be free, not a
>> guarantee. A new hook after buddy merging sets the bits.
>>
>> Bitmaps are stored per zone, protected by the zone lock. A workqueue
>> asynchronously processes the bitmaps, trying to isolate and report pag=
es
>> that are still free. The backend (virtio-balloon) is responsible for
>> reporting these batched pages to the host synchronously. Once reportin=
g/
>> freeing is complete, isolated pages are returned back to the buddy.
>>
>> There are still various things to look into (e.g., memory hotplug, mor=
e
>> efficient locking, possible races when disabling).
>>
>> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
>> ---
>>  include/linux/page_hinting.h |  45 +++++++
>>  mm/Kconfig                   |   6 +
>>  mm/Makefile                  |   1 +
>>  mm/page_alloc.c              |  18 +--
>>  mm/page_hinting.c            | 250 ++++++++++++++++++++++++++++++++++=
+
>>  5 files changed, 312 insertions(+), 8 deletions(-)
>>  create mode 100644 include/linux/page_hinting.h
>>  create mode 100644 mm/page_hinting.c
>>
>> diff --git a/include/linux/page_hinting.h b/include/linux/page_hinting=
=2Eh
>> new file mode 100644
>> index 000000000000..4900feb796f9
>> --- /dev/null
>> +++ b/include/linux/page_hinting.h
>> @@ -0,0 +1,45 @@
>> +/* SPDX-License-Identifier: GPL-2.0 */
>> +#ifndef _LINUX_PAGE_HINTING_H
>> +#define _LINUX_PAGE_HINTING_H
>> +
>> +/*
>> + * Minimum page order required for a page to be hinted to the host.
>> + */
>> +#define PAGE_HINTING_MIN_ORDER         (MAX_ORDER - 2)
>> +
> Why use (MAX_ORDER - 2)? Is this just because of the issues I pointed
> out earlier for is it due to something else? I'm just wondering if
> this will have an impact on architectures outside of x86 as I had
> chose pageblock_order which happened to be MAX_ORDER - 2 on x86, but I
> don't know that the impact of doing that is on other architectures
> versus the (MAX_ORDER - 2) approach you took here.
If I am not wrong then any order=C2=A0 < (MAX_ORDER - 2) will break the T=
HP.
That's one reason we decided to stick with this.
>
>> +/*
>> + * struct page_hinting_config: holds the information supplied by the =
balloon
>> + * device to page hinting.
>> + * @hint_pages:                Callback which reports the isolated pa=
ges
>> + *                     synchornously to the host.
>> + * @max_pages:         Maxmimum pages that are going to be hinted to =
the host
>> + *                     at a time of granularity >=3D PAGE_HINTING_MIN=
_ORDER.
>> + */
>> +struct page_hinting_config {
>> +       void (*hint_pages)(struct list_head *list);
>> +       int max_pages;
>> +};
>> +
>> +extern int __isolate_free_page(struct page *page, unsigned int order)=
;
>> +extern void __free_one_page(struct page *page, unsigned long pfn,
>> +                           struct zone *zone, unsigned int order,
>> +                           int migratetype, bool hint);
>> +#ifdef CONFIG_PAGE_HINTING
>> +void page_hinting_enqueue(struct page *page, int order);
>> +int page_hinting_enable(const struct page_hinting_config *conf);
>> +void page_hinting_disable(void);
>> +#else
>> +static inline void page_hinting_enqueue(struct page *page, int order)=

>> +{
>> +}
>> +
>> +static inline int page_hinting_enable(const struct page_hinting_confi=
g *conf)
>> +{
>> +       return -EOPNOTSUPP;
>> +}
>> +
>> +static inline void page_hinting_disable(void)
>> +{
>> +}
>> +#endif
>> +#endif /* _LINUX_PAGE_HINTING_H */
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index f0c76ba47695..e97fab429d9b 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -765,4 +765,10 @@ config GUP_BENCHMARK
>>  config ARCH_HAS_PTE_SPECIAL
>>         bool
>>
>> +# PAGE_HINTING will allow the guest to report the free pages to the
>> +# host in fixed chunks as soon as the threshold is reached.
>> +config PAGE_HINTING
>> +       bool
>> +       def_bool n
>> +       depends on X86_64
>>  endmenu
> If there are no issue with using the term "PAGE_HINTING" I guess I
> will update my patch set to use that term instead of aeration.
Not sure, at places like virtio_balloon, we may have to think of
something else to avoid any confusion.
>
>> diff --git a/mm/Makefile b/mm/Makefile
>> index ac5e5ba78874..73be49177656 100644
>> --- a/mm/Makefile
>> +++ b/mm/Makefile
>> @@ -94,6 +94,7 @@ obj-$(CONFIG_Z3FOLD)  +=3D z3fold.o
>>  obj-$(CONFIG_GENERIC_EARLY_IOREMAP) +=3D early_ioremap.o
>>  obj-$(CONFIG_CMA)      +=3D cma.o
>>  obj-$(CONFIG_MEMORY_BALLOON) +=3D balloon_compaction.o
>> +obj-$(CONFIG_PAGE_HINTING) +=3D page_hinting.o
>>  obj-$(CONFIG_PAGE_EXTENSION) +=3D page_ext.o
>>  obj-$(CONFIG_CMA_DEBUGFS) +=3D cma_debug.o
>>  obj-$(CONFIG_USERFAULTFD) +=3D userfaultfd.o
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index d66bc8abe0af..8a44338bd04e 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -69,6 +69,7 @@
>>  #include <linux/lockdep.h>
>>  #include <linux/nmi.h>
>>  #include <linux/psi.h>
>> +#include <linux/page_hinting.h>
>>
>>  #include <asm/sections.h>
>>  #include <asm/tlbflush.h>
>> @@ -874,10 +875,10 @@ compaction_capture(struct capture_control *capc,=
 struct page *page,
>>   * -- nyc
>>   */
>>
>> -static inline void __free_one_page(struct page *page,
>> +inline void __free_one_page(struct page *page,
>>                 unsigned long pfn,
>>                 struct zone *zone, unsigned int order,
>> -               int migratetype)
>> +               int migratetype, bool hint)
>>  {
>>         unsigned long combined_pfn;
>>         unsigned long uninitialized_var(buddy_pfn);
>> @@ -980,7 +981,8 @@ static inline void __free_one_page(struct page *pa=
ge,
>>                                 migratetype);
>>         else
>>                 add_to_free_area(page, &zone->free_area[order], migrat=
etype);
>> -
>> +       if (hint)
>> +               page_hinting_enqueue(page, order);
>>  }
> I'm not sure I am a fan of the way the word "hint" is used here. At
> first I thought this was supposed to be !hint since I thought hint
> meant that it was a hinted page, not that we need to record that this
> page has been freed. Maybe "record" or "report" might be a better word
> to use here.
"hint" basically means that the page is supposed to be hinted.
>>  /*
>> @@ -1263,7 +1265,7 @@ static void free_pcppages_bulk(struct zone *zone=
, int count,
>>                 if (unlikely(isolated_pageblocks))
>>                         mt =3D get_pageblock_migratetype(page);
>>
>> -               __free_one_page(page, page_to_pfn(page), zone, 0, mt);=

>> +               __free_one_page(page, page_to_pfn(page), zone, 0, mt, =
true);
>>                 trace_mm_page_pcpu_drain(page, 0, mt);
>>         }
>>         spin_unlock(&zone->lock);
>> @@ -1272,14 +1274,14 @@ static void free_pcppages_bulk(struct zone *zo=
ne, int count,
>>  static void free_one_page(struct zone *zone,
>>                                 struct page *page, unsigned long pfn,
>>                                 unsigned int order,
>> -                               int migratetype)
>> +                               int migratetype, bool hint)
>>  {
>>         spin_lock(&zone->lock);
>>         if (unlikely(has_isolate_pageblock(zone) ||
>>                 is_migrate_isolate(migratetype))) {
>>                 migratetype =3D get_pfnblock_migratetype(page, pfn);
>>         }
>> -       __free_one_page(page, pfn, zone, order, migratetype);
>> +       __free_one_page(page, pfn, zone, order, migratetype, hint);
>>         spin_unlock(&zone->lock);
>>  }
>>
>> @@ -1369,7 +1371,7 @@ static void __free_pages_ok(struct page *page, u=
nsigned int order)
>>         migratetype =3D get_pfnblock_migratetype(page, pfn);
>>         local_irq_save(flags);
>>         __count_vm_events(PGFREE, 1 << order);
>> -       free_one_page(page_zone(page), page, pfn, order, migratetype);=

>> +       free_one_page(page_zone(page), page, pfn, order, migratetype, =
true);
>>         local_irq_restore(flags);
>>  }
>>
>> @@ -2969,7 +2971,7 @@ static void free_unref_page_commit(struct page *=
page, unsigned long pfn)
>>          */
>>         if (migratetype >=3D MIGRATE_PCPTYPES) {
>>                 if (unlikely(is_migrate_isolate(migratetype))) {
>> -                       free_one_page(zone, page, pfn, 0, migratetype)=
;
>> +                       free_one_page(zone, page, pfn, 0, migratetype,=
 true);
>>                         return;
>>                 }
>>                 migratetype =3D MIGRATE_MOVABLE;
>> diff --git a/mm/page_hinting.c b/mm/page_hinting.c
>> new file mode 100644
>> index 000000000000..0bfa09f8c3ed
>> --- /dev/null
>> +++ b/mm/page_hinting.c
>> @@ -0,0 +1,250 @@
>> +// SPDX-License-Identifier: GPL-2.0
>> +/*
>> + * Page hinting core infrastructure to enable a VM to report free pag=
es to its
>> + * hypervisor.
>> + *
>> + * Copyright Red Hat, Inc. 2019
>> + *
>> + * Author(s): Nitesh Narayan Lal <nitesh@redhat.com>
>> + */
>> +
>> +#include <linux/mm.h>
>> +#include <linux/slab.h>
>> +#include <linux/page_hinting.h>
>> +#include <linux/kvm_host.h>
>> +
>> +/*
>> + * struct zone_free_area: For a single zone across NUMA nodes, it hol=
ds the
>> + * bitmap pointer to track the free pages and other required paramete=
rs
>> + * used to recover these pages by scanning the bitmap.
>> + * @bitmap:            Pointer to the bitmap in PAGE_HINTING_MIN_ORDE=
R
>> + *                     granularity.
>> + * @base_pfn:          Starting PFN value for the zone whose bitmap i=
s stored.
>> + * @end_pfn:           Indicates the last PFN value for the zone.
>> + * @free_pages:                Tracks the number of free pages of gra=
nularity
>> + *                     PAGE_HINTING_MIN_ORDER.
>> + * @nbits:             Indicates the total size of the bitmap in bits=
 allocated
>> + *                     at the time of initialization.
>> + */
>> +struct zone_free_area {
>> +       unsigned long *bitmap;
>> +       unsigned long base_pfn;
>> +       unsigned long end_pfn;
>> +       atomic_t free_pages;
>> +       unsigned long nbits;
>> +} free_area[MAX_NR_ZONES];
>> +
> You still haven't addressed the NUMA issue I pointed out with v10. You
> are only able to address the first set of zones with this setup. As
> such you can end up missing large sections of memory if it is split
> over multiple nodes.
I think I did.
>
>> +static void init_hinting_wq(struct work_struct *work);
>> +static DEFINE_MUTEX(page_hinting_init);
>> +const struct page_hinting_config *page_hitning_conf;
>> +struct work_struct hinting_work;
>> +atomic_t page_hinting_active;
>> +
>> +void free_area_cleanup(int nr_zones)
>> +{
> I'm not sure why you are passing nr_zones as an argument here. Won't
> this always be MAX_NR_ZONES?
free_area_cleanup() gets called from page_hinting_disable() and
page_hinting_enable(). In page_hinting_enable() when the allocation
fails we may not have to perform cleanup for all the zones everytime.
>
>> +       int zone_idx;
>> +
>> +       for (zone_idx =3D 0; zone_idx < nr_zones; zone_idx++) {
>> +               bitmap_free(free_area[zone_idx].bitmap);
>> +               free_area[zone_idx].base_pfn =3D 0;
>> +               free_area[zone_idx].end_pfn =3D 0;
>> +               free_area[zone_idx].nbits =3D 0;
>> +               atomic_set(&free_area[zone_idx].free_pages, 0);
>> +       }
>> +}
>> +
>> +int page_hinting_enable(const struct page_hinting_config *conf)
>> +{
>> +       unsigned long bitmap_size =3D 0;
>> +       int zone_idx =3D 0, ret =3D -EBUSY;
>> +       struct zone *zone;
>> +
>> +       mutex_lock(&page_hinting_init);
>> +       if (!page_hitning_conf) {
>> +               for_each_populated_zone(zone) {
> So for_each_populated_zone will go through all of the NUMA nodes. So
> if I am not mistaken you will overwrite the free_area values of all
> the previous nodes with the last node in the system.
Not sure if I understood.
>  So if we have a
> setup that has all the memory in the first node, and none in the
> second it would effectively disable free page hinting would it not?
Why will it happen? The base_pfn will still be pointing to the base_pfn
of the first node. Isn't?
>
>> +                       zone_idx =3D zone_idx(zone);
>> +#ifdef CONFIG_ZONE_DEVICE
>> +                       if (zone_idx =3D=3D ZONE_DEVICE)
>> +                               continue;
>> +#endif
>> +                       spin_lock(&zone->lock);
>> +                       if (free_area[zone_idx].base_pfn) {
>> +                               free_area[zone_idx].base_pfn =3D
>> +                                       min(free_area[zone_idx].base_p=
fn,
>> +                                           zone->zone_start_pfn);
>> +                               free_area[zone_idx].end_pfn =3D
>> +                                       max(free_area[zone_idx].end_pf=
n,
>> +                                           zone->zone_start_pfn +
>> +                                           zone->spanned_pages);
>> +                       } else {
>> +                               free_area[zone_idx].base_pfn =3D
>> +                                       zone->zone_start_pfn;
>> +                               free_area[zone_idx].end_pfn =3D
>> +                                       zone->zone_start_pfn +
>> +                                       zone->spanned_pages;
>> +                       }
>> +                       spin_unlock(&zone->lock);
>> +               }
>> +
>> +               for (zone_idx =3D 0; zone_idx < MAX_NR_ZONES; zone_idx=
++) {
>> +                       unsigned long pages =3D free_area[zone_idx].en=
d_pfn -
>> +                                       free_area[zone_idx].base_pfn;
>> +                       bitmap_size =3D (pages >> PAGE_HINTING_MIN_ORD=
ER) + 1;
>> +                       if (!bitmap_size)
>> +                               continue;
>> +                       free_area[zone_idx].bitmap =3D bitmap_zalloc(b=
itmap_size,
>> +                                                                  GFP=
_KERNEL);
>> +                       if (!free_area[zone_idx].bitmap) {
>> +                               free_area_cleanup(zone_idx);
>> +                               mutex_unlock(&page_hinting_init);
>> +                               return -ENOMEM;
>> +                       }
>> +                       free_area[zone_idx].nbits =3D bitmap_size;
>> +               }
> So this is the bit that still needs to address hotplug right?=20
Yes, hotplug still needs to be addressed.
> I would
> imagine you need to reallocate this if the spanned_pages range changes
> correct?
>
>> +               page_hitning_conf =3D conf;
>> +               INIT_WORK(&hinting_work, init_hinting_wq);
>> +               ret =3D 0;
>> +       }
>> +       mutex_unlock(&page_hinting_init);
>> +       return ret;
>> +}
>> +EXPORT_SYMBOL_GPL(page_hinting_enable);
>> +
>> +void page_hinting_disable(void)
>> +{
>> +       cancel_work_sync(&hinting_work);
>> +       page_hitning_conf =3D NULL;
>> +       free_area_cleanup(MAX_NR_ZONES);
>> +}
>> +EXPORT_SYMBOL_GPL(page_hinting_disable);
>> +
>> +static unsigned long pfn_to_bit(struct page *page, int zone_idx)
>> +{
>> +       unsigned long bitnr;
>> +
>> +       bitnr =3D (page_to_pfn(page) - free_area[zone_idx].base_pfn)
>> +                        >> PAGE_HINTING_MIN_ORDER;
>> +       return bitnr;
>> +}
>> +
>> +static void release_buddy_pages(struct list_head *pages)
>> +{
>> +       int mt =3D 0, zone_idx, order;
>> +       struct page *page, *next;
>> +       unsigned long bitnr;
>> +       struct zone *zone;
>> +
>> +       list_for_each_entry_safe(page, next, pages, lru) {
>> +               zone_idx =3D page_zonenum(page);
>> +               zone =3D page_zone(page);
>> +               bitnr =3D pfn_to_bit(page, zone_idx);
>> +               spin_lock(&zone->lock);
>> +               list_del(&page->lru);
>> +               order =3D page_private(page);
>> +               set_page_private(page, 0);
>> +               mt =3D get_pageblock_migratetype(page);
>> +               __free_one_page(page, page_to_pfn(page), zone,
>> +                               order, mt, false);
>> +               spin_unlock(&zone->lock);
>> +       }
>> +}
>> +
>> +static void bm_set_pfn(struct page *page)
>> +{
>> +       struct zone *zone =3D page_zone(page);
>> +       int zone_idx =3D page_zonenum(page);
>> +       unsigned long bitnr =3D 0;
>> +
>> +       lockdep_assert_held(&zone->lock);
>> +       bitnr =3D pfn_to_bit(page, zone_idx);
>> +       /*
>> +        * TODO: fix possible underflows.
>> +        */
>> +       if (free_area[zone_idx].bitmap &&
>> +           bitnr < free_area[zone_idx].nbits &&
>> +           !test_and_set_bit(bitnr, free_area[zone_idx].bitmap))
>> +               atomic_inc(&free_area[zone_idx].free_pages);
>> +}
>> +
>> +static void scan_zone_free_area(int zone_idx, int free_pages)
>> +{
>> +       int ret =3D 0, order, isolated_cnt =3D 0;
>> +       unsigned long set_bit, start =3D 0;
>> +       LIST_HEAD(isolated_pages);
>> +       struct page *page;
>> +       struct zone *zone;
>> +
>> +       for (;;) {
>> +               ret =3D 0;
>> +               set_bit =3D find_next_bit(free_area[zone_idx].bitmap,
>> +                                       free_area[zone_idx].nbits, sta=
rt);
>> +               if (set_bit >=3D free_area[zone_idx].nbits)
>> +                       break;
>> +               page =3D pfn_to_online_page((set_bit << PAGE_HINTING_M=
IN_ORDER) +
>> +                               free_area[zone_idx].base_pfn);
>> +               if (!page)
>> +                       continue;
>> +               zone =3D page_zone(page);
>> +               spin_lock(&zone->lock);
>> +
>> +               if (PageBuddy(page) && page_private(page) >=3D
>> +                   PAGE_HINTING_MIN_ORDER) {
>> +                       order =3D page_private(page);
>> +                       ret =3D __isolate_free_page(page, order);
>> +               }
>> +               clear_bit(set_bit, free_area[zone_idx].bitmap);
>> +               atomic_dec(&free_area[zone_idx].free_pages);
>> +               spin_unlock(&zone->lock);
>> +               if (ret) {
>> +                       /*
>> +                        * restoring page order to use it while releas=
ing
>> +                        * the pages back to the buddy.
>> +                        */
>> +                       set_page_private(page, order);
>> +                       list_add_tail(&page->lru, &isolated_pages);
>> +                       isolated_cnt++;
>> +                       if (isolated_cnt =3D=3D page_hitning_conf->max=
_pages) {
>> +                               page_hitning_conf->hint_pages(&isolate=
d_pages);
>> +                               release_buddy_pages(&isolated_pages);
>> +                               isolated_cnt =3D 0;
>> +                       }
>> +               }
>> +               start =3D set_bit + 1;
>> +       }
>> +       if (isolated_cnt) {
>> +               page_hitning_conf->hint_pages(&isolated_pages);
>> +               release_buddy_pages(&isolated_pages);
>> +       }
>> +}
>> +
> I really worry that this loop is going to become more expensive as the
> size of memory increases. For example if we hint on just 16 pages we
> would have to walk something like 4K bits, 512 longs, if a system had
> 64G of memory. Have you considered testing with a larger memory
> footprint to see if it has an impact on performance?
I am hoping this will be noticeable in will-it-scale's page_fault1, if I
run it on a larger system?
>
>> +static void init_hinting_wq(struct work_struct *work)
>> +{
>> +       int zone_idx, free_pages;
>> +
>> +       atomic_set(&page_hinting_active, 1);
>> +       for (zone_idx =3D 0; zone_idx < MAX_NR_ZONES; zone_idx++) {
>> +               free_pages =3D atomic_read(&free_area[zone_idx].free_p=
ages);
>> +               if (free_pages >=3D page_hitning_conf->max_pages)
>> +                       scan_zone_free_area(zone_idx, free_pages);
>> +       }
>> +       atomic_set(&page_hinting_active, 0);
>> +}
>> +
>> +void page_hinting_enqueue(struct page *page, int order)
>> +{
>> +       int zone_idx;
>> +
>> +       if (!page_hitning_conf || order < PAGE_HINTING_MIN_ORDER)
>> +               return;
> I would think it is going to be expensive to be jumping into this
> function for every freed page. You should probably have an inline
> taking care of the order check before you even get here since it would
> be faster that way.
I see, I can take a look. Thanks.
>
>> +
>> +       bm_set_pfn(page);
>> +       if (atomic_read(&page_hinting_active))
>> +               return;
> So I would think this piece is racy. Specifically if you set a PFN
> that is somewhere below the PFN you are currently processing in your
> scan it is going to remain unset until you have another page freed
> after the scan is completed. I would worry you can end up with a batch
> free of memory resulting in a group of pages sitting at the start of
> your bitmap unhinted.
True, but that will be hinted next time threshold is met.
>
> In my patches I resolved this by looping through all of the zones,
> however your approach is missing the necessary pieces to make that
> safe as you could end up in a soft lockup with the scanning thread
> spinning on a noisy system.
>
>> +       zone_idx =3D zone_idx(page_zone(page));
>> +       if (atomic_read(&free_area[zone_idx].free_pages) >=3D
>> +                       page_hitning_conf->max_pages) {
>> +               int cpu =3D smp_processor_id();
>> +
>> +               queue_work_on(cpu, system_wq, &hinting_work);
>> +       }
>> +}
--=20
Thanks
Nitesh


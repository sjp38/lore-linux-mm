Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40187C742A2
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 01:13:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EADAE214AF
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 01:13:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EADAE214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9728F8E010C; Thu, 11 Jul 2019 21:13:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FC458E00DB; Thu, 11 Jul 2019 21:13:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7269F8E010C; Thu, 11 Jul 2019 21:13:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9F18E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 21:13:08 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x7so5566731qtp.15
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 18:13:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=j6L95OkmQQKt0N2hrLZtfIfyX02PTxzPTg7TYGeWWE0=;
        b=EThJc7NOJJqcbOoiw0gEMn8C4el6Tt92g1Yljlu9yAk4buBFmXPRnPDJ2IMi2GdQgV
         cYz0wNp/nibaANc7G9yj3kMSsPthQE+qShlF6tUXDH2l7tIzonPhcBnf4STQSyjZCeCO
         qkGcsUOs+DYM+EBr056h4wmU/zh3E6MiCy0lrnRm/WCru30PJ8bG73Dg1m6Q50aFpgBP
         OiHXALLUaoKWvr+wQgfUAH8lzpIj5ea2EBPjWB68UbcHy2Vdt7bSiDm9womofzdeFLEA
         tcTi1u1CZXTlid+lI39j+Hr6EcJIwGsOhVFECAKVktMFqa6RuX4UWX7gCUijAey7fFIt
         nhvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAViSn6UNs3AL3Ldp3LTn7wChp8m2OMHVVBYeS4FfywK0K8hiaD2
	KLGc70tl3G3XRmCqPqM/Fvc4Dkz6Q7dyIgnLyyyiwYiBgdxw1ZXOHD2awpkw7zxPklmxGd80MCz
	6UIrlLIHmQ47aPVImz27UWLePgkF5kvB+Ur5sei9wAWM2HQwOLi2iMIJ5sWvVU4hgXQ==
X-Received: by 2002:ac8:1418:: with SMTP id k24mr4043507qtj.54.1562893987972;
        Thu, 11 Jul 2019 18:13:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqvR/yy6bfzAUiVTUfnilzkOJC/x1vB5CMpKxDvytkx6PnHNwEdbwRXfJtx07XhaJNF3iC
X-Received: by 2002:ac8:1418:: with SMTP id k24mr4043463qtj.54.1562893986752;
        Thu, 11 Jul 2019 18:13:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562893986; cv=none;
        d=google.com; s=arc-20160816;
        b=UCq5L3IpIesIKP8nnEsv2HJBdqewVzIION3jREMRJRGF50KRck1+wSANPZB8VfZuv8
         USSf1KQRFTtjvUD7C0silru+fxZdQg2BhV3xtbzrjIUUmKYoDjx1BeBRVTsdef/sriGH
         ULIyZl1GoHbXV3pOyP0c8ksIWweYDrcOJ/PMjAHTr/5zKIoR59t2+mxvkbKajPe9AJoD
         UfyS1dVI9g6i03geSHFtle0omIXATjkKaG0DiAwb3m5tMDea2Y/JfVPU9xAw0BUFo+q+
         wwq81/TURUsdHiTUD21sSsfjnOJiZIYMe6Air85VWgbWshcxvRySBvzGYHz4d2d85UOY
         WJ9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=j6L95OkmQQKt0N2hrLZtfIfyX02PTxzPTg7TYGeWWE0=;
        b=wOyE/WJcP9LYkOCreT1YTNd+wneQGhw9lViw7c8eY3iiY7Ry0liqi1pYOeTwqzwyvU
         8Ek8MfxrHAK7qNpO+wSoFClYyx8cEWKFSk+7ELTRYhleHbB5T5VZ3zvIstHW7+soHiaV
         HogMETWM0wx3wP1K1GSS7ztOTcbiK2C+nLSqK4AvnwUelxRV8UuYb7IP42SM/GUzEG5Z
         ZDkr6A5kUE/EaEjCuCrq2rmI0twOeos2JM6jjKcPb6XwBTEdMP4UGCgFuye+q26Gxqfv
         xiv/NmCkJDLiCoRubcdZDkaG6VrWl6X9mvoBRa4+VUKaR0/8jGLws75OvSsp2y/YAgWG
         Dfuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m39si4349996qvh.124.2019.07.11.18.13.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 18:13:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CD29C307D92F;
	Fri, 12 Jul 2019 01:13:05 +0000 (UTC)
Received: from [10.40.204.17] (ovpn-204-17.brq.redhat.com [10.40.204.17])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 115605C207;
	Fri, 12 Jul 2019 01:12:49 +0000 (UTC)
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
 <3c6c6b93-eb21-a04c-d0db-6f1b134540db@redhat.com>
 <CAKgT0UcaKhAf+pTeE1CRxqhiPtR2ipkYZZ2+aChetV7=LDeSeA@mail.gmail.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <521db934-3acd-5287-6e75-67feead8ca63@redhat.com>
Date: Thu, 11 Jul 2019 21:12:45 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAKgT0UcaKhAf+pTeE1CRxqhiPtR2ipkYZZ2+aChetV7=LDeSeA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Fri, 12 Jul 2019 01:13:06 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/11/19 7:20 PM, Alexander Duyck wrote:
> On Thu, Jul 11, 2019 at 10:58 AM Nitesh Narayan Lal <nitesh@redhat.com>=
 wrote:
>>
>> On 7/10/19 5:56 PM, Alexander Duyck wrote:
>>> On Wed, Jul 10, 2019 at 12:52 PM Nitesh Narayan Lal <nitesh@redhat.co=
m> wrote:
>>>> This patch introduces the core infrastructure for free page hinting =
in
>>>> virtual environments. It enables the kernel to track the free pages =
which
>>>> can be reported to its hypervisor so that the hypervisor could
>>>> free and reuse that memory as per its requirement.
>>>>
>>>> While the pages are getting processed in the hypervisor (e.g.,
>>>> via MADV_FREE), the guest must not use them, otherwise, data loss
>>>> would be possible. To avoid such a situation, these pages are
>>>> temporarily removed from the buddy. The amount of pages removed
>>>> temporarily from the buddy is governed by the backend(virtio-balloon=

>>>> in our case).
>>>>
>>>> To efficiently identify free pages that can to be hinted to the
>>>> hypervisor, bitmaps in a coarse granularity are used. Only fairly bi=
g
>>>> chunks are reported to the hypervisor - especially, to not break up =
THP
>>>> in the hypervisor - "MAX_ORDER - 2" on x86, and to save space. The b=
its
>>>> in the bitmap are an indication whether a page *might* be free, not =
a
>>>> guarantee. A new hook after buddy merging sets the bits.
>>>>
>>>> Bitmaps are stored per zone, protected by the zone lock. A workqueue=

>>>> asynchronously processes the bitmaps, trying to isolate and report p=
ages
>>>> that are still free. The backend (virtio-balloon) is responsible for=

>>>> reporting these batched pages to the host synchronously. Once report=
ing/
>>>> freeing is complete, isolated pages are returned back to the buddy.
>>>>
>>>> There are still various things to look into (e.g., memory hotplug, m=
ore
>>>> efficient locking, possible races when disabling).
>>>>
>>>> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
> So just FYI, I thought I would try the patches. It looks like there
> might be a bug somewhere that is causing it to free memory it
> shouldn't be. After about 10 minutes my VM crashed with a system log
> full of various NULL pointer dereferences.

That's interesting, I have tried the patches with MADV_DONTNEED as well.
I just retried it but didn't see any crash. May I know what kind of
workload you are running?

>  The only change I had made
> is to use MADV_DONTNEED instead of MADV_FREE in QEMU since my headers
> didn't have MADV_FREE on the host. It occurs to me one advantage of
> MADV_DONTNEED over MADV_FREE is that you are more likely to catch
> these sort of errors since it zeros the pages instead of leaving them
> intact.
For development purpose maybe. For the final patch-set I think we
discussed earlier why we should keep MADV_FREE.
>
>>>> ---
>>>>  include/linux/page_hinting.h |  45 +++++++
>>>>  mm/Kconfig                   |   6 +
>>>>  mm/Makefile                  |   1 +
>>>>  mm/page_alloc.c              |  18 +--
>>>>  mm/page_hinting.c            | 250 ++++++++++++++++++++++++++++++++=
+++
>>>>  5 files changed, 312 insertions(+), 8 deletions(-)
>>>>  create mode 100644 include/linux/page_hinting.h
>>>>  create mode 100644 mm/page_hinting.c
>>>>
>>>> diff --git a/include/linux/page_hinting.h b/include/linux/page_hinti=
ng.h
>>>> new file mode 100644
>>>> index 000000000000..4900feb796f9
>>>> --- /dev/null
>>>> +++ b/include/linux/page_hinting.h
>>>> @@ -0,0 +1,45 @@
>>>> +/* SPDX-License-Identifier: GPL-2.0 */
>>>> +#ifndef _LINUX_PAGE_HINTING_H
>>>> +#define _LINUX_PAGE_HINTING_H
>>>> +
>>>> +/*
>>>> + * Minimum page order required for a page to be hinted to the host.=

>>>> + */
>>>> +#define PAGE_HINTING_MIN_ORDER         (MAX_ORDER - 2)
>>>> +
>>> Why use (MAX_ORDER - 2)? Is this just because of the issues I pointed=

>>> out earlier for is it due to something else? I'm just wondering if
>>> this will have an impact on architectures outside of x86 as I had
>>> chose pageblock_order which happened to be MAX_ORDER - 2 on x86, but =
I
>>> don't know that the impact of doing that is on other architectures
>>> versus the (MAX_ORDER - 2) approach you took here.
>> If I am not wrong then any order  < (MAX_ORDER - 2) will break the THP=
=2E
>> That's one reason we decided to stick with this.
> That is true for x86, but I don't think that is true for other
> architectures. That is why I went with pageblock_order instead of just
> using a fixed value such as MAX_ORDER - 2.
I see, I will have to check this.
>
> <snip>
>
>>>> diff --git a/mm/page_hinting.c b/mm/page_hinting.c
>>>> new file mode 100644
>>>> index 000000000000..0bfa09f8c3ed
>>>> --- /dev/null
>>>> +++ b/mm/page_hinting.c
>>>> @@ -0,0 +1,250 @@
>>>> +// SPDX-License-Identifier: GPL-2.0
>>>> +/*
>>>> + * Page hinting core infrastructure to enable a VM to report free p=
ages to its
>>>> + * hypervisor.
>>>> + *
>>>> + * Copyright Red Hat, Inc. 2019
>>>> + *
>>>> + * Author(s): Nitesh Narayan Lal <nitesh@redhat.com>
>>>> + */
>>>> +
>>>> +#include <linux/mm.h>
>>>> +#include <linux/slab.h>
>>>> +#include <linux/page_hinting.h>
>>>> +#include <linux/kvm_host.h>
>>>> +
>>>> +/*
>>>> + * struct zone_free_area: For a single zone across NUMA nodes, it h=
olds the
>>>> + * bitmap pointer to track the free pages and other required parame=
ters
>>>> + * used to recover these pages by scanning the bitmap.
>>>> + * @bitmap:            Pointer to the bitmap in PAGE_HINTING_MIN_OR=
DER
>>>> + *                     granularity.
>>>> + * @base_pfn:          Starting PFN value for the zone whose bitmap=
 is stored.
>>>> + * @end_pfn:           Indicates the last PFN value for the zone.
>>>> + * @free_pages:                Tracks the number of free pages of g=
ranularity
>>>> + *                     PAGE_HINTING_MIN_ORDER.
>>>> + * @nbits:             Indicates the total size of the bitmap in bi=
ts allocated
>>>> + *                     at the time of initialization.
>>>> + */
>>>> +struct zone_free_area {
>>>> +       unsigned long *bitmap;
>>>> +       unsigned long base_pfn;
>>>> +       unsigned long end_pfn;
>>>> +       atomic_t free_pages;
>>>> +       unsigned long nbits;
>>>> +} free_area[MAX_NR_ZONES];
>>>> +
>>> You still haven't addressed the NUMA issue I pointed out with v10. Yo=
u
>>> are only able to address the first set of zones with this setup. As
>>> such you can end up missing large sections of memory if it is split
>>> over multiple nodes.
>> I think I did.
> I just realized what you did. Actually this doesn't really improve
> things in my opinion. More comments below.
>
>>>> +static void init_hinting_wq(struct work_struct *work);
>>>> +static DEFINE_MUTEX(page_hinting_init);
>>>> +const struct page_hinting_config *page_hitning_conf;
>>>> +struct work_struct hinting_work;
>>>> +atomic_t page_hinting_active;
>>>> +
>>>> +void free_area_cleanup(int nr_zones)
>>>> +{
>>> I'm not sure why you are passing nr_zones as an argument here. Won't
>>> this always be MAX_NR_ZONES?
>> free_area_cleanup() gets called from page_hinting_disable() and
>> page_hinting_enable(). In page_hinting_enable() when the allocation
>> fails we may not have to perform cleanup for all the zones everytime.
> Just adding a NULL pointer check to this loop below would still keep
> it pretty cheap as the cost for initializing memory to 0 isn't that
> high, and this is slow path anyway. Either way I guess it works.=20
Yeah.
> You
> might want to reset the bitmap pointer to NULL though after you free
> it to more easily catch the double free case.
I think resetting the bitmap pointer to NULL is a good idea. Thanks.
>
>>>> +       int zone_idx;
>>>> +
>>>> +       for (zone_idx =3D 0; zone_idx < nr_zones; zone_idx++) {
>>>> +               bitmap_free(free_area[zone_idx].bitmap);
>>>> +               free_area[zone_idx].base_pfn =3D 0;
>>>> +               free_area[zone_idx].end_pfn =3D 0;
>>>> +               free_area[zone_idx].nbits =3D 0;
>>>> +               atomic_set(&free_area[zone_idx].free_pages, 0);
>>>> +       }
>>>> +}
>>>> +
>>>> +int page_hinting_enable(const struct page_hinting_config *conf)
>>>> +{
>>>> +       unsigned long bitmap_size =3D 0;
>>>> +       int zone_idx =3D 0, ret =3D -EBUSY;
>>>> +       struct zone *zone;
>>>> +
>>>> +       mutex_lock(&page_hinting_init);
>>>> +       if (!page_hitning_conf) {
>>>> +               for_each_populated_zone(zone) {
>>> So for_each_populated_zone will go through all of the NUMA nodes. So
>>> if I am not mistaken you will overwrite the free_area values of all
>>> the previous nodes with the last node in the system.
>> Not sure if I understood.
> I misread the code. More comments below.
>
>>>  So if we have a
>>> setup that has all the memory in the first node, and none in the
>>> second it would effectively disable free page hinting would it not?
>> Why will it happen? The base_pfn will still be pointing to the base_pf=
n
>> of the first node. Isn't?
> So this does address my concern however, it introduces a new issue.
> Specifically you could end up introducing a gap of unused bits if the
> memory from one zone is not immediately adjacent to another. This gets
> back to the SPARSEMEM issue that I think Dave pointed out.
Yeah, he did point it out. It looks a valid issue, I will look into it.
>
>
> <snip>
>
>>>> +static void scan_zone_free_area(int zone_idx, int free_pages)
>>>> +{
>>>> +       int ret =3D 0, order, isolated_cnt =3D 0;
>>>> +       unsigned long set_bit, start =3D 0;
>>>> +       LIST_HEAD(isolated_pages);
>>>> +       struct page *page;
>>>> +       struct zone *zone;
>>>> +
>>>> +       for (;;) {
>>>> +               ret =3D 0;
>>>> +               set_bit =3D find_next_bit(free_area[zone_idx].bitmap=
,
>>>> +                                       free_area[zone_idx].nbits, s=
tart);
>>>> +               if (set_bit >=3D free_area[zone_idx].nbits)
>>>> +                       break;
>>>> +               page =3D pfn_to_online_page((set_bit << PAGE_HINTING=
_MIN_ORDER) +
>>>> +                               free_area[zone_idx].base_pfn);
>>>> +               if (!page)
>>>> +                       continue;
>>>> +               zone =3D page_zone(page);
>>>> +               spin_lock(&zone->lock);
>>>> +
>>>> +               if (PageBuddy(page) && page_private(page) >=3D
>>>> +                   PAGE_HINTING_MIN_ORDER) {
>>>> +                       order =3D page_private(page);
>>>> +                       ret =3D __isolate_free_page(page, order);
>>>> +               }
>>>> +               clear_bit(set_bit, free_area[zone_idx].bitmap);
>>>> +               atomic_dec(&free_area[zone_idx].free_pages);
>>>> +               spin_unlock(&zone->lock);
>>>> +               if (ret) {
>>>> +                       /*
>>>> +                        * restoring page order to use it while rele=
asing
>>>> +                        * the pages back to the buddy.
>>>> +                        */
>>>> +                       set_page_private(page, order);
>>>> +                       list_add_tail(&page->lru, &isolated_pages);
>>>> +                       isolated_cnt++;
>>>> +                       if (isolated_cnt =3D=3D page_hitning_conf->m=
ax_pages) {
>>>> +                               page_hitning_conf->hint_pages(&isola=
ted_pages);
>>>> +                               release_buddy_pages(&isolated_pages)=
;
>>>> +                               isolated_cnt =3D 0;
>>>> +                       }
>>>> +               }
>>>> +               start =3D set_bit + 1;
>>>> +       }
>>>> +       if (isolated_cnt) {
>>>> +               page_hitning_conf->hint_pages(&isolated_pages);
>>>> +               release_buddy_pages(&isolated_pages);
>>>> +       }
>>>> +}
>>>> +
>>> I really worry that this loop is going to become more expensive as th=
e
>>> size of memory increases. For example if we hint on just 16 pages we
>>> would have to walk something like 4K bits, 512 longs, if a system had=

>>> 64G of memory. Have you considered testing with a larger memory
>>> footprint to see if it has an impact on performance?
>> I am hoping this will be noticeable in will-it-scale's page_fault1, if=
 I
>> run it on a larger system?
> What you will probably see is that the CPU that is running the scan is
> going to be sitting at somewhere near 100% because I cannot see how it
> can hope to stay efficient if it has to check something like 512 64b
> longs searching for just a handful of idle pages.
>
>>>> +static void init_hinting_wq(struct work_struct *work)
>>>> +{
>>>> +       int zone_idx, free_pages;
>>>> +
>>>> +       atomic_set(&page_hinting_active, 1);
>>>> +       for (zone_idx =3D 0; zone_idx < MAX_NR_ZONES; zone_idx++) {
>>>> +               free_pages =3D atomic_read(&free_area[zone_idx].free=
_pages);
>>>> +               if (free_pages >=3D page_hitning_conf->max_pages)
>>>> +                       scan_zone_free_area(zone_idx, free_pages);
>>>> +       }
>>>> +       atomic_set(&page_hinting_active, 0);
>>>> +}
>>>> +
>>>> +void page_hinting_enqueue(struct page *page, int order)
>>>> +{
>>>> +       int zone_idx;
>>>> +
>>>> +       if (!page_hitning_conf || order < PAGE_HINTING_MIN_ORDER)
>>>> +               return;
>>> I would think it is going to be expensive to be jumping into this
>>> function for every freed page. You should probably have an inline
>>> taking care of the order check before you even get here since it woul=
d
>>> be faster that way.
>> I see, I can take a look. Thanks.
>>>> +
>>>> +       bm_set_pfn(page);
>>>> +       if (atomic_read(&page_hinting_active))
>>>> +               return;
>>> So I would think this piece is racy. Specifically if you set a PFN
>>> that is somewhere below the PFN you are currently processing in your
>>> scan it is going to remain unset until you have another page freed
>>> after the scan is completed. I would worry you can end up with a batc=
h
>>> free of memory resulting in a group of pages sitting at the start of
>>> your bitmap unhinted.
>> True, but that will be hinted next time threshold is met.
> Yes, but that assumes that there is another free immediately coming.
> It is possible that you have a big application run and then
> immediately shut down and have it free all its memory at once. Worst
> case scenario would be that it starts by freeing from the end and
> works toward the start. With that you could theoretically end up with
> a significant chunk of memory waiting some time for another big free
> to come along.

Any suggestion on some benchmark/test application which I could run to
see this kind of behavior?

--=20
Thanks
Nitesh


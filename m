Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67987C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 19:23:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0731120449
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 19:23:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0731120449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4E5F8E0003; Thu,  7 Mar 2019 14:23:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FE278E0002; Thu,  7 Mar 2019 14:23:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 877DE8E0003; Thu,  7 Mar 2019 14:23:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5609D8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 14:23:30 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id g42so272357qtb.20
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 11:23:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to;
        bh=lD/RdAUQnjTYa2cT8ZPnIaQqKXS2T9SbJwinxhE6q88=;
        b=aK9QKiP6GwYFx6HM7olQ8e54t75b4QGrzRHdvz1b6OZ/FRUhnKl7rU2pPTBBa9Qj5r
         QpNop0g7KaJXbOSLcUIl4k0J7Copk0YuZMMeCbY5bdpCiF2pnUn6t5Cgl2ag5D/VgPn/
         9/SkJ42UMdjqBLczNlHiY18BZh6z4PGowsLfuaLs4xlBNnZEz/2isD2rTb2uBieh/XPw
         2/F8Vm1ECQihxfznYOPsBXEsXH/YrRhsLevsNePEX00NxizvcovyjvDeCLws4XugHb5u
         0uCnPutxAHVLfI9fnjUW3Ite9145jnAxlIGpb6TCXzl0KuehX+V1+R8vLi0dVbzNNkgD
         wXvg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV1ZptJlK1zNeQZHRXdMpK55CfKUOdYU0b7ZpPPvClQKqU2sPXM
	WuyA5wG/pDmap90yC3xmXv9RjBDcr3HadZR8V/c+D0ro4Qmbb3dck667DMWESgqqH4u6v/dmUvR
	LkAzWsb3xP2ZC34Cs6Sun5OYRi/koQ26W7WxP4IOgImfkR7W7MUZ3XNqdI/T5h6GlwQ==
X-Received: by 2002:ac8:1497:: with SMTP id l23mr11468232qtj.296.1551986610036;
        Thu, 07 Mar 2019 11:23:30 -0800 (PST)
X-Google-Smtp-Source: APXvYqx7eF7H4/HvECn1BO55SVyZkmItUIbP3VxcxzRaf6xnoGJU7sXjiyN2tpPzEUeAzjRbWH3G
X-Received: by 2002:ac8:1497:: with SMTP id l23mr11468148qtj.296.1551986608942;
        Thu, 07 Mar 2019 11:23:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551986608; cv=none;
        d=google.com; s=arc-20160816;
        b=zjnPnf+rTDx5h/3MWUgVcz0L70Tn0UKpX3A8ox1UxUOSsOYvaI0hgodZhB/i2tu0SG
         pssMlqIp6ptcAD5eXAmig78wJei5lCDGl1L9AnHRQKb8EAqWqNAm/5OyI/wWUKwWhFFn
         p/WcdiUuoLZyO0Av+NniW3wMF9azAAcMfOk7YgyND/BO7AgladL5WKmbexicirB98W++
         hUa0kauGLxZQeflzhGLd/6EoNOdL7ieIRRFGcTxj+eIuoNHrxw/0q6fM13mlbkI78B8/
         +xEZ+HP0siFZ5kq4ig01LU3GM6OOnQTXaCa3nH66Ni/JwrXWkMrRX6fm8pneHl6mjUOM
         AMwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :autocrypt:openpgp:from:references:cc:to:subject;
        bh=lD/RdAUQnjTYa2cT8ZPnIaQqKXS2T9SbJwinxhE6q88=;
        b=sPBLiiGOCPllftx9SfwKSlRmtDtogcVuG9W4zmsdlRSVAPDc2pNRg++ruPq+ooAZOr
         bG2XNqEXOyFxIl8L17BMgeKRcQhhtxl31wB1T4T3BWEGvEaEy3kBFaawBuxTVaL/cm8T
         UrvEa5cYYHYs+2oPnXXDt+LJYKNqskUXYKuAiGs+fvZDtjdHlnxrxYErDAYd1N4yoxk7
         H5zAPVxL2b0+QV+0YhHN0zkOrLjOlpWBf4vwWg2vNDeN+80nGled//d14i2s018LeuzT
         yvUGPnexUIk2grSLSOZY3EHiClFZbTa6y65+o0dceh/EEGn8ZumQkwy3943IeHAg64Ea
         KZIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g17si852347qtg.23.2019.03.07.11.23.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 11:23:28 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EC5F23001952;
	Thu,  7 Mar 2019 19:23:27 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 35F171001DD8;
	Thu,  7 Mar 2019 19:23:19 +0000 (UTC)
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free
 pages
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306155048.12868-3-nitesh@redhat.com>
 <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com>
Date: Thu, 7 Mar 2019 14:23:18 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="LRRsTmOUFCNMKmyP7qPLy2b0ygzL5O5at"
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Thu, 07 Mar 2019 19:23:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--LRRsTmOUFCNMKmyP7qPLy2b0ygzL5O5at
Content-Type: multipart/mixed; boundary="zmr2OPVqRHdEf7yjlMKc5SZzYYfvPGbhQ";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
Message-ID: <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com>
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free
 pages
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306155048.12868-3-nitesh@redhat.com>
 <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
In-Reply-To: <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>

--zmr2OPVqRHdEf7yjlMKc5SZzYYfvPGbhQ
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US


On 3/7/19 1:30 PM, Alexander Duyck wrote:
> On Wed, Mar 6, 2019 at 7:51 AM Nitesh Narayan Lal <nitesh@redhat.com> w=
rote:
>> This patch enables the kernel to scan the per cpu array
>> which carries head pages from the buddy free list of order
>> FREE_PAGE_HINTING_MIN_ORDER (MAX_ORDER - 1) by
>> guest_free_page_hinting().
>> guest_free_page_hinting() scans the entire per cpu array by
>> acquiring a zone lock corresponding to the pages which are
>> being scanned. If the page is still free and present in the
>> buddy it tries to isolate the page and adds it to a
>> dynamically allocated array.
>>
>> Once this scanning process is complete and if there are any
>> isolated pages added to the dynamically allocated array
>> guest_free_page_report() is invoked. However, before this the
>> per-cpu array index is reset so that it can continue capturing
>> the pages from buddy free list.
>>
>> In this patch guest_free_page_report() simply releases the pages back
>> to the buddy by using __free_one_page()
>>
>> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
> I'm pretty sure this code is not thread safe and has a few various issu=
es.
>
>> ---
>>  include/linux/page_hinting.h |   5 ++
>>  mm/page_alloc.c              |   2 +-
>>  virt/kvm/page_hinting.c      | 154 ++++++++++++++++++++++++++++++++++=
+
>>  3 files changed, 160 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/page_hinting.h b/include/linux/page_hinting=
=2Eh
>> index 90254c582789..d554a2581826 100644
>> --- a/include/linux/page_hinting.h
>> +++ b/include/linux/page_hinting.h
>> @@ -13,3 +13,8 @@
>>
>>  void guest_free_page_enqueue(struct page *page, int order);
>>  void guest_free_page_try_hinting(void);
>> +extern int __isolate_free_page(struct page *page, unsigned int order)=
;
>> +extern void __free_one_page(struct page *page, unsigned long pfn,
>> +                           struct zone *zone, unsigned int order,
>> +                           int migratetype);
>> +void release_buddy_pages(void *obj_to_free, int entries);
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 684d047f33ee..d38b7eea207b 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -814,7 +814,7 @@ static inline int page_is_buddy(struct page *page,=
 struct page *buddy,
>>   * -- nyc
>>   */
>>
>> -static inline void __free_one_page(struct page *page,
>> +inline void __free_one_page(struct page *page,
>>                 unsigned long pfn,
>>                 struct zone *zone, unsigned int order,
>>                 int migratetype)
>> diff --git a/virt/kvm/page_hinting.c b/virt/kvm/page_hinting.c
>> index 48b4b5e796b0..9885b372b5a9 100644
>> --- a/virt/kvm/page_hinting.c
>> +++ b/virt/kvm/page_hinting.c
>> @@ -1,5 +1,9 @@
>>  #include <linux/mm.h>
>>  #include <linux/page_hinting.h>
>> +#include <linux/page_ref.h>
>> +#include <linux/kvm_host.h>
>> +#include <linux/kernel.h>
>> +#include <linux/sort.h>
>>
>>  /*
>>   * struct guest_free_pages- holds array of guest freed PFN's along wi=
th an
>> @@ -16,6 +20,54 @@ struct guest_free_pages {
>>
>>  DEFINE_PER_CPU(struct guest_free_pages, free_pages_obj);
>>
>> +/*
>> + * struct guest_isolated_pages- holds the buddy isolated pages which =
are
>> + * supposed to be freed by the host.
>> + * @pfn: page frame number for the isolated page.
>> + * @order: order of the isolated page.
>> + */
>> +struct guest_isolated_pages {
>> +       unsigned long pfn;
>> +       unsigned int order;
>> +};
>> +
>> +void release_buddy_pages(void *obj_to_free, int entries)
>> +{
>> +       int i =3D 0;
>> +       int mt =3D 0;
>> +       struct guest_isolated_pages *isolated_pages_obj =3D obj_to_fre=
e;
>> +
>> +       while (i < entries) {
>> +               struct page *page =3D pfn_to_page(isolated_pages_obj[i=
].pfn);
>> +
>> +               mt =3D get_pageblock_migratetype(page);
>> +               __free_one_page(page, page_to_pfn(page), page_zone(pag=
e),
>> +                               isolated_pages_obj[i].order, mt);
>> +               i++;
>> +       }
>> +       kfree(isolated_pages_obj);
>> +}
> You shouldn't be accessing __free_one_page without holding the zone
> lock for the page. You might consider confining yourself to one zone
> worth of hints at a time. Then you can acquire the lock once, and then
> return the memory you have freed.
That is correct.
>
> This is one of the reasons why I am thinking maybe a bit in the page
> and then spinning on that bit in arch_alloc_page might be a nice way
> to get around this. Then you only have to take the zone lock when you
> are finding the pages you want to hint on and setting the bit
> indicating they are mid hint. Otherwise you have to take the zone lock
> to pull pages out, and to put them back in and the likelihood of a
> lock collision is much higher.
Do you think adding a new flag to the page structure will be acceptable?
>
>> +
>> +void guest_free_page_report(struct guest_isolated_pages *isolated_pag=
es_obj,
>> +                           int entries)
>> +{
>> +       release_buddy_pages(isolated_pages_obj, entries);
>> +}
>> +
>> +static int sort_zonenum(const void *a1, const void *b1)
>> +{
>> +       const unsigned long *a =3D a1;
>> +       const unsigned long *b =3D b1;
>> +
>> +       if (page_zonenum(pfn_to_page(a[0])) > page_zonenum(pfn_to_page=
(b[0])))
>> +               return 1;
>> +
>> +       if (page_zonenum(pfn_to_page(a[0])) < page_zonenum(pfn_to_page=
(b[0])))
>> +               return -1;
>> +
>> +       return 0;
>> +}
>> +
>>  struct page *get_buddy_page(struct page *page)
>>  {
>>         unsigned long pfn =3D page_to_pfn(page);
>> @@ -33,9 +85,111 @@ struct page *get_buddy_page(struct page *page)
>>  static void guest_free_page_hinting(void)
>>  {
>>         struct guest_free_pages *hinting_obj =3D &get_cpu_var(free_pag=
es_obj);
>> +       struct guest_isolated_pages *isolated_pages_obj;
>> +       int idx =3D 0, ret =3D 0;
>> +       struct zone *zone_cur, *zone_prev;
>> +       unsigned long flags =3D 0;
>> +       int hyp_idx =3D 0;
>> +       int free_pages_idx =3D hinting_obj->free_pages_idx;
>> +
>> +       isolated_pages_obj =3D kmalloc(MAX_FGPT_ENTRIES *
>> +                       sizeof(struct guest_isolated_pages), GFP_KERNE=
L);
>> +       if (!isolated_pages_obj) {
>> +               hinting_obj->free_pages_idx =3D 0;
>> +               put_cpu_var(hinting_obj);
>> +               return;
>> +               /* return some logical error here*/
>> +       }
>> +
>> +       sort(hinting_obj->free_page_arr, free_pages_idx,
>> +            sizeof(unsigned long), sort_zonenum, NULL);
>> +
>> +       while (idx < free_pages_idx) {
>> +               unsigned long pfn =3D hinting_obj->free_page_arr[idx];=

>> +               unsigned long pfn_end =3D hinting_obj->free_page_arr[i=
dx] +
>> +                       (1 << FREE_PAGE_HINTING_MIN_ORDER) - 1;
>> +
>> +               zone_cur =3D page_zone(pfn_to_page(pfn));
>> +               if (idx =3D=3D 0) {
>> +                       zone_prev =3D zone_cur;
>> +                       spin_lock_irqsave(&zone_cur->lock, flags);
>> +               } else if (zone_prev !=3D zone_cur) {
>> +                       spin_unlock_irqrestore(&zone_prev->lock, flags=
);
>> +                       spin_lock_irqsave(&zone_cur->lock, flags);
>> +                       zone_prev =3D zone_cur;
>> +               }
>> +
>> +               while (pfn <=3D pfn_end) {
>> +                       struct page *page =3D pfn_to_page(pfn);
>> +                       struct page *buddy_page =3D NULL;
>> +
>> +                       if (PageCompound(page)) {
>> +                               struct page *head_page =3D compound_he=
ad(page);
>> +                               unsigned long head_pfn =3D page_to_pfn=
(head_page);
>> +                               unsigned int alloc_pages =3D
>> +                                       1 << compound_order(head_page)=
;
>> +
>> +                               pfn =3D head_pfn + alloc_pages;
>> +                               continue;
>> +                       }
>> +
> I don't think the buddy allocator has compound pages.
Yes, I don't need this.
>
>> +                       if (page_ref_count(page)) {
>> +                               pfn++;
>> +                               continue;
>> +                       }
>> +
> A ref count of 0 doesn't mean the page isn't in use. It could be in
> use by something such as SLUB for instance.
Yes but it is not the criteria by which we are isolating.

If PageBuddy() is returning true then only we actually try and isolate.

I can possibly remove the compound and page_ref_count() checks.

>
>> +                       if (PageBuddy(page) && page_private(page) >=3D=

>> +                           FREE_PAGE_HINTING_MIN_ORDER) {
>> +                               int buddy_order =3D page_private(page)=
;
>> +
>> +                               ret =3D __isolate_free_page(page, budd=
y_order);
>> +                               if (ret) {
>> +                                       isolated_pages_obj[hyp_idx].pf=
n =3D pfn;
>> +                                       isolated_pages_obj[hyp_idx].or=
der =3D
>> +                                                               buddy_=
order;
>> +                                       hyp_idx +=3D 1;
>> +                               }
>> +                               pfn =3D pfn + (1 << buddy_order);
>> +                               continue;
>> +                       }
>> +
> So this is where things start to get ugly. Basically because we were
> acquiring the hints when they were freed we end up needing to check
> either this page, and the PFN for all of the higher order pages this
> page could be a part of. Since we are currently limiting ourselves to
> MAX_ORDER - 1 it shouldn't be too expensive. I don't recall if your
> get_buddy_page already had that limitation coded in but we should
> probably look at doing that there.=20
Do you mean the check for page order?
> Then we can just skip the PageBuddy
> check up here and have it automatically start walking all pages your
> original page could be a part of looking for the highest page order
> that might still be free.
>
>> +                       buddy_page =3D get_buddy_page(page);
>> +                       if (buddy_page && page_private(buddy_page) >=3D=

>> +                           FREE_PAGE_HINTING_MIN_ORDER) {
>> +                               int buddy_order =3D page_private(buddy=
_page);
>> +
>> +                               ret =3D __isolate_free_page(buddy_page=
,
>> +                                                         buddy_order)=
;
>> +                               if (ret) {
>> +                                       unsigned long buddy_pfn =3D
>> +                                               page_to_pfn(buddy_page=
);
>> +
>> +                                       isolated_pages_obj[hyp_idx].pf=
n =3D
>> +                                                               buddy_=
pfn;
>> +                                       isolated_pages_obj[hyp_idx].or=
der =3D
>> +                                                               buddy_=
order;
>> +                                       hyp_idx +=3D 1;
>> +                               }
>> +                               pfn =3D page_to_pfn(buddy_page) +
>> +                                       (1 << buddy_order);
>> +                               continue;
>> +                       }
> This is essentially just a duplicate of the code above. As I mentioned
> before it would probably make sense to just combine this block with
> that one.
Yeap, I should get rid of this. Now as we are capturing post buddy
merging we don't need this.
Thanks.
>
>> +                       pfn++;
>> +               }
>> +               hinting_obj->free_page_arr[idx] =3D 0;
>> +               idx++;
>> +               if (idx =3D=3D free_pages_idx)
>> +                       spin_unlock_irqrestore(&zone_cur->lock, flags)=
;
>> +       }
>>
>>         hinting_obj->free_pages_idx =3D 0;
>>         put_cpu_var(hinting_obj);
>> +
>> +       if (hyp_idx > 0)
>> +               guest_free_page_report(isolated_pages_obj, hyp_idx);
>> +       else
>> +               kfree(isolated_pages_obj);
>> +               /* return some logical error here*/
>>  }
>>
>>  int if_exist(struct page *page)
>> --
>> 2.17.2
>>
--=20
Regards
Nitesh


--zmr2OPVqRHdEf7yjlMKc5SZzYYfvPGbhQ--

--LRRsTmOUFCNMKmyP7qPLy2b0ygzL5O5at
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyBb6YACgkQo4ZA3AYy
ozmCaA/+Ku69HN5UrLXxGKOH9J1me7OkBbv8LGga2tIiMAtgPqA/90WMSOMMtiC1
J1lnuJNKqRLIKpo6C8MSkS2xo4EWrzGuE55VIc0Zk6EZsnZF79ccRNC/y06Eh8vC
hI0UyEpE+rqEpW3HL8ZImZkaY7FkT1U5XQWhshis4PUddQOHRsEMo/1L+XA6Qewk
qm5TwKKdmFVNBs9Aoa3uHRPJ0wMOCVTT3m8Mp9R5lAhW9vz/n0r7t4Zi4dK+1lRD
v+kMXPSLZZHZBfYPYi5ZfnwdDpUl3HmwqjVvlptqYexfwui0NMQ4zRpGX4HS9Vq8
nMJjQAkTlo2s3GDMOwvvTNj46XWrY2Zr2/FglyiBqAlEp8F2NrGIFhYEIaZNoPWE
arISjFp5VmkF8vYKOnAXzsAghKAoCV6GC9lRYNr+4RokUcUH0Uz+P3nSFNkyGVOG
oyt78Edc4gtDRsqB/ytze/mEjoaHxGtyoWeYu5tb7lUpgAOVQm1iqQ4BF3gTWd2F
gnJOyMiHtIB8GPDOB+ADYci7Iyoirr1NG0vXB8nCmmcNY6XQH9NUk9C0QQl9LHGb
4MERT++hpuZr7Ilqcb4O6D7c3I3tL715zU3nSOoN5x/JYG+o8iShXBoaG9clirdG
TcjnRN4KtkaN1ACxBeEJhQ9/DNQ95Vwn/MZgXhQBWqneoiktdpk=
=dmCE
-----END PGP SIGNATURE-----

--LRRsTmOUFCNMKmyP7qPLy2b0ygzL5O5at--


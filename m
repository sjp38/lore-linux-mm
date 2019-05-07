Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9414C04AAB
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:24:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57C0420825
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:24:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57C0420825
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E18416B026D; Tue,  7 May 2019 17:24:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC9BB6B026E; Tue,  7 May 2019 17:24:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C91BF6B026F; Tue,  7 May 2019 17:24:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id A67C46B026D
	for <linux-mm@kvack.org>; Tue,  7 May 2019 17:24:43 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id w34so20806702qtc.16
        for <linux-mm@kvack.org>; Tue, 07 May 2019 14:24:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=OC4Sjv26Zd+YD1r+wvL4lQ34otzvmIRCLxxYA33WL7I=;
        b=lvH9StX6We0bPDpsOjLhE7QT62KlKJg5DN12Ef/FUPbtmHjulHq5l5JKI3gWcn6IGW
         XiozhyilApcIktzGmW5NtSLcQ1d4aZQFFEJYhr27G6+TJcDvJtPViNLM2W7+0erVHx/g
         AwMYY1AloeHa7ralHOpP/UUIEQacNTqLKEgzZp3RwfhEk7nWTnv4VTcZpfc9op2RKYPE
         Nl5x1sgf7OkeWJ5AYkmilYGQf/Mdgr8fcmH25EGaNJ7+bMToDs5eSMv2vmVYThbQP0Oi
         bZ5Snz2kVigA/sTcaiUxbgiz2UMob8De5QRRt1EIKZg8O2xvbSPRlowPwU9eWNAuKE8p
         jktA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVe5E8nkELFdumP3AIEryNOc95PKSR8jT6zwaQQDamR61yqGH1B
	/exraS4g7lYrL9f5qO34rJ11A7R7ZP8uAuP7UxLao/lsXVaHCeXwqPlX1QW1XEAi5hCzLLAxck6
	RQHLl2XMtcaYjapZyHfrBllAWKiI9WlsR2NNQT7O51Er4T1t4qiDZmftODGnJjeic2Q==
X-Received: by 2002:a0c:d1ad:: with SMTP id e42mr27300287qvh.208.1557264283432;
        Tue, 07 May 2019 14:24:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAmhzjeXt8GrPGtnbJPZf5ygf2ZHWISwc4ura4zT4E2hvqxxN5dFcdfQcjc55DVqRqGKSt
X-Received: by 2002:a0c:d1ad:: with SMTP id e42mr27300255qvh.208.1557264282901;
        Tue, 07 May 2019 14:24:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557264282; cv=none;
        d=google.com; s=arc-20160816;
        b=Tt2GF1WOeWQ2GKUXgTY/+jL8jzqA7pL8xEX+tSePOlt45jiGEXwuEZrwEtZDd5mmlT
         8UnTgImejumhDWzZv/qjLLZKwPWChCQZFZyH3NoIBiAB5CkJxU5BHfrOzVIEK8iYoJpo
         qP9D5Jkw9Ub66bmiLgI2E0oTinF7lEozPtkZfGHpU+2Jrs+bYkogD16Ub+25dO8m0axR
         eCakE6livYLT0ncWVdzay2tpW+9hoF9oSlbUPqzrp8EfXm/tb5C3H2YxCAswlRKxr4Sr
         6fE4sINjt2NAmRsja/Lr9Ay1/im292gyAtJE0XXHvDFzA/AJdnAI4gVmDxVkU7YR2d6p
         4nug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=OC4Sjv26Zd+YD1r+wvL4lQ34otzvmIRCLxxYA33WL7I=;
        b=o0Pjk8xMbnWKqxnxFceeTVp72w8Rj1KajJrISgv1cQTMmeGyk13QVNynZc+VlvzvhW
         cSkT49Za60/kVXjoetQ63Pl20XceOxMysI9RviMCZdTwGugmlbLU9zWTaqDcMdSDoQbx
         L1r2fPFDhjZqzX8NcaJR39VQsN+XP6bLlXq5nKTCzGfP6tq4EMPMDPuQTSK6UzugB0FY
         hf5EKjD1Fxh7rEyStP2gE2FiWsCUWLWbAPxCb+5InOsFCjPMPHh8GcznS4bf7l2wRknd
         Tmkd7uPEkXGXT2GeGZLtUfE/Rz1YHyxEapE7IxSybqahtdqOgFmY0z4fndZ5bm3/C7lz
         GHsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h1si1421211qkf.133.2019.05.07.14.24.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 14:24:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E501E81DE5;
	Tue,  7 May 2019 21:24:41 +0000 (UTC)
Received: from [10.36.116.95] (ovpn-116-95.ams2.redhat.com [10.36.116.95])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 391241001DDD;
	Tue,  7 May 2019 21:24:38 +0000 (UTC)
Subject: Re: [PATCH v2 5/8] mm/memory_hotplug: Drop MHP_MEMBLOCK_API
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 linux-ia64@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
 linux-s390 <linux-s390@vger.kernel.org>, Linux-sh
 <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
 Michal Hocko <mhocko@suse.com>, Oscar Salvador <osalvador@suse.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Wei Yang <richard.weiyang@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Qian Cai <cai@lca.pw>, Arun KS <arunks@codeaurora.org>,
 Mathieu Malaterre <malat@debian.org>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-6-david@redhat.com>
 <CAPcyv4ge1pSOopfHof4USn=7Skc-UV4Xhd_s=h+M9VXSp_p1XQ@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <d83fec16-ceff-2f6f-72e1-48996187d5ba@redhat.com>
Date: Tue, 7 May 2019 23:24:37 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4ge1pSOopfHof4USn=7Skc-UV4Xhd_s=h+M9VXSp_p1XQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 07 May 2019 21:24:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07.05.19 23:19, Dan Williams wrote:
> On Tue, May 7, 2019 at 11:38 AM David Hildenbrand <david@redhat.com> wrote:
>>
>> No longer needed, the callers of arch_add_memory() can handle this
>> manually.
>>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: David Hildenbrand <david@redhat.com>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Oscar Salvador <osalvador@suse.com>
>> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>> Cc: Wei Yang <richard.weiyang@gmail.com>
>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> Cc: Qian Cai <cai@lca.pw>
>> Cc: Arun KS <arunks@codeaurora.org>
>> Cc: Mathieu Malaterre <malat@debian.org>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> ---
>>  include/linux/memory_hotplug.h | 8 --------
>>  mm/memory_hotplug.c            | 9 +++------
>>  2 files changed, 3 insertions(+), 14 deletions(-)
>>
>> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
>> index 2d4de313926d..2f1f87e13baa 100644
>> --- a/include/linux/memory_hotplug.h
>> +++ b/include/linux/memory_hotplug.h
>> @@ -128,14 +128,6 @@ extern void arch_remove_memory(int nid, u64 start, u64 size,
>>  extern void __remove_pages(struct zone *zone, unsigned long start_pfn,
>>                            unsigned long nr_pages, struct vmem_altmap *altmap);
>>
>> -/*
>> - * Do we want sysfs memblock files created. This will allow userspace to online
>> - * and offline memory explicitly. Lack of this bit means that the caller has to
>> - * call move_pfn_range_to_zone to finish the initialization.
>> - */
>> -
>> -#define MHP_MEMBLOCK_API               (1<<0)
>> -
>>  /* reasonably generic interface to expand the physical pages */
>>  extern int __add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
>>                        struct mhp_restrictions *restrictions);
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index e1637c8a0723..107f72952347 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -250,7 +250,7 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
>>  #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
>>
>>  static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>> -               struct vmem_altmap *altmap, bool want_memblock)
>> +                                  struct vmem_altmap *altmap)
>>  {
>>         int ret;
>>
>> @@ -293,8 +293,7 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
>>         }
>>
>>         for (i = start_sec; i <= end_sec; i++) {
>> -               err = __add_section(nid, section_nr_to_pfn(i), altmap,
>> -                               restrictions->flags & MHP_MEMBLOCK_API);
>> +               err = __add_section(nid, section_nr_to_pfn(i), altmap);
>>
>>                 /*
>>                  * EEXIST is finally dealt with by ioresource collision
>> @@ -1066,9 +1065,7 @@ static int online_memory_block(struct memory_block *mem, void *arg)
>>   */
>>  int __ref add_memory_resource(int nid, struct resource *res)
>>  {
>> -       struct mhp_restrictions restrictions = {
>> -               .flags = MHP_MEMBLOCK_API,
>> -       };
>> +       struct mhp_restrictions restrictions = {};
> 
> With mhp_restrictions.flags no longer needed, can we drop
> mhp_restrictions and just go back to a plain @altmap argument?
> 

Oscar wants to use it to configure from where to allocate vmemmaps. That
was the original driver behind it.

-- 

Thanks,

David / dhildenb


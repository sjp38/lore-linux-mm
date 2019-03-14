Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E89BFC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 08:37:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7728221852
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 08:37:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7728221852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E58C78E0003; Thu, 14 Mar 2019 04:37:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E06A68E0001; Thu, 14 Mar 2019 04:37:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C81E38E0003; Thu, 14 Mar 2019 04:37:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6BB3B8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 04:37:55 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id a1so2075663edx.4
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:37:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=2TVfHMBUtvZhaz01nChQNEoKLzEApMIElU09UXoaeDs=;
        b=fpg5qnlq2M3Hz86X3ILAJ9Rr9d6qMkv/3LgpGuO0gxNLjOL1/SkMsntHk2ahh2dESy
         tk48zIJr7t3Oim3YT7UAb0zEld0/DSvPHF3/B7d760nUI9Z69MhdFcPutuuckqQoOMTk
         IX9EFxTiPuSt0MEmIITZT1IgpSWcDfHH0m5ni80HhqcvTKjSb5BaJ0xYSlytRb1V6iuZ
         Zc71ceAKsYP1+dEfU7Ro0HrOqzkS8A7369el9A5Niz/NNdmNh31sUzTlvI9dHnTP5BlE
         YZh8AhVZZfoxTPupeV+T2LoPWXGl9bHYTLu4W1M1zCB9Q0tH0owoP4105FtX6PA11NlQ
         c4yg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: APjAAAWcXKmOHBmKIotIATM45+2hkzmx6xfqL387gzChAtgoK7Vs3EgV
	OxBKwd2tuf0ZvXq1MzB5ogOj48xdfo0PLQLoTk5ThG/qARfn334ezukAPagr0fxOK12HAHW558S
	BMZmq5/kK+nbuwCPjlTJxX7p4VLwJyAJSgegBAcb8BuLsEau3A0XZuxM6Q6o48j+19g==
X-Received: by 2002:aa7:d383:: with SMTP id x3mr10569080edq.61.1552552675000;
        Thu, 14 Mar 2019 01:37:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHXTEu9/sm8wl60Zfbx0+qmGuwUJ1DTKchwSXOAKIo1VYTwlB/Ls9D8IfWFXxdLi+nwRfy
X-Received: by 2002:aa7:d383:: with SMTP id x3mr10569017edq.61.1552552673689;
        Thu, 14 Mar 2019 01:37:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552552673; cv=none;
        d=google.com; s=arc-20160816;
        b=HKp5lLD4db4sO/zUTdyaM6x2s5SAqAkAL/apd3ExGSJ5gxv7dOdJRB4fWmsLRmFXWC
         VXVS6e1IefZfelUW7iE7iZpDv8Ddauj6jSUkh0/YB/3Fr/S+yiFMmdtKKhJI1PUPRiUD
         Nda6lDZeDhVu63a/541X4+yBtbllaH6HOCoUGXpiMgSW932WQVfeTu40Ow4mXUpkVkcE
         Jye29dKbzI/Tjoo1UJHhhx0/KO1vM3CFaoKcEa32MXrnPAEyGodv/DU0JdopNaMZgEM+
         Mywe2u7FGUZeHVRKuwtEm3ft2kdo0C2PrbARJLPCZw6/Mn54ZulmmwfjSK/NRUoNRSQh
         KEtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=2TVfHMBUtvZhaz01nChQNEoKLzEApMIElU09UXoaeDs=;
        b=w5Gw+LZ+tg72u9Tudj26bAxVuLvscuxGBfA7mjlOc9ktizYF55IB5dtbniewa01KNV
         UG0yp+n6UVaUZ5NnVBwWcVhMGCUcWxFPlU3NqHuA/g+dlftbTB6M/IYWlOArjby+a3Ke
         fmg3+EeEvZ5+a0rlEmX9YnijL7E08VDZIUKl44dGIIsL6h7Tc9XVs8WMuvpXrVkt339K
         b4U5sbL7yS59m8/RnYl4ONVWxUmBgt0qpUOTtfh6G1JWAJeOe+tCHew9P/lWhXFHElXJ
         HLznNc11DRY3eLDQDyeXqAwTnIVbRugkyTpoy6FBwatOw4TYrSo69kcNWxHTVYp4oEfM
         0YFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j18si755951edr.99.2019.03.14.01.37.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 01:37:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8ABD2AC32;
	Thu, 14 Mar 2019 08:37:52 +0000 (UTC)
Subject: Re: [Xen-devel] xen: Can't insert balloon page into VM userspace (WAS
 Re: [linux-linus bisection] complete test-arm64-arm64-xl-xsm)
To: David Hildenbrand <david@redhat.com>,
 Boris Ostrovsky <boris.ostrovsky@oracle.com>,
 Andrew Cooper <andrew.cooper3@citrix.com>,
 Matthew Wilcox <willy@infradead.org>, Julien Grall <julien.grall@arm.com>
Cc: k.khlebnikov@samsung.com, Stefano Stabellini <sstabellini@kernel.org>,
 Kees Cook <keescook@chromium.org>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 "VMware, Inc." <pv-drivers@vmware.com>,
 osstest service owner <osstest-admin@xenproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 linux-mm@kvack.org, Julien Freche <jfreche@vmware.com>,
 Nadav Amit <namit@vmware.com>, xen-devel@lists.xenproject.org
References: <E1h3Uiq-0002L6-Ij@osstest.test-lab.xenproject.org>
 <80211e70-5f54-9421-8e8f-2a4fc758ce39@arm.com>
 <46118631-61d4-adb6-6ffc-4e7c62ea3da9@arm.com>
 <20190312171421.GJ19508@bombadil.infradead.org>
 <e0b64793-260d-5e70-0544-e7290509b605@redhat.com>
 <45323ea0-2a50-8891-830e-e1f8a8ed23ea@citrix.com>
 <f4b40d91-9c41-60ed-6b4e-df47af8e5292@oracle.com>
 <9a40e1ff-7605-e822-a1d2-502a12d0fba7@redhat.com>
 <6f8aca6c-355b-7862-75aa-68fe566f76fb@redhat.com>
From: Juergen Gross <jgross@suse.com>
Openpgp: preference=signencrypt
Autocrypt: addr=jgross@suse.com; prefer-encrypt=mutual; keydata=
 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
Message-ID: <ec71c03e-987d-2b73-9fe6-2604a3c32017@suse.com>
Date: Thu, 14 Mar 2019 09:37:50 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <6f8aca6c-355b-7862-75aa-68fe566f76fb@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 12/03/2019 20:46, David Hildenbrand wrote:
> On 12.03.19 19:23, David Hildenbrand wrote:
>> On 12.03.19 19:02, Boris Ostrovsky wrote:
>>> On 3/12/19 1:24 PM, Andrew Cooper wrote:
>>>> On 12/03/2019 17:18, David Hildenbrand wrote:
>>>>> On 12.03.19 18:14, Matthew Wilcox wrote:
>>>>>> On Tue, Mar 12, 2019 at 05:05:39PM +0000, Julien Grall wrote:
>>>>>>> On 3/12/19 3:59 PM, Julien Grall wrote:
>>>>>>>> It looks like all the arm test for linus [1] and next [2] tree
>>>>>>>> are now failing. x86 seems to be mostly ok.
>>>>>>>>
>>>>>>>> The bisector fingered the following commit:
>>>>>>>>
>>>>>>>> commit 0ee930e6cafa048c1925893d0ca89918b2814f2c
>>>>>>>> Author: Matthew Wilcox <willy@infradead.org>
>>>>>>>> Date:   Tue Mar 5 15:46:06 2019 -0800
>>>>>>>>
>>>>>>>>      mm/memory.c: prevent mapping typed pages to userspace
>>>>>>>>      Pages which use page_type must never be mapped to userspace as it would
>>>>>>>>      destroy their page type.  Add an explicit check for this instead of
>>>>>>>>      assuming that kernel drivers always get this right.
>>>>>> Oh good, it found a real problem.
>>>>>>
>>>>>>> It turns out the problem is because the balloon driver will call
>>>>>>> __SetPageOffline() on allocated page. Therefore the page has a type and
>>>>>>> vm_insert_pages will deny the insertion.
>>>>>>>
>>>>>>> My knowledge is quite limited in this area. So I am not sure how we can
>>>>>>> solve the problem.
>>>>>>>
>>>>>>> I would appreciate if someone could provide input of to fix the mapping.
>>>>>> I don't know the balloon driver, so I don't know why it was doing this,
>>>>>> but what it was doing was Wrong and has been since 2014 with:
>>>>>>
>>>>>> commit d6d86c0a7f8ddc5b38cf089222cb1d9540762dc2
>>>>>> Author: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
>>>>>> Date:   Thu Oct 9 15:29:27 2014 -0700
>>>>>>
>>>>>>     mm/balloon_compaction: redesign ballooned pages management
>>>>>>
>>>>>> If ballooned pages are supposed to be mapped into userspace, you can't mark
>>>>>> them as ballooned pages using the mapcount field.
>>>>>>
>>>>> Asking myself why anybody would want to map balloon inflated pages into
>>>>> user space (this just sounds plain wrong but my understanding to what
>>>>> XEN balloon driver does might be limited), but I assume the easy fix
>>>>> would be to revert
>>>> I suspect the bug here is that the balloon driver is (ab)used for a
>>>> second purpose
>>>
>>> Yes. And its name is alloc_xenballooned_pages().
>>>
>>
>> Haven't had a look at the code yet, but would another temporary fix be
>> to clear/set PG_offline when allocating/freeing a ballooned page?
>> (assuming here that only such pages will be mapped to user space)
>>
> 
> I guess something like this could do the trick if I understood it correctly:
> 
> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> index 39b229f9e256..d37dd5bb7a8f 100644
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -604,6 +604,7 @@ int alloc_xenballooned_pages(int nr_pages, struct
> page **pages)
>         while (pgno < nr_pages) {
>                 page = balloon_retrieve(true);
>                 if (page) {
> +                       __ClearPageOffline(page);
>                         pages[pgno++] = page;
>  #ifdef CONFIG_XEN_HAVE_PVMMU
>                         /*
> @@ -645,8 +646,10 @@ void free_xenballooned_pages(int nr_pages, struct
> page **pages)
>         mutex_lock(&balloon_mutex);
> 
>         for (i = 0; i < nr_pages; i++) {
> -               if (pages[i])
> +               if (pages[i]) {
> +                       __SetPageOffline(pages[i]);
>                         balloon_append(pages[i]);
> +               }
>         }
> 
>         balloon_stats.target_unpopulated -= nr_pages;
> 
> 
> At least this way, the pages allocated (and thus eventually mapped to
> user space) would not be marked, but the other ones would remain marked
> and could be excluded by makedumptool.
> 

I think this patch should do the trick. Julien, could you give it a
try? On x86 I can't reproduce your problem easily as dom0 is PV with
plenty of unpopulated pages for grant memory not suffering from
missing "offline" bit.


Juergen


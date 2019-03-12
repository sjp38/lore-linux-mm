Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FE95C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 19:46:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0793214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 19:46:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0793214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 598638E0003; Tue, 12 Mar 2019 15:46:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51D788E0002; Tue, 12 Mar 2019 15:46:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BD978E0003; Tue, 12 Mar 2019 15:46:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0D4198E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:46:27 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id c25so3351740qtj.13
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 12:46:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=l7EBwXt6tn0WxFbfWsvbwwQn2EZoZ61aFy6A4LSMx9k=;
        b=CJ1BOJr5IMamv0sU6T8iu+Ghf+pkBYhN6E7EArasuGVSelNHUceHpuzg5d6xlxg8qw
         YkayxpUv9AheKpZiHMtW5Yrv9kS5ZClaK60OZBTTQqbxGpv7oqS8xP+PHk3CQWAqBBSj
         POpAQX4EN4Iw1ASRbQcKKA3816A9yLMS61UWuvqLt4qXdEpZhF3XB3UGZZLziWeGI+UY
         Wc1tuyGoRoloNI4kl84w4ytIGl5NpJx77QXvXIifQeKiCs5xh0+GP+qBTEppgq2o43lc
         22WR32r39CxX78A4x4BcxHDK/D+LBhKMJoOdZgCkBMl6jIZM0gVhFcTljBJqNoMNzNGW
         1SFg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXzOgxjprk3PuhHRS/W22/Q6yOOkxyyYPMWkkz7uqtiZpqSybEc
	yLw6k2gW6h5pd0A7Y3yHIiB1bldnMzWCTwoev5gYAt5CvNUhd7CFjxNQQndo7J3tKwL05h1gQXJ
	vWF8IKBkeZfc2GUkvQg7lqxsbEToVbPSeRNTaa2cIkVdcJbL//bv6EkVPq8cDyw3qrw==
X-Received: by 2002:a37:32d4:: with SMTP id y203mr29339301qky.282.1552419986798;
        Tue, 12 Mar 2019 12:46:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5SzRUVuVH1F3t5J2ZfiM3tEkruXmlcY1KC3e8f6GqM8UVxAB4qxrMibnZuk04AJnOTa1U
X-Received: by 2002:a37:32d4:: with SMTP id y203mr29339246qky.282.1552419985838;
        Tue, 12 Mar 2019 12:46:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552419985; cv=none;
        d=google.com; s=arc-20160816;
        b=Q5LsZXFhtBNMOz9KHrkOSJegkyEhlrQ9JHY2yttXEMGb+Tfu/xhz9qn4KxE5F2+7yu
         N9n+ZBOKKngqFbCkNUf1CLzPv8+CNH6sRYq27fESUhcvJVYRuZvPFRKz+CaF/MsybkvY
         JYNj0X0JQ/Z+lefCqiWJlK4gz/+0e9wRy8N8FtKikMtw1lHYhRn9JgBISQepIg7GCT5f
         zupQl25XNK03WmfvsNem71BsGBTkMquJEjd5ozyEQ5X/vNXBnttfZy3ZERgsF3ibobnP
         xnG5Urs2B7k5vBk6JqQPpszqWRtmUzuvHnHDdmiP35xyRmUQIywxD+HXoUo6fl9grsOw
         mI9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp
         :references:cc:to:from:subject;
        bh=l7EBwXt6tn0WxFbfWsvbwwQn2EZoZ61aFy6A4LSMx9k=;
        b=zA4eCUnEiZXXE9xw4n4ICjP7WUv+X3LTVxbri1Bt8j9L9aedlPG9Xv3XqzrtF1FGWg
         bvB/F+V0wAz/oVKfigHecJv4pB+QJUK+uDl978cTW4DdDaXmvsbNWKXXjE1dLWGoncPw
         lq/83DPKOsAaw0qt0rF+bivhV9M4IA16zgBof2/5LtWzKgYzRNBsxtcscMoDDmj/HVMW
         xjelAwA8fGP7u5n81LybzMaDov/YJoySfb5mKPpeUpZ3TnpRr+4XQ//cvlRI+i8+9gM2
         8FHqPrehNfET7HwtNUnZc7uRZOJ+TWbrEmb/BumzG/TTsmjnnJQH2uaAySrG5fU+rL+c
         o31w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n32si3101753qvc.145.2019.03.12.12.46.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 12:46:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7611B30833C0;
	Tue, 12 Mar 2019 19:46:24 +0000 (UTC)
Received: from [10.36.116.121] (ovpn-116-121.ams2.redhat.com [10.36.116.121])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 17BB21001E70;
	Tue, 12 Mar 2019 19:46:20 +0000 (UTC)
Subject: Re: [Xen-devel] xen: Can't insert balloon page into VM userspace (WAS
 Re: [linux-linus bisection] complete test-arm64-arm64-xl-xsm)
From: David Hildenbrand <david@redhat.com>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>,
 Andrew Cooper <andrew.cooper3@citrix.com>,
 Matthew Wilcox <willy@infradead.org>, Julien Grall <julien.grall@arm.com>
Cc: Juergen Gross <jgross@suse.com>, k.khlebnikov@samsung.com,
 Stefano Stabellini <sstabellini@kernel.org>,
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
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <6f8aca6c-355b-7862-75aa-68fe566f76fb@redhat.com>
Date: Tue, 12 Mar 2019 20:46:20 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <9a40e1ff-7605-e822-a1d2-502a12d0fba7@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Tue, 12 Mar 2019 19:46:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 12.03.19 19:23, David Hildenbrand wrote:
> On 12.03.19 19:02, Boris Ostrovsky wrote:
>> On 3/12/19 1:24 PM, Andrew Cooper wrote:
>>> On 12/03/2019 17:18, David Hildenbrand wrote:
>>>> On 12.03.19 18:14, Matthew Wilcox wrote:
>>>>> On Tue, Mar 12, 2019 at 05:05:39PM +0000, Julien Grall wrote:
>>>>>> On 3/12/19 3:59 PM, Julien Grall wrote:
>>>>>>> It looks like all the arm test for linus [1] and next [2] tree
>>>>>>> are now failing. x86 seems to be mostly ok.
>>>>>>>
>>>>>>> The bisector fingered the following commit:
>>>>>>>
>>>>>>> commit 0ee930e6cafa048c1925893d0ca89918b2814f2c
>>>>>>> Author: Matthew Wilcox <willy@infradead.org>
>>>>>>> Date:   Tue Mar 5 15:46:06 2019 -0800
>>>>>>>
>>>>>>>      mm/memory.c: prevent mapping typed pages to userspace
>>>>>>>      Pages which use page_type must never be mapped to userspace as it would
>>>>>>>      destroy their page type.  Add an explicit check for this instead of
>>>>>>>      assuming that kernel drivers always get this right.
>>>>> Oh good, it found a real problem.
>>>>>
>>>>>> It turns out the problem is because the balloon driver will call
>>>>>> __SetPageOffline() on allocated page. Therefore the page has a type and
>>>>>> vm_insert_pages will deny the insertion.
>>>>>>
>>>>>> My knowledge is quite limited in this area. So I am not sure how we can
>>>>>> solve the problem.
>>>>>>
>>>>>> I would appreciate if someone could provide input of to fix the mapping.
>>>>> I don't know the balloon driver, so I don't know why it was doing this,
>>>>> but what it was doing was Wrong and has been since 2014 with:
>>>>>
>>>>> commit d6d86c0a7f8ddc5b38cf089222cb1d9540762dc2
>>>>> Author: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
>>>>> Date:   Thu Oct 9 15:29:27 2014 -0700
>>>>>
>>>>>     mm/balloon_compaction: redesign ballooned pages management
>>>>>
>>>>> If ballooned pages are supposed to be mapped into userspace, you can't mark
>>>>> them as ballooned pages using the mapcount field.
>>>>>
>>>> Asking myself why anybody would want to map balloon inflated pages into
>>>> user space (this just sounds plain wrong but my understanding to what
>>>> XEN balloon driver does might be limited), but I assume the easy fix
>>>> would be to revert
>>> I suspect the bug here is that the balloon driver is (ab)used for a
>>> second purpose
>>
>> Yes. And its name is alloc_xenballooned_pages().
>>
> 
> Haven't had a look at the code yet, but would another temporary fix be
> to clear/set PG_offline when allocating/freeing a ballooned page?
> (assuming here that only such pages will be mapped to user space)
> 

I guess something like this could do the trick if I understood it correctly:

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 39b229f9e256..d37dd5bb7a8f 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -604,6 +604,7 @@ int alloc_xenballooned_pages(int nr_pages, struct
page **pages)
        while (pgno < nr_pages) {
                page = balloon_retrieve(true);
                if (page) {
+                       __ClearPageOffline(page);
                        pages[pgno++] = page;
 #ifdef CONFIG_XEN_HAVE_PVMMU
                        /*
@@ -645,8 +646,10 @@ void free_xenballooned_pages(int nr_pages, struct
page **pages)
        mutex_lock(&balloon_mutex);

        for (i = 0; i < nr_pages; i++) {
-               if (pages[i])
+               if (pages[i]) {
+                       __SetPageOffline(pages[i]);
                        balloon_append(pages[i]);
+               }
        }

        balloon_stats.target_unpopulated -= nr_pages;


At least this way, the pages allocated (and thus eventually mapped to
user space) would not be marked, but the other ones would remain marked
and could be excluded by makedumptool.

-- 

Thanks,

David / dhildenb


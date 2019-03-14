Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB784C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 14:15:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AA962184E
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 14:15:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AA962184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B5BB8E0004; Thu, 14 Mar 2019 10:15:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33CA28E0001; Thu, 14 Mar 2019 10:15:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DFC78E0004; Thu, 14 Mar 2019 10:15:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B97558E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 10:15:34 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e46so2483935ede.9
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 07:15:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=kONhBAPY44HqBxJX5W9yE4oQc9yjrV4GJBwWJtM75jA=;
        b=uP88xcRm6dx58nPmqfxUfnT0jpxA/IzTZgG5PexfIetc7m2KmlTaJI19U/EnCTFGxx
         jEIvACCaI/JyS3PsfJVmAApSXAHOckm53xBpUi+FPLhlIrj7yZa2HEwyuffmlD7GVO40
         Uja0lwnhN/5+0mYWE2DtM7tqn7dtQgf3x+6h91X6266VAxCu8hmyWITb/aTeS6lZdKTy
         sak9H5FEKLefFtMupzmJRIwzZGGrflm6l7Pfvrz9rEg94HiKmQe+o/RlpX+EunFrxstR
         qp7TmhwSzsrQS3HlazLtnAkQyXVQFuKIRKGEVCHrY6DOSTZlUoWUFAKjUltYhk20nMlL
         bItw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: APjAAAU5IYA/QXeG2xT6eFn6oAJjmnONWLKgr6VuSIkd4qFg38QlJPve
	FBzs3oATyDFPQ+TpuEZV2AkiCvfNVlW4M6DlSwCMAQjWeRkWXnsOUvrEKSJNhZ4vhonxaT9uzi4
	q+HXfQJGMwyYPd/EpO8kcjqyk24dlfsmTIof9KrDjptMki2GQJfoFohx+uWcbTF8bDg==
X-Received: by 2002:a50:bd8b:: with SMTP id y11mr11996378edh.26.1552572934330;
        Thu, 14 Mar 2019 07:15:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVnNRQbUsnYSr0aShfBAU3EcsHwTjLNCHK+IM7n0Kr3rKzfZy3+1Oj3lrLgHJIFIPI/4M1
X-Received: by 2002:a50:bd8b:: with SMTP id y11mr11996334edh.26.1552572933524;
        Thu, 14 Mar 2019 07:15:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552572933; cv=none;
        d=google.com; s=arc-20160816;
        b=CxxSg+oMI5nqhmu8Hzu9xWsb/DcOSXjoM9+5fSQx0Xa25SK+EZrg0pLdbpmoufQRfW
         NcZqJ7pCePDv+a1rID13ldA/9x0OWqpKMjPM+NNdorUuvPJdcJHm3WhVyRRg8kAwLBgm
         tEs9QlYH9k8VosAcOtYcavZSthJMcL5Igf2NDqA73pUk6Cc6H59CkQW6jRQzL9s8//tp
         zfYEoZLvUSJu3drFFPh0na9FcuMCYf+74rwPBgPe3dx/tX4AjNXlTTEyf2+m/RqYEdud
         zaX5ouV9wUHsT52/XCn5yFbrx04oGJb/8zThowyN3zwt4ouZ9EvCAuWeDhEfKs/NiFqI
         DaHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=kONhBAPY44HqBxJX5W9yE4oQc9yjrV4GJBwWJtM75jA=;
        b=ZfkVd2dxNf/Ye/6mDqsupRtOnHO4DygNrZeulAv+47Up3GmndzGXC3eoy79RXh8ybk
         tw7UDSjMRS/M2v3ugmj24eqLWK54/79W7CL4lsE+tH6VGPqKNJpZtjtbmS2a1fvgMdCY
         l5TNISBMf/QMZ5KYi66++9d8ioYT41Gg2G7ztbx8Ke74KBlmhQNd8v2MXhF+fjm/CYUU
         OCvUm3KkwRQSsewG9nxbem73mGRu9C+nUGvx2XwZO2s6zoD0idfxVnC8JmkyRUlCdkcF
         iLK7aB4DVd8huGg1vsw446oHfvpkFov+RGPWMmQ4h7EJZhN+0/xJdaCQaRD9TxUpfG5B
         Wpuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f5si1929643edw.438.2019.03.14.07.15.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 07:15:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B1255AF68;
	Thu, 14 Mar 2019 14:15:32 +0000 (UTC)
Subject: Re: [Xen-devel] xen: Can't insert balloon page into VM userspace (WAS
 Re: [linux-linus bisection] complete test-arm64-arm64-xl-xsm)
To: Julien Grall <julien.grall@arm.com>, David Hildenbrand
 <david@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>,
 Andrew Cooper <andrew.cooper3@citrix.com>,
 Matthew Wilcox <willy@infradead.org>
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
 <ec71c03e-987d-2b73-9fe6-2604a3c32017@suse.com>
 <cb525882-b52f-c142-8a6a-e5cb491e05d0@arm.com>
From: Juergen Gross <jgross@suse.com>
Openpgp: preference=signencrypt
Autocrypt: addr=jgross@suse.com; prefer-encrypt=mutual; keydata=
 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
Message-ID: <d3e87824-b3a2-ed8a-d2ca-1a9fd439a204@suse.com>
Date: Thu, 14 Mar 2019 15:15:31 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <cb525882-b52f-c142-8a6a-e5cb491e05d0@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 14/03/2019 15:12, Julien Grall wrote:
> Hi,
> 
> On 3/14/19 8:37 AM, Juergen Gross wrote:
>> On 12/03/2019 20:46, David Hildenbrand wrote:
>>> On 12.03.19 19:23, David Hildenbrand wrote:
>>>
>>> I guess something like this could do the trick if I understood it
>>> correctly:
>>>
>>> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
>>> index 39b229f9e256..d37dd5bb7a8f 100644
>>> --- a/drivers/xen/balloon.c
>>> +++ b/drivers/xen/balloon.c
>>> @@ -604,6 +604,7 @@ int alloc_xenballooned_pages(int nr_pages, struct
>>> page **pages)
>>>          while (pgno < nr_pages) {
>>>                  page = balloon_retrieve(true);
>>>                  if (page) {
>>> +                       __ClearPageOffline(page);
>>>                          pages[pgno++] = page;
>>>   #ifdef CONFIG_XEN_HAVE_PVMMU
>>>                          /*
>>> @@ -645,8 +646,10 @@ void free_xenballooned_pages(int nr_pages, struct
>>> page **pages)
>>>          mutex_lock(&balloon_mutex);
>>>
>>>          for (i = 0; i < nr_pages; i++) {
>>> -               if (pages[i])
>>> +               if (pages[i]) {
>>> +                       __SetPageOffline(pages[i]);
>>>                          balloon_append(pages[i]);
>>> +               }
>>>          }
>>>
>>>          balloon_stats.target_unpopulated -= nr_pages;
>>>
>>>
>>> At least this way, the pages allocated (and thus eventually mapped to
>>> user space) would not be marked, but the other ones would remain marked
>>> and could be excluded by makedumptool.
>>>
>>
>> I think this patch should do the trick. Julien, could you give it a
>> try? On x86 I can't reproduce your problem easily as dom0 is PV with
>> plenty of unpopulated pages for grant memory not suffering from
>> missing "offline" bit.
> 
> Sure. I managed to get the console working with the patch suggested by
> David. Feel free to add my tested-by if when you resend it as is.

David, could you please send a proper patch with your Sob?


Juergen


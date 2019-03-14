Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67624C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 14:16:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15B5E2085A
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 14:16:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15B5E2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7E0D8E0003; Thu, 14 Mar 2019 10:16:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2B2C8E0001; Thu, 14 Mar 2019 10:16:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CCC98E0003; Thu, 14 Mar 2019 10:16:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6EC088E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 10:16:43 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id e31so5407199qtb.22
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 07:16:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=BsP7Txcbsu+XPjs1jRcJqvSZD4+hjnOxoo6VhE+3f7w=;
        b=l/KhnxQg5ZzHZoLJTfffLTRrv/mmjpIU1IMhtpLeZiWZwxiu3Qag8MhaF0Tu6hrdX5
         7NfQTgxRQqZsuBUz/MlK0mMMAQTQpW57wVhBp2UDldqhiEtXtTjzGoU3e4eNFi1PqO/M
         ViyT4hLhsQ5NaeN+6i/SHlj7IvgoWC79ylyBHkge9DE/Wqam7a/fMuSS+Kdg5/A3m3wh
         u1WrvT9GG+GgFnqZUuo2EeH+qV9IhJb7yMv9teFQzfAQQWrlJCBkhXiCKrfZggZ2UNMY
         SugxJ+gfEPWi64JRfvDeWyeZlp1Yed48A1onRtH2DYLvBot9nzTDdbeiSg1G8a32yoMD
         Z2xw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXSpiveQhGs0VPfJyWaN2MRk4KkD4ggJIfKcCzMoBRcf5ohpiLg
	WVD0aNZqntIgOBOeJPsR2S1Nm7FkhCXqnbk+4TwSJ1m/8wc4bqxjROfek/JQcxyMrAF/Jcj2+vo
	I9U2yz5cJ3WFWt2Ql0KAl3v+WGkzEO9nFwEElm1c5IwAPxsrcsSxXkSOsr7K+VRAOfw==
X-Received: by 2002:ac8:3739:: with SMTP id o54mr930968qtb.291.1552573003263;
        Thu, 14 Mar 2019 07:16:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwmZko+/aA2jAPA6wqb8Q1HeyrZoo64yBxEwyN9hKoM9ZpYINKYhDqfPiTXlOQ/Oz5v/th7
X-Received: by 2002:ac8:3739:: with SMTP id o54mr930917qtb.291.1552573002548;
        Thu, 14 Mar 2019 07:16:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552573002; cv=none;
        d=google.com; s=arc-20160816;
        b=m0JXPfg0G1+I9kc+TQEkrupYThoWev6Yr469Fy1E0tZzzK2uuazVheas6ZYZbIoJkc
         xF2dBdoDl+vZXtvsbIMdasUV9+qsj2IfyVJVBwZwVDbn0JRwIACbTyrty1kXCLWv0l3Z
         U3snI6SdI6WfnI/PzeCs2UAK3NYQqxitUR/4sPqN4zKwCAbpMn7jxt3D1ivf5XyECbaV
         0zhhRdMtk2URhHuxhJlBvfvZek6sepfyT4NAADscPfcOE/8CaX4dVg7oh4leIX7YFgF7
         Lv3J1gnGOnjfpHCRLE+wq7QS2DpXHvYm9dM7UwBS+uyiBAFAZqEDqHdE+FXnd239NE88
         IamQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=BsP7Txcbsu+XPjs1jRcJqvSZD4+hjnOxoo6VhE+3f7w=;
        b=GytuX+JhmnZ5e8/fuuXNgqv+ck2qMVG1kb7J+S/BYAtywU07u4PoPZ35sh7bpDiU9E
         KKV9/BBvY2x9uEJMtHW2Hl8YCqnCuGFQ8CqUXoMXlt3a74Qip2q7rBV3gowKaK8n5arx
         jcb+I5X8nqwh4RqsRZy6Rmu54DeR8hxZgAC0ZC18C9x3djVLkvuxFgLSObcB5slDBfjr
         rTYQ/MvYRlgNRfVffYF5k0fe/kBdFCnmbxXUkgix4SuoSE6lA3+JFDwwbKApMc4HH4ot
         vK2Nu8gJUxLNoWmdfRFqZnu4c5yyjUXokC7p0A5Kq35euwZ1Hd4hRFXrCq/RQf61TdR4
         uVcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f199si2153903qka.25.2019.03.14.07.16.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 07:16:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8C7113005FCB;
	Thu, 14 Mar 2019 14:16:41 +0000 (UTC)
Received: from [10.36.117.188] (ovpn-117-188.ams2.redhat.com [10.36.117.188])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 46F1E1001E62;
	Thu, 14 Mar 2019 14:16:38 +0000 (UTC)
Subject: Re: [Xen-devel] xen: Can't insert balloon page into VM userspace (WAS
 Re: [linux-linus bisection] complete test-arm64-arm64-xl-xsm)
To: Juergen Gross <jgross@suse.com>, Julien Grall <julien.grall@arm.com>,
 Boris Ostrovsky <boris.ostrovsky@oracle.com>,
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
 <d3e87824-b3a2-ed8a-d2ca-1a9fd439a204@suse.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <7ab068a3-2eaf-0eb0-cf25-43635e198ef7@redhat.com>
Date: Thu, 14 Mar 2019 15:16:37 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <d3e87824-b3a2-ed8a-d2ca-1a9fd439a204@suse.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Thu, 14 Mar 2019 14:16:41 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 14.03.19 15:15, Juergen Gross wrote:
> On 14/03/2019 15:12, Julien Grall wrote:
>> Hi,
>>
>> On 3/14/19 8:37 AM, Juergen Gross wrote:
>>> On 12/03/2019 20:46, David Hildenbrand wrote:
>>>> On 12.03.19 19:23, David Hildenbrand wrote:
>>>>
>>>> I guess something like this could do the trick if I understood it
>>>> correctly:
>>>>
>>>> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
>>>> index 39b229f9e256..d37dd5bb7a8f 100644
>>>> --- a/drivers/xen/balloon.c
>>>> +++ b/drivers/xen/balloon.c
>>>> @@ -604,6 +604,7 @@ int alloc_xenballooned_pages(int nr_pages, struct
>>>> page **pages)
>>>>          while (pgno < nr_pages) {
>>>>                  page = balloon_retrieve(true);
>>>>                  if (page) {
>>>> +                       __ClearPageOffline(page);
>>>>                          pages[pgno++] = page;
>>>>   #ifdef CONFIG_XEN_HAVE_PVMMU
>>>>                          /*
>>>> @@ -645,8 +646,10 @@ void free_xenballooned_pages(int nr_pages, struct
>>>> page **pages)
>>>>          mutex_lock(&balloon_mutex);
>>>>
>>>>          for (i = 0; i < nr_pages; i++) {
>>>> -               if (pages[i])
>>>> +               if (pages[i]) {
>>>> +                       __SetPageOffline(pages[i]);
>>>>                          balloon_append(pages[i]);
>>>> +               }
>>>>          }
>>>>
>>>>          balloon_stats.target_unpopulated -= nr_pages;
>>>>
>>>>
>>>> At least this way, the pages allocated (and thus eventually mapped to
>>>> user space) would not be marked, but the other ones would remain marked
>>>> and could be excluded by makedumptool.
>>>>
>>>
>>> I think this patch should do the trick. Julien, could you give it a
>>> try? On x86 I can't reproduce your problem easily as dom0 is PV with
>>> plenty of unpopulated pages for grant memory not suffering from
>>> missing "offline" bit.
>>
>> Sure. I managed to get the console working with the patch suggested by
>> David. Feel free to add my tested-by if when you resend it as is.
> 
> David, could you please send a proper patch with your Sob?
> 

Yes, on it :)

Cheers!

> 
> Juergen
> 


-- 

Thanks,

David / dhildenb


Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32846C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 09:11:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D00C62084D
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 09:11:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D00C62084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 603886B026B; Thu, 11 Apr 2019 05:11:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B2A26B026C; Thu, 11 Apr 2019 05:11:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47B586B026D; Thu, 11 Apr 2019 05:11:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 281A26B026B
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 05:11:13 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id f15so4920997qtk.16
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 02:11:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=8E2KdT0nS178aMSdueFeU/FHLjG8oqMN+fGvgRpK7e4=;
        b=EfJYdIg/FjpGnoydeAeVmv2oBEkc+I8Yoc0VBXmP8QOvSpnP06Yp3QGKPLqiFFRzUz
         RuAaXQNS3ZxKZsV9hedwazH22ogIeIobB8gWRi+HupImtt2l2iQagNeAWcWoj4LMyrnK
         nGqtuVP9Ms9YCBwO6rORx3V3+jt/FZ5S76roYpW2gkcw93uFdMko/wCbwH7JtwHDgs/f
         a08036PjpL8W3rMvQOV8t8L8ygtGzF1v8eqiqeO9bpPpzwErdG0TI/3NzXld4hZo9zUa
         Gip77EWGG8AWH5ukQoUmkawbdhX2cptBTLz12mEHpzOacHO/WOfndlQQi7eRlfc8Anw5
         U/Aw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWqZ7cp7BYMIwxt43I8KjQBXmb9f28xmAUXUpsI2oabq6sIMbD3
	atR/5TbTlZPoy52XXDshWRaZpYjz2/hNd9e3ueG4uuPufaR2IMA+EQtyBTlQsVGYtrLcLpoJnj3
	0LhVIkjFS1odSKqkoEiaZqgvKA7Dt1B2TyneA6EkBiHbnD5S2Jl9qMUnvI38sduIzFA==
X-Received: by 2002:aed:3b9c:: with SMTP id r28mr39819430qte.22.1554973872907;
        Thu, 11 Apr 2019 02:11:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykV8bQlMRP+TCy5Ld10IHF28UYbqBSDtEGpgx3lJGL6XDDVVUZ5j+18jWMvGsMdqJzZ1K6
X-Received: by 2002:aed:3b9c:: with SMTP id r28mr39819399qte.22.1554973872219;
        Thu, 11 Apr 2019 02:11:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554973872; cv=none;
        d=google.com; s=arc-20160816;
        b=pfeTX6BNJYkoYUE+sgkfQRvIuI2zMaB3jlyIJXBONOxLe9HmdZSK8Btzt+UT0VSeam
         mZyLNclqL6zkYmoqryo8lPS7Ybi2TW+ixwseDhzLgmmcvlSm0cRnc0o8bjmu4WW5Qg4Y
         Q5yJCgotkaKvqa5QHGf1ZqEdbqWaLWa/H4OfG46yR2v0qzdBtO1owR7yBlvyNkACWLX+
         UZCORBAgZhoD3stv3l3x2hDOKswDgh6JYmT0JtkHZvrVZOJ+6ehThDcKr2x+79bgnAtR
         LLnE0/hQh+XvOyiK4BoWIZf8jGZwJSFeMZRYnEFFvPYIGjE764xgwjZFjKPN7Quel1AB
         E0tQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=8E2KdT0nS178aMSdueFeU/FHLjG8oqMN+fGvgRpK7e4=;
        b=b+DZPsf+vyKdp/EVccv78LZ/FPCmfOjJ7sdQ8s+LAnM/MtPHckmZim+KIU1w5NKFgU
         Mjmo7IfdcJRNkPg1LLUHpz/Uhg6xKHsZntmiDdm+/5wv8vo/QTj3vsQJxkKPgLdYsWk5
         wlvUFk8WQEvVrNwDMDD24yCdcbPSwC+PpyIk6vpi938iiyGCHy37GsyPM9HLByCJITUZ
         FPqRS+Pfyw5Uo7BgTbFn2kAdT39X4djZNezBEbzbAFe5vAqFCZQz8UbdOrmdD4AirIhg
         ir6/y4D5a5YjUlkL88VZoyjUL7BZywa/5pgOfKyA2N9/6IDsJnk0HmGvTvugk4a4iD4q
         +6VQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r26si12978357qtb.222.2019.04.11.02.11.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 02:11:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 194AFC023C;
	Thu, 11 Apr 2019 09:11:11 +0000 (UTC)
Received: from [10.36.118.43] (unknown [10.36.118.43])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E1EA617136;
	Thu, 11 Apr 2019 09:11:08 +0000 (UTC)
Subject: Re: [PATCH] mm/memory_hotplug: Drop memory device reference after
 find_memory_block()
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador
 <osalvador@suse.de>, Pavel Tatashin <pasha.tatashin@soleen.com>,
 Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
 Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>
References: <20190410101455.17338-1-david@redhat.com>
 <20190411084141.GQ10383@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <0bbe632f-cb85-4a98-0c79-ded11cf39081@redhat.com>
Date: Thu, 11 Apr 2019 11:11:05 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190411084141.GQ10383@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 11 Apr 2019 09:11:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.04.19 10:41, Michal Hocko wrote:
> On Wed 10-04-19 12:14:55, David Hildenbrand wrote:
>> While current node handling is probably terribly broken for memory block
>> devices that span several nodes (only possible when added during boot,
>> and something like that should be blocked completely), properly put the
>> device reference we obtained via find_memory_block() to get the nid.
> 
> The changelog could see some improvements I believe. (Half) stating
> broken status of multinode memblock is not really useful without a wider
> context so I would simply remove it. More to the point, it would be much
> better to actually describe the actual problem and the user visible
> effect.
> 
> "
> d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug") has started
> using find_memory_block to get a nodeid for the beginnig of the onlined
> pfn range. The commit has missed that the memblock contains a reference
> counted object and a missing put_device will leak the kobject behind
> which ADD THE USER VISIBLE EFFECT HERE.
> "

I don't think mentioning the commit a second time is really needed.

"
Right now we are using find_memory_block() to get the node id for the
pfn range to online. We are missing to drop a reference to the memory
block device. While the device still gets unregistered via
device_unregister(), resulting in no user visible problem, the device is
never released via device_release(), resulting in a memory leak. Fix
that by properly using a put_device().
"

> 
>> Fixes: d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug")
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Oscar Salvador <osalvador@suse.de>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: David Hildenbrand <david@redhat.com>
>> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>> Cc: Wei Yang <richard.weiyang@gmail.com>
>> Cc: Qian Cai <cai@lca.pw>
>> Cc: Arun KS <arunks@codeaurora.org>
>> Cc: Mathieu Malaterre <malat@debian.org>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
> 
> Other than that
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
>> ---
>>  mm/memory_hotplug.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 5eb4a4c7c21b..328878b6799d 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -854,6 +854,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>>  	 */
>>  	mem = find_memory_block(__pfn_to_section(pfn));
>>  	nid = mem->nid;
>> +	put_device(&mem->dev);
>>  
>>  	/* associate pfn range with the zone */
>>  	zone = move_pfn_range(online_type, nid, pfn, nr_pages);
>> -- 
>> 2.20.1
> 


-- 

Thanks,

David / dhildenb


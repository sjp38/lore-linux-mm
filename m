Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8917CC48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 08:27:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C708215EA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 08:27:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C708215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD3C16B0003; Tue, 25 Jun 2019 04:27:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D84C88E0003; Tue, 25 Jun 2019 04:27:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4AF18E0002; Tue, 25 Jun 2019 04:27:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9ECED6B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 04:27:11 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n77so18977961qke.17
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 01:27:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=kdQMEnNMjhjHAeqdU733i3ujTlowle5FLjHOZHXduWM=;
        b=mQVR5jFfVGruvEX8l3FnfE/qh1BAwMw3QUkmwziOk8duhMlJY/bGjyxKfda9qGaQoX
         kqgs12QujkxHUxfMFEwd+evzJZNNkAiw1L5KKQNlMmwR0ZGC0qxWupjr/Ysx/nWnMXvq
         xBRq/ynMZrbU9xBEPr4kbw7xWNz3Jf94hiyDuyz1HmrEOULp0cM4bTJ7LYeYEM1xreBS
         QmS3nwJG47GtcePHxwgoTpZXhYD/2KCHST5qqBQWJUmcrey+ssN40nSRPvqQjpmSgg+P
         zA5s9JtGGdqaz+ChG5JENwtypnAOJGp672Dk1GqFFDKpgXdIfJ76TSUsxCnxvzuDlon5
         qZLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVwj/ABXpZWFyqjpbYP5GqWeFSsL/gObSXl3xploLk+7aC2v2i7
	HbaNetafkJuILNRfQixiqqHu7Wqh2ORjGFSf3JPVOkrfXVgMqZYEC1GrIxUVO58Gamsqo5yW2Jm
	NWX6v1BqgwrOgcLhQPNsezBJkuxehWRm+Oy6fH0HpVseTOw24NFVyFKV0+9+I2GgWqg==
X-Received: by 2002:a0c:aedc:: with SMTP id n28mr37259065qvd.242.1561451231422;
        Tue, 25 Jun 2019 01:27:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsAdu41e2KtyqSMJRmUvymUeVtYYnQGq7AQb3LXpErmQk6FvcYYPPDL7EscRqZde9tApDE
X-Received: by 2002:a0c:aedc:: with SMTP id n28mr37259029qvd.242.1561451230873;
        Tue, 25 Jun 2019 01:27:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561451230; cv=none;
        d=google.com; s=arc-20160816;
        b=wvX/0m/64aS0Zrg5P+Hi8zxAHxAedO6Uj9DS9Lg0aU8D1XE7jrkZbXyR7ga26r64dd
         KFS5TJoaki/c8lYS0+312XhV6kXW/s8/ktLA7Vot8PdqfUnlRAeoPCPXXAWNu9sIXgTA
         7w17ZOHX8MIlTEaZe8D6uNYudsTSbWJFbVWTUV8+hCDxBHATGcuRZ6+ZFUXS7gwYyn3t
         5poj1ZkWBsyZxN00yuZA6doDuyH0k/+lJomGtxSsduzgPyTdqiCpsalCtSZXkAlEX+TD
         sKxssZiQeces1hEhGylDhYtDZyvPxIsqD6kw0o0lexSdcli6zps8TbWsjPCjWUIulPZW
         IfNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=kdQMEnNMjhjHAeqdU733i3ujTlowle5FLjHOZHXduWM=;
        b=dKVJPDhPBXlUbTQorQb7RXZfN4WQFc29EOz6j2AMwl6iEWEFVLllSepoooz3Gbmi/j
         h2xb9hPK8WQM0YgoUsSv8fP+9VilPePXrxAV+Eu2MvVRKx4SksijBlabb9QBrEia/g09
         OaBPsBnSW9cIbTqyLHjovMrT/ZiEx8B3qKqjaHVtWzM6cviDsGRxacdc6WV9thtEamCC
         6Ijgy6sEAnCQ+51S5YQc1FTkVp0NexGtxj24+xGomvPnirflO6BSHOC3RusIxvIBn4Ge
         KGh92gweL+fvjh3ppYWSlz14D2XSUjQQCmwEs5y/0Y72nmOjpyCL8VkIM727AV7Z+82L
         PZnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k3si1946572qvh.30.2019.06.25.01.27.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 01:27:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E6258307CDD5;
	Tue, 25 Jun 2019 08:27:09 +0000 (UTC)
Received: from [10.36.117.83] (ovpn-117-83.ams2.redhat.com [10.36.117.83])
	by smtp.corp.redhat.com (Postfix) with ESMTP id DAB7C600C7;
	Tue, 25 Jun 2019 08:27:07 +0000 (UTC)
Subject: Re: [PATCH v2 1/5] drivers/base/memory: Remove unneeded check in
 remove_memory_block_devices
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
 pasha.tatashin@soleen.com, Jonathan.Cameron@huawei.com,
 anshuman.khandual@arm.com, vbabka@suse.cz, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190625075227.15193-1-osalvador@suse.de>
 <20190625075227.15193-2-osalvador@suse.de>
 <3e820fee-f82f-3336-ff34-31c66dbbbbfe@redhat.com>
 <0ed2f4ec-cc6f-8b81-46b0-d56d90ac1e86@redhat.com>
 <20190625080909.GA15394@linux>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <14272082-6ed4-a5d2-e275-2b4ebb53e65c@redhat.com>
Date: Tue, 25 Jun 2019 10:27:02 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190625080909.GA15394@linux>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Tue, 25 Jun 2019 08:27:10 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25.06.19 10:09, Oscar Salvador wrote:
> On Tue, Jun 25, 2019 at 10:03:31AM +0200, David Hildenbrand wrote:
>> On 25.06.19 10:01, David Hildenbrand wrote:
>>> On 25.06.19 09:52, Oscar Salvador wrote:
>>>> remove_memory_block_devices() checks for the range to be aligned
>>>> to memory_block_size_bytes, which is our current memory block size,
>>>> and WARNs_ON and bails out if it is not.
>>>>
>>>> This is the right to do, but we do already do that in try_remove_memory(),
>>>> where remove_memory_block_devices() gets called from, and we even are
>>>> more strict in try_remove_memory, since we directly BUG_ON in case the range
>>>> is not properly aligned.
>>>>
>>>> Since remove_memory_block_devices() is only called from try_remove_memory(),
>>>> we can safely drop the check here.
>>>>
>>>> To be honest, I am not sure if we should kill the system in case we cannot
>>>> remove memory.
>>>> I tend to think that WARN_ON and return and error is better.
>>>
>>> I failed to parse this sentence.
>>>
>>>>
>>>> Signed-off-by: Oscar Salvador <osalvador@suse.de>
>>>> ---
>>>>  drivers/base/memory.c | 4 ----
>>>>  1 file changed, 4 deletions(-)
>>>>
>>>> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>>>> index 826dd76f662e..07ba731beb42 100644
>>>> --- a/drivers/base/memory.c
>>>> +++ b/drivers/base/memory.c
>>>> @@ -771,10 +771,6 @@ void remove_memory_block_devices(unsigned long start, unsigned long size)
>>>>  	struct memory_block *mem;
>>>>  	int block_id;
>>>>  
>>>> -	if (WARN_ON_ONCE(!IS_ALIGNED(start, memory_block_size_bytes()) ||
>>>> -			 !IS_ALIGNED(size, memory_block_size_bytes())))
>>>> -		return;
>>>> -
>>>>  	mutex_lock(&mem_sysfs_mutex);
>>>>  	for (block_id = start_block_id; block_id != end_block_id; block_id++) {
>>>>  		mem = find_memory_block_by_id(block_id, NULL);
>>>>
>>>
>>> As I said when I introduced this, I prefer to have such duplicate checks
>>> in place in case we have dependent code splattered over different files.
>>> (especially mm/ vs. drivers/base). Such simple checks avoid to document
>>> "start and size have to be aligned to memory blocks".
>>
>> Lol, I even documented it as well. So yeah, if you're going to drop this
>> once, also drop the one in create_memory_block_devices().
> 
> TBH, I would not mind sticking with it.
> What sticked out the most was that in the previous check, we BUG_on while
> here we just print out a warning, so it seemed quite "inconsistent" to me.
> 
> And I only stumbled upon this when I was testing a kernel module that
> hot-removed memory in a different granularity.
> 
> Anyway, I do not really feel strong here, I can perfectly drop this patch as I
> would rather have the focus in the following-up patches, which are the important
> ones IMO.

Whetever you prefer, I can live with either :)

(yes, separating this patch from the others makes sense)

-- 

Thanks,

David / dhildenb


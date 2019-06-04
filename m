Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97340C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:56:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B68A24DFE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:56:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B68A24DFE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D455B6B000A; Tue,  4 Jun 2019 02:56:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF5D06B000D; Tue,  4 Jun 2019 02:56:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B97C66B0269; Tue,  4 Jun 2019 02:56:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9112B6B000A
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 02:56:46 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id o98so10168635ota.11
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 23:56:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=ymqVe3s6tfM0Y8vvFQ4JFNP+zdafSaUNycCSNHkfZOI=;
        b=iH3VAk4F8lVUXPh4R1NZxVzIvSJGjz1siD1AnIWyEh/lSo5ztL/A1exGUjaEzqnEls
         1vyA4b5rH/+HUVA3mNfUdD4KRmPlAKZ1drYz6mv4nNU46j6iWkA0lR0aznv7SMDQHI3p
         +3pcddgOVXWNvsxWqE5MZ92qvWNRwtuyC2eB+58I7UVbCH2FgYNUp9XOx0dO5E+ws4hc
         q6KAXXCZIYCRHM5TNrzqG1C3FhIYn5t3T59RL0CgwXQhBPOsZgwuAeRDugOQSgGpzQJ5
         bbMExLbf/QabGTsjWJa0/NfgiH42M6H5RgskOMJUNKypzJDkrXmqG73fV5/eeNL+uvyB
         4fOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU0oxbEHa618uAdGNPAd8WW+qV0/ici9mQCCaLAv/6mXgfYAhZF
	NIv7ynWrGy9RQiQP7o3O+I1ThEaFTuibOYyyA5+vxFP/p0xHqJl9lUPLvy6nuGu/qwGX2DHQ3pg
	IrlHLcL2VR+8wdPMbNvu3sOE2h6zC2Dhtixm54EehtN1a4iwcz6vGZlGNMfi01F3rNA==
X-Received: by 2002:aca:5b83:: with SMTP id p125mr3305550oib.164.1559631406295;
        Mon, 03 Jun 2019 23:56:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9H7jnYGQlgqpZivUpze3rlMrNY8NLgLNmNdQyh+aOjfxG0jufUl0og6CqDHVuacHW+Hqt
X-Received: by 2002:aca:5b83:: with SMTP id p125mr3305530oib.164.1559631405609;
        Mon, 03 Jun 2019 23:56:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559631405; cv=none;
        d=google.com; s=arc-20160816;
        b=gOs+Zj2sZubgxuaQSqM38MDxQVbvWKsNG43s0BaCgaruLpYjmx03hcYapsDnTsp5Nb
         S91nEBT3qiGLBd8tOFWAiam1kZIwNu3xfGX8+ri9C/fkJ3++ouhchrXfOqlIiMXCqM1n
         RITEqHCB2JNGH+BTQDilSwHOVZHRSIzatNoBwuZBIIup9aOLgIo96SnAR/JRJ8+D6qgi
         mcJnKNevlUQPqnYiTaU03xwJnLcWXdhmNr484aw40uGXlBcYH6Pr1v7H51TycazschX0
         RAaDAaEXpd15DNMLPbtySxiS4+p4ldcBGWyL/I3tVveNx37bDuYlfJSDvOfDhYn5r4ZT
         qApw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=ymqVe3s6tfM0Y8vvFQ4JFNP+zdafSaUNycCSNHkfZOI=;
        b=nInk1xKYUv151JKpNrjuJ3ONpDKJPsn3xriFc8kZ0Wq0caHiy1WxL1qCbKCrCyT4rL
         VW6BtMlHJprhIL94gmVd8MRcnA3+MG84QTyNnD08ttyp8NXOx5lT2gSFPx0oM63jQSAL
         eEMNt+HFSd7XyL0VVDMTH8T8crGgJEAUQ/sA/6L0LlnTkE0orAQNHW0YVhpphVo5TIT6
         0g+9zWmRq+oHhGo9CL3e3RgKtto908oRpvoS61OKmj9gNQoOJ0Y8fsHYu8KI7nwAa2A3
         E9lQieVSg7Sc3xkJUy6DEYRvGJHiwhttLWj0U4wkeeoZN8wZVJy2R1JX+6xBXsBR/4e0
         0txQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t26si8860969otl.82.2019.06.03.23.56.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 23:56:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EF1C2368E3;
	Tue,  4 Jun 2019 06:56:44 +0000 (UTC)
Received: from [10.36.117.37] (ovpn-117-37.ams2.redhat.com [10.36.117.37])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 61C2B60FD5;
	Tue,  4 Jun 2019 06:56:41 +0000 (UTC)
Subject: Re: [PATCH v3 05/11] drivers/base/memory: Pass a block_id to
 init_memory_block()
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
 Dan Williams <dan.j.williams@intel.com>, Igor Mammedov
 <imammedo@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-6-david@redhat.com>
 <20190603214932.3xsvxwiiutcve4tz@master>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <cd708cec-f369-4176-16c9-93a3c8ab6947@redhat.com>
Date: Tue, 4 Jun 2019 08:56:40 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190603214932.3xsvxwiiutcve4tz@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 04 Jun 2019 06:56:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03.06.19 23:49, Wei Yang wrote:
> On Mon, May 27, 2019 at 01:11:46PM +0200, David Hildenbrand wrote:
>> We'll rework hotplug_memory_register() shortly, so it no longer consumes
>> pass a section.
>>
>> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> ---
>> drivers/base/memory.c | 15 +++++++--------
>> 1 file changed, 7 insertions(+), 8 deletions(-)
>>
>> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>> index f180427e48f4..f914fa6fe350 100644
>> --- a/drivers/base/memory.c
>> +++ b/drivers/base/memory.c
>> @@ -651,21 +651,18 @@ int register_memory(struct memory_block *memory)
>> 	return ret;
>> }
>>
>> -static int init_memory_block(struct memory_block **memory,
>> -			     struct mem_section *section, unsigned long state)
>> +static int init_memory_block(struct memory_block **memory, int block_id,
>> +			     unsigned long state)
>> {
>> 	struct memory_block *mem;
>> 	unsigned long start_pfn;
>> -	int scn_nr;
>> 	int ret = 0;
>>
>> 	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
>> 	if (!mem)
>> 		return -ENOMEM;
>>
>> -	scn_nr = __section_nr(section);
>> -	mem->start_section_nr =
>> -			base_memory_block_id(scn_nr) * sections_per_block;
>> +	mem->start_section_nr = block_id * sections_per_block;
>> 	mem->end_section_nr = mem->start_section_nr + sections_per_block - 1;
>> 	mem->state = state;
>> 	start_pfn = section_nr_to_pfn(mem->start_section_nr);
>> @@ -694,7 +691,8 @@ static int add_memory_block(int base_section_nr)
>>
>> 	if (section_count == 0)
>> 		return 0;
>> -	ret = init_memory_block(&mem, __nr_to_section(section_nr), MEM_ONLINE);
>> +	ret = init_memory_block(&mem, base_memory_block_id(base_section_nr),
>> +				MEM_ONLINE);
> 
> If my understanding is correct, section_nr could be removed too.

Yes you are, this has already been addressed in linux-next.


-- 

Thanks,

David / dhildenb


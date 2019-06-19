Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51BD6C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 09:03:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 004C72080C
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 09:03:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 004C72080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 921F86B0003; Wed, 19 Jun 2019 05:03:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F85F8E0002; Wed, 19 Jun 2019 05:03:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E6448E0001; Wed, 19 Jun 2019 05:03:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D4356B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 05:03:54 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id k13so14859555qkj.4
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:03:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=csOWPk/qSqc8Sms/1Ae5io1JExjYKmvhMMQFit8FhSY=;
        b=h1lDSxmO5BU9C6XJFsde4l5YWSZ4QCpwyU8JzLVXOYNDaSlChbtTyvPG62CF5Dfarj
         xl5rqjA1QDyXrGEmU2J4uJbwbAdgL7pu8otSnVzaW1HpsAoOosU4z1imB4FIOpVh4NRl
         WerDBCB+Wfyo9Qmzsh53jDxPmvUkSrrKAi73lviLNfBXqhnbGTGogRscwHtQdlj5R6j9
         C+vwSQY/ng0xVXVKgOxamCe6gvGLSzPxylXYzGFuvJzrpkiCAxNUg1oYcNyBdwfKOFCM
         LXcRhVOdbjFsizn+4QyIqiBQTFl05AGwwA3r7FpJHDdxftpbCmHWUgmNwadyBnbI0lfw
         uOYw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXLTy2qkmhgMseWvQzFXA1gOhkmKQK39EMKI5EEjXNXpW6EQ27n
	g564KWIlgsTDoX4tnOfL4nPwjNifHK4GHKHtrqLmpmx6x3cGh/uxcUb6H1MgWk7ze+8K07XABwk
	RB2TZch4+PV9xTKSAF6FPUYP33TaT1LOMCaefg1w2ZZbKJEAhpHhOD0dQAx/kQutODg==
X-Received: by 2002:aed:2241:: with SMTP id o1mr92563233qtc.233.1560935034126;
        Wed, 19 Jun 2019 02:03:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7QnK/cEd7JOw0fLF8h5Nbz9MqagWK3A5xSItMvaBy900OZQEizdkvUbbWCfC03bHFxEYR
X-Received: by 2002:aed:2241:: with SMTP id o1mr92563186qtc.233.1560935033561;
        Wed, 19 Jun 2019 02:03:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560935033; cv=none;
        d=google.com; s=arc-20160816;
        b=R7BFnPaUhWPj5nIlnwFtpsC5diCw2PMBPeYZ60NvQgxFHSKd8dw96P4MsKPiKfFusN
         pzREJLixlDZ2rzZUE18aW1lrW1zpC0F0VS/kfVXZKAuAz2eV+ovdo3CuJ0FjDlscTVCl
         KT7ErE7dDDVcIHFp04/27uNzX/pKs2QBVDtgM/VuXf+3fEBymMyD97zHOb9xbaQgWqEl
         yIQpGt8tDZ8dUjEktbTlUlgnlCEzKEchvC+A8Drf5a1PIBqdilEqOC2LGuCp5ruoVpQV
         VSD1ue5r2jgIZXptlBBPWQYDiwc3/3jkIRt6rkLo0fDIi/qryVqYxExLHEFvHE3yzr0Y
         iEjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=csOWPk/qSqc8Sms/1Ae5io1JExjYKmvhMMQFit8FhSY=;
        b=wwoXGNQZziuFb3/vjqQ0DGniiXTSNWutoVcfgTWGz8JspStmY5hLiKV7fcT4S7m5lK
         jexk5SOP5nie7DRD4sMjYLycVRZDt8mJ+tp2Y7099CZ7gCfWKece1QzohNgFO23dQDeY
         szAVYQNTwOcwk82je1i3/2wDdG047KMssGA181RrOO2KNXbr69V1D3y+37uPSI7vqn87
         Z+u4Q0SWVMKcZTLx2tMoxNT1/fXe6jcOENd31u1nGXvdYcJJ/QMWECSDI5p0SKZseO5c
         sZqIkeMjJAkV7FHJXLNPS0ehYooDC/kFzkBTdn8bIJCtz0REf1YI740ulfag1yWszRfq
         ImXA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d22si2173142qtk.191.2019.06.19.02.03.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 02:03:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B5B222F8BFE;
	Wed, 19 Jun 2019 09:03:52 +0000 (UTC)
Received: from [10.36.117.229] (ovpn-117-229.ams2.redhat.com [10.36.117.229])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5B15484FF;
	Wed, 19 Jun 2019 09:03:50 +0000 (UTC)
Subject: Re: [PATCH v2] mm/sparse: set section nid for hot-add memory
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>,
 Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org,
 akpm@linux-foundation.org, anshuman.khandual@arm.com
References: <20190618005537.18878-1-richardw.yang@linux.intel.com>
 <20190618074900.GA10030@linux> <20190618083212.GA24738@richard>
 <93d7ea6c-135e-7f12-9d75-b3657862dea0@redhat.com>
 <20190619061025.GA5717@dhcp22.suse.cz>
 <aaa9d3af-0472-ffde-a565-fe6a067a4c49@redhat.com>
 <20190619090126.GI2968@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <5630056e-cc60-c451-714b-f8524eb70839@redhat.com>
Date: Wed, 19 Jun 2019 11:03:49 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190619090126.GI2968@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 19 Jun 2019 09:03:52 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 19.06.19 11:01, Michal Hocko wrote:
> On Wed 19-06-19 10:54:08, David Hildenbrand wrote:
>> On 19.06.19 08:10, Michal Hocko wrote:
>>> On Tue 18-06-19 10:40:06, David Hildenbrand wrote:
>>>> On 18.06.19 10:32, Wei Yang wrote:
>>>>> On Tue, Jun 18, 2019 at 09:49:48AM +0200, Oscar Salvador wrote:
>>>>>> On Tue, Jun 18, 2019 at 08:55:37AM +0800, Wei Yang wrote:
>>>>>>> In case of NODE_NOT_IN_PAGE_FLAGS is set, we store section's node id in
>>>>>>> section_to_node_table[]. While for hot-add memory, this is missed.
>>>>>>> Without this information, page_to_nid() may not give the right node id.
>>>>>>>
>>>>>>> BTW, current online_pages works because it leverages nid in memory_block.
>>>>>>> But the granularity of node id should be mem_section wide.
>>>>>>
>>>>>> I forgot to ask this before, but why do you mention online_pages here?
>>>>>> IMHO, it does not add any value to the changelog, and it does not have much
>>>>>> to do with the matter.
>>>>>>
>>>>>
>>>>> Since to me it is a little confused why we don't set the node info but still
>>>>> could online memory to the correct node. It turns out we leverage the
>>>>> information in memblock.
>>>>
>>>> I'd also drop the comment here.
>>>>
>>>>>
>>>>>> online_pages() works with memblock granularity and not section granularity.
>>>>>> That memblock is just a hot-added range of memory, worth of either 1 section or multiple
>>>>>> sections, depending on the arch or on the size of the current memory.
>>>>>> And we assume that each hot-added memory all belongs to the same node.
>>>>>>
>>>>>
>>>>> So I am not clear about the granularity of node id. section based or memblock
>>>>> based. Or we have two cases:
>>>>>
>>>>> * for initial memory, section wide
>>>>> * for hot-add memory, mem_block wide
>>>>
>>>> It's all a big mess. Right now, you can offline initial memory with
>>>> mixed nodes. Also on my list of many ugly things to clean up.
>>>>
>>>> (I even remember that we can have mixed nodes within a section, but I
>>>> haven't figured out yet how that is supposed to work in some scenarios)
>>>
>>> Yes, that is indeed the case. See 4aa9fc2a435abe95a1e8d7f8c7b3d6356514b37a.
>>> How to fix this? Well, I do not think we can. Section based granularity
>>> simply doesn't agree with the reality and so we have to live with that.
>>> There is a long way to remove all those section size assumptions from
>>> the code though.
>>>
>>
>> Trying to remove NODE_NOT_IN_PAGE_FLAGS could work, but we would have to
>> identify how exactly needs that. For memory blocks, we need a different
>> approach (I have in my head to make ->nid indicate if we are dealing
>> with mixed nodes. If mixed, disallow onlining/offlining).
> 
> Well, I am not sure we really have to care about mutli-nodes memblocks
> much. The API is clumsy but does anybody actually care? The vast
> majority of hotplug usecases simply do not do that in the first place
> right?

Yes, AFAIK it could be done, resulting in unpredictable outcome.

And if they do need a smaller granularity to describe their
> memory topology then we need a different user API rather the fiddle with
> implementation details I would argue.
> 

It is not about supporting it, it is about properly blocking it.

-- 

Thanks,

David / dhildenb


Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30F97C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 13:13:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA20121773
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 13:13:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA20121773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 291FF6B0003; Fri, 24 May 2019 09:13:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 243256B0006; Fri, 24 May 2019 09:13:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10A596B0007; Fri, 24 May 2019 09:13:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B94196B0003
	for <linux-mm@kvack.org>; Fri, 24 May 2019 09:13:55 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t58so14064090edb.22
        for <linux-mm@kvack.org>; Fri, 24 May 2019 06:13:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=3fw090aTVktVJ3NzZ7aWLVmJU6bW++ZMYzHZhNmKVZU=;
        b=YukBvz9xJY4DxPIkgpbpA9Z9/k0fzMHRIU8HhEKazne4wV5cm+wDM7oLgie1ZztHfS
         ULZDjzJ14nwwvu5Z2tbIhmXd0A04MeiyFij2Lhq8prnx8O+/X7MBKw+UhWvbAu5nB6g8
         inICDLfgeoXviOquwpEGGzWzeGXg7LP+sDF78Okv3HWfQA6Flpv+xCVWich4Ajij1Rjf
         NHQhnR2tVCzDB2rv7VANNlodyaEe0ELnQX2GEtLfnBpUxlaVUcD2X3g1aJojq3NYC2V/
         BMjLU6OulYCTjZesw2RHH2UuBZF18ryMQJJxsqcy9E4wUllOeL2iNCdkuLl8p54TGRkq
         etSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAX5UTRF1NvUIdSzZVvetBdxAmvlZo/LmACR/zDnnul21OL13ESn
	T2AiCj0FVQEEpEP3pQB3oL0xDEmiI0+cvhSWZDi8Y+97abvkakxgBg5zz/MKPhtVydTye38D0kq
	AIWJALdYMbCJN4x93ubuK6KYiu+NbyAtbYxRfJwp42JkKbHWuj7PtZFsg6Y6ggWdVmg==
X-Received: by 2002:a05:6402:1610:: with SMTP id f16mr105099110edv.171.1558703635320;
        Fri, 24 May 2019 06:13:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwTfbPLWC1qvJkOOfbZnpW9nq5D9Dt075bexDU9h100tA63TGGhIOqUldF/khN43zAPctN
X-Received: by 2002:a05:6402:1610:: with SMTP id f16mr105099003edv.171.1558703634445;
        Fri, 24 May 2019 06:13:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558703634; cv=none;
        d=google.com; s=arc-20160816;
        b=w+nDngIzJSYXNtSUOLAyI6rYoZz6Rd7geQZqz5st4gu75d1Eog7OiOwxW6k2H071o6
         yhUOYezYJa+FLW5MX7oM4Dmp10IT3W+m1TTTXij4Z/42d8DuBoQoYn9Q6x4BQ65p3TfX
         ol1OiFJHVgzjmb/5NuAE6EHFRijJ37p08LSJcUTC2sO4w/ApmRwksr3WfFiqoT6ww4vf
         txGnrSbo0SZaX8le5Sr0lXPAmXzfeGRhneZvw1KfOOMk77oK6dCdlG4ftF8geD1tL/8X
         y43PB9dQDJR4gQqoxYUx1GGTFtDoJp2TtnkOVsUPo+TU5rrXOdINv//tQ5KGmYIbck1p
         C/mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=3fw090aTVktVJ3NzZ7aWLVmJU6bW++ZMYzHZhNmKVZU=;
        b=m+WRs2tZ0gEU8nPVDfNQGgsMWS/nsU2xZnkrx0Br0nknEM4GhwR6y2GGhRDqenh3yP
         10ZOFw7OasmK394IfElcCCsp4jGcRt8Wjvx2TiRraFLZqsU1m8A+kinfRRCOgViz22ct
         u1Ebske7prsSNm5mY5+v05ZO1LEBqtRpvcpy6jPFmXKHzm0DHQfSSIjx9QWv/8HR0dD/
         8MtA2zbeKWhtnnY+UvofO9ztllnIdmndZPydiwKRFF/Sx1VL9evEJzlf6nrTVvh8R5fq
         FnGrP7Qo59X4Wf46aoh4En18bOROdWgQ5/Kh+7Yq8Gf70o6MtKm+o8MLJunLL+ra053u
         jx4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z5si1686544ejb.106.2019.05.24.06.13.53
        for <linux-mm@kvack.org>;
        Fri, 24 May 2019 06:13:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1388CA78;
	Fri, 24 May 2019 06:13:53 -0700 (PDT)
Received: from [10.162.42.134] (p8cg001049571a15.blr.arm.com [10.162.42.134])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 99E793F5AF;
	Fri, 24 May 2019 06:13:49 -0700 (PDT)
Subject: Re: mm/compaction: BUG: NULL pointer dereference
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Suzuki K Poulose <suzuki.poulose@arm.com>, linux-mm@kvack.org,
 akpm@linux-foundation.org, mhocko@suse.com, cai@lca.pw,
 linux-kernel@vger.kernel.org, marc.zyngier@arm.com,
 kvmarm@lists.cs.columbia.edu, kvm@vger.kernel.org
References: <1558689619-16891-1-git-send-email-suzuki.poulose@arm.com>
 <cfddd75a-b302-5557-05b8-2b328bba27c8@arm.com>
 <20190524123047.GO18914@techsingularity.net>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <9ae23db2-e696-047b-af18-1e75ebbda085@arm.com>
Date: Fri, 24 May 2019 18:43:59 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190524123047.GO18914@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/24/2019 06:00 PM, Mel Gorman wrote:
> On Fri, May 24, 2019 at 04:26:16PM +0530, Anshuman Khandual wrote:
>>
>>
>> On 05/24/2019 02:50 PM, Suzuki K Poulose wrote:
>>> Hi,
>>>
>>> We are hitting NULL pointer dereferences while running stress tests with KVM.
>>> See splat [0]. The test is to spawn 100 VMs all doing standard debian
>>> installation (Thanks to Marc's automated scripts, available here [1] ).
>>> The problem has been reproduced with a better rate of success from 5.1-rc6
>>> onwards.
>>>
>>> The issue is only reproducible with swapping enabled and the entire
>>> memory is used up, when swapping heavily. Also this issue is only reproducible
>>> on only one server with 128GB, which has the following memory layout:
>>>
>>> [32GB@4GB, hole , 96GB@544GB]
>>>
>>> Here is my non-expert analysis of the issue so far.
>>>
>>> Under extreme memory pressure, the kswapd could trigger reset_isolation_suitable()
>>> to figure out the cached values for migrate/free pfn for a zone, by scanning through
>>> the entire zone. On our server it does so in the range of [ 0x10_0000, 0xa00_0000 ],
>>> with the following area of holes : [ 0x20_0000, 0x880_0000 ].
>>> In the failing case, we end up setting the cached migrate pfn as : 0x508_0000, which
>>> is right in the center of the zone pfn range. i.e ( 0x10_0000 + 0xa00_0000 ) / 2,
>>> with reset_migrate = 0x88_4e00, reset_free = 0x10_0000.
>>>
>>> Now these cached values are used by the fast_isolate_freepages() to find a pfn. However,
>>> since we cant find anything during the search we fall back to using the page belonging
>>> to the min_pfn (which is the migrate_pfn), without proper checks to see if that is valid
>>> PFN or not. This is then passed on to fast_isolate_around() which tries to do :
>>> set_pageblock_skip(page) on the page which blows up due to an NULL mem_section pointer.
>>>
>>> The following patch seems to fix the issue for me, but I am not quite convinced that
>>> it is the right fix. Thoughts ?
>>>
>>>
>>> diff --git a/mm/compaction.c b/mm/compaction.c
>>> index 9febc8c..9e1b9ac 100644
>>> --- a/mm/compaction.c
>>> +++ b/mm/compaction.c
>>> @@ -1399,7 +1399,7 @@ fast_isolate_freepages(struct compact_control *cc)
>>>  				page = pfn_to_page(highest);
>>>  				cc->free_pfn = highest;
>>>  			} else {
>>> -				if (cc->direct_compaction) {
>>> +				if (cc->direct_compaction && pfn_valid(min_pfn)) {
>>>  					page = pfn_to_page(min_pfn);
>>
>> pfn_to_online_page() here would be better as it does not add pfn_valid() cost on
>> architectures which does not subscribe to CONFIG_HOLES_IN_ZONE. But regardless if
>> the compaction is trying to scan pfns in zone holes, then it should be avoided.
> 
> CONFIG_HOLES_IN_ZONE typically applies in special cases where an arch
> punches holes within a section. As both do a section lookup, the cost is
> similar but pfn_valid in general is less subtle in this case. Normally
> pfn_valid_within is only ok when a pfn_valid check has been made on the
> max_order aligned range as well as a zone boundary check. In this case,
> it's much more straight-forward to leave it as pfn_valid.

Sure, makes sense.


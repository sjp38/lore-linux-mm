Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BF29C282DA
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 14:43:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B7AE208C0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 14:43:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B7AE208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB5F26B0010; Tue,  9 Apr 2019 10:43:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C647D6B0269; Tue,  9 Apr 2019 10:43:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2E946B026A; Tue,  9 Apr 2019 10:43:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 683446B0010
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 10:43:27 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l19so8662121edr.12
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 07:43:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=POBBhKXh7zW2WcFHIt6RBnZ+MCssZ0smmDtbk80yIDc=;
        b=oDR7J2dnknoPDmNcBB2ygjQPErztkDlCE7lbrv/i1pNkVSFwV/cQB3IcMeP0GX2UIe
         rNGBXx2FdBaBH8PjfMXM4TcshdQTSuUE7XCXaYQg2EJHLDq7M8TkLevhq9E3Cn/qBKgC
         mCTq0csx7fY2k7HFZ7FBhBdIwubv6QYiMXGk2fZCC6I1wVdaSY+6DjC4wDqLv3TpGGvS
         CBtFU4ktxRwvPsSUsxzqhcY6vT20UC3ougrY0TZZw3uLv10WDNoCV6XMs/cRD12D6/kM
         P04/1pbh8NrjLFPvMPuOIwA230gur3u288SoSbWCHV78Rtc3aXoU8pf7Kly9bOayjX3V
         NNdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAX3HsH1KiObk4lkb33iY0Fe+FnrQf7OujvLm49X42pzp9XpjLdz
	F1+AhVKWnXTuxWYGgGxiC5T01o7FdptF4YaIlZcAusS2AydqgPh3VNFFQzm00XH4mIcuCSm7wpC
	rTEZVcJLxiB9fJYnL2DdUpmhV7FX32noEQqawGVex2aJFbJ/asGHNvfGzEDRycFCGtg==
X-Received: by 2002:a50:cb06:: with SMTP id g6mr5900104edi.89.1554821006973;
        Tue, 09 Apr 2019 07:43:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzg2DHD9sk8ZKUB6UBhWd5eSIs2m0oYJcayN6xmo/PW7upaehu4UwgY6T2RMZSyTZowBxwp
X-Received: by 2002:a50:cb06:: with SMTP id g6mr5900068edi.89.1554821006101;
        Tue, 09 Apr 2019 07:43:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554821006; cv=none;
        d=google.com; s=arc-20160816;
        b=Gd0K8o6rbmbZbHLzCDPSomho20xR8mJW4eBrsovboOd6v6a/UceZyTL2qy2luvuBcH
         JPlPnh2qvjrsvB1tVwlS8Vot9rpt7485DNCwpeBJ3cw1mYb6m/se/s2O6Ni5apqJ/iPr
         jtSCQW5xCQc0h4ElrawpeIqznSyXu5Rc75moM+vNou3grMDumb5vTSKPpkNOWXBkwoIY
         xvohKil57IGAwcLY8fKJ7fBX05dhWh5MoSfn3m0k8I1EwIkzqmGQNTvqWo04eTki2/hJ
         wrvvP1toWWz2FVzKVM5z4GH4TaDdVDAXv//vyNnK6Ib3r47jjb968BmDxDnuhAhGe7EY
         L36A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=POBBhKXh7zW2WcFHIt6RBnZ+MCssZ0smmDtbk80yIDc=;
        b=gN4tvLF7HxLtY6BxoU5hnqqnzv+12sFhczSyJ3j/EsvDILvNqSEVh7qF8cc/ALoEs7
         +ESavko9hvx0HFfy6s8DLGqyE8KZdq+wYc6o7NWq8dP0fVcchtwxbwPyl5bFwmi+a3XU
         JvJp8Ri2L5LJx9MOyYymGSPILlxkqehFZ8QaLMPmQyRq3JznkYwGSR6GKsoyauG07DJJ
         P+hMZFvQzpWXize4d6aFd2fZd3b3HQ8eaeHYnjGh3Uzowdi/3GR16dW09hofYOgsI+j5
         sNV49/l9C8nhku4uJddmY0/+PdQxENqkZLinm0eBzMKJK33j313TWowud26+r1ogDASy
         PCeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y22si656214ejr.376.2019.04.09.07.43.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 07:43:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2033EAFDA;
	Tue,  9 Apr 2019 14:43:25 +0000 (UTC)
Subject: Re: [PATCH] mm/vmstat: fix /proc/vmstat format for
 CONFIG_DEBUG_TLBFLUSH=y CONFIG_SMP=n
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Roman Gushchin <guro@fb.com>, Jann Horn <jannh@google.com>
References: <155481488468.467.4295519102880913454.stgit@buzz>
 <a606145d-b2e6-a55d-5e62-52492309e7dc@suse.cz>
 <bfcc286e-48dd-8069-3287-a923e4b5ab65@yandex-team.ru>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <81880eb3-ab26-e968-1820-5d5e46f82836@suse.cz>
Date: Tue, 9 Apr 2019 16:43:24 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <bfcc286e-48dd-8069-3287-a923e4b5ab65@yandex-team.ru>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/9/19 3:28 PM, Konstantin Khlebnikov wrote:
> On 09.04.2019 16:16, Vlastimil Babka wrote:
>> On 4/9/19 3:01 PM, Konstantin Khlebnikov wrote:
>>> Commit 58bc4c34d249 ("mm/vmstat.c: skip NR_TLB_REMOTE_FLUSH* properly")
>>> depends on skipping vmstat entries with empty name introduced in commit
>>> 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable in /proc/vmstat")
>>> but reverted in commit b29940c1abd7 ("mm: rename and change semantics of
>>> nr_indirectly_reclaimable_bytes").
>> 
>> Oops, good catch.
> 
> Also 4.19.y has broken format in /sys/devices/system/node/node*/vmstat and /proc/zoneinfo.
> Do you have any plans on pushing related slab changes into that stable branch?

Hmm do you mean this?
https://lore.kernel.org/linux-mm/20181030174649.16778-1-guro@fb.com/

Looks like Roman marked it wrongly for # 4.14.x-4.18.x and I didn't notice, my
slab changes are indeed 4.20, so we should resend for 4.19.

>> 
>>> So, skipping no longer works and /proc/vmstat has misformatted lines " 0".
>>> This patch simply shows debug counters "nr_tlb_remote_*" for UP.
>> 
>> Right, that's the the best solution IMHO.
>> 
>>> Fixes: 58bc4c34d249 ("mm/vmstat.c: skip NR_TLB_REMOTE_FLUSH* properly")
>>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>> 
>> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>> 
>>> ---
>>>   mm/vmstat.c |    5 -----
>>>   1 file changed, 5 deletions(-)
>>>
>>> diff --git a/mm/vmstat.c b/mm/vmstat.c
>>> index 36b56f858f0f..a7d493366a65 100644
>>> --- a/mm/vmstat.c
>>> +++ b/mm/vmstat.c
>>> @@ -1274,13 +1274,8 @@ const char * const vmstat_text[] = {
>>>   #endif
>>>   #endif /* CONFIG_MEMORY_BALLOON */
>>>   #ifdef CONFIG_DEBUG_TLBFLUSH
>>> -#ifdef CONFIG_SMP
>>>   	"nr_tlb_remote_flush",
>>>   	"nr_tlb_remote_flush_received",
>>> -#else
>>> -	"", /* nr_tlb_remote_flush */
>>> -	"", /* nr_tlb_remote_flush_received */
>>> -#endif /* CONFIG_SMP */
>>>   	"nr_tlb_local_flush_all",
>>>   	"nr_tlb_local_flush_one",
>>>   #endif /* CONFIG_DEBUG_TLBFLUSH */
>>>
>> 
> 


Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E62AC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 13:28:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7C57206DE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 13:28:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="iBaYW+pz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7C57206DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 663326B000E; Tue,  9 Apr 2019 09:28:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60F166B0010; Tue,  9 Apr 2019 09:28:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B27A6B0266; Tue,  9 Apr 2019 09:28:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id D73F36B000E
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 09:28:22 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id 6so4743912lje.9
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 06:28:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=VjRruI8djhucgyAMlj7xodONb9ALXoGATbrjszORgNQ=;
        b=ptzERRLuQwPJZO3SECYDARMuaOpQhGeduE803FkK3tgpQzceV94pyHIID6mvaKj6+e
         2/0WhtXcqn8KAjT+xn/hDSTnVuMJfQxDOUcovg9NaLGkrMaJqKxGXxezV3NKXa/TKxlF
         pWyc/yDy+2hHFVw/2NVhDcXw1By6qm4rSNea5VqrAMD8vMuuzQsUls+Fg9ZzCtmWsOX8
         1nibBeKgN+0iPVGlo3o9Geh4eEuUBVkMkYtH69FHq4BNcv8pNpXhwNMXw2qLs2IzaIwE
         slQh9YbvQ8UykyYF0C0BBvqoG+intwLRwBfnaCrgTNrKisGlk0M0iZo0lb712oaYfjIC
         8RpQ==
X-Gm-Message-State: APjAAAVtr/ZwCIi3M6tvsmbITaW3uo8wCcl9xGXV6wRIAOq6vRcJnqAX
	gIKHQp8mTGEUhY9l/0UtLygpxEhdJbT76cx5JxREPI2/N45fdIhslBhgFy73bsF3kWjqDClUIuN
	GeERv8eFE3r+ApSnLdiHZXpBPFXHusJCLFrFy4lxOyPzQvtf+P/zQtGnaMlLWHqbYOw==
X-Received: by 2002:ac2:51aa:: with SMTP id f10mr19299015lfk.82.1554816502272;
        Tue, 09 Apr 2019 06:28:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygFnBEHdywOORHKrP++Dm0dWW4N9znntyh17MU8q9QOew3e6YjfRu9pG4JiRA/y3ZC4N4i
X-Received: by 2002:ac2:51aa:: with SMTP id f10mr19298947lfk.82.1554816501257;
        Tue, 09 Apr 2019 06:28:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554816501; cv=none;
        d=google.com; s=arc-20160816;
        b=J4x6KNJYoVqheusEJWBXCT9T81LkUnN1mmLZuegFicMEuScNsJ5sLjD4tiEbqOX7ug
         RXr11mp4D/mU3r+x39C9tXsgb9qcp5AY9mejmKM47+Ov3CcK3UQNEheOVM//UkjzwVJK
         Id6hM0eTCOFF2OctMUAdIy/eYVGHM6AswK6gqQtD1hp3T2pogSEQ81rPnnMMJ+OIn98p
         7ChFjeycSLiI4HCEsIZFDXZJcq1w1nTbBgE1Jp/niO4hDiqy7SdrZ0dO9AW5HH0DQixa
         NCfK3VEQ+0X0qYbGkFq4kGckJGKIHEVZ2G4RHWufGYmX9YsT5Pig8Uw0jKrELg5amaf9
         RkiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=VjRruI8djhucgyAMlj7xodONb9ALXoGATbrjszORgNQ=;
        b=1KpuEEpoWCUmVxBrr+bm9LgX7MKeoJX1LcD3rSAH88L62mwfwqrKumWP86TcuqRzY7
         Ge8JoE1Vv4z+ZaUZy2K1vwQ2ByqkNsuvgvebu8aA05+sH/mpOedJpm9YB7aAO+mtz1nN
         y+0Yyd5zytUvl4b8sx4PJJXzeOX6eYfVo+OtTuSZTUUc1s5groNnmWgmqjJ5pPHVtDeA
         jrLkJy/Xp4zL9k4h0dqoP/aPgOA6H3jocJED4RY+9vnOV6mIBYZ1c8XSwvEBWpVmtOFL
         tizOqWRiGkotMnBIrMcIzuiDSSSExRUeM4wTj54Ha4NqX3iwB/AQQQNBTqnb6io+NJq7
         tvuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=iBaYW+pz;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [2a02:6b8:0:1a2d::193])
        by mx.google.com with ESMTP id w7si22655939lfn.14.2019.04.09.06.28.21
        for <linux-mm@kvack.org>;
        Tue, 09 Apr 2019 06:28:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) client-ip=2a02:6b8:0:1a2d::193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=iBaYW+pz;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1g.mail.yandex.net (mxbackcorp1g.mail.yandex.net [IPv6:2a02:6b8:0:1402::301])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id D18EB2E14F6;
	Tue,  9 Apr 2019 16:28:20 +0300 (MSK)
Received: from smtpcorp1p.mail.yandex.net (smtpcorp1p.mail.yandex.net [2a02:6b8:0:1472:2741:0:8b6:10])
	by mxbackcorp1g.mail.yandex.net (nwsmtp/Yandex) with ESMTP id KfSHyaGGju-SKoCjpoD;
	Tue, 09 Apr 2019 16:28:20 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1554816500; bh=VjRruI8djhucgyAMlj7xodONb9ALXoGATbrjszORgNQ=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=iBaYW+pzOtFft2RoU1ryob84UBiaY7uSRN8YNSAOOXMnGgwxCK1uSLiBzDBNPX30d
	 3i34ePUzjxeUTeB6FsiY7msfRNXPlOfl1PetsKt3HA6OhipcVo/g2H+chvJNO62lT+
	 T5Jr8LoymiWlljXZNHvS7eiZa+HoV0OOKRWw27MI=
Authentication-Results: mxbackcorp1g.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-vpn.dhcp.yndx.net (dynamic-vpn.dhcp.yndx.net [2a02:6b8:0:3711::1:6d])
	by smtpcorp1p.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id Xv5rbSDqdC-SK08xJE1;
	Tue, 09 Apr 2019 16:28:20 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH] mm/vmstat: fix /proc/vmstat format for
 CONFIG_DEBUG_TLBFLUSH=y CONFIG_SMP=n
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Roman Gushchin <guro@fb.com>, Jann Horn <jannh@google.com>
References: <155481488468.467.4295519102880913454.stgit@buzz>
 <a606145d-b2e6-a55d-5e62-52492309e7dc@suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <bfcc286e-48dd-8069-3287-a923e4b5ab65@yandex-team.ru>
Date: Tue, 9 Apr 2019 16:28:18 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <a606145d-b2e6-a55d-5e62-52492309e7dc@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09.04.2019 16:16, Vlastimil Babka wrote:
> On 4/9/19 3:01 PM, Konstantin Khlebnikov wrote:
>> Commit 58bc4c34d249 ("mm/vmstat.c: skip NR_TLB_REMOTE_FLUSH* properly")
>> depends on skipping vmstat entries with empty name introduced in commit
>> 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable in /proc/vmstat")
>> but reverted in commit b29940c1abd7 ("mm: rename and change semantics of
>> nr_indirectly_reclaimable_bytes").
> 
> Oops, good catch.

Also 4.19.y has broken format in /sys/devices/system/node/node*/vmstat and /proc/zoneinfo.
Do you have any plans on pushing related slab changes into that stable branch?

> 
>> So, skipping no longer works and /proc/vmstat has misformatted lines " 0".
>> This patch simply shows debug counters "nr_tlb_remote_*" for UP.
> 
> Right, that's the the best solution IMHO.
> 
>> Fixes: 58bc4c34d249 ("mm/vmstat.c: skip NR_TLB_REMOTE_FLUSH* properly")
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
>> ---
>>   mm/vmstat.c |    5 -----
>>   1 file changed, 5 deletions(-)
>>
>> diff --git a/mm/vmstat.c b/mm/vmstat.c
>> index 36b56f858f0f..a7d493366a65 100644
>> --- a/mm/vmstat.c
>> +++ b/mm/vmstat.c
>> @@ -1274,13 +1274,8 @@ const char * const vmstat_text[] = {
>>   #endif
>>   #endif /* CONFIG_MEMORY_BALLOON */
>>   #ifdef CONFIG_DEBUG_TLBFLUSH
>> -#ifdef CONFIG_SMP
>>   	"nr_tlb_remote_flush",
>>   	"nr_tlb_remote_flush_received",
>> -#else
>> -	"", /* nr_tlb_remote_flush */
>> -	"", /* nr_tlb_remote_flush_received */
>> -#endif /* CONFIG_SMP */
>>   	"nr_tlb_local_flush_all",
>>   	"nr_tlb_local_flush_one",
>>   #endif /* CONFIG_DEBUG_TLBFLUSH */
>>
> 


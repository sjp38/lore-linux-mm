Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEE7AC10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 15:14:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 372AD2084F
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 15:14:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="hzUCGN+h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 372AD2084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C01596B0010; Tue,  9 Apr 2019 11:14:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8B506B0269; Tue,  9 Apr 2019 11:14:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A7A796B026A; Tue,  9 Apr 2019 11:14:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 42BA56B0010
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 11:14:54 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id j20so2437376lfh.23
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 08:14:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Zq7XV50n7QXA0gzTBdPE0IaBxIK3vgM1+6amziQnoP4=;
        b=Ur7TlTTctOhQWfCAFEXDMeQP3BYP8t+Lc1i8NboaVjwnVw2kKrA9tW+HtkTuh6J1w2
         amIJRktEii2R8s6KsU736whmxSKIwsWV8/LaAeD4TON81WAr33TNQ9o9PlxQ/ACObhS5
         PtUoTze4AtXFIwsoI2g3EwHZhhLizSN4xV2YuVsIo1zXGY/oGKO61eGhYHjgiSeYitj0
         JpYvtIHFZF0llrLNJL/EJiWVE5t6m0daTPCXhX21UggqZvggMrEj6hsj4R709Sb/wBol
         GZ8ss0u0lXdQyz4vQpEYKAhlg5U/8PNh4IFM/ZHC3bfyMEyHbVlv5MtiaMQUFoqo0G2D
         dtpA==
X-Gm-Message-State: APjAAAWvfL4TKcYZj4vKU52xCPVFgPAJuPMIbf9TVZr8RWEXqaVul8XH
	D4/XZhteiK/z+LHYz1tDmxmf+7UO6NxCskiRCQ7HMg34dpp6+ppS8QvcP9xTaK4eXx3xDqLaqEB
	Sb1EWvJbHdr0IqyMVdstVmM/9Ux6EJXNS03F2Fqaise6zVl0EGeIp+TH1KuM5L0vKjg==
X-Received: by 2002:ac2:5a0e:: with SMTP id q14mr19090222lfn.47.1554822893471;
        Tue, 09 Apr 2019 08:14:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxApa44ExwmRd+cDup7WTzHLiDPsSpldt7DLBqWEte7r2FDIsopY4KqFenBToasGY6E/NJ4
X-Received: by 2002:ac2:5a0e:: with SMTP id q14mr19090166lfn.47.1554822892358;
        Tue, 09 Apr 2019 08:14:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554822892; cv=none;
        d=google.com; s=arc-20160816;
        b=ir+YwEU+7Q6q1R6X3Ju+stG/xkiTej5rYBRnTpli00j8Xcm6jxiIWKrw3ixxApP8Tr
         V9pIN5FPuCSWqBckHqfYfiDWMpMkCwU/5PSxHoJTnRpM890iiO9fDay10SuS9cFCt7p/
         JpkYf1beODNqImZn9XhI5i2qkzg+hEi6axiGZSErlrspsJSwi+Cu8YfOH/4WeK8g4Gjs
         0nq69aLHilhJTUHlEZFsQszeVSwtq9kms3VM5d+qaM30bf+aJhT7tHnja9WeoR9KbR7b
         5JR9mG6gE8KeK6BMAG3foywM+tFVEIdPDDGCZeiwNI9UpQkB/5ygIemPeVIwxnKGr4jy
         ccLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=Zq7XV50n7QXA0gzTBdPE0IaBxIK3vgM1+6amziQnoP4=;
        b=znGTMA1rhQ+R+uYjxEfGmojtEH2y2cB+qOaSmMHEFmDPp8U/498dn/4Pd2Edo24bWQ
         ZAWbUXO27zek/v/cGZP2kQhHU/JdGrC6VboldjLZVrid2SbpfuQmw+xBYOWHiaE9+RK9
         ttkd/bX7v5xkHEouj3ldPAe/xRkMEFIIA2KyK6/OnTl3QJ7Zqf2nDfIM7sAHGjnB5CLz
         8f35Ef4O9SctIqQH5SlFCDVEv6wl4NF8DhvbYda2/xdAlzI7TU6Yb1ft4GPKZsOR0swo
         CD5LGwMY9IjzDyierfAHETglsry2ECo0VgJvaTzKwi+TotxT+Aj6E2In2BUHGnjGnvZc
         jaQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=hzUCGN+h;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [2a02:6b8:0:1a2d::193])
        by mx.google.com with ESMTP id u8si29693268ljg.36.2019.04.09.08.14.52
        for <linux-mm@kvack.org>;
        Tue, 09 Apr 2019 08:14:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) client-ip=2a02:6b8:0:1a2d::193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=hzUCGN+h;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1o.mail.yandex.net (mxbackcorp1o.mail.yandex.net [IPv6:2a02:6b8:0:1a2d::301])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id A76C12E124E;
	Tue,  9 Apr 2019 18:14:51 +0300 (MSK)
Received: from smtpcorp1p.mail.yandex.net (smtpcorp1p.mail.yandex.net [2a02:6b8:0:1472:2741:0:8b6:10])
	by mxbackcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTP id O6B4N7cw9s-Epe4nNAf;
	Tue, 09 Apr 2019 18:14:51 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1554822891; bh=Zq7XV50n7QXA0gzTBdPE0IaBxIK3vgM1+6amziQnoP4=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=hzUCGN+hKdMsnX47sEsw2Dh0TaJ17wBUMk+eFFp8yvRU2HIJV31WqaqlcNctOm3Pv
	 hfhK/fBuSyBHWdBY6jFCRWFyZcORXl/BvxMdA/5KU9DOedFOH7Rm5xlSCu4sro9nRk
	 m2BapnreM33Zyj5NR1hxDyw/NdqG2O/7gWnFQ9Qw=
Authentication-Results: mxbackcorp1o.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-vpn.dhcp.yndx.net (dynamic-vpn.dhcp.yndx.net [2a02:6b8:0:3711::1:6d])
	by smtpcorp1p.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id Nakda5vvvL-Ep0iGsqr;
	Tue, 09 Apr 2019 18:14:51 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH] mm/vmstat: fix /proc/vmstat format for
 CONFIG_DEBUG_TLBFLUSH=y CONFIG_SMP=n
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Roman Gushchin <guro@fb.com>, Jann Horn <jannh@google.com>
References: <155481488468.467.4295519102880913454.stgit@buzz>
 <a606145d-b2e6-a55d-5e62-52492309e7dc@suse.cz>
 <bfcc286e-48dd-8069-3287-a923e4b5ab65@yandex-team.ru>
 <81880eb3-ab26-e968-1820-5d5e46f82836@suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <abd24dbf-c5b2-1222-c066-5a6736ad3ecb@yandex-team.ru>
Date: Tue, 9 Apr 2019 18:14:50 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <81880eb3-ab26-e968-1820-5d5e46f82836@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 09.04.2019 17:43, Vlastimil Babka wrote:
> On 4/9/19 3:28 PM, Konstantin Khlebnikov wrote:
>> On 09.04.2019 16:16, Vlastimil Babka wrote:
>>> On 4/9/19 3:01 PM, Konstantin Khlebnikov wrote:
>>>> Commit 58bc4c34d249 ("mm/vmstat.c: skip NR_TLB_REMOTE_FLUSH* properly")
>>>> depends on skipping vmstat entries with empty name introduced in commit
>>>> 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable in /proc/vmstat")
>>>> but reverted in commit b29940c1abd7 ("mm: rename and change semantics of
>>>> nr_indirectly_reclaimable_bytes").
>>>
>>> Oops, good catch.
>>
>> Also 4.19.y has broken format in /sys/devices/system/node/node*/vmstat and /proc/zoneinfo.
>> Do you have any plans on pushing related slab changes into that stable branch?
> 
> Hmm do you mean this?
> https://lore.kernel.org/linux-mm/20181030174649.16778-1-guro@fb.com/
> 
> Looks like Roman marked it wrongly for # 4.14.x-4.18.x and I didn't notice, my
> slab changes are indeed 4.20, so we should resend for 4.19.

Yep, this should fix zoneinfo
but /sys/devices/system/node/node*/vmstat needs yet another fix.

> 
>>>
>>>> So, skipping no longer works and /proc/vmstat has misformatted lines " 0".
>>>> This patch simply shows debug counters "nr_tlb_remote_*" for UP.
>>>
>>> Right, that's the the best solution IMHO.
>>>
>>>> Fixes: 58bc4c34d249 ("mm/vmstat.c: skip NR_TLB_REMOTE_FLUSH* properly")
>>>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>>>
>>> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>>>
>>>> ---
>>>>    mm/vmstat.c |    5 -----
>>>>    1 file changed, 5 deletions(-)
>>>>
>>>> diff --git a/mm/vmstat.c b/mm/vmstat.c
>>>> index 36b56f858f0f..a7d493366a65 100644
>>>> --- a/mm/vmstat.c
>>>> +++ b/mm/vmstat.c
>>>> @@ -1274,13 +1274,8 @@ const char * const vmstat_text[] = {
>>>>    #endif
>>>>    #endif /* CONFIG_MEMORY_BALLOON */
>>>>    #ifdef CONFIG_DEBUG_TLBFLUSH
>>>> -#ifdef CONFIG_SMP
>>>>    	"nr_tlb_remote_flush",
>>>>    	"nr_tlb_remote_flush_received",
>>>> -#else
>>>> -	"", /* nr_tlb_remote_flush */
>>>> -	"", /* nr_tlb_remote_flush_received */
>>>> -#endif /* CONFIG_SMP */
>>>>    	"nr_tlb_local_flush_all",
>>>>    	"nr_tlb_local_flush_one",
>>>>    #endif /* CONFIG_DEBUG_TLBFLUSH */
>>>>
>>>
>>
> 


Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31391C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 17:13:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3BD22086D
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 17:13:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3BD22086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87B9D6B0008; Tue, 11 Jun 2019 13:13:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82C676B000A; Tue, 11 Jun 2019 13:13:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71A226B000C; Tue, 11 Jun 2019 13:13:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3A3DB6B0008
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 13:13:03 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id o184so10057379pfg.1
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:13:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=vuHq9B1aoWOaYBu7ywq8Wc6FcpUAvHQw4AOpcLoWUm8=;
        b=XOZZkS1EhhvWLgln/z9sYBsmf9j0MrR8oBcgwU5SyOTy8JR4X06Df4fHaIF1Xet3z+
         7ndXOkgeyJ8ws02SaD4exNDvBImquyKJZjf4sNmi0/TU7urKZU+tW2CxCl+0iroXybg6
         Fc2OimI9Y2DpW3x9Nc9OYPE7dEnnIpzQMG3T0q18BmxBBr6EeCVaIw++/SeAQBUKU6PY
         Ix2PnnUE50/I5GEAZT87XsxD8k5ivRa0pBup0ZDPSDfvo2L8Oaem5JSzKMwQEfJI9kwC
         3kuvAZw/rwuKEDeO5sMTQccFkwgWRN5P0bFzyM7mu2228aNbo8EQCPLEzGTIVxgVtao3
         FmaA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWZjiXoD3cbpGMDGhh0uwgiDrzn7nQKcmjgyeXD7BuVksARcpZ0
	5lDtDYeQRqSlkRrqCo5aJArVP7XzRAJL8W/JE1D+O8pW+Ex4bUGs3xAW4B/Xuhn6GsaJ7ttuxv/
	k/XOndYBtMdXFffwx9TVQJTIFBfhalKtXJp9FzojNqa084iSUDsQsa7ESjBgtElgm6g==
X-Received: by 2002:a62:b517:: with SMTP id y23mr84250634pfe.182.1560273182756;
        Tue, 11 Jun 2019 10:13:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtZWrILL29SXL5heUmZ71lETvmF8axsxLBha1SvrZ/QFEmCErL46RrH+3CeUs8SoB3oAuu
X-Received: by 2002:a62:b517:: with SMTP id y23mr84250554pfe.182.1560273181945;
        Tue, 11 Jun 2019 10:13:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560273181; cv=none;
        d=google.com; s=arc-20160816;
        b=OrJRcHh9eiOohN/8XkGBAxDmlOHuviIQ/VLt3lPbisBbKrVA6pLluALbPfAJWHHKAf
         n8eZIzajYwV4YpwVar8JiTIQ7J3x1aIVJJGwFUger3RBlXTqs2Z3PEzR36LqSILc9eR8
         ZxJ6NGIm+lFpUUEfIYnxCwzVEb7gUNFdhP7M3II5BgLhj//IdfV4ptXWq8CQa8YC8nDs
         s8BLWCFxgvgSxHLrioC43mUK1LuCG6zuGdnCYubKDyzYTbkWmKK+vj8oeD+BADddV4lp
         vG+wIB2xvgF80CELwZLQGRMxVsHAb5OXhTGJhkKA7wGUSQOuPAWuJiISGHTRSePFlhhA
         fJeg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=vuHq9B1aoWOaYBu7ywq8Wc6FcpUAvHQw4AOpcLoWUm8=;
        b=fdqc24vyjvbmKpJDCv7uw9ssSKpxhl/J5BTX+vfeISIe6ac4Wij+QF5rie2UpDYMVY
         BioTOB5NPm9gXavvB4oyOZApn2Oj2hmLA9MiE5gGnIDwhqv2NKouIWMp69ni3kr7hbFo
         Nkhsc4sJkRzpdApnsOYwVXsj2DuhsA5+yKLhW35gQgBYbWyIJ/MsTT+/tTWNcPWjVwj/
         plAJoHp+o4PlPgfRtDnLXl7uBQkWrHEvigbQnVFXsXPx4vBCfTKUW5Hun0SCeTXZYODX
         oyBgE4E/sWSHWI0eNXEISaRAGG62yFBIvxnSqMGl4hPKfVx3TpPbmc7+ga/q06QLgZpl
         Mbmw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id b5si2936051pjo.26.2019.06.11.10.13.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 10:13:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TTwX3IJ_1560273151;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TTwX3IJ_1560273151)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 12 Jun 2019 01:12:35 +0800
Subject: Re: [v7 PATCH 1/2] mm: vmscan: remove double slab pressure by inc'ing
 sc->nr_scanned
To: Oscar Salvador <osalvador@suse.de>, ying.huang@intel.com,
 hannes@cmpxchg.org, mhocko@suse.com, mgorman@techsingularity.net,
 kirill.shutemov@linux.intel.com, josef@toxicpanda.com, hughd@google.com,
 shakeelb@google.com, hdanton@sina.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1559025859-72759-1-git-send-email-yang.shi@linux.alibaba.com>
 <1560202615.3312.6.camel@suse.de>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <d99fbe8f-9c80-d407-e848-0be00e3b8886@linux.alibaba.com>
Date: Tue, 11 Jun 2019 10:12:25 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <1560202615.3312.6.camel@suse.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000043, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/10/19 2:36 PM, Oscar Salvador wrote:
> On Tue, 2019-05-28 at 14:44 +0800, Yang Shi wrote:
>> The commit 9092c71bb724 ("mm: use sc->priority for slab shrink
>> targets")
>> has broken up the relationship between sc->nr_scanned and slab
>> pressure.
>> The sc->nr_scanned can't double slab pressure anymore.  So, it sounds
>> no
>> sense to still keep sc->nr_scanned inc'ed.  Actually, it would
>> prevent
>> from adding pressure on slab shrink since excessive sc->nr_scanned
>> would
>> prevent from scan->priority raise.
> Hi Yang,
>
> I might be misunderstanding this, but did you mean "prevent from scan-
> priority decreasing"?
> I guess we are talking about balance_pgdat(), and in case
> kswapd_shrink_node() returns true (it means we have scanned more than
> we had to reclaim), raise_priority becomes false, and this does not let
> sc->priority to be decreased, which has the impact that less pages will
>   be reclaimed the next round.

Yes, exactly.

>
> Sorry for bugging here, I just wanted to see if I got this right.
>
>


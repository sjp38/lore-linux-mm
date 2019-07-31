Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17CECC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:23:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCBF7208C3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:23:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCBF7208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BB228E0003; Wed, 31 Jul 2019 09:23:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56C5C8E0001; Wed, 31 Jul 2019 09:23:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40DE88E0003; Wed, 31 Jul 2019 09:23:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E502C8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:23:53 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so42349458ede.23
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 06:23:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=r+9YjRzKAoDDNjTcVwt+BxUknqmdF55iA+1SdxYntQY=;
        b=MPcwhqIutItJ9pWRo8ZaqZdIinrVw33PwzqEwhBVGv3aauXjd9Pc5XC1Dw4jc6cynA
         gIDGwzk/Q3AOoV3+z5WDhC02S08sqAC0KdQLIplBmClGhsms0v+1ZCETQKqLeDvHXRCm
         qPWAjUp3TAParcCqQpMR7kYM0cIRGsptgByjHuOutKkzhotMaNLEzTb6iI4JpyI9eBXR
         qFlF9QUnrC/i+7geYkZRU7vjbXaT2qqkITz/YeN8C5MZxNyRv86TfHwEcykmafu4beC3
         /UVeDy5VmdgUqInpGNxZhpT/z7jpy9i34JSZJOWvjBNC8ZHbvlx14wj8MJTo7U5YgTd+
         MWgA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAV81r/SKtB8fSRnkxahY76iAqITDWh+AC62fp49plfpyapw8lgW
	vxsxUbYJJh2joQCQy8zA59My/eGqGFTfn46wETr/j/xiSjoXZinHtL1IjseB+UCEnMJ+MPE168/
	ZHuVQq79hxU6XkSHfLpPwwtzNkNKIKoKuj0tXXtieMT+y4BqKqKA2H+HsxcmdqpIZ0g==
X-Received: by 2002:a17:906:9149:: with SMTP id y9mr91537828ejw.98.1564579433448;
        Wed, 31 Jul 2019 06:23:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4jgXuS9OZFKG+UTvC53eUwTF4euNS2E9BwZBi0fMLQbHr0vBfcxgQUUCwU5baAj2uqejA
X-Received: by 2002:a17:906:9149:: with SMTP id y9mr91537783ejw.98.1564579432677;
        Wed, 31 Jul 2019 06:23:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564579432; cv=none;
        d=google.com; s=arc-20160816;
        b=uJ3Y//5p7IpFDoq+ALZ7xOmLyMGYH++8moQyLNtDvoat6Wr1/UGhjmSa0FphQBy2xJ
         0jchQcF3yj92mutrwh1wcK9VKIl31QRUvHrCqRh1Dc3+L/4/fVHJcQ7UnjHG8fgVuc5t
         EuywYD7xv5lh1cCK88e6ecfy+tepuYqJU3pFI+5GWqNj6TUSRikRNWe99Gvlc0NYvwZB
         sMimZc6UPGCvYnyhhrh/L4r2FWEBcY9x7vtIvbe2MMXkXmSZvSiH567m7GuqlmA9QzLa
         8c2ogI899aO0el6/IvIKEOimgP1InCzYw3EALyrWaImu5d0lcUvvCP/aFplOyUCX5oHs
         h0Ag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=r+9YjRzKAoDDNjTcVwt+BxUknqmdF55iA+1SdxYntQY=;
        b=LaKUuthkd/ZqwxdWwQVGB9K4S4Bsu2atEQQq8trDKaptMzi0XPQw8dTyxoTpY9Y5Se
         76ajC555Vzqngq6tn2p6PEnxcmKuHRaIPgjc20M1VxHggopwUNXPE0Tycd0cC5Mf8/TI
         V8GdRLNujUZJyHJiaNMUoy2jdVyiRC+Xwsoqsdf9M9xA+ct1xl840sBjzZrIjAORUDDI
         wjr34bDZ6IipUcIRs2H2z0RT6cSLp7sCUqlLi6VP8p/zuJRer8RakQ0jpaxxQ/uCT4pN
         wgp/yVuylqbF7xCeo8EfBg7yy1+9tPvjX3DOi8k40GB2b9WJeJY1VidWxPDS0S7IdrXm
         0MEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b57si21189890edc.406.2019.07.31.06.23.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 06:23:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1D46EAE21;
	Wed, 31 Jul 2019 13:23:52 +0000 (UTC)
Subject: Re: [RFC PATCH 3/3] hugetlbfs: don't retry when pool page allocations
 start to fail
To: Mike Kravetz <mike.kravetz@oracle.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
 Johannes Weiner <hannes@cmpxchg.org>,
 Andrew Morton <akpm@linux-foundation.org>
References: <20190724175014.9935-1-mike.kravetz@oracle.com>
 <20190724175014.9935-4-mike.kravetz@oracle.com>
 <20190725081350.GD2708@suse.de>
 <6a7f3705-9550-e22f-efa1-5e3616351df6@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <d4099d77-418b-4d4b-715f-7b37347d5f8d@suse.cz>
Date: Wed, 31 Jul 2019 15:23:51 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <6a7f3705-9550-e22f-efa1-5e3616351df6@oracle.com>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/25/19 7:15 PM, Mike Kravetz wrote:
> On 7/25/19 1:13 AM, Mel Gorman wrote:
>> On Wed, Jul 24, 2019 at 10:50:14AM -0700, Mike Kravetz wrote:
>>> When allocating hugetlbfs pool pages via /proc/sys/vm/nr_hugepages,
>>> the pages will be interleaved between all nodes of the system.  If
>>> nodes are not equal, it is quite possible for one node to fill up
>>> before the others.  When this happens, the code still attempts to
>>> allocate pages from the full node.  This results in calls to direct
>>> reclaim and compaction which slow things down considerably.
>>>
>>> When allocating pool pages, note the state of the previous allocation
>>> for each node.  If previous allocation failed, do not use the
>>> aggressive retry algorithm on successive attempts.  The allocation
>>> will still succeed if there is memory available, but it will not try
>>> as hard to free up memory.
>>>
>>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>>
>> set_max_huge_pages can fail the NODEMASK_ALLOC() alloc which you handle
>> *but* in the event of an allocation failure this bug can silently recur.
>> An informational message might be justified in that case in case the
>> stall should recur with no hint as to why.
> 
> Right.
> Perhaps a NODEMASK_ALLOC() failure should just result in a quick exit/error.
> If we can't allocate a node mask, it is unlikely we will be able to allocate
> a/any huge pages.  And, the system must be extremely low on memory and there
> are likely other bigger issues.

Agreed. But I would perhaps drop __GFP_NORETRY from the mask allocation
as that can fail for transient conditions.

> There have been discussions elsewhere about discontinuing the use of
> NODEMASK_ALLOC() and just putting the mask on the stack.  That may be
> acceptable here as well.
> 
>>                                            Technically passing NULL into
>> NODEMASK_FREE is also safe as kfree (if used for that kernel config) can
>> handle freeing of a NULL pointer. However, that is cosmetic more than
>> anything. Whether you decide to change either or not;
> 
> Yes.
> I will clean up with an updated series after more feedback.
> 
>>
>> Acked-by: Mel Gorman <mgorman@suse.de>
>>
> 
> Thanks!
> 


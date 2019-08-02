Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06CBBC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 10:20:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C70BB206A3
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 10:20:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C70BB206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60E746B0006; Fri,  2 Aug 2019 06:20:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E6266B0008; Fri,  2 Aug 2019 06:20:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D52F6B000A; Fri,  2 Aug 2019 06:20:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id F22066B0006
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 06:20:35 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id w25so46626188edu.11
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 03:20:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=QNAEBdHDLcTguWDKnVzev8+F1y6jsJiQcaikt82sJbI=;
        b=S8MLgUcwHxLSr8PpLGHcABcys7JLaIawHuQc3qNm5vMXBH5VJlKpFRRGmVTVCnLdhD
         hhco1Usdv2v0/yPo2rmKau0rV3OWz5kah/eSOgM34wMQvMteaIG9lCd5DnM7AhTMxX94
         l22+zhdhf/8FFhI5WrBD9PmTsD0dx4dyT9FWxytHwskIt2dzcLISuwEQA+NPdaK6a9aL
         Qodg4Z6xrRPedNi3cVcQOGh61Pvr7BAW9BLOepb28EH5Wl5tBTVhtn16mDjL/Ei7aFk2
         7vD11ac3rwQtOOtlRnxnJSv+VB6iyH8FDu1CnbzFJ+RKRptvRRSlW3QlYcxZqKrpxlaF
         LRGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAWvAu7dOkIuPldsIcdoXSkgk7CO9BbbQ585izAsSaSd3H3Y8YB5
	5s5O2mi/bTT6OYlFNX2bTRVirFC4u06nWW8PUME2zyARsh/NGIFtKpthWAJO47Mu1JvKxpXTg2n
	cs1uTSq1/6zqmxES/HKRlydB8YXRnVdN7H3rObN0ty0pHbRGypSyRC6pyD1SYt3iR5w==
X-Received: by 2002:a50:ac24:: with SMTP id v33mr118269818edc.30.1564741235573;
        Fri, 02 Aug 2019 03:20:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIt7ViG3usOaAtXzF1Eb4q577vnXqlJLzrp37ZxGu+O4fx0f1faVxbWxKVm27zA/7cpUGw
X-Received: by 2002:a50:ac24:: with SMTP id v33mr118269765edc.30.1564741234847;
        Fri, 02 Aug 2019 03:20:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564741234; cv=none;
        d=google.com; s=arc-20160816;
        b=dFFU+1bYUuRgRGm//fMOEJK/fSqk56wI8zKh5buFIrRXKuMsQSDz6kd2JS02DUkrus
         qOomGFcHFsV2U4fZzkZutR7pK6YXSMaF+9zNLW+dJR3vQhHqdr5FjC1fXnvOEaBewQqP
         QyN+h+Za562smMKvUCOGT0B1bTfcfsNhQQTabxCM/0GFNOeCwyG5InwjyJAKjVT9z+r9
         OpyndV3Oxi4KPQOisrfelGyj3qM+9m5hgfH+00qSNgkvvKWzvnrn+48PzuefNpGqIz+X
         vRKVz3wDDdp6u5kMJ60gXKqhV58dAVp0Nm14cXxOlRo33V5WGebaoV5iPUfZCuWd+Qci
         ORAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=QNAEBdHDLcTguWDKnVzev8+F1y6jsJiQcaikt82sJbI=;
        b=sHBka9EhKs6knGIkUS+h0rG4kHOUF1Xt3pdVSZQBmPif5gmCVmu8VoQS/sEKMRj6wM
         S4qw5B2HZASQ4bkcycb9Ogw60HeNsYa5TqKNkn66N4ir4+tFX/hYlfsgpQCsrpbtHhsF
         3NQO6/t/NyYCdrtVvp6VksI36tZQ/G9a2uy/hiW4HBW5hKfi4w+IffN9UjTPcHmkUPYC
         1bS9DTV7mTiI347/G65wzExR70UmrJ8DRPVY3yhMF7AxEUOz05eWQqSqsImFYzwsuoRq
         8avP+3M7RXOZDES+/IBLB5lncsxm4QAgj+tHV4eDCWOBGIFwxYaePNOTVaySKVwoO/En
         g2jg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n29si26207662edd.66.2019.08.02.03.20.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 03:20:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4649EAE03;
	Fri,  2 Aug 2019 10:20:34 +0000 (UTC)
Subject: Re: [RFC PATCH 2/3] mm, compaction: use MIN_COMPACT_COSTLY_PRIORITY
 everywhere for costly orders
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
 Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>,
 Andrew Morton <akpm@linux-foundation.org>
References: <20190724175014.9935-1-mike.kravetz@oracle.com>
 <20190724175014.9935-3-mike.kravetz@oracle.com>
 <278da9d8-6781-b2bc-8de6-6a71e879513c@suse.cz>
 <0942e0c2-ac06-948e-4a70-a29829cbcd9c@oracle.com>
 <89ba8e07-b0f8-4334-070e-02fbdfc361e3@suse.cz>
 <2f1d6779-2b87-4699-abf7-0aa59a2e74d9@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a0f01341-a5d8-d015-c37e-4932eaafd868@suse.cz>
Date: Fri, 2 Aug 2019 12:20:33 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <2f1d6779-2b87-4699-abf7-0aa59a2e74d9@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/1/19 10:33 PM, Mike Kravetz wrote:
> On 8/1/19 6:01 AM, Vlastimil Babka wrote:
>> Could you try testing the patch below instead? It should hopefully
>> eliminate the stalls. If it makes hugepage allocation give up too early,
>> we'll know we have to involve __GFP_RETRY_MAYFAIL in allowing the
>> MIN_COMPACT_PRIORITY priority. Thanks!
> 
> Thanks.  This patch does eliminate the stalls I was seeing.

Great, thanks! I'll send a proper patch then.

> In my testing, there is little difference in how many hugetlb pages are
> allocated.  It does not appear to be giving up/failing too early.  But,
> this is only with __GFP_RETRY_MAYFAIL.  The real concern would with THP
> requests.  Any suggestions on how to test that?

AFAICS the default THP defrag mode is unaffected, as GFP_TRANSHUGE_LIGHT doesn't
include __GFP_DIRECT_RECLAIM, so it never reaches this code. Madvised THP
allocations will be affected, which should best be tested the same way as Andrea
and Mel did in the __GFP_THISNODE debate.


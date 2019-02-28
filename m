Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35FD6C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 22:11:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFEE22084D
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 22:11:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="CD2TxwtF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFEE22084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A4748E0003; Thu, 28 Feb 2019 17:11:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 154B28E0001; Thu, 28 Feb 2019 17:11:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0695A8E0003; Thu, 28 Feb 2019 17:11:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id C97FD8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 17:11:39 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id c188so19311262ywf.14
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 14:11:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=lp0YkothahhdP4oQqOkXRwHxr5NEdq2Tk+d6kbvXpvs=;
        b=JLvmetaFe/xptU8yEXCPU//FiCFvAQ+7K3uNGb/as9PmgXYttGOUmgJzNsm+MHWkdQ
         50L58dmAaoAayAqBsE58b8SEuc7oIiDsbTIbOkfRpMYlB723rn/lZEJoR4G5MW49G/Hs
         tUFepr+qx7Q8OS+h18JMvPwSC0mvwgrUNMlOW+F3QNze9zhWin69k4fVaiI9JI6Q9SiX
         TyHf+duWLio726qKO3fOSgWnGeXxaAQ3qkPZyZxSWrc1wmqFB9eU3NWGpTmvOMBJzG+/
         8LiuXrkwifxX10oQkEATxMh/MA6vpEZtLR/v8YKZ7JUJGr+rUhsR7OJxAb48McOTIRnr
         hDdw==
X-Gm-Message-State: APjAAAUNa5H7Ny/27sYbuJuRLEvw1UTK1QT3LvHic5epyWe9u4nAPJWL
	Mc9UoHCSAF0GDdcToUw5gzGg29dUknpUW7uIk4jLRzINGscH2QYLT8bgo1m5+zVAhEWxycZQrzs
	ksp5xnJxy1Njyl7xtSsPldJdvbxH8B1HmDTsgr7f1uV6UBsDCZS6aYGZFGLho140HKQ==
X-Received: by 2002:a81:7084:: with SMTP id l126mr1029298ywc.203.1551391899529;
        Thu, 28 Feb 2019 14:11:39 -0800 (PST)
X-Google-Smtp-Source: APXvYqwrVQ+5zvy/3Bw5368PSEuQE6qnvhHnENFr4Fgvr/eebc/WyLgUcEaV0wNqQkxHyFqXl1kN
X-Received: by 2002:a81:7084:: with SMTP id l126mr1029260ywc.203.1551391898797;
        Thu, 28 Feb 2019 14:11:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551391898; cv=none;
        d=google.com; s=arc-20160816;
        b=kj5bku3RM+HGYYHyFP9YAhpQ5hVJMDgEFoJExmAgxJYOPAujyE9LznrSMEg5Ughexi
         /xaRqmLMIRpCPh+/shojLt1tk/uu3OZfZZfm3LmIjsZptP/cUsB8S1lKd986/6mJetey
         TaLec9jHS/s4M11TC8T1o/wXA5CJVTtswKiG4ccnjxccnYGtSDpbavywWlfMM7e1jbND
         eF09YbaHzwZBWCWql2nngQIjjx902zIq/4WLyrjMctYHyIfxCtRCtpn4Gcu5+5rmfOHk
         qKqX4IdtvLQ7PnutNzq3PmmnIG4Zfb/vekOWLLwAlC6r1+dfVDZK9PnLnWNrrFvSGOv+
         acxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=lp0YkothahhdP4oQqOkXRwHxr5NEdq2Tk+d6kbvXpvs=;
        b=qShWflb2to0kzb/3bGa8ltJfxp1o5Xb9/R0/1cvjddgYniH1qHoHr6QWnOgVH5HDg5
         xTJVavZ8ND73lxYd/WCFiaMSA+oEW4QIGxqrZdXpIkQqYPXrcofdVxoSS7uJWcm7u+rN
         uzI9rEAxg2ZEwdyr+zRGwDSldF83gXp+AKBOI++q+k7LfH1+vNSqjPtXk+8lC/wLQLnb
         NrEhb2E7U0OOi7xll0LarD8eC89QrxbJ55+F8oC9c3QmOGvWAslUVzF9kLau8z2aF2EW
         AgeufkxSLCj4YYdlwRdXTrJoqq0ve1a++jF0U7xKitKAkCkhINatlZf8xRqEvPt5bI80
         Tc3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=CD2TxwtF;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id c19si1356593ybf.340.2019.02.28.14.11.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 14:11:38 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=CD2TxwtF;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c785c990000>; Thu, 28 Feb 2019 14:11:37 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 28 Feb 2019 14:11:37 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 28 Feb 2019 14:11:37 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 28 Feb
 2019 22:11:37 +0000
Subject: Re: [PATCH v2 2/4] mm: remove zone_lru_lock() function access
 ->lru_lock directly
To: Vlastimil Babka <vbabka@suse.cz>, Andrey Ryabinin
	<aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>
CC: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Michal Hocko
	<mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>
References: <20190228083329.31892-1-aryabinin@virtuozzo.com>
 <20190228083329.31892-2-aryabinin@virtuozzo.com>
 <44ffadb4-4235-76c9-332f-680dda5da521@nvidia.com>
 <67a79bb9-12b5-e668-abb1-ef91a9cbfea8@suse.cz>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <1f978daf-a037-e7e8-079f-80b421e663e1@nvidia.com>
Date: Thu, 28 Feb 2019 14:11:36 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <67a79bb9-12b5-e668-abb1-ef91a9cbfea8@suse.cz>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1551391897; bh=lp0YkothahhdP4oQqOkXRwHxr5NEdq2Tk+d6kbvXpvs=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=CD2TxwtFekB+bBed5i0C1P4DuD2v5dgZN5qqtiUld50Q948O/cWRv7yuw5gs/TDEQ
	 FR9v7o8SGJLGMEzBTYMb4VC1rjPp+RfJztcpEXyfH7kqwO2HurvKBogeltDkmhKdyV
	 jSVGop4Ot6AWpm3d23F7Luig9XGcMjxBRgPac0ciDvobI8UI7gU8vqQoWxtvdTjZNn
	 /uXzPbJqd8HuQYuqMhLg2j9AmqQVDYadRch9zSM2P/VIzyK0ZSKQ/omIEN6VJ6YEz5
	 zbNC7GfJBfL7wTVavZe7xcODbD3Pe7sDxcfcQwTIdN/CMX5jcUeyM372zo+/Fkjkpw
	 21BdF8AWj+V1w==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/28/19 1:56 PM, Vlastimil Babka wrote:
> On 2/28/2019 10:44 PM, John Hubbard wrote:
>> Instead of removing that function, let's change it, and add another
>> (since you have two cases: either a page* or a pgdat* is available),
>> and move it to where it can compile, like this:
>>
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 80bb6408fe73..cea3437f5d68 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1167,6 +1167,16 @@ static inline pg_data_t *page_pgdat(const struct page *page)
>>         return NODE_DATA(page_to_nid(page));
>>  }
>>  
>> +static inline spinlock_t *zone_lru_lock(pg_data_t *pgdat)
> 
> In that case it should now be named node_lru_lock(). zone_lru_lock() was a
> wrapper introduced to make the conversion of per-zone to per-node lru_lock smoother.
> 

Sounds good to me.

thanks,
-- 
John Hubbard
NVIDIA


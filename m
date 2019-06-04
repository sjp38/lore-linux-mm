Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1EAA1C28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 19:29:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF79A2075B
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 19:29:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="rQWBsgW5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF79A2075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6536F6B0271; Tue,  4 Jun 2019 15:29:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 604CC6B0273; Tue,  4 Jun 2019 15:29:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CCBC6B0274; Tue,  4 Jun 2019 15:29:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3138F6B0271
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 15:29:55 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id d6so17886739ybj.16
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 12:29:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=L5ssfsr4CdbgOzijHbr9sPxMKKvikmBYGkIxWSlzZPI=;
        b=bvVl/1Be92uYxJ97l16CWlImSxfQ8MEbzP9DBHwpy7R+6n7kxx//FgK3arLFlo418r
         Vb1UiOFS6ROyB79q/ZkQi1X+asOblRGIVPPv4w3TrsDlczfaPS8dPIf+eqagPg/n27dQ
         0XN8hBM0CZaZ5ijxeG5qW8eCjI6mz8gq6sE9X9TYq1vmyLLGOhPP8Y3K/sTh14oa+aH7
         cPBrlFnTd7JTjckuqDwYroioSZpPvnIpFnC+3eozx2jt4zjw60V11UNjmNsG15BRdLP3
         ps/NYMn6s4fFJfBnMcI2QnK/yeCeQkNuuCw7kgrt8Emac7SLZy+z88Rp8adGNVqnkMCK
         zCcw==
X-Gm-Message-State: APjAAAUU+uocqccxXw4UH6ROcVsZXQicXbuDq8oUxLKSRf/ylWMouqQ7
	/O7Tep7HSXWUxkK0eAfUg8ds9f8YUDGa8mbykYAXW/bQUtk6G1/isKMwsbFePn/9sCQ6vQAmMFq
	QSIbV5Gny9c2JHSDj0A3sZ2mQQgaG32PC+J1EvVA3R6Wzqh7iOphBaD6eeSo8WMbSNg==
X-Received: by 2002:a25:b848:: with SMTP id b8mr9371063ybm.387.1559676594876;
        Tue, 04 Jun 2019 12:29:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUAUn5XbNKfTyJYEGYujVcd+7t1fxpBlMFLHxlBtw3F7DedLN0IwmfoCoS3/pGceDWd2jD
X-Received: by 2002:a25:b848:: with SMTP id b8mr9371020ybm.387.1559676593771;
        Tue, 04 Jun 2019 12:29:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559676593; cv=none;
        d=google.com; s=arc-20160816;
        b=y9ESvvxhTZFUkQAqLlDlvFghXsYkB9jVPw+j1w72ZqkzRFP6j3w5kHYVqZFF6psvFy
         /6RdJyVNzvtbrl34scnzDQMrFMiTt1bT6s7R+P3fGZ04/XowoBXyA3XmGtnmYsMxyV3H
         0NzpFSMT/DxzyAdC3Cch3Hv+pQsnfpGdYaSn6OubhCURm/9erRD3AZFHCxTHZ3xgBQ4c
         uCjkvW7R9VxwIqkc6+XnnJi5q1Z3jb5SFvX02tlzmCAw09xWCEI2tf2cSBbWMM6Dzx6I
         VfghEGjpnsoKie0pfayuqq9eA8p3Lu76fAd7I405VC1g5VhJsxhwcp4HJhN4twvyT+KL
         4ffA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=L5ssfsr4CdbgOzijHbr9sPxMKKvikmBYGkIxWSlzZPI=;
        b=jIhU9G6cLxhmtgTRfdHsiRJuvEPcnOxAxywr6EIhLiB3KMC1xiSkPLiL2WQRAzm58w
         QVuAR0mOnbeFvvZbg7avuoHo7zJ9Hbx15Ln3PoSPWHUzflReWYgbJRTJQvND+w61gGa/
         HjNc3Y9YwUKW7bSvz83XU1m2/z9nHMjZwRC5D3TP/Qq4a3/ezcfaZxKjtiuHGZOC6wf9
         dF6AbYQzEXkohOhrohpuxu9xBr5WGL0ZvgRbmWBX4EmaThLwJx/cULc97L05aPR3ZeV4
         qB0yCbloNEhJJkrrTSlwu/wCyi5krvG/vIAGv6eqE8oWb3MPv/EEcq8npcZstF9dK9nv
         i2Fg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=rQWBsgW5;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id o130si5075621yba.114.2019.06.04.12.29.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 12:29:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=rQWBsgW5;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf6c6ae0000>; Tue, 04 Jun 2019 12:29:51 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 04 Jun 2019 12:29:52 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 04 Jun 2019 12:29:52 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 4 Jun
 2019 19:29:52 +0000
Subject: Re: [PATCHv2 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
To: Ira Weiny <ira.weiny@intel.com>, Christoph Hellwig <hch@infradead.org>
CC: Pingfan Liu <kernelfans@gmail.com>, <linux-mm@kvack.org>, Andrew Morton
	<akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.ibm.com>, Dan Williams
	<dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, "Aneesh
 Kumar K.V" <aneesh.kumar@linux.ibm.com>, Keith Busch <keith.busch@intel.com>,
	<linux-kernel@vger.kernel.org>, Sanket Murti <smurti@nvidia.com>, "Ralph
 Pattinson" <rpattinson@nvidia.com>
References: <1559543653-13185-1-git-send-email-kernelfans@gmail.com>
 <20190603164206.GB29719@infradead.org>
 <20190603235610.GB29018@iweiny-DESK2.sc.intel.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <4b448fa6-dd85-ca45-5cb8-d2c950bddf37@nvidia.com>
Date: Tue, 4 Jun 2019 12:29:51 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190603235610.GB29018@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559676591; bh=L5ssfsr4CdbgOzijHbr9sPxMKKvikmBYGkIxWSlzZPI=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=rQWBsgW5BRDGBf1MYzgpB3Q35yRaA45Lx6vyonOmAVTZnpSbwf2zHeSvs8Yh0CtyO
	 yhGbnjVHZsxQ5JRJtlCOI63vBIro0O+7q/ZqJChiGfgFQ7rX9uXSFWZNlqbwRei6tx
	 Wppl46/8Xx/ObqeQ/f5M8qolzh+OKE4Qj2NM666ELlnpWDyKZgOEtM35jz1Nn8qOit
	 VEDsbi7C6JAONUUIsKyZHjIMJ3mR9A0K80wih6aJYiEEMsA3vIynzzmfbveBjY0N6T
	 4gtxYjsCF2R7ZgYG9suvbq7rEE/CjgnJkNMDF+eAh9df3xa4fJ2Pof2ndbE7KfBelY
	 YtdL+BuoLdNBg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/3/19 4:56 PM, Ira Weiny wrote:
> On Mon, Jun 03, 2019 at 09:42:06AM -0700, Christoph Hellwig wrote:
>>> +#if defined(CONFIG_CMA)
>>
>> You can just use #ifdef here.
>>
>>> +static inline int reject_cma_pages(int nr_pinned, unsigned int gup_flags,
>>> +	struct page **pages)
>>
>> Please use two instead of one tab to indent the continuing line of
>> a function declaration.
>>
>>> +{
>>> +	if (unlikely(gup_flags & FOLL_LONGTERM)) {
>>
>> IMHO it would be a little nicer if we could move this into the caller.
> 
> FWIW we already had this discussion and thought it better to put this here.
> 
> https://lkml.org/lkml/2019/5/30/1565
> 
> Ira
> 
> [PS John for some reason your responses don't appear in that thread?]


Thanks for pointing out the email glitches! It looks like it's making it over to
lore.kernel.org/linux-mm, but not to lkml.org, nor to the lore.kernel.org/lkml 
section either:

    https://lore.kernel.org/linux-mm/e389551e-32c3-c9f2-2861-1a8819dc7cc9@nvidia.com/

...and I've already checked the DKIM signatures, they're all good. So I think this
is getting narrowed down to, messages from nvidia.com (or at least from me) are not
making it onto the lkml list server.  I'm told that this can actually happen *because*
of DKIM domains: list servers may try to avoid retransmitting from DKIM domains. sigh.

Any hints are welcome, otherwise I'll try to locate the lkml admins and see what can
be done.

(+Sanket, Ralph from our email team)


thanks,
-- 
John Hubbard
NVIDIA
 


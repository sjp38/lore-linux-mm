Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83897C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:43:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B3492146F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:43:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B3492146F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB7A48E0003; Mon, 18 Feb 2019 12:43:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C66F88E0002; Mon, 18 Feb 2019 12:43:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B57148E0003; Mon, 18 Feb 2019 12:43:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 717508E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 12:43:02 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id b3so7490481edi.0
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 09:43:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=uQ7jsgiUahSLHYaAm7Xy7qVXzVImOAWirYYuT5ZzgME=;
        b=rc7LC0qAaD1SK+FjtKOdK4DI03eCOHfmIk9bkusNNdopTX3Dth/YNhjirXya9clKqc
         0W8G4Lhwy1nJ5xJCshD5iZcxvIH1og/2gwupxDHwFXdGBDqA87p/dvoYgUUh5JYPDB23
         H5FRF6sxIBgOPPlyAfYt/0ccKh2+HBEG6w0/qT3jKT7gRHaAp7aqq8iC45F1BFmeexYd
         dEjktMPX4ABcCXsKevmUjYyBzcCUkd+nXqQw6N5/ry2CIW053czpHRu8BzNWQSH9Wbi8
         6QB7EzL/PUhcxmxpkZkrpSETpzNc/M+dlPbrXnEqJI2kJGeRpIAwyQZsowaDIQ3s0ZDN
         gIuA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuY67HhdCgy9XMBAggxdIytxSEstTHJgZfFD+RCBR3L5Vpr/PYXP
	E6GG028m5/qiEo3GWqxo5qyjkUXNQELwSFcDZWkrnkfpyYlzRh3Nf0nCKK7GY14ECDI7ixS9mhN
	/gpSixwbCimenei4E9QmHDQ0HhrXVnrYGYK4xSrOftvGPoPLYk47WqJFueUrjA8QmdA==
X-Received: by 2002:a17:906:e282:: with SMTP id gg2mr17513416ejb.84.1550511782016;
        Mon, 18 Feb 2019 09:43:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZTcUNeXySGq9jpxIYmGI9MAyNrudlVbpTR3GInEsbgjaL3S/i0BMmTFXNoKRnKj8AWWzEv
X-Received: by 2002:a17:906:e282:: with SMTP id gg2mr17513383ejb.84.1550511781243;
        Mon, 18 Feb 2019 09:43:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550511781; cv=none;
        d=google.com; s=arc-20160816;
        b=uHe8qF41ukATbIE/Ma7OntT77l+JuqoVWgBv1FRh+BhsdwsXpArvkv4BzHvyBp4Pws
         FnlEynnquY1VhbPuIbsHuQBwX8ym6bZFcrR2fuH0zkDFtGdp8SjXos8RYaidZ+gQgVjr
         VmdbaZ041Vi7qK56EMl0zReeiqYXyIWRltWS2T2gUWlUDcCI39jZmIlGKRtILI5oj+PK
         D5fflB8NdZUlLJPweqq9+LDaMGCL09f2VZCW4daNYnowzfUnGeIKqv64kLPeNKQ/6v3e
         GcGgwOX2ESUh0Wp+ra5GozXCiE4lNZUzhzbSsNFmwSAhJ+fgTk1q5nK7oYGb/qEv4o8+
         BwIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=uQ7jsgiUahSLHYaAm7Xy7qVXzVImOAWirYYuT5ZzgME=;
        b=F7fM25+icb8GI8DjX3czpk0gp0gb3si9Ae0jsgSeNEb17g5FKxJca5R4ZAn0yi7Oeh
         KtN+Ez03523HVOsRZeJkgzB3rDgTNapCEMw19kawv803jty0mblCtnnALxP03fxnHd82
         IgpAE0z9QRtliRf/NnBRgSLshT+HDJqNQdBRxqD7qcG/FxyAozFmRu1pZwhIHDEkWhwn
         FBEG98xM+4MX8WGF2bPVJPJdA/P5EbUvEDEZMaYr+O3wQCjrY5asi+0KDaffOQml0lC9
         bX5e1Wd0JDd9P8p9Vo4czN6xkAphV9tVY7A/IsprbQZ3Cj1GDMsxY4duStQQ2o3tVD0m
         /EjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a57si3273291edd.310.2019.02.18.09.43.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 09:43:01 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 91026AD9D;
	Mon, 18 Feb 2019 17:43:00 +0000 (UTC)
Subject: Re: [RFC PATCH 01/31] mm: migrate: Add exchange_pages to exchange two
 lists of pages.
To: Zi Yan <ziy@nvidia.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@kernel.org>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>, John Hubbard
 <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>,
 Nitin Gupta <nigupta@nvidia.com>, David Nellans <dnellans@nvidia.com>
References: <20190215220856.29749-1-zi.yan@sent.com>
 <20190215220856.29749-2-zi.yan@sent.com>
 <20190217112943.GP12668@bombadil.infradead.org>
 <65A1FFA0-531C-4078-9704-3F44819C3C07@nvidia.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2630a452-8c53-f109-1748-36b98076c86e@suse.cz>
Date: Mon, 18 Feb 2019 18:42:59 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <65A1FFA0-531C-4078-9704-3F44819C3C07@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/18/19 6:31 PM, Zi Yan wrote:
> The purpose of proposing exchange_pages() is to avoid allocating any new 
> page,
> so that we would not trigger any potential page reclaim or memory 
> compaction.
> Allocating a temporary page defeats the purpose.

Compaction can only happen for order > 0 temporary pages. Even if you used
single order = 0 page to gradually exchange e.g. a THP, it should be better than
u64. Allocating order = 0 should be a non-issue. If it's an issue, then the
system is in a bad state and physically contiguous layout is a secondary concern.


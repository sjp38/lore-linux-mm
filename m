Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA3E4C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:35:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8D4E20679
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:35:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8D4E20679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 397756B0005; Tue, 13 Aug 2019 05:35:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3483B6B0006; Tue, 13 Aug 2019 05:35:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25ECB6B0007; Tue, 13 Aug 2019 05:35:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0070.hostedemail.com [216.40.44.70])
	by kanga.kvack.org (Postfix) with ESMTP id 030236B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 05:35:19 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 8BF8A8248AA1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:35:19 +0000 (UTC)
X-FDA: 75816896358.26.seat67_857b2a38c580c
X-HE-Tag: seat67_857b2a38c580c
X-Filterd-Recvd-Size: 2062
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:35:17 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D6E7C337;
	Tue, 13 Aug 2019 02:35:15 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D48873F706;
	Tue, 13 Aug 2019 02:35:14 -0700 (PDT)
Date: Tue, 13 Aug 2019 10:35:12 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Matthew Wilcox <willy@infradead.org>, Qian Cai <cai@lca.pw>
Subject: Re: [PATCH v3 3/3] mm: kmemleak: Use the memory pool for early
 allocations
Message-ID: <20190813093512.GE62772@arrakis.emea.arm.com>
References: <20190812160642.52134-1-catalin.marinas@arm.com>
 <20190812160642.52134-4-catalin.marinas@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190812160642.52134-4-catalin.marinas@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 05:06:42PM +0100, Catalin Marinas wrote:
> @@ -466,9 +419,13 @@ static struct kmemleak_object *mem_pool_alloc(gfp_t gfp)
>  	struct kmemleak_object *object;
>  
>  	/* try the slab allocator first */
> -	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
> -	if (object)
> -		return object;
> +	if (object_cache) {
> +		object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
> +		if (object)
> +			return object;
> +		else
> +			WARN_ON_ONCE(1);

Oops, this was actually my debug warning just to make sure it triggered
(tested with failslab). The WARN_ON_ONCE(1) should be removed (I changed
it locally in case I post an update).

I noticed it in Andrew's subsequent checkpatch fix.

-- 
Catalin


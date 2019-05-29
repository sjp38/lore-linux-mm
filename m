Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09261C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 10:03:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBC1721670
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 10:03:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBC1721670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 513416B000C; Wed, 29 May 2019 06:03:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C4976B0010; Wed, 29 May 2019 06:03:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 409D06B0266; Wed, 29 May 2019 06:03:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0A45C6B000C
	for <linux-mm@kvack.org>; Wed, 29 May 2019 06:03:45 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c1so2610902edi.20
        for <linux-mm@kvack.org>; Wed, 29 May 2019 03:03:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=k7vAdyLZjnT8uLHEkZ9JbwrYg6ht7jQJOdRxeraMo4U=;
        b=MXvI/sSIz4F/LEhLqEaPLSzmvuJyeB7XoYzry8N4MDXk3cqjfNeQ4UqeojPTdr8e3L
         dbIfV6ZEhJ0kp248IpfPFC+6+sHTpbTUqkeX0S/zFglr7WRXmVSLhiBF4fb1aivbUNPf
         nBrpbjJEdK6KqIYHKcghiNNWx30m5ZiX90oZL+63svXjcIy9DMnkfyZEqq21Jytzp+T9
         Otq6KfUVfwcvc3qknE2nvpP60yOiA9d75bkgeLQe/pO+Figa5lSZ9Yol9XjEnaRvcamq
         jKk4qlO7q9bpP0QkI7neJZBsq9SiUZCpOVkKNPzLFmBD7UhQGlodwtjIcSSeEuDNrXeg
         h70Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: APjAAAXggdU8jB78U9CguayQoKSK4ZWxJF1yhnNABZymRwpmLTvR/3Rb
	kU4Vf0nXDgGxkqLvLJk4sGvU7EQF8GDwfXxG/Fdn0XLaeKiPP7kejwFqIuI4oBZIBw56iWRiNvJ
	2S18tHZOevFsL24YabvQ6rqb25D8ADmRrCdL3WAqWEwHQEtRpRAP7ZCalzDCXYEbCfQ==
X-Received: by 2002:aa7:c403:: with SMTP id j3mr99165526edq.144.1559124224600;
        Wed, 29 May 2019 03:03:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8+QwIWLSDFHlxzCI8l61Cx4PNMNg+limi24hM91FL3ifFvv1Y+NVFe9ocVYHG/F7CXexw
X-Received: by 2002:aa7:c403:: with SMTP id j3mr99165370edq.144.1559124223621;
        Wed, 29 May 2019 03:03:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559124223; cv=none;
        d=google.com; s=arc-20160816;
        b=QtGgPsODG09IoV3H0YAbpRSI2OVaY6sielW/gIww0Lmcx+v0cENqeBJX7ECR3+vUnp
         xhrqsWZ8luU/LN/Y7NsI5SJ5uO1tXx3bGJxyI24befzlqfmkw+3pH8iXWSOCEvRiDRo7
         b/jyYNMuQEhb35bgdNQcWt4atlZDid7DA8Pi65o35h+ui86j2I54HpsYXGLzXSZoPQh3
         B4CTlwOjNfq1Q2r8yFuly+dxEMGS/XzF+LnTc3j4ZHWPrY6K7A6UvhFrhKg7vUj1McmH
         Wtpi6Kb+sxlwtj9UmyzWf4tKYSptezaZ264/rppFWbE0ljhEQuQzIr5BRFHzunVzMjEo
         mqug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=k7vAdyLZjnT8uLHEkZ9JbwrYg6ht7jQJOdRxeraMo4U=;
        b=txBePtO5yvTTy4ftaQTYvrCf76cEyNunAQNCzegzVYZma+JSY+PeSxnAETHNTn0MOO
         iHdcWs0nl2kTv18AnwQ2lRweKfGTDICSpCWkBqBJvngbx9UshCT3ubce+kE4mGUtvWZl
         WM1IHR/xkxopQcu1ZIo+f8cvlCR3+xjucLQs5QOzLWDRoLG+uYAjh7aGmt2PK/ZSRIMO
         lIQuO9SgcbTIqqY0k+AmNDMTJQDd0/qUyS1Nzv4bexUsAnCBOV4DqtjbND5QohgaTMLl
         FKR8C11/pw4LsuBuEXQD1hpgJVSZHIMvKjYWVyRmfMe6noSrzGp7xurFcsQUqSgMc54n
         tt/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l14si3802171edv.262.2019.05.29.03.03.43
        for <linux-mm@kvack.org>;
        Wed, 29 May 2019 03:03:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9374A341;
	Wed, 29 May 2019 03:03:42 -0700 (PDT)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6034F3F5AF;
	Wed, 29 May 2019 03:03:41 -0700 (PDT)
Date: Wed, 29 May 2019 11:03:38 +0100
From: Will Deacon <will.deacon@arm.com>
To: Robin Murphy <robin.murphy@arm.com>, akpm@linux-foundation.org
Cc: catalin.marinas@arm.com, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3.1 4/4] arm64: mm: Implement pte_devmap support
Message-ID: <20190529100338.GB4485@fuggles.cambridge.arm.com>
References: <cover.1558547956.git.robin.murphy@arm.com>
 <817d92886fc3b33bcbf6e105ee83a74babb3a5aa.1558547956.git.robin.murphy@arm.com>
 <13026c4e64abc17133bbfa07d7731ec6691c0bcd.1559050949.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <13026c4e64abc17133bbfa07d7731ec6691c0bcd.1559050949.git.robin.murphy@arm.com>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 02:46:59PM +0100, Robin Murphy wrote:
> In order for things like get_user_pages() to work on ZONE_DEVICE memory,
> we need a software PTE bit to identify device-backed PFNs. Hook this up
> along with the relevant helpers to join in with ARCH_HAS_PTE_DEVMAP.
> 
> Signed-off-by: Robin Murphy <robin.murphy@arm.com>
> ---
> 
> Fix to build correctly under all combinations of
> CONFIG_PGTABLE_LEVELS and CONFIG_TRANSPARENT_HUGEPAGE.
> 
>  arch/arm64/Kconfig                    |  1 +
>  arch/arm64/include/asm/pgtable-prot.h |  1 +
>  arch/arm64/include/asm/pgtable.h      | 21 +++++++++++++++++++++
>  3 files changed, 23 insertions(+)

Acked-by: Will Deacon <will.deacon@arm.com>

Andrew -- please can you update the previous version of this patch, which
I think you picked up?

Thanks,

Will


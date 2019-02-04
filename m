Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72EF0C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 19:44:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 362A42087C
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 19:44:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 362A42087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB0EE8E005A; Mon,  4 Feb 2019 14:44:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3BC78E001C; Mon,  4 Feb 2019 14:44:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ADC088E005A; Mon,  4 Feb 2019 14:44:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 66F4A8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 14:44:31 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 3so644750pfn.16
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 11:44:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=ROdzO7wrarIK/x0WbX4/VW6PLz3LefBEweqj4uDvt5U=;
        b=J/FJoBBNdrSw/wszssrbgqUZT32+WqJcivm7NqVX5672ra0dsszrCosd/IFfODj7sN
         0EUAhuzsVwg8fmRQw4edJqSOfM3qKbus7MeWcODTtyIR79ywj5VyAT0o+1FI125g733P
         1eK9pqPaPTQPi63y6puBhj/dCoROtYumYRQHDML6o7VD54mvUbiUb+Vg4lVT+Pe9G5f7
         cqSU/y74My3XvH1o50c4P0obXGn7QfQwtLRBHShdPgqkbfJ78RgZIjoZf3RVLxgXmfW/
         CDCbggDMpR1tXQKxIHcMTPZZuE9Dep1YzwSNvWzUeW343c4Aov+o3B/DDdrDT1Et1vHO
         yObg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZMG9wA6AYJz2VYYVR9TrIIW13exT3rrtqREyIubW3p9HgrJlN7
	Ie1hnMSvgd9wWAx2dYloiGtnrNOnjB9zBs5PCd7tLRGuDK2PaQSR+ra11ZupizMS9sxz37R1XeQ
	E46W9F6O/3onx3KQULvtAbtwj8H2xdzkb5f3ruwiQK7wsN+f+M15t/p9+4qGdkshNjw==
X-Received: by 2002:a17:902:e78e:: with SMTP id cp14mr1107146plb.4.1549309471077;
        Mon, 04 Feb 2019 11:44:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ3MyWumhxxol304VeDfBnTl1xFQJxNLq/K/HXUT3LXwTB1r8h9hEDQXG3GyGvkbcJdUwNv
X-Received: by 2002:a17:902:e78e:: with SMTP id cp14mr1107114plb.4.1549309470435;
        Mon, 04 Feb 2019 11:44:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549309470; cv=none;
        d=google.com; s=arc-20160816;
        b=Q2g0G8LAjlKo3RzCqCLmOVVHMq0YpoB0uVY53df00zt4Gu4iwwSIQp09XpyehZ2qza
         iVHSay7H3QvSO2LteRIGYlHNSB59QjfbXFqXfUjf2Y5yfr60bIbcCnpWQ8pASFMxLIO1
         P7qCJuMFdAEojes2kJ07DG4G5cHprR2q/enc7q7+NAcMsqQpUjb/h7tJ1VcMVEvNFC9I
         zp1NpfpwStpWBkFGhikfkYDeN2cX6XpHpGngWglaEiJ+brw9StdZBSiVW2tHn4QBOewV
         emNZxbnRsjHeANXB/kcGEKsXxgh/GYTEqr+GjZTue8mG/K8fDk5C7bPsoxK/BwUX9wrz
         YtwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=ROdzO7wrarIK/x0WbX4/VW6PLz3LefBEweqj4uDvt5U=;
        b=PeWThhKSRiKvKgTlvavATaHyr8qkTvEni10fdHitAzkWfgcWMcWnAeEJ0SJNAJPQyO
         Wwo0Irdjw8Q3arHqzU1AfQU45xiqsyfBTMXix4iCGcBWM9YGeVLlZVXcyA+uOKcBZJ31
         +OL78s5V+outrPisQj4Ka7oZVb8Kqj8xiLVmaPZ7o0ocjAQ57eWQmq+Scd1ammbsI7Z3
         fmY2r6MnlHAS/ylQf/Ccix31ssp60S6186xpUfYugI0cGWE3l5lD0newsGjAWz219MTa
         slJtn/Lqu73snZUEydf0PKc3vwAFcRdGFMMAhIc30Gl72q79ME7jmFixc2fd5kR6eCGW
         bkuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id x186si837039pfx.269.2019.02.04.11.44.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 11:44:30 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Feb 2019 11:44:29 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,560,1539673200"; 
   d="scan'208";a="131487746"
Received: from ray.jf.intel.com (HELO [10.7.201.17]) ([10.7.201.17])
  by orsmga002.jf.intel.com with ESMTP; 04 Feb 2019 11:44:29 -0800
Subject: Re: [RFC PATCH 3/4] kvm: Add guest side support for free memory hints
To: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, kvm@vger.kernel.org
Cc: rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com, x86@kernel.org,
 mingo@redhat.com, bp@alien8.de, hpa@zytor.com, pbonzini@redhat.com,
 tglx@linutronix.de, akpm@linux-foundation.org
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181552.12095.46287.stgit@localhost.localdomain>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <24277842-c920-4a12-57d1-2ebcdf3c1534@intel.com>
Date: Mon, 4 Feb 2019 11:44:29 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190204181552.12095.46287.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/4/19 10:15 AM, Alexander Duyck wrote:
> +#ifdef CONFIG_KVM_GUEST
> +#include <linux/jump_label.h>
> +extern struct static_key_false pv_free_page_hint_enabled;
> +
> +#define HAVE_ARCH_FREE_PAGE
> +void __arch_free_page(struct page *page, unsigned int order);
> +static inline void arch_free_page(struct page *page, unsigned int order)
> +{
> +	if (static_branch_unlikely(&pv_free_page_hint_enabled))
> +		__arch_free_page(page, order);
> +}
> +#endif

So, this ends up with at least a call, a branch and a ret added to the
order-0 paths, including freeing pages to the per-cpu-pageset lists.
That seems worrisome.

What performance testing has been performed to look into the overhead
added to those paths?


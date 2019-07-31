Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E9B5C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 16:43:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3149A208E3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 16:43:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3149A208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8FAE8E0009; Wed, 31 Jul 2019 12:43:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B18458E0001; Wed, 31 Jul 2019 12:43:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 991FE8E0009; Wed, 31 Jul 2019 12:43:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5F25E8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 12:43:48 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d2so37859710pla.18
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:43:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=pH3zblpaQqt46p89L32EHFGyiK0T3As5Sdc+17tjb88=;
        b=rlziDCLuLJbW7tKpe/JVg4lQ76y+TNCJsQg4hVqHm+8ug/iUpVK0z7a4kHkOlReeuH
         gz30ELR6SehVNjCtdfdXLLfz5G/YfLsVGw8H04XoegJO5IPhbx7sPTR72kRFB4f00NGl
         WjWQ/AugI2fy/A5Qc6uY7o2lCyTrKgoFhG5Nnd7pyynfJdBDGMEwb5jCZZzhxAs8oJyz
         UiCUqxuRSHm9xiOlHjd9U/xm3URZEzk/MtV9UHQOB15luW/tiZoJIhoVghTwhHthUJi6
         VX1MSnX98RRkvVE4Cf+5pcR2daaa3BZE8wrvuQll6yqtG4znIVtRnbTkmK2OQrv/55G/
         fbXg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV1gJrou/7YGkmri7NqlZzT1qg4D25OmWrM5eqeiQimgqYPky/l
	Zwa8x4XfaQ/xYDheXwbh5cw5Hnv01KbayGYNhhWAdu9tto+uCELDUVx0mgAT5YKvbKAl0MGvgAg
	iPw7ZxOlQjGJzoEO7MR5KRmzEqAYY7sfHCmWnmJi7/qxl4ACT6SIh1YtV2/r3tDAQVQ==
X-Received: by 2002:a17:902:b48f:: with SMTP id y15mr123818061plr.268.1564591428060;
        Wed, 31 Jul 2019 09:43:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9XG2zZ1efvgsoEev2iOf2yXo0Vr+Pkyx9jvwNs6WVJcJ5szL8LhcntctzEpq2+PzSFFvd
X-Received: by 2002:a17:902:b48f:: with SMTP id y15mr123818014plr.268.1564591427429;
        Wed, 31 Jul 2019 09:43:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564591427; cv=none;
        d=google.com; s=arc-20160816;
        b=zMW4C5LzImJKzIADvMYTtEXcwMUa2GFZW9oLqjuiJOKCKStfFkHpkGoWTkyRjCqxmZ
         9ZP68Nn919TmbunrpmkvtrG4AMqF6Nxm12lgGh0VoL9Tkt24ZnF9NPe0fq0oRoVMHgMB
         NrqTvNfpTXtpzeE69dQgBOCJ/CyX9OQU6EPlrR2U8hwXN3gn/X6bTwlASTcGuHuPrMWr
         L/Z1XX6/p0WkKIOlO98B1WO/iMGYLxU0QuyGhCH6tJWGZpPchEcvEW65H6PvgTCtrIGi
         7wTdGs4iUCceBN7WU51zOYUu1UG4rjW3c6Wqtim+rOdS+36VyB8gVQVpaROFP6Og6hk5
         2lYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=pH3zblpaQqt46p89L32EHFGyiK0T3As5Sdc+17tjb88=;
        b=JWB8/yvJgh1ZzYMHAG/ZFRyHWPpZqqR1uuyBkSC6lc9W2+EivG1Yqd1EMvCpj94JOw
         b8U30uLYdC9xZ4cu+RvCJuB1rJkUD4ynyVJo55hNEU8GUCG5w1whyxQgAQuNdaPvSs4H
         wnEWJUeIe/4NZddZ2ZPVCV1wjk45EvwDmAXR9HDGZimz8gR0X24LTYRBPJwqCAtINXPP
         WcNnjyeNzZEdXRRnJ0qzO/mII79IAVVBSGfX1szHCqDJt1v9x0ay26nvm2a5UGszxXAg
         PCmTML5ZRZyYk8K4C//jYwjPjQoQNhEz/ltreLEtnTrEOXnIa0bPGwCG+s28LKoYelT7
         A+QQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id f10si1822617pjw.89.2019.07.31.09.43.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 09:43:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 31 Jul 2019 09:43:46 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,330,1559545200"; 
   d="scan'208";a="183748784"
Received: from ray.jf.intel.com (HELO [10.7.201.140]) ([10.7.201.140])
  by orsmga002.jf.intel.com with ESMTP; 31 Jul 2019 09:43:46 -0700
Subject: Re: [PATCH v6 1/2] arm64: Define
 Documentation/arm64/tagged-address-abi.rst
To: Vincenzo Frascino <vincenzo.frascino@arm.com>,
 linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>, Andrey Konovalov <andreyknvl@google.com>,
 Szabolcs Nagy <szabolcs.nagy@arm.com>
References: <cover.1563904656.git.andreyknvl@google.com>
 <20190725135044.24381-1-vincenzo.frascino@arm.com>
 <20190725135044.24381-2-vincenzo.frascino@arm.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <b74e7ce7-d58a-68a0-2f28-6648ec6302c0@intel.com>
Date: Wed, 31 Jul 2019 09:43:46 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190725135044.24381-2-vincenzo.frascino@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/25/19 6:50 AM, Vincenzo Frascino wrote:
> With the relaxed ABI proposed through this document, it is now possible
> to pass tagged pointers to the syscalls, when these pointers are in
> memory ranges obtained by an anonymous (MAP_ANONYMOUS) mmap().

I don't see a lot of description of why this restriction is necessary.
What's the problem with supporting MAP_SHARED?


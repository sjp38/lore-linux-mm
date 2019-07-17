Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D2C6C76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 21:06:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C26E21743
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 21:06:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C26E21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01F0B6B0005; Wed, 17 Jul 2019 17:06:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F39408E0003; Wed, 17 Jul 2019 17:06:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD92F8E0001; Wed, 17 Jul 2019 17:06:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A79FF6B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 17:06:03 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h3so15338186pgc.19
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 14:06:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=K4XEFsFATw1pbOoLQ6soUpNaR34pv37vhpkI16sjb1w=;
        b=JEKGzEOpe9w1kyzCFWN16svHXeZWneWW2c/YhnxoQUuuyBQTi9iU/12w0V5TOKR4Oo
         b8y49nGnhX4LDo0yTwdmZNF9Rl6llC6znCEFc9CksbGs7TZk+i+KGOppbGPfBGHhrpNq
         2+nkYCqlZ9zU+sketb6/CwotQimgVwS/Q8qZajokytpwCMJW3NSNDiafk2a69egcPxCO
         pYl6j1hE9msVRY722zgAyO297ACagkv1cKyRW4MnpbzDePSUuyxZJXqUSkmu8l02lrbl
         AoVS2anAL0VtnjM+5Oyy/hM2SAWOxjwvjwSpFHIYb0b9dmXEqyjCZT1k0//gEWntVWT5
         YYNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUFwFcIhMbbQuuiJxEBQC6SMcYkDS+z6hEpJiSTLUNcZ5GCGqGS
	RLq80M3FnYvFhir/rNBv4HLVkK/bl7UiA3Di0z5NKDUsOrgU7DA7oNujyO+YlOAPR38RSmYvUz9
	8mj2vYxtsqaJKri1zEdVfEFfRknYe+Tz0DpQUzJoKgHe0XvNGE3i+PlGmY8/IxSTlSA==
X-Received: by 2002:a17:902:a60d:: with SMTP id u13mr46043634plq.144.1563397563359;
        Wed, 17 Jul 2019 14:06:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYdYO4lHY5Br2mIg+BshlPN8uq3xqU5Z0W/4UiZmtMDywTa7+PHNn9x2EsUuvogbcuSkH3
X-Received: by 2002:a17:902:a60d:: with SMTP id u13mr46043581plq.144.1563397562602;
        Wed, 17 Jul 2019 14:06:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563397562; cv=none;
        d=google.com; s=arc-20160816;
        b=yFQ4GWf/fdWMfwxSgLPUj3x9ZRCP1m+XEi0Y3APpMf6ttTDOwSqSg9Ojdn7yxXQIiE
         cnEbZuZxVjqQMvMEckU0af3tF869NQaNPsWM9+cQTeJGqt+7rJr4/w+fm9W8a80XYn2A
         b8vTxzzdXWsmZV225S44GC8E0Q3KI6wEjzqVm9bhg2UMkeZom7Otxcid+DwSv09YqAKx
         02u7PUFG+A1sWtJSfP64KM6/RcL2k/irPdZIFGwSm7WRHFpQPR4+X/pjNGUWjVWCjw03
         y7SomsxTDiJ1IpzWUbVCMULY7swKXMXupXdb5VbcWqjUG/7Or5wM38Ol+wQN3mRs9n+O
         yVDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=K4XEFsFATw1pbOoLQ6soUpNaR34pv37vhpkI16sjb1w=;
        b=rIALCqQpQnj4h8u2ORwNUcNdWsUsWB8+J2qVTwI5Owk8DjpXziFuGKdZRVagaEhFeH
         9ln+t9sOUohuy9fINIrQWVdHehkzr00W1+pYIlFCJHX7FfkdCIe2KkfQa2kz4mRirCm6
         9334XnLbiShNkGCgODlUqNAnATZwk/m0mcvJL7FFtBf9YScSzzn2TyCLNyv2LTAv9TQM
         EIYZ2IDN0cCYct2TJv/zXyryAZWwVWkLV8riNVNvx9RIfcYzXaAhwrgpJAhmWHGyXlYR
         Oq01D9sx3AZzi2WqyiO4zz/YDU5BxoPHZGYGxgH7j4+ttLZTNMhGQM8jghKn6cSB0JeG
         vU6w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id v9si22541965plp.4.2019.07.17.14.06.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 14:06:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jul 2019 14:06:02 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,275,1559545200"; 
   d="scan'208";a="170368619"
Received: from ray.jf.intel.com (HELO [10.7.201.140]) ([10.7.201.140])
  by orsmga003.jf.intel.com with ESMTP; 17 Jul 2019 14:06:01 -0700
Subject: Re: [PATCH 2/3] x86/mm: Sync also unmappings in vmalloc_sync_one()
To: Joerg Roedel <joro@8bytes.org>, Dave Hansen
 <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>,
 Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, Joerg Roedel <jroedel@suse.de>
References: <20190717071439.14261-1-joro@8bytes.org>
 <20190717071439.14261-3-joro@8bytes.org>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <28a4c10f-f895-e8ff-d07b-9e4c35aa6342@intel.com>
Date: Wed, 17 Jul 2019 14:06:01 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190717071439.14261-3-joro@8bytes.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/17/19 12:14 AM, Joerg Roedel wrote:
> 
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index 4a4049f6d458..d71e167662c3 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -194,11 +194,12 @@ static inline pmd_t *vmalloc_sync_one(pgd_t *pgd, unsigned long address)
>  
>  	pmd = pmd_offset(pud, address);
>  	pmd_k = pmd_offset(pud_k, address);
> -	if (!pmd_present(*pmd_k))
> -		return NULL;
>  
> -	if (!pmd_present(*pmd))
> +	if (pmd_present(*pmd) ^ pmd_present(*pmd_k))
>  		set_pmd(pmd, *pmd_k);

Wouldn't:

	if (pmd_present(*pmd) != pmd_present(*pmd_k))
		set_pmd(pmd, *pmd_k);

be a bit more intuitive?

But, either way, these look fine.  For the series:

Reviewed-by: Dave Hansen <dave.hansen@linux.intel.com>


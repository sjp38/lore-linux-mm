Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A683AC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 15:38:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D689222A1
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 15:38:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D689222A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB75F8E0003; Thu, 14 Feb 2019 10:38:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C40888E0001; Thu, 14 Feb 2019 10:38:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABAB28E0003; Thu, 14 Feb 2019 10:38:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6395D8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:38:21 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id e68so4587731plb.3
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 07:38:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=lLvZ+WDrlDdmzqmLSKvFpHNBGJww10QsMQ6B79SA0QI=;
        b=lSw7NNZtkg4HScbTmnhvV4HUR6hm9/4kv2v9OM3IsMVcCnp4Qbu+W5pLVMs3jDW5an
         uZduTgexO3IVptJm7ylDx14ihaMfk7POgSp1yFxJNVBlhgmbpteGaZLdW4t8HJkGEsvp
         zDJrQ8/0cdM0/ihOjFTrJ85PId4MzvhkGgGKQWU87CibQVV07FDyEVjCdkrhGNpBxsR8
         E7DF3RlbbOpv3MF/i+4ZxPRQaVo4jWK4/Ng0F8JorJoNqJ0jmzjyvvECrdITxUQ7vhUF
         scS4KG+6+FRoYAVuvWamQVrGDHbuB5abRIGf1Fc2gUFCMIWdvRiOy4kgPbQZcwZh9tK/
         3G3w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubXxCAo9kTsggQYiFc+LwMwJvYMqjdtH5RacIdBLJz4ePRaCgkM
	OvRJpjBsIwXvoYRFJLyh1lC35rdhaF+sIA/gpYFkqRNh9eEBWY87BZ4hwTv+7W5MTNy7mW4Y0AB
	f9lq+3vkycg6ARX3lb+/o0ZAEJJ7H0R/KG53W5GVhrlwgfg4Jo9+WIUH+MITcww378w==
X-Received: by 2002:a17:902:887:: with SMTP id 7mr4820138pll.164.1550158701066;
        Thu, 14 Feb 2019 07:38:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibj5rSFeYDyEnKeCTB97SsI9FBZMIYO0DJuP54Gbh6WWNDw862RsaoZtXLP68l8P1eNYHme
X-Received: by 2002:a17:902:887:: with SMTP id 7mr4820086pll.164.1550158700354;
        Thu, 14 Feb 2019 07:38:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550158700; cv=none;
        d=google.com; s=arc-20160816;
        b=Ss1OrNxX2Lfug0svL2FYu6kL231SNAyq3pst9jTR6weJVnd6c+RFBnwTCdzeGIwpOE
         IJB8afXvS0Y8YdyZE6hdMOKqAOM9p93mV3cudsCPy8fygfFDNPqGncXcetRmuevJmZJb
         VIa3xD1mISiGQGUwTS6gJLDiqJceMdDzA3sPkOK0g/SqnqyAeWia4XMEJRmVQ33ihy/u
         0okhJDI8tYtccdzNXoEnW0YE+bIsLS3DPUN0q3EEjP/pS8MvEqgnpLm4/ND2Fpbi+DBO
         9zMVgpLx99F1CfNghqHrJW8drOmpoaGAh4cw0KA3zJKB1vDX9Rh8OcO9m0pKDfwDMir4
         YVig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=lLvZ+WDrlDdmzqmLSKvFpHNBGJww10QsMQ6B79SA0QI=;
        b=m6JemSG1KnwrGQp+hUHvirCfd3mEHhf/rfc1NB3IPUQ+r5YMHz249SSITB7FeTLDbF
         kH7YpsWwnVDdzXVn4V1QJN2oQD56xhtwP45GI/MS52+2/qkINexXpM+VJKsDD9cqZ6JA
         aAe7xfX3AqVxcFgocUxIJ2L+t8pZblTlhS6/64PG3HVUPd6T71zrfVatKq/7uYADGIQO
         EQ4xV4kLh4eiIZzFCEpYwiXJETsI+TOM5RD0mzsTuF2DdrIZCPQAzalrr/zGfXGPIG6O
         oTPbtezcmDCdUQS0aB0wTA8jGgNrVAZicRkKrEZQfAfrtTnusw2y45vrVCISudHYUmmY
         2Kkw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id j66si2707648pfc.251.2019.02.14.07.38.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 07:38:20 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Feb 2019 07:38:19 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,369,1544515200"; 
   d="scan'208";a="138620403"
Received: from pmmonter-mobl.amr.corp.intel.com (HELO [10.254.87.236]) ([10.254.87.236])
  by orsmga001.jf.intel.com with ESMTP; 14 Feb 2019 07:38:19 -0800
Subject: Re: [RFC 0/4] mm: Introduce lazy exec permission setting on a page
To: Anshuman Khandual <anshuman.khandual@arm.com>,
 Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill@shutemov.name,
 kirill.shutemov@linux.intel.com, vbabka@suse.cz, will.deacon@arm.com
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
 <20190213112135.GA9296@c02tf0j2hf1t.cambridge.arm.com>
 <20190213153819.GS4525@dhcp22.suse.cz>
 <0b6457d0-eed1-54e4-789b-d62881bea013@arm.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <92390cc9-3116-7b80-c2b1-5a7d29102a25@intel.com>
Date: Thu, 14 Feb 2019 07:38:19 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <0b6457d0-eed1-54e4-789b-d62881bea013@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/13/19 10:04 PM, Anshuman Khandual wrote:
>> Are there any numbers to show the optimization impact?
> This series transfers execution cost linearly with nr_pages from migration path
> to subsequent exec access path for normal, THP and HugeTLB pages. The experiment
> is on mainline kernel (1f947a7a011fcceb14cb912f548) along with some patches for
> HugeTLB and THP migration enablement on arm64 platform.
> 
> A. [Normal Pages]
> 
> nr_pages	migration1 	migration2	execfault1	execfault2	
> 
> 1000 		7.000000	3.000000	24.000000	31.000000
> 5000 		38.000000 	18.000000	127.000000	153.000000
> 10000 		80.000000 	40.000000	289.000000	343.000000
> 15000		120.000000	60.000000	435.000000	514.000000
> 19900 		159.000000	79.000000	576.000000	681.000000

Do these numbers comprehend the increased fault costs or just the
decreased migration costs?


Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0F8FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:37:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57DE2217F5
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:37:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57DE2217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 038EC8E0003; Tue, 26 Feb 2019 07:37:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2C088E0001; Tue, 26 Feb 2019 07:37:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF5F78E0003; Tue, 26 Feb 2019 07:37:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9AAA18E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:37:21 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id d17so9741602pls.2
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 04:37:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=PWcpKlQs/lVAdJRhgl9taO2la9Rzx6kFkdRThMVNMT0=;
        b=cxEC3iuWWlcPvw5Y1TzUSQkeSgSXLjXG6hHi94XJD3ETyioE3pAqDPrpmLlnoujB4P
         hFUYVduhMAG1TM9epT3x1b6jDV2dHCGtqba1SVwQbtp/kP0k837bLJtV7X3cZ+xtDM9n
         f0hHlwx8+Wdkz/xDg8r4LU3i4Kb7WdtQ5SvbkSWhaumPyK2OFFSxyy2WCjMm0Ko4qhaO
         crLTu3UexxSL+0ZK3POrwOaDlVy3aHflUAA3Nt8qy75UniinXlxQjNibqoWs5G5LehAc
         rFqrr6cPOuHzYEylz3iibRgD7YKhDogpPcXlnuhsZq2aXGDtmdi43J5NK5tqfVCUAISv
         LTjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZbgdatKRms/peJahQdu6jzgeTXNJkTtIws23yPYCi3EoeETSb0
	zCXgPGnKhCu4CpgdUtpt0cOjQoobSUq8a8cEY4H26sLMuRdtxHLEbtRIwHtXCuOik6rqzwsmCB7
	ukWc2BDA+X3zw9JNVeJ1StwQlTzX1UzstNRWqI5oLqM0XLPx4bK8HZNQv5+Cd22fzQQ==
X-Received: by 2002:a63:b447:: with SMTP id n7mr24311562pgu.401.1551184641307;
        Tue, 26 Feb 2019 04:37:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaPmGJFfY86St0c3SsLKSUBIBr4xUph+rsheyo2Bc1cQwEbxrQC/0VIm99N81D4jK980BZJ
X-Received: by 2002:a63:b447:: with SMTP id n7mr24311511pgu.401.1551184640464;
        Tue, 26 Feb 2019 04:37:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551184640; cv=none;
        d=google.com; s=arc-20160816;
        b=ZM8SmgzQA7LFGiMm3/CRPQtluyz3H5lS2Zf3835qsJFmg9FSQr6nFKXjcukaoFFD1c
         7/VFVgp2YdrdRX11VUtExGwlGcOHrST5XEHjQlwqHWABGijhHJbDu/4nP4Nd+fZXdyy2
         +WJm89cuDNlQoY1yeS+THsaq+MgvsEgNpyzg+y2mNz+1Uedn5O0HIwXNVSkBQK9UjsO3
         13d6Zu2tbGXkezRnbI52Z2p/sSUBnlOdcBjBnLmeSCAwp+M6lh/HQyBsi7BGEDorYWG4
         bFPtFSNYrjnEPHr+8LIxVCjMw78xOeS4GHy0K543hfAcky/020HNanEv6T/7Lh9E7U0e
         tmQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=PWcpKlQs/lVAdJRhgl9taO2la9Rzx6kFkdRThMVNMT0=;
        b=Z8ryv9QxkrdRLSmlawO0AvOP6ZbYB/cDkM/rxHp3++GF4gR4swJUxVs6Kyt7ceEBR4
         IOExnjQqk2wKulDJrartEZN1Ymxtug69o23kYX234HNSlUd4dtMG2eaV9frS2DQRtnu5
         Mq5uI+kCgTrzx2NDxw7orX2JRithXwHizn8IquYgOMxVsdeuph7P/XVMdAcWuLGsafFz
         7ijMqmm4D0/Xk5ZIA9t53MZqvjduKM5d0fJpiizJRwdqh89Wo2Op/WrR7TlLLSowGtXz
         s9z50y83UBaIopG7Ly1INKPzmtahCkH9rUID7byJCF3Pr6IxiBOQRcKOZZCcnKIyZtBg
         gx3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id z190si11950036pgd.238.2019.02.26.04.37.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 04:37:20 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Feb 2019 04:37:19 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,415,1544515200"; 
   d="scan'208";a="141741081"
Received: from sfhorwa1-mobl1.amr.corp.intel.com (HELO [10.251.19.118]) ([10.251.19.118])
  by orsmga001.jf.intel.com with ESMTP; 26 Feb 2019 04:37:19 -0800
Subject: Re: [PATCH 2/6] mm/memblock: make full utilization of numa info
To: Pingfan Liu <kernelfans@gmail.com>
Cc: x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>,
 Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andy Lutomirski <luto@kernel.org>,
 Andi Kleen <ak@linux.intel.com>, Petr Tesarik <ptesarik@suse.cz>,
 Michal Hocko <mhocko@suse.com>, Stephen Rothwell <sfr@canb.auug.org.au>,
 Jonathan Corbet <corbet@lwn.net>, Nicholas Piggin <npiggin@gmail.com>,
 Daniel Vacek <neelx@redhat.com>, LKML <linux-kernel@vger.kernel.org>
References: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
 <1551011649-30103-3-git-send-email-kernelfans@gmail.com>
 <0371b80b-3b4c-2377-307f-2001153edd19@intel.com>
 <CAFgQCTtuy=ueX_Eb5Z56SKMACc05qtPMJOw-WAgBbCAH_wZyjA@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <9725bf2a-55b7-5378-8d9a-a13983391b95@intel.com>
Date: Tue, 26 Feb 2019 04:37:44 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAFgQCTtuy=ueX_Eb5Z56SKMACc05qtPMJOw-WAgBbCAH_wZyjA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/25/19 9:40 PM, Pingfan Liu wrote:
>> This doesn't get used until patch 6 as far as I can tell.  Was there a
>> reason to define it here?
>>
> Yes, it gets used until patch 6. Patch 6 has two groups of
> pre-requirements [1-2] and [3-5]. Do you think reorder the patches and
> moving [3-5] ahead of [1-2] is a better choice?

I'd rather that you just introduce the code along with its first user.


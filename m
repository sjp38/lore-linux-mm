Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5864BC31E49
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 16:21:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C7C920644
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 16:21:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C7C920644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E5F88E0002; Thu, 13 Jun 2019 12:21:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BD858E0001; Thu, 13 Jun 2019 12:21:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 786128E0002; Thu, 13 Jun 2019 12:21:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 40B9F8E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:21:18 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u21so11685527pfn.15
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 09:21:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=k0aKspGg5nR73UMzVHi3yW+G0s+tA/2NVii3ecaROkY=;
        b=iczmRQt3vGHsm8Wrbg3qTooOpUxdRzu8xfEwz1p9Vs4WbtvcKYD5ta70fINU0h1t9W
         draC5atv696vmKFP/R6pCsnJErG3NehgkbhUZMJzaNXQQ7XCArBckC9pwBvUpWJyNJCU
         rBOXjlrde4HiQa+B2NvOBWmiqc3PWnxuDG3PZREPvvawefgY8eHtOn+k4OK4Ik53/XV7
         +tw3t6Qmcw3JFpq3nCx4JuwM7n001wFnlndqf2VweeGuzIT1igOiFnXc3QJ595XTVxF3
         uicjW9CCTqci+McAkIqtrr7qyMNQHAdjK2uoCQrhqHHqLxjtpj5iO9hrK8kcV18n7oZZ
         pnOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVQIu71gsPSmTfCdvISbbePkXmAAixD6n8oeHsdQNHrxXBsmmkM
	4+uFe/rbkuXBYR278UNap6K9WZLawt/89lSPgecAdZ6sd6usdPaMXpWIkBOcM3CwzYJRg2+bkkz
	uz/cVcyuulmFy3NmPTBiKVIWbKVTWA34fYj+22VGU6bkUHYJI3Hw6Axtxoz7altSc/A==
X-Received: by 2002:a17:90a:5884:: with SMTP id j4mr6697787pji.142.1560442877960;
        Thu, 13 Jun 2019 09:21:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFSDuwuzEDkw56tTbpYrpviRdsvy+m3LVpjWH3GtWFxYIhgjCVXNpxOak5vovCPXZOqf0H
X-Received: by 2002:a17:90a:5884:: with SMTP id j4mr6697724pji.142.1560442877203;
        Thu, 13 Jun 2019 09:21:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560442877; cv=none;
        d=google.com; s=arc-20160816;
        b=MBeQNsvBwOy9nl5SDdixpohmNJ50Ut3rA7QpSZ8k6irpeDnEbrIDYd/72uXUedzgg9
         cZQ7TXL0TgFrYomZceVtn4cLNcPhwsXuqgJ0IoTEDCbM3bmHHKYitxTffwQlfk0H+JP6
         hsZos9hqqW3PxFuRSBRJN7/QBbVsY86PCHWkzFC1BXbN1f/BxdeoDLLy4XXHdZnEPRnJ
         wtFa/+frar6tBMG8qOvjg/G0DUDn38w9vsLFGggcUR34V8tx2teM2rbUni5pgHxB0QUj
         KAhxMCtuW5tsECU06s+p3iR+VoTe3XmkyZEzLq6kt45RqIfcz5erkNO810rv6OZSNoYj
         6WDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=k0aKspGg5nR73UMzVHi3yW+G0s+tA/2NVii3ecaROkY=;
        b=xysbyHQXj1YG6twmBkW4+a0CdEcWwJXArmTedPNbIT10IdWHwhuz7QjyMYW1UfZNWX
         T0l6O2CwGHA8d1ymc0ZDg5NQaY5wNrHgbTM20aDJaEVUR6bROhnMM/d45jOJpmH6Z5yi
         r1b2k/rP64JGUk4vNLwQvSLDA125TZADy1+vgYCNLGfeT389GtrvXHEkMqb2CX8yeXTq
         L1dYJxA9U7Qc7g1oUwOWXLDtoPIjKuq80oURYKepgW3cMvHwSRZxHRX8FDUmpLfmAnkg
         OB4BFO7fhGddZXRoaPjRHoq4/dKzwbcbKaP4OdPm4CGfbgSJpWL8odGhXTlgYL6vEEB9
         R+rw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id w7si185585pgs.168.2019.06.13.09.21.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 09:21:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Jun 2019 09:21:16 -0700
X-ExtLoop1: 1
Received: from enagarix-mobl.amr.corp.intel.com (HELO [10.251.15.213]) ([10.251.15.213])
  by orsmga004.jf.intel.com with ESMTP; 13 Jun 2019 09:21:16 -0700
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM
 secrets
To: Andy Lutomirski <luto@kernel.org>, Alexander Graf <graf@amazon.com>,
 Nadav Amit <namit@vmware.com>
Cc: Marius Hillenbrand <mhillenb@amazon.de>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux-MM <linux-mm@kvack.org>, Alexander Graf <graf@amazon.de>,
 David Woodhouse <dwmw@amazon.co.uk>,
 the arch/x86 maintainers <x86@kernel.org>,
 Peter Zijlstra <peterz@infradead.org>
References: <20190612170834.14855-1-mhillenb@amazon.de>
 <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
 <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net>
 <CALCETrXHbS9VXfZ80kOjiTrreM2EbapYeGp68mvJPbosUtorYA@mail.gmail.com>
 <459e2273-bc27-f422-601b-2d6cdaf06f84@amazon.com>
 <CALCETrVRuQb-P7auHCgxzs5L=qA2_qHzVGTtRMAqoMAut0ETFw@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <f1dfbfb4-d2d5-bf30-600f-9e756a352860@intel.com>
Date: Thu, 13 Jun 2019 09:20:53 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CALCETrVRuQb-P7auHCgxzs5L=qA2_qHzVGTtRMAqoMAut0ETFw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/13/19 9:13 AM, Andy Lutomirski wrote:
>> It might make sense to use it for kmap_atomic() for debug purposes, as
>> it ensures that other users can no longer access the same mapping
>> through the linear map. However, it does come at quite a big cost, as we
>> need to shoot down the TLB of all other threads in the system. So I'm
>> not sure it's of general value?
> What I meant was that kmap_atomic() could use mm-local memory so that
> it doesn't need to do a global shootdown.  But I guess it's not
> actually used for real on 64-bit, so this is mostly moot.  Are you
> planning to support mm-local on 32-bit?

Do we *do* global shootdowns on kmap_atomic()s on 32-bit?  I thought we
used entirely per-cpu addresses, so a stale entry from another CPU can
get loaded in the TLB speculatively but it won't ever actually get used.
 I think it goes:

kunmap_atomic() ->
__kunmap_atomic() ->
kpte_clear_flush() ->
__flush_tlb_one_kernel() ->
__flush_tlb_one_user() ->
__native_flush_tlb_one_user() ->
invlpg

The per-cpu address calculation is visible in kmap_atomic_prot():

        idx = type + KM_TYPE_NR*smp_processor_id();


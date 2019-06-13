Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9074DC31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:05:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6226521537
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:05:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6226521537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15B056B000A; Thu, 13 Jun 2019 16:05:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10C898E0003; Thu, 13 Jun 2019 16:05:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3DC98E0002; Thu, 13 Jun 2019 16:05:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC46A6B000A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:05:37 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id f2so166829plr.0
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:05:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Nv+mSJLpVdLAG7vlAHra04PuZ9o6AU7j1dUb1EOlRTA=;
        b=j1sI3ntnkzVxz8YKtP11iJYroJRY8ZFQZs+M2sQ12XNCXEfzG6mZJOFVBC61BqagEf
         xMJ9GK/4R0v2Br+M63Xrt4LCFvKCfyBVNw9qkE30Buo5njUGQaZMWOe+wuC/j8QKLOEs
         E46J2sEo5jq88YMmYWj0+K2eNLKIboegrEUBhZ1ofXUCXbBid/o8YmxGbfG8XM8QACjp
         KW06xSAt7AItyyEOfEVI9SldSObOt/4YJPXnjjoCu0cNs4o3oyNe5G9E0xngAvqcJ3WM
         HgWaKnt8u6stXd3je9PGJpgkpjwJEHbDHIFieUkhL/gtmQt4l7EOkYFfnXFG2xokm5LA
         GqYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU7FnJM/OFiFYs8DpH0eN09UhoDtmBvnurwX3+xbajNOdmMtb78
	YJBbyI7dTLDZG6I9VNmsB6u0NDFpo/+r0j1qWR66SSNAg2wJ80AkkFbCmyJt5plw2RDSeh5UiRX
	Y3K2yXfg4cDT8GQAYB9uC4qWcNmGWQ6ZcSxSyYfz6TAB0Cif1W26TqxV2GVhPBxZmWw==
X-Received: by 2002:a62:778d:: with SMTP id s135mr23422940pfc.204.1560456337343;
        Thu, 13 Jun 2019 13:05:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmh2YhePHDsgpxN7mSSFdxvTkOHaaNKps8V8rBUVsjVgqaKgzG+gxsBWAOuPV4PV2P4UpQ
X-Received: by 2002:a62:778d:: with SMTP id s135mr23422861pfc.204.1560456336562;
        Thu, 13 Jun 2019 13:05:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560456336; cv=none;
        d=google.com; s=arc-20160816;
        b=zRZCox2N0plI828QjogLj9zjNAW/owqTa54L1PNXH5D6hdh14k8o6NO6RSeqjik41O
         39WgvC8OUjaFlebrmKz8P/voGsrI6v9cnSifu8287aCftv7Jwkm3KM53wxFpQrm2ycMG
         iZy9ucHRsSP6LbIPAoZbP/2afA92rPKAS6Ubr+y/as7c+tnGpwohWUA2iypnSHMsB/oQ
         ADuWC/7ALhfJLGcKcZNH6xrgbkVNmUwlZJWFiLoTOYoT4MGztZrxFYZ5geG86GFhaxoc
         4Y9SlX0OXtVAXoy8kSrVLFm0iA9US9Bxg7JNT1wrwRSZamBItPFqMUYpda3d8pg4+gr5
         VjHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Nv+mSJLpVdLAG7vlAHra04PuZ9o6AU7j1dUb1EOlRTA=;
        b=FKwzu6K4sV5/MqWnrUAnQJfLkb9N/SjS1apNFgioB4weYzvKoJMCGlpoCnbBy5dcgt
         Mxw1HpMJsioasBF3C6Ka+1HsGSn7qjl7Zl+P9ogLxzGE6XJwmLEX5S+dEB6Mq55cZ1wA
         g4JCWYDRwxvNSpEK+mBikenhHdZ+TUkw5AkJbxDUA/yb76kRMG/liabLqrQVfimimJEJ
         /oniwNeiEG+enV0ss4WEEjTS4gPpUjs/bAgmAEPMypJMiMslhKuc/pJPOMRXG35SWZXV
         0j8pdb75DlgkuiVACb1NtoiV3QHjTtIaCdrk6DNa5MPkGRqVylErSw9fgWC/RID6do6V
         e2UA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id g29si549480pgb.259.2019.06.13.13.05.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 13:05:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of sean.j.christopherson@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Jun 2019 13:05:35 -0700
X-ExtLoop1: 1
Received: from sjchrist-coffee.jf.intel.com (HELO linux.intel.com) ([10.54.74.36])
  by orsmga005.jf.intel.com with ESMTP; 13 Jun 2019 13:05:35 -0700
Date: Thu, 13 Jun 2019 13:05:35 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Nadav Amit <namit@vmware.com>, Andy Lutomirski <luto@kernel.org>,
	Alexander Graf <graf@amazon.com>,
	Marius Hillenbrand <mhillenb@amazon.de>,
	kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Kernel Hardening <kernel-hardening@lists.openwall.com>,
	Linux-MM <linux-mm@kvack.org>, Alexander Graf <graf@amazon.de>,
	David Woodhouse <dwmw@amazon.co.uk>,
	the arch/x86 maintainers <x86@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM
 secrets
Message-ID: <20190613200535.GC18385@linux.intel.com>
References: <20190612170834.14855-1-mhillenb@amazon.de>
 <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
 <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net>
 <CALCETrXHbS9VXfZ80kOjiTrreM2EbapYeGp68mvJPbosUtorYA@mail.gmail.com>
 <459e2273-bc27-f422-601b-2d6cdaf06f84@amazon.com>
 <CALCETrVRuQb-P7auHCgxzs5L=qA2_qHzVGTtRMAqoMAut0ETFw@mail.gmail.com>
 <f1dfbfb4-d2d5-bf30-600f-9e756a352860@intel.com>
 <70BEF143-00BA-4E4B-ACD7-41AD2E6250BE@vmware.com>
 <f7f08704-dc4b-c5f8-3889-0fb5957c9c86@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f7f08704-dc4b-c5f8-3889-0fb5957c9c86@intel.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 10:49:42AM -0700, Dave Hansen wrote:
> On 6/13/19 10:29 AM, Nadav Amit wrote:
> > Having said that, I am not too excited to deal with this issue. Do
> > people still care about x86/32-bit?
> No, not really.

Especially not for KVM, given the number of times 32-bit KVM has been
broken recently without anyone noticing for several kernel releases.


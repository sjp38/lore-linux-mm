Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D8B6C4321A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:49:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E16522089E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:48:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E16522089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74B1F6B0272; Mon, 10 Jun 2019 18:48:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FC6E6B0273; Mon, 10 Jun 2019 18:48:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C3146B0276; Mon, 10 Jun 2019 18:48:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 26B2D6B0272
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 18:48:59 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c17so8159872pfb.21
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:48:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1OUwWeLrUq+dlOxulLlkl7WSpPLxR0uc2y6Q8h98sLs=;
        b=WoYj07LvoR0eMt8kfRAw2MriGAFqF9fhoFZPqhhw0NTTIyZwzfXEf0Ls1Ym5Gj9Vxo
         1G41LID7x1cAEIWZ82eq74PNng9GbWQSk3ZL8s5PjAKpLq534y/hceNNpZvDfJIGSbTg
         i4TiK6FhrY61xkKmvacD6SURpCdwlhJuzy/D8C59Uvu5RAZ5SP0x5Dx79hvx0XC4RwrM
         TqrJf4bQlRDj5m9oCSCDuw/21zGUJsNJwsH/xlJB4iZ1V8K96nm9maKoSHDUL2ZXCHh7
         XvM31yolEh+tmEU4h1AGyrjRhqy63po/VwAZ9M1JdmwOLp9ZxS+EZ92Hx2VJr0MPD56g
         yc2A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUeK/39rfNDmwMxB380piBwHf+H4U+MtfYE77/6CxPsvvSRl4lj
	jCSPn2cBxy6wzbkhl0QUdAJgvRdUlJkRcaE0T3wGfM0bdKm4XyHoA40Cv58n+IMXe6yIzZiXc19
	WxPaFNPSHWepB5zgSICdqMMpGG1fx1gFbZ3lV42dgpXzX60bPT6Pft9yqWM+QeWbHmg==
X-Received: by 2002:a17:902:1c9:: with SMTP id b67mr25602108plb.333.1560206938812;
        Mon, 10 Jun 2019 15:48:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx6V8rB83zaNb6Cr8raVOl7M/rEg1A2j4fwYQCbE2eT1/NctXOONZstlx16n2negZ4NC5QP
X-Received: by 2002:a17:902:1c9:: with SMTP id b67mr25602058plb.333.1560206937971;
        Mon, 10 Jun 2019 15:48:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560206937; cv=none;
        d=google.com; s=arc-20160816;
        b=ODY0+F+QXkn4DvDNk2Ak5Xb0lhEVdmBVFKs/AKotz2Pu/4Ttu6XyPCTzO11nb/fL+9
         U8bAIBLpk4N77Z+E+r/nzDoroePL5yJ+j6hBwh3ElYdgfJDChmY8W23G9gEfFs/U84Y7
         tE3QYckH1yJDyj0Vr3Rbytje4O095KAOtPPK9RAxO10qZpTBLcFTKstuRf5QJELfA27q
         tlbrB0fgR+9G3QTpQ5e9CHZ3c4Xs6iparGYtids4O/Lat5pe99A1Fyi70/GHQmnHvTUW
         RGuOt6rCdHZJf2qygk2cWzN3KfpvCVzmIFphwGGXN2DerE3yMdVBveVjuwis5nq8B8ky
         3uJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=1OUwWeLrUq+dlOxulLlkl7WSpPLxR0uc2y6Q8h98sLs=;
        b=KvN12vP1ft+G/7exCh4ZU5AxcVeR01NajY4gwQ5xuXOK/od9ZsUJpJvUrU6SWpuuIt
         ZQ2TuCDjfzPYIN6zzk/qIDL7FMuLmZqRnmR/NKlWg0UITBEjY2mLQjNiQ7hmCWlGgLOU
         Djc6wbwai/P2IbI3cMFwBwrI7hkTdHBomIq5bYImr96xJMWbfCnnbcSOrMxOXpCEEXos
         bgETiLreGnS3C2klqlKR4trdHTZXctusP3TssK+YMUvpQyGJ8Ms/EcnmauvL3b6n7Tmt
         a+nXg98H5nuD0yQ4UWXmFQuIqOXBrHYoepzSGEhmo4enhUouR55pFt41f0S1CAmeyPV4
         p2gA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id z9si673751pjn.2.2019.06.10.15.48.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 15:48:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Jun 2019 15:48:57 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by fmsmga005.fm.intel.com with ESMTP; 10 Jun 2019 15:48:56 -0700
Message-ID: <1b961c71d30e31ecb22da2c5401b1a81cb802d86.camel@intel.com>
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski
 <luto@amacapital.net>
Cc: Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, "H. Peter Anvin"
 <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar
 <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org,  linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Balbir Singh
 <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,  Cyrill Gorcunov
 <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene
 Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J.
 Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet
 <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz
 <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov
 <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Randy Dunlap
 <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, Dave Martin
 <Dave.Martin@arm.com>
Date: Mon, 10 Jun 2019 15:40:49 -0700
In-Reply-To: <92e56b28-0cd4-e3f4-867b-639d9b98b86c@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
	 <20190606200926.4029-4-yu-cheng.yu@intel.com>
	 <20190607080832.GT3419@hirez.programming.kicks-ass.net>
	 <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
	 <20190607174336.GM3436@hirez.programming.kicks-ass.net>
	 <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
	 <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net>
	 <7e0b97bf1fbe6ff20653a8e4e147c6285cc5552d.camel@intel.com>
	 <25281DB3-FCE4-40C2-BADB-B3B05C5F8DD3@amacapital.net>
	 <e26f7d09376740a5f7e8360fac4805488b2c0a4f.camel@intel.com>
	 <3f19582d-78b1-5849-ffd0-53e8ca747c0d@intel.com>
	 <5aa98999b1343f34828414b74261201886ec4591.camel@intel.com>
	 <0665416d-9999-b394-df17-f2a5e1408130@intel.com>
	 <5c8727dde9653402eea97bfdd030c479d1e8dd99.camel@intel.com>
	 <ac9a20a6-170a-694e-beeb-605a17195034@intel.com>
	 <328275c9b43c06809c9937c83d25126a6e3efcbd.camel@intel.com>
	 <92e56b28-0cd4-e3f4-867b-639d9b98b86c@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-06-10 at 15:02 -0700, Dave Hansen wrote:
> On 6/10/19 1:58 PM, Yu-cheng Yu wrote:
> > > > On each memory request, the kernel then must consider a percentage of
> > > > allocated space in its calculation, and on systems with less memory
> > > > this quickly becomes a problem.
> > > 
> > > I'm not sure what you're referring to here?  Are you referring to our
> > > overcommit limits?
> > 
> > Yes.
> 
> My assumption has always been that these large, potentially sparse
> hardware tables *must* be mmap()'d with MAP_NORESERVE specified.  That
> should keep them from being problematic with respect to overcommit.

Ok, we will go back to do_mmap() with MAP_PRIVATE, MAP_NORESERVE and
VM_DONTDUMP.  The bitmap will cover only 48-bit address space.

We then create PR_MARK_CODE_AS_LEGACY.  The kernel will set the bitmap, but it
is going to be slow.

Perhaps we still let the app fill the bitmap?

Yu-cheng


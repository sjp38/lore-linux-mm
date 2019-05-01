Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 964B2C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 22:01:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CEA42085A
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 22:01:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CEA42085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EBE8F6B0005; Wed,  1 May 2019 18:01:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6EA56B0006; Wed,  1 May 2019 18:01:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D36BB6B0007; Wed,  1 May 2019 18:01:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7796B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 18:01:54 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m35so200596pgl.6
        for <linux-mm@kvack.org>; Wed, 01 May 2019 15:01:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CS7LbYoPibyc87lVkhPVK+F/JCApQtyCOzkPKm+7umc=;
        b=UFsMzP/k6XJRMkMcSXkCLSGpaUtWxbZftYh81hicmcEAV6Hqlhih72zjpjKQiJCWs/
         b7J9+VwjnfQ6e79LSNC1G0IRFgoJUTDDncYrGz2B71WUCRbwgMImbRugBip+zFubtTVz
         nNi9VuXYBkFID9co6+Zo5/o4zNBBkhZMyIbKhMNU6wtEksdYGey2dFTg2n2otANlr8p2
         RwfqgMGx3msQhENZWE6kxyqc129SREJLoWQaab3chOjGrbU+tqMVsvvFYOpTB5HGjZga
         sOQzGxXvbVhrqRuwccdgVdFaUrj3sCuh12r0nifB11/9oSsipEcRhUBqKtsN3hZZLEFq
         RJOw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVlTLhuXQi4pfuqq6XAO/3Qsnq5eaWCHwv+msT++N5RZEboMLir
	bxADEbSTsdjCnc1MOFgpd4tqUtcNxYZKMG5r+2Kbwom0pBf9RR7Ck+/XsKjzXgx01mveqqyJXgW
	Yitib6+2gN1oxEd6BXeAz2hQemmGwFCl2O6gGQ7uoZuEopcF7pAiwEORVLmshpkK26Q==
X-Received: by 2002:a63:1820:: with SMTP id y32mr326753pgl.287.1556748114328;
        Wed, 01 May 2019 15:01:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSY9ZPpKUVogkhs2BLvCU6jA/L7Xygp3RMn2cjiJjztkgMCI/YGzhP7vEasKiTB52PQKDg
X-Received: by 2002:a63:1820:: with SMTP id y32mr326701pgl.287.1556748113614;
        Wed, 01 May 2019 15:01:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556748113; cv=none;
        d=google.com; s=arc-20160816;
        b=H6guNB6dAeKyhdpZ0+mk880/0E4zxQSqp9/cxARt/6kAhuR4Ht1RIGJXjm17MC+Uqu
         Q8+HzkfJ9XcYz5D4j3+5hAjGL3wR2TwDPIv5i4Rgoj1v0SeL3ssoy41BS1e7TOPm0X08
         ycNIMxvV8oqtZYAFusSISnV0urws4FYUy+R3C8AiwCHl+W3VgEWSvcewB10uBOlsb4eR
         mIhXg2IWonPzcphQHvMtnAkFk6qMGZvfcoKgBD6wRCq3xPT1SmL5dYxiz3ogoBqaQoux
         wZYVimPS2f0txjQrf6L58aoGyhUxqwtAVMpAXqAMCuYbwraFQlMzE3kZamxmwe/aBX0L
         EOvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=CS7LbYoPibyc87lVkhPVK+F/JCApQtyCOzkPKm+7umc=;
        b=i6XpB/kQOzRkxniOpWtqBfGVK8zBMquO8YuhPvZX3HsQb/AnTzlPqKaf+1sL2TEQlL
         CtKZdO64NqGFDTVmSE+7uzA1h6PTX5txeIyxzYyIbIK4XzN8C8TLmrj+zE4n94kRAVjF
         9DZcCh2IwvhQgA/O88UETLZag7ZtcEyxuB6GdLenTRfBFp3dEPifXUeBP27IV7/28+W9
         AoOrSV19qfpNb/Ql265LXQRAo4L4QQ6mpUl3jqOOk/G7HCEZUjUJUBChcaWrf5DuHwO+
         GXTNxhy1IhLPP6tKx/bRa/PG2RxNl+Lk7s8Sx9O2Nqc9A7N+xsqusXZaQzNZBx9ek0qD
         VlmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id b9si43371859pla.275.2019.05.01.15.01.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 15:01:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 May 2019 15:01:52 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 01 May 2019 15:01:49 -0700
Message-ID: <1c69263279be0b2f6582e58a0bf28bc213d94693.camel@intel.com>
Subject: Re: [PATCH] binfmt_elf: Extract .note.gnu.property from an ELF file
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org,  linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>,
 Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov
 <esyr@redhat.com>,  Florian Weimer <fweimer@redhat.com>, "H.J. Lu"
 <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet
 <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz
 <mike.kravetz@oracle.com>,  Nadav Amit <nadav.amit@gmail.com>, Oleg
 Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra
 <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>,  Dave Martin <Dave.Martin@arm.com>
Date: Wed, 01 May 2019 14:54:23 -0700
In-Reply-To: <20190501213709.GD28500@bombadil.infradead.org>
References: <20190501211217.5039-1-yu-cheng.yu@intel.com>
	 <20190501213709.GD28500@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-05-01 at 14:37 -0700, Matthew Wilcox wrote:
> On Wed, May 01, 2019 at 02:12:17PM -0700, Yu-cheng Yu wrote:
> > +++ b/fs/Kconfig.binfmt
> > @@ -35,6 +35,10 @@ config COMPAT_BINFMT_ELF
> >  config ARCH_BINFMT_ELF_STATE
> >  	bool
> >  
> > +config ARCH_USE_GNU_PROPERTY
> > +	bool
> > +	depends on 64BIT
> 
> I don't think this is right.  I think you should get rid of the depends line
> and instead select the symbol from each of argh64 and x86 Kconfig files.

That makes sense.  Thanks!

Yu-cheng


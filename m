Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 979CCC43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:15:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB26F2067D
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:15:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB26F2067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3CF56B000A; Thu, 25 Apr 2019 11:15:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E14EB6B000C; Thu, 25 Apr 2019 11:15:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2AF96B000D; Thu, 25 Apr 2019 11:15:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9CF426B000A
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 11:15:05 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d21so161138pfr.3
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:15:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2DbBLv0DXv4u7HvOi587w4iwb3NYWEgoW0IaFGYc2Pg=;
        b=qzY8dgDszFsisxVdnbenOCIxb1Yxj0ZkK1LDZ30g4KUNe2gYbQsnuUs1NyoBuAdnEE
         7TBRneLfWohCWCG/kv5CgYWzYW9zNinHcM6W6Dgi83kiVb4NE6B3aIn2EjzyncfI33gG
         lw6MXPv7jzEC6CiGwDqanwMDdd70BZSIfA4T5puGrsaKV0AvHSSZvF5JsZdjb3y8x6iF
         LMiwgTL8AAL1yubINXtd3WytmCNank/TDY4JI7GiJjtyo/XXSPdcwb1bsaOlj2dZxWmu
         5XoVO2OOekpSymIedb4kv3kMA7jOYKKysBgqsU80EDokZHjgRu/iIrJsU3Cxm2/yjgXx
         Fp4A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUxUxl8PQMElpS0xr/3lh2wCEeqd3tDiu93jkIycucmoAJRYe5x
	cikc1IJ4EwhN2t73K2jdqOEecD/egKtYvxczmN9hTaI6ajTyn9L0PlQIRPRuXPk6P7imeimf0nO
	Nd0traMq7DQ4PWOsmWVCXCn5gopjABedVLhv43mdwuyqn+0OMZQ9PruhmxqRAZxahBQ==
X-Received: by 2002:a62:604:: with SMTP id 4mr40792184pfg.38.1556205305282;
        Thu, 25 Apr 2019 08:15:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJIg9GxoSM5xd5lxzjixyM8SNBsNSg+ptbCqvCn5P5hpUhhbJKcurPo8/kRlIVnAU/Iy/R
X-Received: by 2002:a62:604:: with SMTP id 4mr40792102pfg.38.1556205304455;
        Thu, 25 Apr 2019 08:15:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556205304; cv=none;
        d=google.com; s=arc-20160816;
        b=qpVdZCVAxzWqS6MvDTn4jvW3R6yE2i53ZKS4aIXKHmhA+jvk0Z/QVGvfLlbK4BZfnD
         b+o3kP3dP62bgZ/HfwNt828gC2NcUQ3eej/SaCsLVtpDVqXZYUnhQfvqpUfvEHT1v1tX
         kvoCbBGhfIfzUADDXqB8WCH0BjuZVM3YUr/bEuMAi+RCXmU2N1Yo6oCvb+z4fUTC0W+X
         czYrzb8EDzmGRUA1s9Ycl2+6cq2f7Sq0RzQJgKhLQt0RYC8HSpm/7ZSUa1xH4DF85ejX
         xVl6dQfpl4qwt1vnkBlWPo00W9KfQZN3ZKFAz2Fd6QXiXkyPuWPJ5GO/MI7Mr6JDnpyf
         2RqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=2DbBLv0DXv4u7HvOi587w4iwb3NYWEgoW0IaFGYc2Pg=;
        b=Ee/E4qF9dl2KGt/s3YNBaW32ejDGRV8L0hWZ6dAIpDNRwqiW4a7vmnRe4hbgTSrSlD
         JcbpwDq0s/7JVNc/IDgsTICxfO1gL8XiYL3qvWA20OyGgNzJxDMcBcpQlZZMpWMoavEo
         YJQ6wwyl6Mb1xb553ip8NhoEg3b2aLkcfIpka/IELb6VxAKqXMF1lV1pFEh7osQu7qn1
         3C5sud4TkDIXdM8AsPZqTpYVBCHiELx2be2CrK9Ek04acJLrWZAAv5NIU+4J66U/4D7J
         n8HDOT+7Tty8zA3yqOUPUuY02UxzhjIZ+Nycn1diai+OTy0LzCUnG+kg0zMpL1udt+n5
         vwZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id k131si21953573pga.267.2019.04.25.08.15.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 08:15:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Apr 2019 08:15:03 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,394,1549958400"; 
   d="scan'208";a="340728748"
Received: from yyu32-desk1.sc.intel.com ([10.144.155.177])
  by fmsmga005.fm.intel.com with ESMTP; 25 Apr 2019 08:15:02 -0700
Message-ID: <e7bbb51291434a9c8526d7b617929465d5784121.camel@intel.com>
Subject: Re: [RFC PATCH v6 22/26] x86/cet/shstk: ELF header parsing of
 Shadow Stack
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Dave Martin <Dave.Martin@arm.com>
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
 <vedvyas.shanbhogue@intel.com>
Date: Thu, 25 Apr 2019 08:14:52 -0700
In-Reply-To: <20190425110211.GZ3567@e103592.cambridge.arm.com>
References: <20181119214809.6086-1-yu-cheng.yu@intel.com>
	 <20181119214809.6086-23-yu-cheng.yu@intel.com>
	 <20190425110211.GZ3567@e103592.cambridge.arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-04-25 at 12:02 +0100, Dave Martin wrote:
> On Mon, Nov 19, 2018 at 01:48:05PM -0800, Yu-cheng Yu wrote:
> > Look in .note.gnu.property of an ELF file and check if Shadow Stack needs
> > to be enabled for the task.
> 
> What's the status of this series?  I don't see anything in linux-next
> yet.
> 
> For describing ELF features, Arm has recently adopted
> NT_GNU_PROPERTY_TYPE_0, with properties closely modelled on
> GNU_PROPERTY_X86_FEATURE_1_AND etc. [1]
> 
> So, arm64 will be need something like this patch for supporting new
> features (such as the Branch Target Identification feature of ARMv8.5-A
> [2]).
> 
> If this series isn't likely to merge soon, can we split this patch into
> generic and x86-specific parts and handle them separately?
> 
> It would be good to see the generic ELF note parsing move to common
> code -- I'll take a look and comment in more detail.

Yes, I will work on that.

> 
> [...]
> 
> > diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
> > index 69c0f892e310..557ed0ba71c7 100644
> > --- a/arch/x86/include/asm/elf.h
> > +++ b/arch/x86/include/asm/elf.h
> > @@ -381,4 +381,9 @@ struct va_alignment {
> >  
> >  extern struct va_alignment va_align;
> >  extern unsigned long align_vdso_addr(unsigned long);
> > +
> > +#ifdef CONFIG_ARCH_HAS_PROGRAM_PROPERTIES
> > +extern int arch_setup_features(void *ehdr, void *phdr, struct file *file,
> > +			       bool interp);
> > +#endif
> >  #endif /* _ASM_X86_ELF_H */
> > diff --git a/arch/x86/include/uapi/asm/elf_property.h
> > b/arch/x86/include/uapi/asm/elf_property.h
> > new file mode 100644
> > index 000000000000..af361207718c
> > --- /dev/null
> > +++ b/arch/x86/include/uapi/asm/elf_property.h
> > @@ -0,0 +1,15 @@
> > +/* SPDX-License-Identifier: GPL-2.0 */
> > +#ifndef _UAPI_ASM_X86_ELF_PROPERTY_H
> > +#define _UAPI_ASM_X86_ELF_PROPERTY_H
> > +
> > +/*
> > + * pr_type
> > + */
> > +#define GNU_PROPERTY_X86_FEATURE_1_AND (0xc0000002)
> > +
> > +/*
> > + * Bits for GNU_PROPERTY_X86_FEATURE_1_AND
> > + */
> > +#define GNU_PROPERTY_X86_FEATURE_1_SHSTK	(0x00000002)
> > +
> 
> Generally we seem to collect all ELF definitions in <linux/uapi/elf.h>,
> including arch-specific ones.

Agree.

> 
> Is a new header really needed here?
> 
> [...]
> 
> > diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> > index 54207327f98f..007ff0fbae84 100644
> > --- a/fs/binfmt_elf.c
> > +++ b/fs/binfmt_elf.c
> > @@ -1081,6 +1081,21 @@ static int load_elf_binary(struct linux_binprm *bprm)
> >  		goto out_free_dentry;
> >  	}
> >  
> > +#ifdef CONFIG_ARCH_HAS_PROGRAM_PROPERTIES
> > +	if (interpreter) {
> > +		retval = arch_setup_features(&loc->interp_elf_ex,
> > +					     interp_elf_phdata,
> > +					     interpreter, true);
> 
> Can we dummy no-op functions in the common headers to avoid this
> ifdeffery?  Logically all arches will always do this step, even if it's
> a no-op today.

Sure.

Thanks,

Yu-cheng


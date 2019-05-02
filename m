Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AD59C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 15:56:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0611920675
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 15:56:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0611920675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 751DC6B0003; Thu,  2 May 2019 11:56:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 703CB6B0006; Thu,  2 May 2019 11:56:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5CB1F6B0007; Thu,  2 May 2019 11:56:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 222C66B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 11:56:12 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s19so1447418plp.6
        for <linux-mm@kvack.org>; Thu, 02 May 2019 08:56:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DV8tNnvAzhdosXEajSqQ9L2SxnFCpg190lOLJjhQj08=;
        b=T3OtT8EozIeE/Zs/e/XfS+zOYQrQS1nGYlmVbM7ixZ5AhB38BwFOyLXR1FN7x2zrNf
         jwjEiRvtLrG81LEm0GNWvy/2PT/VpYN7MFku4ZMTOKTIuRy2Mcu1b9XYv4lTVTQU1A4u
         OQlFh86o/JF6U1N9v35kRfMIxAwEOWqwoSA5alpeu9trin1mge69Jbhpa639qS9v82pV
         Ziw05ybNdDb5X2eCYY0okywTY5elo87S8yYgJmeZbRKza5NDiHAaHDP2xbD9drKU+VZ3
         JlGs/tcdMncrzKlS2cTQ+kn5M9m4IPhCshaYCqbLF38+2BRR3+CzQaXC6M/vy/J+miaj
         RsVw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWyg3beeBxB59pEuwTDqn5BRVTf3F42lNe9Xuyaz4cUgjOweEz1
	kIrRKF5itUnxIyWgt89lmm/yUs5dzT7S8OCF+ZR26/iOI8YSQTRKYsZ0+Y1GjBXYe6H6/yMAdIY
	yHcGWkQLJKszchE/Salzjr/kZCvtv+wt6ywsK5nsNlq4zBZroee/kIkuiWcB5cuLJlg==
X-Received: by 2002:a17:902:b617:: with SMTP id b23mr4331305pls.73.1556812571805;
        Thu, 02 May 2019 08:56:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNfKV/n1tK9Om+Hr0WjUzdp1LB/8Ith73qQKp+XOAVQZf+bC+x79p+16hXFgOaX1ShsLk4
X-Received: by 2002:a17:902:b617:: with SMTP id b23mr4331246pls.73.1556812571061;
        Thu, 02 May 2019 08:56:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556812571; cv=none;
        d=google.com; s=arc-20160816;
        b=TU+lzsOR74StITTh4OKahXDBLo6lbWqJR1ZFUmyJ0V36W1CZ06ZznRn98pskjBt3ND
         wsveT7wW952RmYZSg8T8juK8wQRMkAQboCOAca2mNc/uauwT9MqbxLEOzd2SpWnetUPZ
         i6qtRMDQ8g3WLIXhmD6zRCJzQMsXugP9bYDd8v6+CEgqX5N3uq5uWcSUNHo341FUJwqo
         dQBtFA5Ie+1n+zpfz3wUnFiRnXGXxI9lmEz8ePnZHPET+ZfC6zTqrlIo06tHLp8jjCoA
         1zk4Pmx3oZCzoYYTViCmJd6p/dD2CQpuAF//jR3mUr0FpBg00BR9zv3IxH18ROPNuUH8
         UF4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=DV8tNnvAzhdosXEajSqQ9L2SxnFCpg190lOLJjhQj08=;
        b=lSAp4T6WZvJlO4jYdYFmyJGrOHJBb3EGP0Pjf6oWJeGmRvwrk1taqJhSjeiktplUVO
         0vP1s24NV+MzpVjj4bOWxXDEEZosm7/VhAz0oxwtOCkWQz3I76LXxhkIoDEm6BAbuvzE
         JvavJZk3YoemLjf4udl5ORfWyOnpxdhAq0YdWrbjDdCpTNgjAaUseBy5rZB1RpJ313ti
         ZKbfDMmFWS3pVpOkmN/juMAP5RSJX344xHn6l7vdLLt2NGDDmzJMh2evXBEo5qF8X0hv
         GsLG9s6GmsOVYFFqu0/ywK7Dpfzp/mEsT7bpHz0bN1o3GEQJdXukj4Eus9HEA6+80s/R
         uvjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id t21si12293822pgm.438.2019.05.02.08.56.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 08:56:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 02 May 2019 08:56:10 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,422,1549958400"; 
   d="scan'208";a="147702137"
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by fmsmga007.fm.intel.com with ESMTP; 02 May 2019 08:56:09 -0700
Message-ID: <ed56d7930e630213d74a7df8b9144d01415dac7c.camel@intel.com>
Subject: Re: [PATCH] binfmt_elf: Extract .note.gnu.property from an ELF file
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
 <vedvyas.shanbhogue@intel.com>,  Szabolcs Nagy <szabolcs.nagy@arm.com>,
 libc-alpha@sourceware.org
Date: Thu, 02 May 2019 08:48:42 -0700
In-Reply-To: <20190502142951.GP3567@e103592.cambridge.arm.com>
References: <20190501211217.5039-1-yu-cheng.yu@intel.com>
	 <20190502111003.GO3567@e103592.cambridge.arm.com>
	 <20190502142951.GP3567@e103592.cambridge.arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-05-02 at 15:29 +0100, Dave Martin wrote:
> On Thu, May 02, 2019 at 12:10:04PM +0100, Dave Martin wrote:
> > On Wed, May 01, 2019 at 02:12:17PM -0700, Yu-cheng Yu wrote:
> 
> [...]
> 
> > > diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c > > index
> > > 7d09d125f148..40aa4a4fd64d 100644
> > > --- a/fs/binfmt_elf.c
> > > +++ b/fs/binfmt_elf.c
> > > @@ -1076,6 +1076,19 @@ static int load_elf_binary(struct linux_binprm
> > > *bprm)
> > >  		goto out_free_dentry;
> > >  	}
> > >  
> > > +	if (interpreter) {
> > > +		retval = arch_setup_property(&loc->interp_elf_ex,
> > > +					     interp_elf_phdata,
> > > +					     interpreter, true);
> > > +	} else {
> > > +		retval = arch_setup_property(&loc->elf_ex,
> > > +					     elf_phdata,
> > > +					     bprm->file, false);
> > > +	}
> 
> This will be too late for arm64, since we need to twiddle the mmap prot
> flags for the executable's pages based on the detected properties.
> 
> Can we instead move this much earlier, letting the arch code stash
> something in arch_state that can be consumed later on?
> 
> This also has the advantage that we can report errors to the execve()
> caller before passing the point of no return (i.e., flush_old_exec()).

I will look into that.

> 
> [...]
> 
> > > diff --git a/fs/gnu_property.c b/fs/gnu_property.c
> 
> [...]
> 
> > > +int get_gnu_property(void *ehdr_p, void *phdr_p, struct file *f,
> > > +		     u32 pr_type, u32 *property)
> > > +{
> > > +	struct elf64_hdr *ehdr64 = ehdr_p;
> > > +	int err = 0;
> > > +
> > > +	*property = 0;
> > > +
> > > +	if (ehdr64->e_ident[EI_CLASS] == ELFCLASS64) {
> > > +		struct elf64_phdr *phdr64 = phdr_p;
> > > +
> > > +		err = scan_segments_64(f, phdr64, ehdr64->e_phnum,
> > > +				       pr_type, property);
> > > +		if (err < 0)
> > > +			goto out;
> > > +	} else {
> > > +#ifdef CONFIG_COMPAT
> > > +		struct elf32_hdr *ehdr32 = ehdr_p;
> > > +
> > > +		if (ehdr32->e_ident[EI_CLASS] == ELFCLASS32) {
> > > +			struct elf32_phdr *phdr32 = phdr_p;
> > > +
> > > +			err = scan_segments_32(f, phdr32, ehdr32-
> > > >e_phnum,
> > > +					       pr_type, property);
> > > +			if (err < 0)
> > > +				goto out;
> > > +		}
> > > +#else
> > > +	WARN_ONCE(1, "Exec of 32-bit app, but CONFIG_COMPAT is not
> > > enabled.\n");
> > > +	return -ENOTSUPP;
> > > +#endif
> > > +	}
> 
> We have already made a ton of assumptions about the ELF class by this
> point, and we don't seem to check it explicitly elsewhere, so it is a
> bit weird to police it specifically here.
> 
> Can we simply pass the assumed ELF class as a parameter instead?

Yes.

Yu-cheng


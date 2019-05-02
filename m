Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA8C7C04AA9
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 14:30:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DC1E205F4
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 14:30:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DC1E205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08D886B0007; Thu,  2 May 2019 10:30:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03EE86B0008; Thu,  2 May 2019 10:30:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E972C6B000A; Thu,  2 May 2019 10:30:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9CFDA6B0007
	for <linux-mm@kvack.org>; Thu,  2 May 2019 10:30:02 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f41so1168776ede.1
        for <linux-mm@kvack.org>; Thu, 02 May 2019 07:30:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GjZRT6nPoKpuBmsPa1t099v4/OXTxPeMOIlYa6Pu4ts=;
        b=PPEn3iEt3p0+YkD6E4xqy5BUeu8YC4eJtlNrg/wxUpofgFoyOaIw4WS/fimYhxv8rn
         7VDn4ix+mLw9S5MXYXALdLz/lC50io1K8pZsPF5IkWw7pkJTq5ipBPMmzI9ZR/eTba0V
         24q96rmPthbCDHlrvFvp6UQSe2YQYel9ToZEit6mmhnR0rgKqX4j7l2cooj1ssvVi3P7
         PgPrNc6gTsEVRKdpFb+/VvTsxmXVKlRvxnCijHrvie1ZFXDsoiUqiVI1tm1ORzcYHRvZ
         EXqaYAnVhK8RFQXYbShpVhWVE4HGnShkm0ub4KkwN3Cv9zdszQNItCQnitCi8BQA0tIb
         n4fQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAWrmjhyGOuaq6uHpyEdLcssXfYQYPJHMzPza0/6DYFToQQeks6n
	Txah4ajIueA+fe+bVZ1BmvyuvL5+9ZSXVxpsSrEMY+11a8Ofk2pK2RJuz5krQAQArYdDDMPzT8f
	WYj4MC5bxdlY3hl6FvvXQoa+xoEkqCix7FuO2mmKabAFFdd6wsxD5hFMCvKk3GFd9dg==
X-Received: by 2002:a17:906:6d8d:: with SMTP id h13mr2010982ejt.229.1556807402175;
        Thu, 02 May 2019 07:30:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqylo2kd7AsJ+9V6AFeXQqJCz7yRT5ibYSc4Gka2rLt0k0lZ67b24OHWAHnOwvBCvTgmv6ES
X-Received: by 2002:a17:906:6d8d:: with SMTP id h13mr2010925ejt.229.1556807401019;
        Thu, 02 May 2019 07:30:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556807401; cv=none;
        d=google.com; s=arc-20160816;
        b=bs96l+eH8trc72Jor5yT0SCQDOYkbHRJhNGoH4l8NeZRUbZyRMuiKX1dM26J8LEi7o
         +dvEERhqqPUIHSJYpB1xsNPSCHM1PmGA6EbJLxPYMdrrq5F1J3sIr+ddPRlsP32ND0ZZ
         3wWvRd161P8omvZyJDHb0h35IRnhRKVgMrNMZaUolRUNhdijrECO/7F5lhJqtSQ/zCTy
         JVjq6WGgdcLyR1dW1bg2mGsjdDqi3kfd26d5QFO4yQZ6vaX7+J6eQScrP2wwoD8a/nKq
         NpyEyu6CP1M8M73Yz1bZ/Vwr6Qy3CV1qOjvYlr/c/EgdzWEYaLIB37UbYm3wgu/SWB8h
         regw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GjZRT6nPoKpuBmsPa1t099v4/OXTxPeMOIlYa6Pu4ts=;
        b=1HHMqdjyuzmRIIlBTV6GzJgpUfq+/O2bXgC+m1JSCrVTLr+D+7NYjq80atuYuDekZJ
         rBmLmwUjNgBL4xmEekGY8c3RgrwBLQ41Z1SmTapzBhevu//avsI0O+dSENE2XnhGLDv/
         h58ATVo964jyFeYhH/Hv4EPt0GAZj11IlPxfgmDp/MowxxfLD+TTi89yeZeK6Nwif8k8
         AbuxIQp3oLcTwhd13xQz7FasQIgPiy8v1besaPvaRh0G9bq/VcWeygd2mZVHZ7odnNNk
         PCvW9a9P9pIX8xLKBDJqpgV2f2bZO/cUouOJ9KUWJ4SEnR08u0dgh+lQ7vv7+0DWZIQ3
         chlA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u46si3088661edm.404.2019.05.02.07.30.00
        for <linux-mm@kvack.org>;
        Thu, 02 May 2019 07:30:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C155F374;
	Thu,  2 May 2019 07:29:59 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B4FB13F5AF;
	Thu,  2 May 2019 07:29:54 -0700 (PDT)
Date: Thu, 2 May 2019 15:29:52 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Szabolcs Nagy <szabolcs.nagy@arm.com>, libc-alpha@sourceware.org
Subject: Re: [PATCH] binfmt_elf: Extract .note.gnu.property from an ELF file
Message-ID: <20190502142951.GP3567@e103592.cambridge.arm.com>
References: <20190501211217.5039-1-yu-cheng.yu@intel.com>
 <20190502111003.GO3567@e103592.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190502111003.GO3567@e103592.cambridge.arm.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 02, 2019 at 12:10:04PM +0100, Dave Martin wrote:
> On Wed, May 01, 2019 at 02:12:17PM -0700, Yu-cheng Yu wrote:
> > An ELF file's .note.gnu.property indicates features the executable file
> > can support.  For example, the property GNU_PROPERTY_X86_FEATURE_1_AND
> > indicates the file supports GNU_PROPERTY_X86_FEATURE_1_IBT and/or
> > GNU_PROPERTY_X86_FEATURE_1_SHSTK.
> > 
> > This patch was part of the Control-flow Enforcement series; the original
> > patch is here: https://lkml.org/lkml/2018/11/20/205.  Dave Martin responded
> > that ARM recently introduced new features to NT_GNU_PROPERTY_TYPE_0 with
> > properties closely modelled on GNU_PROPERTY_X86_FEATURE_1_AND, and it is
> > logical to split out the generic part.  Here it is.
> > 
> > With this patch, if an arch needs to setup features from ELF properties,
> > it needs CONFIG_ARCH_USE_GNU_PROPERTY to be set, and a specific
> > arch_setup_property().
> > 
> > For example, for X86_64:
> > 
> > int arch_setup_property(void *ehdr, void *phdr, struct file *f, bool inter)
> > {
> > 	int r;
> > 	uint32_t property;
> > 
> > 	r = get_gnu_property(ehdr, phdr, f, GNU_PROPERTY_X86_FEATURE_1_AND,
> > 			     &property);
> > 	...
> > }

[...]

> > diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c > > index 7d09d125f148..40aa4a4fd64d 100644
> > --- a/fs/binfmt_elf.c
> > +++ b/fs/binfmt_elf.c
> > @@ -1076,6 +1076,19 @@ static int load_elf_binary(struct linux_binprm *bprm)
> >  		goto out_free_dentry;
> >  	}
> >  
> > +	if (interpreter) {
> > +		retval = arch_setup_property(&loc->interp_elf_ex,
> > +					     interp_elf_phdata,
> > +					     interpreter, true);
> > +	} else {
> > +		retval = arch_setup_property(&loc->elf_ex,
> > +					     elf_phdata,
> > +					     bprm->file, false);
> > +	}

This will be too late for arm64, since we need to twiddle the mmap prot
flags for the executable's pages based on the detected properties.

Can we instead move this much earlier, letting the arch code stash
something in arch_state that can be consumed later on?

This also has the advantage that we can report errors to the execve()
caller before passing the point of no return (i.e., flush_old_exec()).

[...]

> > diff --git a/fs/gnu_property.c b/fs/gnu_property.c

[...]

> > +int get_gnu_property(void *ehdr_p, void *phdr_p, struct file *f,
> > +		     u32 pr_type, u32 *property)
> > +{
> > +	struct elf64_hdr *ehdr64 = ehdr_p;
> > +	int err = 0;
> > +
> > +	*property = 0;
> > +
> > +	if (ehdr64->e_ident[EI_CLASS] == ELFCLASS64) {
> > +		struct elf64_phdr *phdr64 = phdr_p;
> > +
> > +		err = scan_segments_64(f, phdr64, ehdr64->e_phnum,
> > +				       pr_type, property);
> > +		if (err < 0)
> > +			goto out;
> > +	} else {
> > +#ifdef CONFIG_COMPAT
> > +		struct elf32_hdr *ehdr32 = ehdr_p;
> > +
> > +		if (ehdr32->e_ident[EI_CLASS] == ELFCLASS32) {
> > +			struct elf32_phdr *phdr32 = phdr_p;
> > +
> > +			err = scan_segments_32(f, phdr32, ehdr32->e_phnum,
> > +					       pr_type, property);
> > +			if (err < 0)
> > +				goto out;
> > +		}
> > +#else
> > +	WARN_ONCE(1, "Exec of 32-bit app, but CONFIG_COMPAT is not enabled.\n");
> > +	return -ENOTSUPP;
> > +#endif
> > +	}

We have already made a ton of assumptions about the ELF class by this
point, and we don't seem to check it explicitly elsewhere, so it is a
bit weird to police it specifically here.

Can we simply pass the assumed ELF class as a parameter instead?

[...]

Cheers
---DavE


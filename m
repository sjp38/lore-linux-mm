Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 890DCC31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 09:32:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B91D207E0
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 09:32:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B91D207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7B426B0003; Wed, 12 Jun 2019 05:32:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2ADD6B0005; Wed, 12 Jun 2019 05:32:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF3036B0006; Wed, 12 Jun 2019 05:32:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 62BFD6B0003
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 05:32:20 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d13so25023847edo.5
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 02:32:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hRLMpHDou3KKc/22WYT4Jpt7MnXsssJX4udDmLKYlic=;
        b=didhmkP8mU6AqhreeXJolIoCdxRPinDMO7rTVnqVhIvSv/dNHposUCysqKtrbhzbN+
         kxtIsd3SfDQ7ceLyiAfTIqs75KwFl1Tep+LEY9i2zxmX5WPz3xqiYGm/vYz4UO0uBlNc
         ucK9fP/+RDlxaDv+eDwwY/ezXutB01mBMSZmpJgQPcvxUVuVTEDFaTapl1B+OeJaknoo
         YKhSconGYdI69A6TEFTAjGQaIqOnb74YPtgfqbWxZlyMrtt7DSOPIiSo/Vrl1dd3qckM
         XSKTstAznLH7xURui924zG0u7xzuV3Fo9smzsx/j0zoF/1e/DwXfY1MtbAxFQXQ1Uu3K
         f8uA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXQc6LI8zm1Kc8ejWVn89cRAqbytxD/XeQNe4ODeD0t19omwogS
	0+Fl/pjCPgWbJTdnmixduq6GslhnDzOhevMTPEvnvwevFW9COtnmKNiNsBfj1CU358SosqwIaO/
	ISg69aY7TtMT7JixH5gPoDkSyouRSpXOQlCI749RkepGl6sIMSp5DTgrkLCq4qPpPSw==
X-Received: by 2002:a50:a5e3:: with SMTP id b32mr47619662edc.169.1560331939936;
        Wed, 12 Jun 2019 02:32:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7RCwpu0l0gjj0wQ2bcJ0aYNEyxVi7GBYjSoCMAuYTGV0K9U7ppY7XLmSGwmh1OpgUneWS
X-Received: by 2002:a50:a5e3:: with SMTP id b32mr47619589edc.169.1560331939027;
        Wed, 12 Jun 2019 02:32:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560331939; cv=none;
        d=google.com; s=arc-20160816;
        b=vQL1f9D2d9Z/8A3XjkA7KnZl8TSkSa8QGJvS1qbNPSr5ofSg0/34ps3oMyB4I2rCbM
         MmcUPNWG3IvrtZFRlCWf5OR1rkUvNHPkx/tVQJ8XoZtsZDrDDnppjJw0uRJHNioQuei0
         9Uwof+ZTnjEez8GECekyLE7GXjAFCUUhioA0wc7YCsSMP0AN38prpzYwoINU7UaGkBh+
         iTM4UNQARL5xEmTFmbcUOb9uG5QB2958gqxPSAC8A1D1PqridZ5mG3xvTpRG7YZZ1Y+P
         2xMvBzgqPGg/q90LDY3bwX7PmUkKNHW34yMUK/OiWxHaIitlY6TfuZhD++SFO+fYKakz
         4I2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=hRLMpHDou3KKc/22WYT4Jpt7MnXsssJX4udDmLKYlic=;
        b=LQT32BJPPG5kUbP+EPrNemwIqIu3zPeIK6OeMd2tHLRM8jamjR36TiUGmT4+LIOvIo
         isFYewnlpm6hPtdNhy8cvxBXMnL5I7H9RUesYJSNjCilld/jsaafLbqvvr18K7IEfT/H
         W5aQuY62QTAab5UeKiEcxCVBdphRdEgumXJ4RLANcH55PV3+N20U9y8hvQU0k7INsGvn
         EGNIp4u2jkDzDBf9nWBtrkSf/O8rF5EPASDMNgGxWh/8t760VsFn+A2kOgUi+BLXjtTa
         gKrWbX+7D3PiueGGP155oIA7s3OIywO2EGZ0ON9XQFezHzar0D+GlIQCZApLpn5Mgs3L
         f5rw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id l2si4018772ejr.264.2019.06.12.02.32.18
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 02:32:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0C99828;
	Wed, 12 Jun 2019 02:32:18 -0700 (PDT)
Received: from c02tf0j2hf1t.cambridge.arm.com (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C6AAD3F246;
	Wed, 12 Jun 2019 02:32:04 -0700 (PDT)
Date: Wed, 12 Jun 2019 10:32:00 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Vincenzo Frascino <vincenzo.frascino@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, Khalid Aziz <khalid.aziz@oracle.com>,
	linux-kselftest@vger.kernel.org,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org,
	Christoph Hellwig <hch@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>, Dmitry Vyukov <dvyukov@google.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	linux-arm-kernel@lists.infradead.org,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>, linux-kernel@vger.kernel.org,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>, enh <enh@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v16 02/16] arm64: untag user pointers in access_ok and
 __uaccess_mask_ptr
Message-ID: <20190612093158.GG10165@c02tf0j2hf1t.cambridge.arm.com>
References: <cover.1559580831.git.andreyknvl@google.com>
 <4327b260fb17c4776a1e3c844f388e4948cfb747.1559580831.git.andreyknvl@google.com>
 <20190610175326.GC25803@arrakis.emea.arm.com>
 <20190611145720.GA63588@arrakis.emea.arm.com>
 <d3dc2b1f-e8c9-c60d-f648-0bc9b08f20e4@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d3dc2b1f-e8c9-c60d-f648-0bc9b08f20e4@arm.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Vincenzo,

On Tue, Jun 11, 2019 at 06:09:10PM +0100, Vincenzo Frascino wrote:
> > diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
> > index 3767fb21a5b8..69d0be1fc708 100644
> > --- a/arch/arm64/kernel/process.c
> > +++ b/arch/arm64/kernel/process.c
> > @@ -30,6 +30,7 @@
> >  #include <linux/kernel.h>
> >  #include <linux/mm.h>
> >  #include <linux/stddef.h>
> > +#include <linux/sysctl.h>
> >  #include <linux/unistd.h>
> >  #include <linux/user.h>
> >  #include <linux/delay.h>
> > @@ -323,6 +324,7 @@ void flush_thread(void)
> >  	fpsimd_flush_thread();
> >  	tls_thread_flush();
> >  	flush_ptrace_hw_breakpoint(current);
> > +	clear_thread_flag(TIF_TAGGED_ADDR);
> 
> Nit: in line we the other functions in thread_flush we could have something like
> "tagged_addr_thread_flush", maybe inlined.

The other functions do a lot more than clearing a TIF flag, so they
deserved their own place. We could do this when adding MTE support. I
think we also need to check what other TIF flags we may inadvertently
pass on execve(), maybe have a mask clearing.

> > diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
> > index 094bb03b9cc2..2e927b3e9d6c 100644
> > --- a/include/uapi/linux/prctl.h
> > +++ b/include/uapi/linux/prctl.h
> > @@ -229,4 +229,9 @@ struct prctl_mm_map {
> >  # define PR_PAC_APDBKEY			(1UL << 3)
> >  # define PR_PAC_APGAKEY			(1UL << 4)
> >  
> > +/* Tagged user address controls for arm64 */
> > +#define PR_SET_TAGGED_ADDR_CTRL		55
> > +#define PR_GET_TAGGED_ADDR_CTRL		56
> > +# define PR_TAGGED_ADDR_ENABLE		(1UL << 0)
> > +
> >  #endif /* _LINUX_PRCTL_H */
> > diff --git a/kernel/sys.c b/kernel/sys.c
> > index 2969304c29fe..ec48396b4943 100644
> > --- a/kernel/sys.c
> > +++ b/kernel/sys.c
> > @@ -124,6 +124,12 @@
> >  #ifndef PAC_RESET_KEYS
> >  # define PAC_RESET_KEYS(a, b)	(-EINVAL)
> >  #endif
> > +#ifndef SET_TAGGED_ADDR_CTRL
> > +# define SET_TAGGED_ADDR_CTRL(a)	(-EINVAL)
> > +#endif
> > +#ifndef GET_TAGGED_ADDR_CTRL
> > +# define GET_TAGGED_ADDR_CTRL()		(-EINVAL)
> > +#endif
> >  
> >  /*
> >   * this is where the system-wide overflow UID and GID are defined, for
> > @@ -2492,6 +2498,16 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
> >  			return -EINVAL;
> >  		error = PAC_RESET_KEYS(me, arg2);
> >  		break;
> > +	case PR_SET_TAGGED_ADDR_CTRL:
> > +		if (arg3 || arg4 || arg5)
> > +			return -EINVAL;
> > +		error = SET_TAGGED_ADDR_CTRL(arg2);
> > +		break;
> > +	case PR_GET_TAGGED_ADDR_CTRL:
> > +		if (arg2 || arg3 || arg4 || arg5)
> > +			return -EINVAL;
> > +		error = GET_TAGGED_ADDR_CTRL();
> > +		break;
> 
> Why do we need two prctl here? We could have only one and use arg2 as set/get
> and arg3 as a parameter. What do you think?

This follows the other PR_* options, e.g. PR_SET_VL/GET_VL,
PR_*_FP_MODE. We will use other bits in arg2, for example to set the
precise vs imprecise MTE trapping.

-- 
Catalin


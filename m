Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 668F5C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 11:17:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2491220B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 11:17:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2491220B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9F0F6B026F; Thu, 13 Jun 2019 07:17:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B74D56B0270; Thu, 13 Jun 2019 07:17:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8B3C6B0271; Thu, 13 Jun 2019 07:17:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 59F6A6B026F
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 07:17:18 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so23121778eds.14
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 04:17:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fNf7W0XDjfuqlv8Ucd7/kRA78LegGdT3pa40skvVgGo=;
        b=BdqbPhIxNLZykFQhdLTIKMwfmVzjU9PzmI7t7Rra9ktKZynwr+wzIRvC82kFHfzQVT
         sJvW/u2KG9MlvnLnTQKsf29D7gW4LbMl137p48kyHaHiVCeaJN3XIh/T+yU8Tr6hyJ4A
         ihF7AoSk0zktUa3nMv216Dxf2oA8m/eBYOmdnKIIQt6MtI9MVOu3RsgJv+3MSVSoCFDg
         6ATNSA55iwzUrnBvivrutHhFZfb1uBn+wiNM1UZK3TYqL30JjO97O8cFt4c+LeQC/Fs2
         4Ku68O87SsZz3LPDxIWOkEFeM384d0Gfdyg2AOf7Ung1f4XotVzhrXsZlUZnjTP+RpEd
         UDIQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAXtscMj58nkgT1lMRWP2GVEp2H4UkoN0YcVBGTv/RjLzF+BUQ+Y
	xdG/HYjMf7ZyVEXJs0ASb5Dfrugd1q9EcCWsszcUFc16eVIioKbfT/z8MDOCT7SDiUTxa5Nq7XK
	Li6d39lQeNcNwqB9AHYxI/Y7fBgOEXjOqx/GjN5hu3IIsrO2DJ2mMfr6drlN6gliceA==
X-Received: by 2002:a17:906:6550:: with SMTP id u16mr53379281ejn.7.1560424637829;
        Thu, 13 Jun 2019 04:17:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzawUPWlND4sT7B7fV8nsnpUk3Dz7SsV5+mV9Dgjl0Tcai7ASK5bnHc1vMU9mYWH74A4LbD
X-Received: by 2002:a17:906:6550:: with SMTP id u16mr53378378ejn.7.1560424627396;
        Thu, 13 Jun 2019 04:17:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560424627; cv=none;
        d=google.com; s=arc-20160816;
        b=Yj3+zQbplYG7VBfkWOu+sypxweFJs9cYyB3py0KL0SerbLg+7L8gvWJ8fV7hH+UybX
         P2ymgPZclPMVBZUt0eoNm+wNqPr7SKPYGaZ4dTVTJgYPS2GKKfJkdMIb5SPp72xteU58
         P09j3PLTvu32PW3Ewid9M9+QUwzFa978V+O/0/z5cu3eaLYKmBMBrnAzgNqYsB911stq
         z611qK+kvPLUGRlDPtInuXUzyHuugv8mp6w0PCZREEl+LsM/WW9MaaV0S/Pn12FKwdxH
         D/HWPwmz7576wR8fLjPeduF5JlM+zq0aTf3Mp4zwZwzxgaDUCM7PckxNkzedgACnQNNX
         3BmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fNf7W0XDjfuqlv8Ucd7/kRA78LegGdT3pa40skvVgGo=;
        b=KnYNJ51snDUwgj6aDvVSqvDBknOyXnQNgJi8CK4cInqGrxTS7M5VE20B2Jzv22PI5i
         nD59LkVVCMFPsiIyLeuHPyIqnW3/65B3n26T40/LYSjNo3Qhw8UkrLiA4V+5PwJBJjGS
         FG0JOPHb3bw5ZVcuAonDMt4bZVM4CHmaijzWdQyxtXWuELv4OOT/bTUXIxU7LkIx1kHx
         uQPR7gLK6f2hkheyZ8PK+V1bW8Y/e+O1YN43gvp0nQJtKjMCI6nC+6BvbBPweD3gZaDo
         svXlg/OFcl1KIFx0NI/IOXNFJhwpLyeQSRDt+RHzKX56kWLd1GuTtuoyhXa43HV+Cil+
         Ji3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id l1si1868189eja.176.2019.06.13.04.17.07
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 04:17:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 68C33367;
	Thu, 13 Jun 2019 04:17:06 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 11EDF3F694;
	Thu, 13 Jun 2019 04:18:44 -0700 (PDT)
Date: Thu, 13 Jun 2019 12:16:59 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Mark Rutland <mark.rutland@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kostya Serebryany <kcc@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>,
	Christoph Hellwig <hch@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Evgeniy Stepanov <eugenis@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>, enh <enh@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v17 03/15] arm64: Introduce prctl() options to control
 the tagged user addresses ABI
Message-ID: <20190613111659.GX28398@e103592.cambridge.arm.com>
References: <cover.1560339705.git.andreyknvl@google.com>
 <a7a2933bea5fe57e504891b7eec7e9432e5e1c1a.1560339705.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a7a2933bea5fe57e504891b7eec7e9432e5e1c1a.1560339705.git.andreyknvl@google.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 01:43:20PM +0200, Andrey Konovalov wrote:
> From: Catalin Marinas <catalin.marinas@arm.com>
> 
> It is not desirable to relax the ABI to allow tagged user addresses into
> the kernel indiscriminately. This patch introduces a prctl() interface
> for enabling or disabling the tagged ABI with a global sysctl control
> for preventing applications from enabling the relaxed ABI (meant for
> testing user-space prctl() return error checking without reconfiguring
> the kernel). The ABI properties are inherited by threads of the same
> application and fork()'ed children but cleared on execve().
> 
> The PR_SET_TAGGED_ADDR_CTRL will be expanded in the future to handle
> MTE-specific settings like imprecise vs precise exceptions.
> 
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> ---
>  arch/arm64/include/asm/processor.h   |  6 +++
>  arch/arm64/include/asm/thread_info.h |  1 +
>  arch/arm64/include/asm/uaccess.h     |  3 +-
>  arch/arm64/kernel/process.c          | 67 ++++++++++++++++++++++++++++
>  include/uapi/linux/prctl.h           |  5 +++
>  kernel/sys.c                         | 16 +++++++
>  6 files changed, 97 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/processor.h
> index fcd0e691b1ea..fee457456aa8 100644
> --- a/arch/arm64/include/asm/processor.h
> +++ b/arch/arm64/include/asm/processor.h
> @@ -307,6 +307,12 @@ extern void __init minsigstksz_setup(void);
>  /* PR_PAC_RESET_KEYS prctl */
>  #define PAC_RESET_KEYS(tsk, arg)	ptrauth_prctl_reset_keys(tsk, arg)
>  
> +/* PR_TAGGED_ADDR prctl */

(A couple of comments I missed in my last reply:)

Name mismatch?

> +long set_tagged_addr_ctrl(unsigned long arg);
> +long get_tagged_addr_ctrl(void);
> +#define SET_TAGGED_ADDR_CTRL(arg)	set_tagged_addr_ctrl(arg)
> +#define GET_TAGGED_ADDR_CTRL()		get_tagged_addr_ctrl()
> +

[...]

> diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
> index 3767fb21a5b8..69d0be1fc708 100644
> --- a/arch/arm64/kernel/process.c
> +++ b/arch/arm64/kernel/process.c
> @@ -30,6 +30,7 @@
>  #include <linux/kernel.h>
>  #include <linux/mm.h>
>  #include <linux/stddef.h>
> +#include <linux/sysctl.h>
>  #include <linux/unistd.h>
>  #include <linux/user.h>
>  #include <linux/delay.h>
> @@ -323,6 +324,7 @@ void flush_thread(void)
>  	fpsimd_flush_thread();
>  	tls_thread_flush();
>  	flush_ptrace_hw_breakpoint(current);
> +	clear_thread_flag(TIF_TAGGED_ADDR);
>  }
>  
>  void release_thread(struct task_struct *dead_task)
> @@ -552,3 +554,68 @@ void arch_setup_new_exec(void)
>  
>  	ptrauth_thread_init_user(current);
>  }
> +
> +/*
> + * Control the relaxed ABI allowing tagged user addresses into the kernel.
> + */
> +static unsigned int tagged_addr_prctl_allowed = 1;
> +
> +long set_tagged_addr_ctrl(unsigned long arg)
> +{
> +	if (!tagged_addr_prctl_allowed)
> +		return -EINVAL;

So, tagging can actually be locked on by having a process enable it and
then some possibly unrelated process clearing tagged_addr_prctl_allowed.
That feels a bit weird.

Do we want to allow a process that has tagging on to be able to turn
it off at all?  Possibly things like CRIU might want to do that.

> +	if (is_compat_task())
> +		return -EINVAL;
> +	if (arg & ~PR_TAGGED_ADDR_ENABLE)
> +		return -EINVAL;

How do we expect this argument to be extended in the future?

I'm wondering whether this is really a bitmask or an enum, or a mixture
of the two.  Maybe it doesn't matter.

> +
> +	if (arg & PR_TAGGED_ADDR_ENABLE)
> +		set_thread_flag(TIF_TAGGED_ADDR);
> +	else
> +		clear_thread_flag(TIF_TAGGED_ADDR);

I think update_thread_flag() could be used here.

[...]

Cheers
---Dave


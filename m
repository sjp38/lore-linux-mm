Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41885C31E49
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:35:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0652C206BB
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:35:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0652C206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F50E6B0006; Thu, 13 Jun 2019 11:35:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A62E6B0008; Thu, 13 Jun 2019 11:35:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66E1C6B000C; Thu, 13 Jun 2019 11:35:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1596E6B0006
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 11:35:32 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l26so31390716eda.2
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:35:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vSD5FUgVNjNOzj9cE71rNaoL/7qxb9b5/pfJb9gP+a0=;
        b=dvmOxHUxZ58XDW7pR5afIoF9/JunAfFQWDJqz7DGHtKnDkw4JjsO68anMBw5mYReWL
         NSvVcyThocAdZL5dapQ3cv2ek6yenCovq+ZO+CLOPGw6o2XnKZ+IZsVv5i1i8h742UVi
         YhlD9LoW6nwo6QaDOCarUcoXgWPmw3pcjjCkatdmF2L2q2vhsDyFwA96i6sizr99ZE1U
         IJB/BtGQOczCohLfEFQRU/9o9QaHzlY6kWDzmEWEr7mFWzfQTITaW606Qsy0T3gkmyDI
         24lEFmuJEUOMGBcq6nHiKaOeLZelSsgkwe8Xw4j2QhOrBIB7breyU1oNHsVVtjM9RXq1
         q+EQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXG05Powaz0YlooUixiKY80XGHjwymLyWBNP8uCmk2MXRElYP26
	rxDGpIP14o260jBotzykr6e5T17zO2fdFndkB8XbCnbDoNrHcfskip0JXru3U8o+30GGXSdqBIV
	jtrtvdJx3jvn37AsFyHGO8EYGxPATHljPEBHW49dp6CdsLXjE353Cc9ZNOqId261W/Q==
X-Received: by 2002:a50:8934:: with SMTP id e49mr67904876ede.156.1560440131599;
        Thu, 13 Jun 2019 08:35:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwIRNqR8lSpXdSS5LbhNJqW+vEuGlvjFV1x6AIDeFsEBPRw/r/leQJ2drYiJLbmg8fX5MG+
X-Received: by 2002:a50:8934:: with SMTP id e49mr67904793ede.156.1560440130752;
        Thu, 13 Jun 2019 08:35:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560440130; cv=none;
        d=google.com; s=arc-20160816;
        b=VgZOtKXYevx16BNNGaMEH0/77zF6PHdRTExB22qH5tt8TN0gyGPIExZepFUszHJCJ5
         +VJ6Z9IUoghwSAA8Jss402+DZbWyipqKcxakr+H+rCgFKv3W9YSr2xODltfJ9mqJ4OC5
         Q8YvgqZhVu5NY61sWtKOHSieQVVaJ4c2T2i+H/3VMH7RZdiCWnh0yFp6+CLYJmEuq6de
         CGcp/hpxzTK9qqD5FbkUrqaCxZedZw8PhSonRcPw5ZvT6cr9u493vNtCa1d89Sc/QsC5
         2nk4fn5U3j/9D5HraplTG6jyxKXN4P+3XhLuwHBH+UQ11xjiPCqI5FiDmXccm38zK5Ex
         +5oA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vSD5FUgVNjNOzj9cE71rNaoL/7qxb9b5/pfJb9gP+a0=;
        b=wMr+wN8Q2k4hGza8W8X57whIM3wfpdok6KBkRXeA7s6qCHI/Re98+1SEX1Svtu/Hb9
         HbP4cZuut1fS84oivXMzpi0yIZ9JRnAVOyTd83sbXVFod3UOIV+QjSFd92/1SL8/FfCE
         FHzAOu9qw0zn+yTPq/QxlFpdb+1On3RM60UU+RMuSy6xqvpB0Cn75yo3j8cBxRupJFSp
         SOgjTgkBP00WymewIWBtTWrT9RUqtAVdb/hHwIceNtkZZNP4tXf1yJ0v4bU+HAQ+OLTH
         qCSZE+UaoBc4xZzOveXWbburABDAORIQU+cSH695Qwy0NA+/T43GAzxcCevYitlnfJ5h
         lheg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id v29si2669047edc.115.2019.06.13.08.35.30
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 08:35:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BF6F23EF;
	Thu, 13 Jun 2019 08:35:29 -0700 (PDT)
Received: from C02TF0J2HF1T.local (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CE4553F718;
	Thu, 13 Jun 2019 08:35:11 -0700 (PDT)
Date: Thu, 13 Jun 2019 16:35:07 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Dave Martin <Dave.Martin@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Mark Rutland <mark.rutland@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
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
Message-ID: <20190613153505.GU28951@C02TF0J2HF1T.local>
References: <cover.1560339705.git.andreyknvl@google.com>
 <a7a2933bea5fe57e504891b7eec7e9432e5e1c1a.1560339705.git.andreyknvl@google.com>
 <20190613111659.GX28398@e103592.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613111659.GX28398@e103592.cambridge.arm.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 12:16:59PM +0100, Dave P Martin wrote:
> On Wed, Jun 12, 2019 at 01:43:20PM +0200, Andrey Konovalov wrote:
> > From: Catalin Marinas <catalin.marinas@arm.com>
> > 
> > It is not desirable to relax the ABI to allow tagged user addresses into
> > the kernel indiscriminately. This patch introduces a prctl() interface
> > for enabling or disabling the tagged ABI with a global sysctl control
> > for preventing applications from enabling the relaxed ABI (meant for
> > testing user-space prctl() return error checking without reconfiguring
> > the kernel). The ABI properties are inherited by threads of the same
> > application and fork()'ed children but cleared on execve().
> > 
> > The PR_SET_TAGGED_ADDR_CTRL will be expanded in the future to handle
> > MTE-specific settings like imprecise vs precise exceptions.
> > 
> > Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> > ---
> >  arch/arm64/include/asm/processor.h   |  6 +++
> >  arch/arm64/include/asm/thread_info.h |  1 +
> >  arch/arm64/include/asm/uaccess.h     |  3 +-
> >  arch/arm64/kernel/process.c          | 67 ++++++++++++++++++++++++++++
> >  include/uapi/linux/prctl.h           |  5 +++
> >  kernel/sys.c                         | 16 +++++++
> >  6 files changed, 97 insertions(+), 1 deletion(-)
> > 
> > diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/processor.h
> > index fcd0e691b1ea..fee457456aa8 100644
> > --- a/arch/arm64/include/asm/processor.h
> > +++ b/arch/arm64/include/asm/processor.h
> > @@ -307,6 +307,12 @@ extern void __init minsigstksz_setup(void);
> >  /* PR_PAC_RESET_KEYS prctl */
> >  #define PAC_RESET_KEYS(tsk, arg)	ptrauth_prctl_reset_keys(tsk, arg)
> >  
> > +/* PR_TAGGED_ADDR prctl */
> 
> (A couple of comments I missed in my last reply:)
> 
> Name mismatch?

Yeah, it went through several names but it seems that I didn't update
all places.

> > +long set_tagged_addr_ctrl(unsigned long arg);
> > +long get_tagged_addr_ctrl(void);
> > +#define SET_TAGGED_ADDR_CTRL(arg)	set_tagged_addr_ctrl(arg)
> > +#define GET_TAGGED_ADDR_CTRL()		get_tagged_addr_ctrl()
> > +
> 
> [...]
> 
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
> >  }
> >  
> >  void release_thread(struct task_struct *dead_task)
> > @@ -552,3 +554,68 @@ void arch_setup_new_exec(void)
> >  
> >  	ptrauth_thread_init_user(current);
> >  }
> > +
> > +/*
> > + * Control the relaxed ABI allowing tagged user addresses into the kernel.
> > + */
> > +static unsigned int tagged_addr_prctl_allowed = 1;
> > +
> > +long set_tagged_addr_ctrl(unsigned long arg)
> > +{
> > +	if (!tagged_addr_prctl_allowed)
> > +		return -EINVAL;
> 
> So, tagging can actually be locked on by having a process enable it and
> then some possibly unrelated process clearing tagged_addr_prctl_allowed.
> That feels a bit weird.

The problem is that if you disable the ABI globally, lots of
applications would crash. This sysctl is meant as a way to disable the
opt-in to the TBI ABI. Another option would be a kernel command line
option (I'm not keen on a Kconfig option).

> Do we want to allow a process that has tagging on to be able to turn
> it off at all?  Possibly things like CRIU might want to do that.

I left it in for symmetry but I don't expect it to be used. A potential
use-case is doing it per subsequent threads in an application.

> > +	if (is_compat_task())
> > +		return -EINVAL;
> > +	if (arg & ~PR_TAGGED_ADDR_ENABLE)
> > +		return -EINVAL;
> 
> How do we expect this argument to be extended in the future?

Yes, for MTE. That's why I wouldn't allow random bits here.

> I'm wondering whether this is really a bitmask or an enum, or a mixture
> of the two.  Maybe it doesn't matter.

User may want to set PR_TAGGED_ADDR_ENABLE | PR_MTE_PRECISE in a single
call.

> > +	if (arg & PR_TAGGED_ADDR_ENABLE)
> > +		set_thread_flag(TIF_TAGGED_ADDR);
> > +	else
> > +		clear_thread_flag(TIF_TAGGED_ADDR);
> 
> I think update_thread_flag() could be used here.

Yes. I forgot you added this.

-- 
Catalin


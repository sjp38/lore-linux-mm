Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08265C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 16:57:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B75C32083D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 16:57:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B75C32083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5742E8E0010; Mon, 25 Feb 2019 11:57:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FCBB8E000E; Mon, 25 Feb 2019 11:57:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39DC88E0010; Mon, 25 Feb 2019 11:57:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D0E7A8E000E
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 11:57:31 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id a9so4224919edy.13
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 08:57:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yAWOqVwPS1JiQWbex88iVewnn0kxHb5cGa4KE98GC2g=;
        b=dIXiIT7JW3Uoq6C2sUsRUP+yKF7W2XTpH0MNzL8l8Bml4s4bvk0kc/oiaAMHFye074
         RIRWIy5mEJTDyAloZwhD/4pd1R10nrw8wHUNWf0b4yqFJ3LJprik4d4SzF3FpOs/zpfD
         84CcByNUccdG5EFSRYl/I0094P3xdDxQ0TDtW/LGLUXsbmYQM8RxukK7sAtm1jcdSj2l
         +ZCnhpf2LxJUFNURJ3VO7557QQz5T4vQOS9RcAntdV9XSlnLvmiNAGd0LtG3aY6yirPx
         zise/e9fzuDFqgeWc8+qm9/3Dnq1jYKAnkCkfR2tV0h5aR/IDwH3hDnPEYHsiluMQtNE
         ODEA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: AHQUAub8UCKun3Xs1qjd706T3/rcgI4neN5oNxCrKH+EjolD2lto7QSr
	a3+TaWeGuQkWpiNwzAMkep4TeqLzfITLe+roKR4OSteGZB9qrmrabFpvjfF79T5dRVFoKyGnP+R
	3ddy39BUKzOqh67tukcqJ8kFLWtubdSO8w57Tp6e37FkmT4bJJ7PELmbxq3ceDouSmw==
X-Received: by 2002:a17:906:970a:: with SMTP id k10mr13989913ejx.102.1551113851375;
        Mon, 25 Feb 2019 08:57:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbVbSMc0xWZkJMUIhLzYC7n/NvUmBQfXqGDcPPQK4OfcNoaNupPOlIWonyE4UnHf+17AuOe
X-Received: by 2002:a17:906:970a:: with SMTP id k10mr13989856ejx.102.1551113850149;
        Mon, 25 Feb 2019 08:57:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551113850; cv=none;
        d=google.com; s=arc-20160816;
        b=g7Q/id07rRkOXhb9zUGClUh0y5GpYPS6ES69C/Knay3JmLmPEo4UtLiJRtWAVyAs0s
         J3DPOky+5VYCb+fj1i0UgqR9mEpfEzk0xizaxQnFFypFbmMX7KDyX/F5lpiITx7Wmu9x
         Ml6/jsrbQCDrrcq2q0jVyzR1UExEPRSQylZyZXrd7PwovFlQ+8xjPLe0J0a7aLHSfgIF
         COIMAg29R2jEqjC3k7ASqAutmBKvjau/iR0Zv/DTo/BHsVUZwpy7U/PZy1o2EM4Hi/Fc
         WbvEFmJlNBansmFXr4Yy/vZv5eZdwCVux7pZoKztYj0BrpOFJOEz6Oq9e6xceNcBvy7p
         MZfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yAWOqVwPS1JiQWbex88iVewnn0kxHb5cGa4KE98GC2g=;
        b=YeaO4Ix1I2tVQQALO/V8v82w6Ev1O1BT/ZUBWGZlDiO5S6UOaG4lvbJOgh3l96JCPY
         jJCQ6SfSoNDA4BiFoEmKOArgUNH818kJRWGUHjb3kwsi5L2hMf1mQnyn3wARaIOhWsbr
         pEY2+wgwLW8sYBc29Z/a3fqd+hVQcIGHhJ62dwstx9Eatds5inrXlFhQ8T9k8ZBeWzOw
         cqeAxEDUpP1YX2O7cOTYriN9U6pvPqHuRRCL852JlsmHip8Ioy/KjUSdSiOp9pj3lGI6
         ICiTOXLXdlgIZMsqtWgQwsxy9RspjHUnh3sQvD7Bt3hydG8OMK7+gWT1znVkhulSBQzy
         vNAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a57si3990551edd.310.2019.02.25.08.57.29
        for <linux-mm@kvack.org>;
        Mon, 25 Feb 2019 08:57:30 -0800 (PST)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 896D180D;
	Mon, 25 Feb 2019 08:57:28 -0800 (PST)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 8F15B3F703;
	Mon, 25 Feb 2019 08:57:23 -0800 (PST)
Date: Mon, 25 Feb 2019 16:57:21 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Cc: Evgenii Stepanov <eugenis@google.com>, nd <nd@arm.com>,
	Kevin Brodsky <Kevin.Brodsky@arm.com>,
	Dave P Martin <Dave.Martin@arm.com>,
	Mark Rutland <Mark.Rutland@arm.com>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
	Will Deacon <Will.Deacon@arm.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Vincenzo Frascino <Vincenzo.Frascino@arm.com>,
	Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>,
	linux-arch <linux-arch@vger.kernel.org>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <Robin.Murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [RFC][PATCH 0/3] arm64 relaxed ABI
Message-ID: <20190225165720.GA79300@arrakis.emea.arm.com>
References: <20181210143044.12714-1-vincenzo.frascino@arm.com>
 <CAAeHK+xPZ-Z9YUAq=3+hbjj4uyJk32qVaxZkhcSAHYC4mHAkvQ@mail.gmail.com>
 <20181212150230.GH65138@arrakis.emea.arm.com>
 <CAAeHK+zxYJDJ7DJuDAOuOMgGvckFwMAoVUTDJzb6MX3WsXhRTQ@mail.gmail.com>
 <20181218175938.GD20197@arrakis.emea.arm.com>
 <20181219125249.GB22067@e103592.cambridge.arm.com>
 <9bbacb1b-6237-f0bb-9bec-b4cf8d42bfc5@arm.com>
 <CAFKCwrhH5R3e5ntX0t-gxcE6zzbCNm06pzeFfYEN2K13c5WLTg@mail.gmail.com>
 <20190212180223.GD199333@arrakis.emea.arm.com>
 <ac8f4e3b-84b8-6067-6a7a-fac7dc48daea@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ac8f4e3b-84b8-6067-6a7a-fac7dc48daea@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Szabolcs,

Thanks for looking into this. Comments below.

On Tue, Feb 19, 2019 at 06:38:31PM +0000, Szabolcs Nagy wrote:
> i think these rules work for the cases i care about, a more
> tricky question is when/how to check for the new syscall abi
> and when/how the TCR_EL1.TBI0 setting may be turned off.

I don't think turning TBI0 off is critical (it's handy for PAC with
52-bit VA but then it's short-lived if you want more security features
like MTE).

> consider the following cases (tb == top byte):
> 
> binary 1: user tb = any, syscall tb = 0
>   tbi is on, "legacy binary"
> 
> binary 2: user tb = any, syscall tb = any
>   tbi is on, "new binary using tb"
>   for backward compat it needs to check for new syscall abi.
> 
> binary 3: user tb = 0, syscall tb = 0
>   tbi can be off, "new binary",
>   binary is marked to indicate unused tb,
>   kernel may turn tbi off: additional pac bits.
> 
> binary 4: user tb = mte, syscall tb = mte
>   like binary 3, but with mte, "new binary using mte"
>   does it have to check for new syscall abi?
>   or MTE HWCAP would imply it?
>   (is it possible to use mte without new syscall abi?)

I think MTE HWCAP should imply it.

> in userspace we want most binaries to be like binary 3 and 4
> eventually, i.e. marked as not-relying-on-tbi, if a dso is
> loaded that is unmarked (legacy or new tb user), then either
> the load fails (e.g. if mte is already used? or can we turn
> mte off at runtime?) or tbi has to be enabled (prctl? does
> this work with pac? or multi-threads?).

We could enable it via prctl. That's the plan for MTE as well (in
addition maybe to some ELF flag).

> as for checking the new syscall abi: i don't see much semantic
> difference between AT_HWCAP and AT_FLAGS (either way, the user
> has to check a feature flag before using the feature of the
> underlying system and it does not matter much if it's a syscall
> abi feature or cpu feature), but i don't see anything wrong
> with AT_FLAGS if the kernel prefers that.

The AT_FLAGS is aimed at capturing binary 2 case above, i.e. the
relaxation of the syscall ABI to accept tb = any. The MTE support will
have its own AT_HWCAP, likely in addition to AT_FLAGS. Arguably,
AT_FLAGS is either redundant here if MTE implies it (and no harm in
keeping it around) or the meaning is different: a tb != 0 may be checked
by the kernel against the allocation tag (i.e. get_user() could fail,
the tag is not entirely ignored).

> the discussion here was mostly about binary 2,

That's because passing tb != 0 into the syscall ABI is the main blocker
here that needs clearing out before merging the MTE support. There is,
of course, a variation of binary 1 for MTE:

binary 5: user tb = mte, syscall tb = 0

but this requires a lot of C lib changes to support properly.

> but for
> me the open question is if we can make binary 3/4 work.
> (which requires some elf binary marking, that is recognised
> by the kernel and dynamic loader, and efficient handling of
> the TBI0 bit, ..if it's not possible, then i don't see how
> mte will be deployed).

If we ignore binary 3, we can keep TBI0 = 1 permanently, whether we have
MTE or not.

> and i guess on the kernel side the open question is if the
> rules 1/2/3/4 can be made to work in corner cases e.g. when
> pointers embedded into structs are passed down in ioctl.

We've been trying to track these down since last summer and we came to
the conclusion that it should be (mostly) fine for the non-weird memory
described above.

-- 
Catalin


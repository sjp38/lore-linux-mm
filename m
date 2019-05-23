Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B108C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 17:44:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 357E22184B
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 17:44:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 357E22184B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2A356B028C; Thu, 23 May 2019 13:44:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDB756B028F; Thu, 23 May 2019 13:44:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA4026B0290; Thu, 23 May 2019 13:44:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 69F286B028C
	for <linux-mm@kvack.org>; Thu, 23 May 2019 13:44:02 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i3so10037747edr.12
        for <linux-mm@kvack.org>; Thu, 23 May 2019 10:44:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kHJs/JbrNQ6jWKwaxaTFP2uZ/QLi62XsNZSDZHyO0G0=;
        b=adWP+drQXzwnFIGRLlU7ps+KStfNm9pF/FeycpqpuXT46vL8K99yrCTkpmla5lTMqx
         24S5aekMG7WGsjHs8fZhNfVMlfzPM0NWxNqfTlkrHXfJ4VWvgTdDL0FR5T2hQ//YYYM5
         cU3dQrDca3xaNmhyhccMBFzbriD8b+xIXgOYgG0Ncd/UwqhBnRGIcqdy82TOML4sABJ1
         mEnGJZIX0dh/q/7Mk/CdbUpfTRi1HKxz2WY4Q28XK0QiiuRyj1X2PdosfZCI4RYYp4pV
         HWjIFnn36mtdCv1SkutvwxiQ5bDCYkArvYXtjAZ+AsQTAlb6TJxJdCMG0gep6gKSu6b4
         THsQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVWZsAjWYfxb44mBmh6yjkjdmcs6/crwHViYq6nZ+Hj5LgY1jfR
	MR2R8rGnsYsrHHIRVHgqr2L6BAZNC1NYpJ2O5GROKR9gakwPeMp/rREP7AkThtlhVMKpfRIeGI8
	p7P8hZrdbSpMxUiFeyIgVBTr3MExBumNTMsZwNJdkqL+tombwd5XmluODkPvxxEz0MQ==
X-Received: by 2002:a50:aed8:: with SMTP id f24mr98120975edd.214.1558633441867;
        Thu, 23 May 2019 10:44:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzr4U0zh3t1U70H9D4SVwkFTAWYLk7LO60YAJZBI2DNpZHMmwJIBytFIlfXKvow7LIO+w11
X-Received: by 2002:a50:aed8:: with SMTP id f24mr98120850edd.214.1558633440599;
        Thu, 23 May 2019 10:44:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558633440; cv=none;
        d=google.com; s=arc-20160816;
        b=ISfzlw+z7WSVUKjxZbjL4uPGeTC8hnDMc7Ksd0NXvqBa7GJj0iOASmj2g/RdqPq/g/
         HYZ6miAsGjM8Wo9HQswS3kQrKtcm515f52382FpztkuQ9fPp+Nqfzo4OuAVbjP5QwWQ2
         ToZfi1zC3lLz/uLLCkghsti+Ix4MnPcrYb+dF1LMPp+OtAt9TVo46KydJqCard3I2IvH
         Um1Vla9J8U3VMfkUL0mlK7v8iojjN4yG8qXi17O0D3wvgs2soOWsWXt3wwaMy0hHRnYV
         y7fhf58ff/ohYGdjpy6ZAz5OoyRF0mgxIlYLqodBS0tHUERXeDeKKScAxKXcdYiuT7qF
         ARkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kHJs/JbrNQ6jWKwaxaTFP2uZ/QLi62XsNZSDZHyO0G0=;
        b=ZXDcwxyhV287Li1+7EP63e+njoSZxzLdrQFry/M9pEINXbDMDzA4+nD1voAdKjbzBN
         ObHfKD1thKRBhOwv8iB7Fnna6EvbYjPJ2W8rR9ph3xPnqResQ+vJfpsDTyZPHJ1ZGWnS
         l4LYFBGIES9c/0x/alw+OgA26VZixMMF5QgavSaxupbv1RJ1R0TkxsAabLnO98iYk/W1
         OhwvryH9SzE3Fdj3F+9kczBCSsGywZCosVqfQDszU97GheWzDBydPitJxiFzl/J7dQD4
         HLcUZBONy9f11T1AqHY6r8E+Hkk2GlF365Y2ORuWZoskGwwr4eztJYpYviXadVFj096O
         F+pg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z16si1287eji.244.2019.05.23.10.44.00
        for <linux-mm@kvack.org>;
        Thu, 23 May 2019 10:44:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 38A8E374;
	Thu, 23 May 2019 10:43:59 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1EE343F5AF;
	Thu, 23 May 2019 10:43:52 -0700 (PDT)
Date: Thu, 23 May 2019 18:43:46 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Kees Cook <keescook@chromium.org>
Cc: enh <enh@google.com>, Evgenii Stepanov <eugenis@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190523174345.6sv3kcipkvlwfmox@mbp>
References: <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp>
 <201905211633.6C0BF0C2@keescook>
 <20190522101110.m2stmpaj7seezveq@mbp>
 <CAJgzZoosKBwqXRyA6fb8QQSZXFqfHqe9qO9je5TogHhzuoGXJQ@mail.gmail.com>
 <20190522163527.rnnc6t4tll7tk5zw@mbp>
 <201905221316.865581CF@keescook>
 <20190523144449.waam2mkyzhjpqpur@mbp>
 <201905230917.DEE7A75EF0@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201905230917.DEE7A75EF0@keescook>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 09:38:19AM -0700, Kees Cook wrote:
> On Thu, May 23, 2019 at 03:44:49PM +0100, Catalin Marinas wrote:
> > There is also the obvious requirement which I didn't mention: new user
> > space continues to run on new/subsequent kernel versions. That's one of
> > the points of contention for this series (ignoring MTE) with the
> > maintainers having to guarantee this without much effort. IOW, do the
> > 500K+ new lines in a subsequent kernel version break any user space out
> > there? I'm only talking about the relaxed TBI ABI. Are the usual LTP,
> > syskaller sufficient? Better static analysis would definitely help.
> 
> We can't have perfect coverage of people actively (or accidentally)
> working to trick static analyzers (and the compiler) into "forgetting"
> about a __user annotation. We can certainly improve analysis (I see
> the other sub-thread on that), but I'd like that work not to block
> this series.

I don't want to block this series either as it's a prerequisite for MTE
but at the moment I'm not confident we tracked down all the places where
things can break and what the future effort will be to analyse new
kernel changes.

We've made lots of progress since March last year (I think when the
first version was posted) by both identifying new places in the kernel
that need untagging and limiting the ranges that user space can tag
(e.g. an mmap() on a device should not allow tagged pointers). Can we
say we are done or more investigation is needed?

> What on this front would you be comfortable with? Given it's a new
> feature isn't it sufficient to have a CONFIG (and/or boot option)?

I'd rather avoid re-building kernels. A boot option would do, unless we
see value in a per-process (inherited) personality or prctl. The
per-process option has the slight advantage that I can boot my machine
normally while being able to run LTP with a relaxed ABI (and a new libc
which tags pointers). I admit I don't have a very strong argument on a
per-process opt-in.

Another option would be a sysctl control together with a cmdline option.

> > Or, if we ever want MTE to be turned on by default (i.e. tag checking),
> > even if everything is tagged with 0, we have to disallow TBI for user
> > and this includes hwasan. There were a small number of programs using
> > the TBI (I think some JavaScript compilers tried this). But now we are
> > bringing in the hwasan support and this can be a large user base. Shall
> > we add an ELF note for such binaries that use TBI/hwasan?
> 
> Just to be clear, you say "disallow TBI for user" -- you mean a
> particular process, yes? i.e. there is no architectural limitation that
> says once we're using MTE nothing can switch to TBI. i.e. a process is
> either doing MTE or TBI (or nothing, but that's the same as TBI).

I may have answered this below. The architecture does not allow TBI
(i.e. faults) if MTE is enabled for a process and address range.

> > > So there needs to be some way to let the kernel know which of three
> > > things it should be doing:
> > > 1- leaving userspace addresses as-is (present)
> > > 2- wiping the top bits before using (this series)
> > 
> > (I'd say tolerating rather than wiping since get_user still uses the tag
> > in the current series)
> > 
> > The current series does not allow any choice between 1 and 2, the
> > default ABI basically becomes option 2.
> 
> What about testing tools that intentionally insert high bits for syscalls
> and are _expecting_ them to fail? It seems the TBI series will break them?
> In that case, do we need to opt into TBI as well?

If there are such tools, then we may need a per-process control. It's
basically an ABI change.

> > > 3- wiping the top bits for most things, but retaining them for MTE as
> > >    needed (the future)
> > 
> > 2 and 3 are not entirely compatible as a tagged pointer may be checked
> > against the memory colour by the hardware. So you can't have hwasan
> > binary with MTE enabled.
> 
> Right: a process must be either MTE or TBI, not both.

Indeed.

> > > I expect MTE to be the "default" in the future. Once a system's libc has
> > > grown support for it, everything will be trying to use MTE. TBI will be
> > > the special case (but TBI is effectively a prerequisite).
> > 
> > The kernel handling of tagged pointers is indeed a prerequisite. The ABI
> > distinction between the above 2 and 3 needs to be solved.
> 
> Does that need solving now or when the MTE series appears? As there is
> no reason to distinguish between "normal" and "TBI", that doesn't seem
> to need solving at this point?

We don't need to solve 2 vs 3 as long as option 3 is an explicit opt-in
(prctl) by the user. Otherwise the kernel cannot guess whether the user
is using TBI or not (and if it does and still opts in to MTE, we can say
it's a user problem ;)).

> > > To choose between "2" and "3", it seems we need a per-process flag to
> > > opt into TBI (and out of MTE).
> > 
> > Or leave option 2 the default and get it to opt in to MTE.
> 
> Given that MTE has to "start" at some point in the binary lifetime, I'm
> fine with opting into MTE. I do expect, though, this will feel redundant
> in a couple years as everything will immediately opt-in. But, okay, this
> is therefore an issue for the MTE series.

Unless Google phases out hwasan soon ;), they may live in parallel for a
while, so a choice of TBI vs MTE.

> Alright, the tl;dr appears to be:
> - you want more assurances that we can find __user stripping in the
>   kernel more easily. (But this seems like a parallel problem.)

Yes, and that we found all (most) cases now. The reason I don't see it
as a parallel problem is that, as maintainer, I promise an ABI to user
and I'd rather stick to it. I don't want, for example, ncurses to stop
working because of some ioctl() rejecting tagged pointers.

If it's just the occasional one-off bug I'm fine to deal with it. But
no-one convinced me yet that this is the case.

As for the generic driver code (filesystems or other subsystems),
without some clear direction for developers, together with static
checking/sparse, on how user pointers are cast to longs (one example),
it would become my responsibility to identify and fix them up with any
kernel release. This series is not providing such guidance, just adding
untagged_addr() in some places that we think matter.

> - we might need to opt in to TBI with a prctl()

Yes, although still up for discussion.

> - all other concerns are for the future MTE series (though it sounds
>   like HWCAP_MTE and a prctl() solve those issues too).

Indeed.

> Is this accurate? What do you see as the blockers for this series at
> this point?

Well, see my comment on your first bullet point above ;).

And thanks for summarising it.

-- 
Catalin


Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75676C282E1
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 11:20:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2693C21773
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 11:20:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2693C21773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 929796B0005; Fri, 24 May 2019 07:20:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DAF16B0006; Fri, 24 May 2019 07:20:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A3D46B0007; Fri, 24 May 2019 07:20:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2BF126B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 07:20:33 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h2so13697931edi.13
        for <linux-mm@kvack.org>; Fri, 24 May 2019 04:20:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4dOxdMcb7O3L1M3PiRQLgBjL4bKwwf1viafNqbe/+gQ=;
        b=sxGyg8n/ylcOiGvwVCmFxtdZw2hucC8AVwh8w76KzezKdKkR88I6G6655noyb1EBEi
         E+kckiZ7rDw7gWsnZVPe4jIAum7ZtStDpTyynUriNOcxnBgQHpDhnYvn4oUOIwfAJSty
         CBCqMx1WhQ+aupm55i8XowZBs/oG2ZYAjZnK1p4yTTkJVYJihcz/QuwF7uGbLXPJ0cHF
         Q/dK+bBZnNVCudYlooF7ly0Gr5Z1E2/KXZFR2WGU1uxP4CLRmnJdyRLnCdeewMQ6a/K8
         PGVm0kTLcd/1bDbrq9kdoJPM602mifgY166OP6LipIVoSgL2qgqu5evcLFd+LAQI78CI
         QgwA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWJdGjWHHsGe1zon0K8Bod/R/S+ns3oJIzq0vFnV/TX3HQN0xqn
	FlV7RLIIUGZlf9nAfP2T9mEHX/kcDZefYOeg9R0XqYvaqZwHVf17Sbi5hvcEhkz8Bo30cVaG9/G
	TseDWqrdveZ8GwxdS+kvtKIVUAQy3mEg0HD+x+7hyfAedXfQX5GKcfAFN+5Y/wxqMBQ==
X-Received: by 2002:a50:94a1:: with SMTP id s30mr105316812eda.4.1558696832728;
        Fri, 24 May 2019 04:20:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5orrhfhx7gTfGr1Q2Anw5xHXI1zSxE73Ab8xoq/qvuOtpHXiZZwDdhNaKnJ+C0oT2ADzv
X-Received: by 2002:a50:94a1:: with SMTP id s30mr105316676eda.4.1558696831269;
        Fri, 24 May 2019 04:20:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558696831; cv=none;
        d=google.com; s=arc-20160816;
        b=c5IOV8aLfEqXIYKbLUaD/V44BR0/rH09SgOZFLX86F7cNlAN+YQfFFMd4fWdi5oWSO
         owjJpyL5QHiGW4hjj/nnbJIHDpWVNSRaAsX8Eu88hg659C7ou4YwHy1d5Z0DhSSu/SK8
         fR3/sI909v6KSW7jAGAF1YHflMubvqLU+DpVRRAFU9v1QhsYCjtwIsM5ySHEkV3x0l8t
         YmlGbaXNAQo5vwudKAI1atJWrkJt0drAQIaIAI7pxNm+GqfUYRx8e+nMHgxLcNRNvE2f
         EBCJJuTR0iqoqjbXG8djgiWvGJ9bTgjE9J3i1N7czknbLZe8MTH5Qcmixbezy9YMYMJa
         M9jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4dOxdMcb7O3L1M3PiRQLgBjL4bKwwf1viafNqbe/+gQ=;
        b=TWOqFaoa5UPIw67cZQduJruE3BLon35KJPergNgl2Y42ntqKVlzQ/nlkNTUhchijOA
         5necAllta1baKWyyk3Jv5JPjPFk7kKEYsU0r8FpmhZOQrKnRQST/9B/lcbafp4GG3omh
         16iXJg/h+V4FREFn8c3Lvp5Jcv95gEVUi9CWv1FDzOgT+yRJ7Mt/04JR6vwKmx+yQT3g
         S8Hsdx2ktDuJbI+z5vZVMjDy/OJDc5QWPCK1MxoJMbYihjP/xGK0GnwrnMSnNNOt4JsW
         RpsSV3T+BpVWQBB8pqGT3BZG/2RJhPl93bguRINXqrtoyuQhynTw6aBhpQ91YSfcrqqj
         OmHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g1si697515ejp.135.2019.05.24.04.20.30
        for <linux-mm@kvack.org>;
        Fri, 24 May 2019 04:20:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C89F4374;
	Fri, 24 May 2019 04:20:29 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B166B3F703;
	Fri, 24 May 2019 04:20:23 -0700 (PDT)
Date: Fri, 24 May 2019 12:20:20 +0100
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
Message-ID: <20190524112020.xcio5jrx6kzmrdnz@mbp>
References: <20190521182932.sm4vxweuwo5ermyd@mbp>
 <201905211633.6C0BF0C2@keescook>
 <20190522101110.m2stmpaj7seezveq@mbp>
 <CAJgzZoosKBwqXRyA6fb8QQSZXFqfHqe9qO9je5TogHhzuoGXJQ@mail.gmail.com>
 <20190522163527.rnnc6t4tll7tk5zw@mbp>
 <201905221316.865581CF@keescook>
 <20190523144449.waam2mkyzhjpqpur@mbp>
 <201905230917.DEE7A75EF0@keescook>
 <20190523174345.6sv3kcipkvlwfmox@mbp>
 <201905231327.77CA8D0A36@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201905231327.77CA8D0A36@keescook>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 02:31:16PM -0700, Kees Cook wrote:
> On Thu, May 23, 2019 at 06:43:46PM +0100, Catalin Marinas wrote:
> > On Thu, May 23, 2019 at 09:38:19AM -0700, Kees Cook wrote:
> > > What about testing tools that intentionally insert high bits for syscalls
> > > and are _expecting_ them to fail? It seems the TBI series will break them?
> > > In that case, do we need to opt into TBI as well?
> > 
> > If there are such tools, then we may need a per-process control. It's
> > basically an ABI change.
> 
> syzkaller already attempts to randomly inject non-canonical and
> 0xFFFF....FFFF addresses for user pointers in syscalls in an effort to
> find bugs like CVE-2017-5123 where waitid() via unchecked put_user() was
> able to write directly to kernel memory[1].
> 
> It seems that using TBI by default and not allowing a switch back to
> "normal" ABI without a reboot actually means that userspace cannot inject
> kernel pointers into syscalls any more, since they'll get universally
> stripped now. Is my understanding correct, here? i.e. exploiting
> CVE-2017-5123 would be impossible under TBI?

Unless the kernel is also using TBI (khwasan), in which case masking out
the top byte wouldn't help. Anyway, as per this discussion, we want the
tagged pointer to remain intact all the way to put_user(), so nothing
gets masked out. I don't think this would have helped with the waitid()
bug.

> If so, then I think we should commit to the TBI ABI and have a boot
> flag to disable it, but NOT have a process flag, as that would allow
> attackers to bypass the masking. The only flag should be "TBI or MTE".
> 
> If so, can I get top byte masking for other architectures too? Like,
> just to strip high bits off userspace addresses? ;)

But you didn't like my option 2 shim proposal which strips the tag on
kernel entry because it lowers the value of MTE ;).

> (Oh, in looking I see this is implemented with sign-extension... why
> not just a mask? So it'll either be valid userspace address or forced
> into the non-canonical range?)

The TTBR0/1 selection on memory accesses is done based on bit 63 if TBI
is disabled and bit 55 when enabled. Sign-extension allows us to use the
same macro for both user and kernel tagged pointers. With MTE tag 0
would be match-all for TTBR0 and 0xff for TTBR1 (so that we don't modify
the virtual address space of the kernel; I need to check the latest spec
to be sure). Note that the VA space for both user and kernel is limited
to 52-bit architecturally so, on access, bits 55..52 must be the same, 0
or 1, otherwise you get a fault.

Since the syzkaller tests would also need to set bits 55-52 (actually 48
for kernel addresses, we haven't merged the 52-bit kernel VA patches
yet) to hit a valid kernel address, I don't think ignoring the top byte
makes much difference to the expected failure scenario.

> > > Alright, the tl;dr appears to be:
> > > - you want more assurances that we can find __user stripping in the
> > >   kernel more easily. (But this seems like a parallel problem.)
> > 
> > Yes, and that we found all (most) cases now. The reason I don't see it
> > as a parallel problem is that, as maintainer, I promise an ABI to user
> > and I'd rather stick to it. I don't want, for example, ncurses to stop
> > working because of some ioctl() rejecting tagged pointers.
> 
> But this is what I don't understand: it would need to be ncurses _using
> TBI_, that would stop working (having started to work before, but then
> regress due to a newly added one-off bug). Regular ncurses will be fine
> because it's not using TBI. So The Golden Rule isn't violated,

Once we introduced TBI and the libc starts tagging heap allocations,
this becomes the new "regular" user space behaviour (i.e. using TBI). So
a new bug would break the golden rule. It could also be an old bug that
went unnoticed (i.e. you changed the graphics card and its driver gets
confused by tagged pointers coming from user-space).

> and by definition, it's a specific regression caused by some bug
> (since TBI would have had to have worked _before_ in the situation to
> be considered a regression now). Which describes the normal path for
> kernel development... add feature, find corner cases where it doesn't
> work, fix them, encounter new regressions, fix those, repeat forever.
> 
> > If it's just the occasional one-off bug I'm fine to deal with it. But
> > no-one convinced me yet that this is the case.
> 
> You believe there still to be some systemic cases that haven't been
> found yet? And even if so -- isn't it better to work on that
> incrementally?

I want some way to systematically identify potential issues (sparse?).
Since problems are most likely in drivers, I don't have all devices to
check and not all users have the knowledge to track down why something
failed.

I think we can do this incrementally as long the TBI ABI is not the
default. Even better if we made it per process.

> > As for the generic driver code (filesystems or other subsystems),
> > without some clear direction for developers, together with static
> > checking/sparse, on how user pointers are cast to longs (one example),
> > it would become my responsibility to identify and fix them up with any
> > kernel release. This series is not providing such guidance, just adding
> > untagged_addr() in some places that we think matter.
> 
> What about adding a nice bit of .rst documentation that describes the
> situation and shows how to use untagged_addr(). This is the kind of
> kernel-wide change that "everyone" needs to know about, and shouldn't
> be the arch maintainer's sole responsibility to fix.

This works (if people read it) but we also need to be more prescriptive
in how casting is done and how we differentiate between a pointer for
dereference (T __user *) and address space management (usually unsigned
long). On top of that, we'd get sparse to check for such conversions and
maybe even checkpatch for some low-hanging fruit.

> > > - we might need to opt in to TBI with a prctl()
> > 
> > Yes, although still up for discussion.
> 
> I think I've talked myself out of it. I say boot param only! :)

I hope I talked you in again ;). I don't see TBI as improving kernel
security.

> So what do you say to these next steps:
> 
> - change untagged_addr() to use a static branch that is controlled with
>   a boot parameter.

access_ok() as well.

> - add, say, Documentation/core-api/user-addresses.rst to describe
>   proper care and handling of user space pointers with untagged_addr(),
>   with examples based on all the cases seen so far in this series.

We have u64_to_user_ptr(). What about the reverse? And maybe changing
get_user_pages() to take void __user *.

> - continue work to improve static analysis.

Andrew Murray in the ARM kernel team started revisiting the old sparse
threads, let's see how it goes.

-- 
Catalin


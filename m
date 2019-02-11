Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E84F0C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:02:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F4612075C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:02:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F4612075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21B758E0104; Mon, 11 Feb 2019 12:02:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CBB18E0103; Mon, 11 Feb 2019 12:02:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BB478E0104; Mon, 11 Feb 2019 12:02:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A49948E0103
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:02:25 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id u19so9918169eds.12
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:02:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AM03LDIyAdxwlP9/6+UbJNq5rNe1LbVWVH16xUNI2hg=;
        b=f/B+f0MW89N4d/F3b5gEB05d47FKE7OmmbQ1M7j1Iv7fvnceJQBWNuUhDMQbkRSCGn
         g4o1jp9Mu9JEEJ0PU9+ugzs6QiJiCrD+d48NF5Au+9o6UAjnKELRhifBlyA/G6vxjPBu
         7vfv/Kv5vMHDfVnaGHkHVS4GdWCw0s01QTAEgdC6ttfyaKIQxLpzOfrzzwz0US2ftD9z
         +OJfTGiT3Hy1oRaowJBGPeAL5j2HUqahWXhMrZFn1kiKDYHcp9pLmeXyW4srkCXYphRt
         ogCbthxpzv4/P5nXHkx5mFIxzKRGshfbtbXCcrTARV+cOR7R/Q86PlCIKKGYIFif86uj
         sfTg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: AHQUAua6hAsibc+VDVzwFFCOw72JZTxXpshl3SVKFze6kf+fpm8kH2RE
	NznIQy2s/kZqnAQD7Qg/Lqd/pLrnuzEhWaQfuawbTDMcMlvHuHloiyNJQ6FRBpQDRMJUCG+vPmI
	3+hzgWAnAT9XMx5EDfc5DPzED6DFcZnpSXV5x3zRMaBaoI9IXVEflZaUgOVPApakHlw==
X-Received: by 2002:a50:97b3:: with SMTP id e48mr3864768edb.159.1549904545195;
        Mon, 11 Feb 2019 09:02:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY+faLZ34x3/zfFE39+qmhCETpxxxUPDKJMPuuUkhtLWgj1z6J3UVC/Yc3VnLlV6Spz4cMj
X-Received: by 2002:a50:97b3:: with SMTP id e48mr3864686edb.159.1549904544143;
        Mon, 11 Feb 2019 09:02:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549904544; cv=none;
        d=google.com; s=arc-20160816;
        b=dogJgf7aqJmY2/2ZXdC7cjDgFwLwRTIIw0X+f3oswFYhg9s4dlz4V/aPav1zWb+LfS
         R49bb/hfp7/Z8nxhGqcSVRP7HU0X2qbrFjfL8GvJOLeKFzZDJwI/PNutxjqc7NQNeKlm
         eWGpRSpc24KitCEeymjAYFoArkvGo/MayzooePdSkSQxnMTLBqN1pfrQWTG+8eqT3Kdl
         TA5kHwNrgfAaFkTC3liIdMwpV1ZF0McZyhiS+2/fE/QERC8OdMWjfqbfEshbFgu7DS/J
         Dh4ngDmFL2M752DtPPuCDhFnLMH+wOxi2tb5Rg9qxrwJdOZAcE1T+/RHzSNu5siQmwAD
         f/wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AM03LDIyAdxwlP9/6+UbJNq5rNe1LbVWVH16xUNI2hg=;
        b=Yk98mELBxykeOXSDUzT4c5O+l/9fSO57h5B5BOjzlUCm19F2MZDUyLLmmz4+vV8bpn
         2iC4ppzPoPiDpgOXhrRRSj9cAYHsr1YZdm29DYt+LH5fgWFmmSIAKskU5+Gx9BOa0Kit
         KHBv8d18EU/w08/eSHTcl+0ud3qCb4GbFgK+auMgKMe/2CwZgdIXpDvCv7d1nP3dOdOF
         N55o6iWND90tHBkfUJCKHuE19nnWsn5ZkAy8VeXI6/IsOLJ6y47F3/Vs1MVXPkmy9EhY
         Bat9IrqWE180/nGrPNv8OhZrIHKv17AQhbLmuga/Lc5x+AlxK26TdslL3S7RzHSGf4YM
         M9pg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l40si3816936edc.447.2019.02.11.09.02.23
        for <linux-mm@kvack.org>;
        Mon, 11 Feb 2019 09:02:24 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EBEC780D;
	Mon, 11 Feb 2019 09:02:22 -0800 (PST)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id ABF053F675;
	Mon, 11 Feb 2019 09:02:18 -0800 (PST)
Date: Mon, 11 Feb 2019 17:02:16 +0000
From: Dave Martin <Dave.Martin@arm.com>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	linux-doc@vger.kernel.org, Will Deacon <will.deacon@arm.com>,
	linux-mm@kvack.org, linux-kselftest@vger.kernel.org,
	Chintan Pandya <cpandya@codeaurora.org>,
	Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>,
	linux-arch@vger.kernel.org, Jacob Bramley <Jacob.Bramley@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Lee Smith <Lee.Smith@arm.com>, linux-arm-kernel@lists.infradead.org,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v9 0/8] arm64: untag user pointers passed to the kernel
Message-ID: <20190211170212.GH3567@e103592.cambridge.arm.com>
References: <cover.1544445454.git.andreyknvl@google.com>
 <20181212170108.GZ3505@e103592.cambridge.arm.com>
 <20190211113511.GA165128@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211113511.GA165128@arrakis.emea.arm.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 11:35:12AM +0000, Catalin Marinas wrote:
> Hi Dave,
> 
> On Wed, Dec 12, 2018 at 05:01:12PM +0000, Dave P Martin wrote:
> > On Mon, Dec 10, 2018 at 01:50:57PM +0100, Andrey Konovalov wrote:
> > > arm64 has a feature called Top Byte Ignore, which allows to embed pointer
> > > tags into the top byte of each pointer. Userspace programs (such as
> > > HWASan, a memory debugging tool [1]) might use this feature and pass
> > > tagged user pointers to the kernel through syscalls or other interfaces.
> [...]
> > It looks like there's been a lot of progress made here towards smoking
> > out most of the sites in the kernel where pointers need to be untagged.
> 
> In summary, based on last summer's analysis, there are two main (and
> rather broad) scenarios of __user pointers use in the kernel: (a)
> uaccess macros, together with access_ok() checks and (b) identifying
> of user address ranges (find_vma() and related, some ioctls). The
> patches here handle the former by allowing sign-extension in access_ok()
> and subsequent uaccess routines work fine with tagged pointers.
> Identifying the latter is a bit more problematic and the approach we
> took was tracking down pointer to long conversion which seems to cover
> the majority of cases. However, this approach doesn't scale as, for
> example, we'd rather change get_user_pages() to sign-extend the address
> rather than all the callers. In lots of other cases we don't even need
> untagging as we don't expect user space to tag such pointers (i.e.
> mmap() of device memory).
> 
> We might be able to improve the static analysis by introducing a
> virt_addr_t but that's significant effort and we still won't cover all
> cases (e.g. it doesn't necessarily catch tcp_zerocopy_receive() which
> wouldn't use a pointer, just a u64 for address).
> 
> > However, I do think that we need a clear policy for how existing kernel
> > interfaces are to be interpreted in the presence of tagged pointers.
> > Unless we have that nailed down, we are likely to be able to make only
> > vague guarantees to userspace about what works, and the ongoing risk
> > of ABI regressions and inconsistencies seems high.
> 
> I agree.
> 
> > Can we define an opt-in for tagged-pointer userspace, that rejects all
> > syscalls that we haven't checked and whitelisted (or that are
> > uncheckable like ioctl)? 
> 
> Defining an opt-in is not a problem, however, rejecting all syscalls
> that we haven't whitelisted is not feasible. We can have an opt-in per
> process (that's what we were going to do with MTE) but the only thing
> we can reasonably do is change the behaviour of access_ok(). That's too
> big a knob and a new syscall that we haven't got around to whitelist may
> just work. This eventually leads to de-facto ABI and our whitelist would
> simply be ignored.
> 
> I'm not really keen on a big syscall shim in the arm64 kernel which
> checks syscall arguments, including in-struct values. If we are to do
> this, I'd rather keep it in user space as part of the C library.
> 
> > In the meantime, I think we really need to nail down the kernel's
> > policies on
> > 
> >  * in the default configuration (without opt-in), is the presence of
> > non-address bits in pointers exchanged with the kernel simply
> > considered broken?  (Even with this series, the de factor answer
> > generally seems to be "yes", although many specific things will now
> > work fine)
> 
> Without these patches, passing non-address bits in pointers is
> considered broken. I couldn't find a case where it would still work with
> non-zero tag but maybe I haven't looked hard enough.
> 
> >  * if not, how do we tighten syscall / interface specifications to
> > describe what happens with pointers containing non-address bits, while
> > keeping the existing behaviour for untagged pointers?
> > 
> > We would want a general recipe that gives clear guidance on what
> > userspace should expect an arbitrarily chosen syscall to do with its
> > pointers, without having to enumerate each and every case.
> 
> That's what we are aiming with the pointer origins, to move away from a
> syscall whitelist to a generic definition. That said, the two approaches
> are orthogonal, we can use the pointer origins as the base rule for
> which syscalls can be whitelisted.
> 
> If we step back a bit to look at the use-case for TBI (and MTE), the
> normal application programmer shouldn't really care about this ABI
> (well, most of the time). The app gets a tagged pointer from the C
> library as a result of a malloc()/realloc() (possibly alloca()) call and
> it expects to be able to pass it back into the kernel (usually via the C
> library) without any awareness of the non-address bits. Now, we can't
> define a user/kernel ABI based on the provenance of the pointer in user
> space (i.e. we only support tags for heap and stack), so we are trying
> to generalise this based where the pointer originated from in the kernel
> (e.g. anonymous mmap()).

This sounds generally reasonable.

It is not adequate for describing changing the tag on already-tagged
memory (which a memory allocator will definitely do), but we may be able
to come up with some weasel words to cover that.

It is also not adequete for describing tagging (and retagging) regions
of the stack -- but as you say, we can rule that use-case out for now
in the interest of simplicity, since we know we wouldn't be able to
deploy it widely for now anyway due to the incompability with non-MTE-
capable hardware.


Ideally we would clarify user/kernel interface semantics in terms of
object and pointer lifetimes and accessibility, but that's a larger
project that should be pursued separately (if at all).

I could also quibble about whether "anonymous mmap" is the right thing
here -- we should still give specific examples of things that do / don't
qualify, to make it clear what we mean.

Cheers
---Dave


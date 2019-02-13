Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05DBFC282CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:58:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1B38222C9
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:58:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1B38222C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EE678E0003; Wed, 13 Feb 2019 09:58:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39D8A8E0001; Wed, 13 Feb 2019 09:58:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28DE98E0003; Wed, 13 Feb 2019 09:58:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF0078E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:58:47 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id v26so1105323eds.17
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:58:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yxMnmaoxEz4IJtmjqyhVHePh2OefJKGWVhjU8IMdmek=;
        b=s+DEEr6WIwklMd/U854IlKU2sFjbxEgPhnb34Nnsxibs8Clq4dXuVqEXs7ylBFXCC4
         wY7oIJbO27G2N2p8DCCXCRpqx37g5jLfsmzqP2OtWJZCum+r3rHkmRgaa9dCUPBlH0wj
         BbthD9erid854Lb2j4nylxcz/PH++uQaiz23pfM26wMxZr8CaN7XLdFrJLGHZGq0jICP
         fJ4cW3JF7XNW1are4x5LvIsEgr+eZYijZ5qplra5yp5rpd7Vw7CL3HMkVDrZqfwqcSAf
         TafLrmDbLEy+AVcflm9kR5EttHADyCO3SGCuRgO3ng/vcP4Bb923YmCSX1Pq+Jm4GODg
         kjIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: AHQUAuaqJQA/YCrc1oHEpcu3Rt4HcU1aZGSLg8azVYbJU58LKZ1OBg5A
	Muk0DK2PJExN7YRF3aLZ9oFx8CSePYRYTL13BvKtWAuUkj0uX2jpwMotRzqh7mXSHRwOqtEiUNU
	HfbG+nCfvPZz2bJ724zfy/d5NfAT0sGiGM96+hq0G75mQ7QeKj6uy50M7VU2QYAwQ/A==
X-Received: by 2002:a17:906:ddb:: with SMTP id p27mr678931eji.162.1550069927274;
        Wed, 13 Feb 2019 06:58:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYbQ7RxEl6f2FweV7yKD8ZgeRk9hlkcVGJEvj5QfLXvV4VnRwAARRMitbzc/MKwuzt5r3v3
X-Received: by 2002:a17:906:ddb:: with SMTP id p27mr678870eji.162.1550069926186;
        Wed, 13 Feb 2019 06:58:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550069926; cv=none;
        d=google.com; s=arc-20160816;
        b=plgvFxhV/o1LPeez/Bymh1weRVtZmEs6Iya14/MNT0zYqYsSfFP36Y77vBzS7pKuqK
         sOStu572Pp6bljy/RF1IuFmTzCum6enmp4tPOA7xLkcy/EGjncJycVjhsTCPouhWqtc+
         J3ewLVGJZfJm7YJaaZlgZPeWxM22UWKjpo8ZIs9FavwAZAp1WEeFM19KBikfm21E3WNB
         rRld+T4Gx+aRdxHuiHSUU27kl/edzpPfnbaWeZ/zOFOk9nPLo8sZd5/81NLhJqHu1SuO
         BfAMg+BrS38mbDgYKHlpwQjO7VuksCRz0Lp3PYMtDRLp/wz3VTcx5O9isgafWRtKKWwA
         GYiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yxMnmaoxEz4IJtmjqyhVHePh2OefJKGWVhjU8IMdmek=;
        b=tJ+JSWaNi2JoTo487j7ZBhMfY6uH6sJa7u2Nc6sHIxgAgdn8t5yNrIMRPH8zbuS9hO
         d2wOaNOBdFfk27i3qD38Ky0/prs/kAZMoO7WrbHWHFbTy+cx//E/kv+o1xycu3US9Q/v
         TLXFFlL1JGgWu1ilIDJ5Li5v5Gzu9PP7eOv9aY+sbOt4wXJyaQFqCiDlrYoexGOivuME
         nug3aE0SVWxJIsmWo8QgbA056sdYiZJF8q5vHPgiRBWUAqII6NKPMZr5WAPkfv1QQncj
         WeoK6Utk0RBeWvNlfJpGAe9+TLyga/DimUxMEJ+rD/kdwxYHCdXHXHV+gg2U5jXmxgRY
         NGaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r25si7375876eja.53.2019.02.13.06.58.45
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 06:58:46 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BDAAD80D;
	Wed, 13 Feb 2019 06:58:44 -0800 (PST)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 145323F589;
	Wed, 13 Feb 2019 06:58:39 -0800 (PST)
Date: Wed, 13 Feb 2019 14:58:37 +0000
From: Dave Martin <Dave.Martin@arm.com>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Evgenii Stepanov <eugenis@google.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
	Will Deacon <will.deacon@arm.com>,
	Kostya Serebryany <kcc@google.com>,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>,
	linux-arch <linux-arch@vger.kernel.org>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [RFC][PATCH 0/3] arm64 relaxed ABI
Message-ID: <20190213145834.GJ3567@e103592.cambridge.arm.com>
References: <cover.1544445454.git.andreyknvl@google.com>
 <20181210143044.12714-1-vincenzo.frascino@arm.com>
 <CAAeHK+xPZ-Z9YUAq=3+hbjj4uyJk32qVaxZkhcSAHYC4mHAkvQ@mail.gmail.com>
 <20181212150230.GH65138@arrakis.emea.arm.com>
 <CAAeHK+zxYJDJ7DJuDAOuOMgGvckFwMAoVUTDJzb6MX3WsXhRTQ@mail.gmail.com>
 <20181218175938.GD20197@arrakis.emea.arm.com>
 <20181219125249.GB22067@e103592.cambridge.arm.com>
 <9bbacb1b-6237-f0bb-9bec-b4cf8d42bfc5@arm.com>
 <CAFKCwrhH5R3e5ntX0t-gxcE6zzbCNm06pzeFfYEN2K13c5WLTg@mail.gmail.com>
 <20190212180223.GD199333@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212180223.GD199333@arrakis.emea.arm.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 06:02:24PM +0000, Catalin Marinas wrote:
> On Mon, Feb 11, 2019 at 12:32:55PM -0800, Evgenii Stepanov wrote:
> > On Mon, Feb 11, 2019 at 9:28 AM Kevin Brodsky <kevin.brodsky@arm.com> wrote:
> > > On 19/12/2018 12:52, Dave Martin wrote:

[...]

> > > >   * A single C object should be accessed using a single, fixed
> > > >     pointer tag throughout its entire lifetime.
> > >
> > > Agreed.  Allocators themselves may need to be excluded though,
> > > depending on how they represent their managed memory.
> > >
> > > >   * Tags can be changed only when there are no outstanding pointers to
> > > >     the affected object or region that may be used to access the object
> > > >     or region (i.e., if the object were allocated from the C heap and
> > > >     is it safe to realloc() it, then it is safe to change the tag; for
> > > >     other types of allocation, analogous arguments can be applied).
> > >
> > > Tags can only be changed at the point of deallocation/
> > > reallocation.  Pointers to the object become invalid and cannot
> > > be used after it has been deallocated; memory tagging allows to
> > > catch such invalid usage.
>
> All the above sound well but that's mostly a guideline on what a C
> library can do. It doesn't help much with defining the kernel ABI.
> Anyway, it's good to clarify the use-cases.

My aim was to clarify the use case in userspace, since I wasn't directly
involved in that.  The kernel ABI needs to be compatible with the the
use case, but doesn't need to specify must of it.

I'm wondering whether we can piggy-back on existing concepts.

We could say that recolouring memory is safe when and only when
unmapping of the page or removing permissions on the page (via
munmap/mremap/mprotect) would be safe.  Otherwise, the resulting
behaviour of the process is undefined.

Hopefully there are friendly fuzzers testing this kind of thing.

[...]

> > It would also be valuable to narrow down the set of "relaxed" (i.e.
> > not tag-checking) syscalls as reasonably possible. We would want to
> > provide tag-checking userspace wrappers for any important calls that
> > are not checked in the kernel. Is it correct to assume that anything
> > that goes through copy_from_user  / copy_to_user is checked?
> 
> I lost track of the context of this thread but if it's just about
> relaxing the ABI for hwasan, the kernel has no idea of the compiler
> generated structures in user space, so nothing is checked.
> 
> If we talk about tags in the context of MTE, than yes, with the current
> proposal the tag would be checked by copy_*_user() functions.

Also put_user() and friends?

It might be reasonable to do the check in access_ok() and skip it in
__put_user() etc.

(I seem to remember some separate discussion about abolishing
__put_user() and friends though, due to the accident risk they pose.)

> > For aio* operations it would be nice if the tag was checked at the
> > time of the actual userspace read/write, either instead of or in
> > addition to at the time of the system call.
> 
> With aio* (and synchronous iovec-based syscalls), the kernel may access
> the memory while the corresponding user process is scheduled out. Given
> that such access is not done in the context of the user process (and
> using the user VA like copy_*_user), the kernel cannot handle potential
> tag faults. Moreover, the transfer may be done by DMA and the device
> does not understand tags.
> 
> I'd like to keep tags as a property of the pointer in a specific virtual
> address space. The moment you convert it to a different address space
> (e.g. kernel linear map, physical address), the tag property is stripped
> and I don't think we should re-build it (and have it checked).

This is probably reasonable.

Ideally we would check the tag at the point of stripping it off, but
most likely it's going to be rather best-effort.

If memory tagging is essential a debugging feature then this seems
an acceptable compromise.

> > > >   * For purposes other than dereference, the kernel shall accept any
> > > >     legitimately tagged pointer (according to the above rules) as
> > > >     identifying the associated memory location.
> > > >
> > > >     So, mprotect(some_page_aligned_object, ...); is valid irrespective
> > > >     of where page_aligned_object() came from.  There is no implicit
> > > >     derefence by the kernel here, hence no tag check.
> > > >
> > > >     The kernel does not guarantee to work correctly if the wrong tag
> > > >     is used, but there is not always a well-defined "right" tag, so
> > > >     we can't really guarantee to check it.  So a pointer derived by
> > > >     any reasonable means by userspace has to be treated as equally
> > > >     valid.
> > >
> > > This is a disputed point :) In my opinion, this is the the most
> > > reasonable approach.
> > 
> > Yes, it would be nice if the kernel explicitly promised, ex.
> > mprotect() over a range of differently tagged pages to be allowed
> > (i.e. address tag should be unchecked).
> 
> I don't think mprotect() over differently tagged pages was ever a
> problem. I originally asked that mprotect() and friends do not accept
> tagged pointers since these functions deal with memory ranges rather
> than dereferencing such pointer (the reason being minimal kernel
> changes). However, given how complicated it is to specify an ABI, I came
> to the conclusion that a pointer passed to such function should be
> allowed to have non-zero top byte. It would be the kernel's
> responsibility to strip it out as appropriate.

I think that if the page range is all the same colour then it should be
legitimate to pass a matching tag.

But it doesn't seem reasonable for the kernel to require this.  If
free() calls munmap(), the page(s) will contain possibly randomly-
coloured garbage.  There's no correct tag to pass in such a case.

The most obvious solution is just to ignore the tags passed by userspace
to such syscalls.  This would imply that the kernel must explicitly
strip it out, as you suggest.

The number of affected syscalls is relatively small though.

Cheers
---Dave


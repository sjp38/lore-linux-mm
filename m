Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC60AC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:33:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88667218D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:33:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="BmQVHGsb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88667218D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23A728E0157; Mon, 11 Feb 2019 15:33:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E8398E0155; Mon, 11 Feb 2019 15:33:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B0598E0157; Mon, 11 Feb 2019 15:33:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id C7C6A8E0155
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:33:09 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id x1so113838vsc.0
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:33:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=r6VRajPoqaThCJT0Dvdiha6ogbe9QcNkbuaAo7A6Lms=;
        b=rLGAx5lU+nfKsAbambpzDPKDl1mh5jYJRhoz++icWW1aZvTjVFU0f0e6KUZA4Kf0LK
         I+xHXVQf1Y4sPPfy9ZirHq8vB8FWVF4Ot/9eC8qa6RI8j4ldaHZAmdvGTnV1Vfnm0sad
         fPRVZ6sQH+hciYy28kL/TtIpEbGjJOFVfFbhdanKcZVnbweDF+/0haoda0MSpPgzvG4x
         J/L5IDpFFoINFqiZ/KjHyUZGjv1ImUEK9vM/jmgu+BKsHK08TCNrqWW7SEFbrh/LIp28
         mJvX0zy6GvkeZZ9+s8PsXDtujyytGFgli2Yy/WYFwdr5SjHztXBR2FnJiBAzQX5e9m/L
         vYPw==
X-Gm-Message-State: AHQUAuZQarKn9eqfyZ3W63civRSNib1iqCcFoW2HDKmhN1co5zKo7zzl
	t1Arm+h6rbnqqGb3IxiHovxP4Frho75UoO+esll9dvrb2+DktNS6jbNx0Pw3+S9cpaP9QYGXJCa
	GJ50n+nz17luySOARju+qQcYq1ZRF1E29GRa5g41SGmOdfMfdXMbLtp0XcWSlM2LzL2FxKkdLQ/
	SjLa3s3JzgnZiaM1yIIExFovNF7L435d/8skY3PVYmJ8UOA2DMOEl7cXX/dm6ynzSh7/iCI4PhL
	eN3pUs3Owo3aMwr3kV7bng6ezCSRRrekLokaE/3qf6leNB0s2d7/3wR3YadHr9XPVIv+rUhOkiz
	46LeB2/ghhGvS4+TRatMb5sCmi7azdlV5seAnHHdRJXd+zykLxc5kXYxsehlp/5Sqgb8S46UZwm
	7
X-Received: by 2002:ab0:210e:: with SMTP id d14mr51044ual.20.1549917189401;
        Mon, 11 Feb 2019 12:33:09 -0800 (PST)
X-Received: by 2002:ab0:210e:: with SMTP id d14mr50995ual.20.1549917188056;
        Mon, 11 Feb 2019 12:33:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549917188; cv=none;
        d=google.com; s=arc-20160816;
        b=ew8WFxzKbkozWAlK4WphwL/MUyAnX9qDSytSZDYymPz1Hl/jwH/l81W0SQ06SDSJex
         qcy2o7W3+y66RIXdThPjOxE/4mh+U+H75kdZNtYMGSY5Ur2BFeRZJD/f+vBU5B17vbyD
         Ufyfy5mioAgcMbLxMzti/VGnFPANmJcCKcNnjnhaIjELTXBbfod4IcjUbfugd55umhTF
         QrO0D/mx0JqexG5RkQL/fPo5wyHkg5UpE+Qs6vkZkGNkR9iKnEwPcPuNdIkOEvwvbWpY
         bZbGZynE7bzLhgjPqWPjh09w93tkPw2mPh6ygJheM4gFA94E+TX4XprXGL+vyNaqpCJw
         /1dw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=r6VRajPoqaThCJT0Dvdiha6ogbe9QcNkbuaAo7A6Lms=;
        b=Jvadk9PcyPJ5xxYXmhftD97CHcC1/3oWk8aQSt9AY6wA0jnLCl+SZVWPg6w6w8tkL9
         Xd7uZMVY0+aIQUYZ6YhzifzWtOXbGq69kX97+e+oqLQPY9I7soL0iJvgQoZ0BQyZul7o
         G9crdZOo6KYCTQpEVqWfaM3UXz5TVsNmyOngoLEHHilkTMLgfvkHQTqA2BNAb5rCisyc
         KXQGyUiBlYq4TMUoM8l35s4Onqdo7R6I0sX55NeFSA8dX2uONywwrymv/ZvV1l2b65Uu
         ErJ0YON32G4ga2WUvObUaoc37nsbDpRVpLEE1ICYjfhkXeUJ+QjP6ZkFlkmdoWbVqgGp
         SJnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BmQVHGsb;
       spf=pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eugenis@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q200sor5633762vke.58.2019.02.11.12.33.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 12:33:08 -0800 (PST)
Received-SPF: pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BmQVHGsb;
       spf=pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eugenis@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=r6VRajPoqaThCJT0Dvdiha6ogbe9QcNkbuaAo7A6Lms=;
        b=BmQVHGsbVwhoYZdBSedRkqIv6og7RMSliRadT3+x3j6C1gbIKUuwcxXzqv5jKmWvjo
         KdPJxVpmNCDYVgKTbZX5dzd/F00C4iJjDGN6QzwEks6s+CaJpSauJ9LlIoNCdIKimi6c
         JGhlLjiLL1uqvF8XnV5O7YMCfE0Cjq5ccbC9r8DysKVu1r5mFlDQX1dL97frVsvPHyu0
         9mrkSPWrFbpeP0Eqh9roRzPndd+Sq7oG4Q2uFQvXNygHhtEZpexHI0RTL5IyfFXeJLib
         sht/JwBIBWaNTiZTNYltal2S7DIierzLBZLEKpRhAH9hiD5e/iEv2Qz7CxmUv+6ZtP7X
         /Qfg==
X-Google-Smtp-Source: AHgI3IYRoxxh5UANRY+c7YFpbiuZIVnkRpZEjVgGacZzLPAQLpz/3AFD8Mhp7mukXr/ijhZ1DgvcmKgyBVxi4v5h/0s=
X-Received: by 2002:a1f:9042:: with SMTP id s63mr29880vkd.17.1549917187324;
 Mon, 11 Feb 2019 12:33:07 -0800 (PST)
MIME-Version: 1.0
References: <cover.1544445454.git.andreyknvl@google.com> <20181210143044.12714-1-vincenzo.frascino@arm.com>
 <CAAeHK+xPZ-Z9YUAq=3+hbjj4uyJk32qVaxZkhcSAHYC4mHAkvQ@mail.gmail.com>
 <20181212150230.GH65138@arrakis.emea.arm.com> <CAAeHK+zxYJDJ7DJuDAOuOMgGvckFwMAoVUTDJzb6MX3WsXhRTQ@mail.gmail.com>
 <20181218175938.GD20197@arrakis.emea.arm.com> <20181219125249.GB22067@e103592.cambridge.arm.com>
 <9bbacb1b-6237-f0bb-9bec-b4cf8d42bfc5@arm.com>
In-Reply-To: <9bbacb1b-6237-f0bb-9bec-b4cf8d42bfc5@arm.com>
From: Evgenii Stepanov <eugenis@google.com>
Date: Mon, 11 Feb 2019 12:32:55 -0800
Message-ID: <CAFKCwrhH5R3e5ntX0t-gxcE6zzbCNm06pzeFfYEN2K13c5WLTg@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/3] arm64 relaxed ABI
To: Kevin Brodsky <kevin.brodsky@arm.com>
Cc: Dave Martin <Dave.Martin@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Shuah Khan <shuah@kernel.org>, 
	Ingo Molnar <mingo@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, 
	Jacob Bramley <Jacob.Bramley@arm.com>, Dmitry Vyukov <dvyukov@google.com>, 
	Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Kostya Serebryany <kcc@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Robin Murphy <robin.murphy@arm.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 9:28 AM Kevin Brodsky <kevin.brodsky@arm.com> wrote:
>
> On 19/12/2018 12:52, Dave Martin wrote:
> > On Tue, Dec 18, 2018 at 05:59:38PM +0000, Catalin Marinas wrote:
> >> On Tue, Dec 18, 2018 at 04:03:38PM +0100, Andrey Konovalov wrote:
> >>> On Wed, Dec 12, 2018 at 4:02 PM Catalin Marinas<catalin.marinas@arm.com>  wrote:
> >>>> The summary of our internal discussions (mostly between kernel
> >>>> developers) is that we can't properly describe a user ABI that covers
> >>>> future syscalls or syscall extensions while not all syscalls accept
> >>>> tagged pointers. So we tweaked the requirements slightly to only allow
> >>>> tagged pointers back into the kernel *if* the originating address is
> >>>> from an anonymous mmap() or below sbrk(0). This should cover some of the
> >>>> ioctls or getsockopt(TCP_ZEROCOPY_RECEIVE) where the user passes a
> >>>> pointer to a buffer obtained via mmap() on the device operations.
> >>>>
> >>>> (sorry for not being clear on what Vincenzo's proposal implies)
> >>> OK, I see. So I need to make the following changes to my patchset AFAIU.
> >>>
> >>> 1. Make sure that we only allow tagged user addresses that originate
> >>> from an anonymous mmap() or below sbrk(0). How exactly should this
> >>> check be performed?
> >> I don't think we should perform such checks. That's rather stating that
> >> the kernel only guarantees that the tagged pointers work if they
> >> originated from these memory ranges.
> > I concur.
> >
> > Really, the kernel should do the expected thing with all "non-weird"
> > memory.
> >
> > In lieu of a proper definition of "non-weird", I think we should have
> > some lists of things that are explicitly included, and also excluded:
> >
> > OK:
> >       kernel-allocated process stack
> >       brk area
> >       MAP_ANONYMOUS | MAP_PRIVATE
> >       MAP_PRIVATE mappings of /dev/zero
> >
> > Not OK:
> >       MAP_SHARED
> >       mmaps of non-memory-like devices
> >       mmaps of anything that is not a regular file
> >       the VDSO
> >       ...
> >
> > In general, userspace can tag memory that it "owns", and we do not assume
> > a transfer of ownership except in the "OK" list above.  Otherwise, it's
> > the kernel's memory, or the owner is simply not well defined.
>
> Agreed on the general idea: a process should be able to pass tagged pointers at the
> syscall interface, as long as they point to memory privately owned by the process. I
> think it would be possible to simplify the definition of "non-weird" memory by using
> only this "OK" list:
> - mmap() done by the process itself, where either:
>    * flags = MAP_PRIVATE | MAP_ANONYMOUS
>    * flags = MAP_PRIVATE and fd refers to a regular file or a well-defined list of
> device files (like /dev/zero)
> - brk() done by the process itself
> - Any memory mapped by the kernel in the new process's address space during execve(),
> with the same restrictions as above ([vdso]/[vvar] are therefore excluded)
>
> > I would also like to see advice for userspace developers, particularly
> > things like (strawman, please challenge!):
>
> To some extent, one could call me a userspace developer, so I'll try to help :)
>
> >   * Userspace should set tags at the point of allocation only.
>
> Yes, tags are only supposed to be set at the point of either allocation or
> deallocation/reallocation. However, allocators can in principle be nested, so an
> allocator could  take a region allocated by malloc() as input and subdivide it
> (changing tags in the process). That said, this suballocator must not free() that
> region until all the suballocations themselves have been freed (thereby restoring the
> tags initially set by malloc()).
>
> >   * If you don't know how an object was allocated, you cannot modify the
> >     tag, period.
>
> Agreed, allocators that tag memory can only operate on memory with a well-defined
> provenance (for instance anonymous mmap() or malloc()).
>
> >   * A single C object should be accessed using a single, fixed pointer tag
> >     throughout its entire lifetime.
>
> Agreed. Allocators themselves may need to be excluded though, depending on how they
> represent their managed memory.
>
> >   * Tags can be changed only when there are no outstanding pointers to
> >     the affected object or region that may be used to access the object
> >     or region (i.e., if the object were allocated from the C heap and
> >     is it safe to realloc() it, then it is safe to change the tag; for
> >     other types of allocation, analogous arguments can be applied).
>
> Tags can only be changed at the point of deallocation/reallocation. Pointers to the
> object become invalid and cannot be used after it has been deallocated; memory
> tagging allows to catch such invalid usage.
>
> >   * When the kernel dereferences a pointer on userspace's behalf, it
> >     shall behave equivalently to userspace dereferencing the same pointer,
> >     including use of the same tag (where passed by userspace).
> >
> >   * Where the pointer tag affects pointer dereference behaviour (i.e.,
> >     with hardware memory colouring) the kernel makes no guarantee to
> >     honour pointer tags correctly for every location a buffer based on a
> >     pointer passed by userspace to the kernel.
> >
> >     (This means for example that for a read(fd, buf, size), we can check
> >     the tag for a single arbitrary location in *(char (*)[size])buf
> >     before passing the buffer to get_user_pages().  Hopefully this could
> >     be done in get_user_pages() itself rather than hunting call sites.
> >     For userspace, it means that you're on your own if you ask the
> >     kernel to operate on a buffer than spans multiple, independently-
> >     allocated objects, or a deliberately striped single object.)
>
> I think both points are reasonable. It is very valuable for the kernel to access
> userspace memory using the user-provided tag, because it enables kernel accesses to
> be checked in the same way as user accesses, allowing to detect bugs that are
> potentially hard to find. For instance, if a pointer to an object is passed to the
> kernel after it has been deallocated, this is invalid and should be detected.
> However, you are absolutely right that the kernel cannot *guarantee* that such a
> check is carried out for the entire memory range (or in fact at all); it should be a
> best-effort approach.

It would also be valuable to narrow down the set of "relaxed" (i.e.
not tag-checking) syscalls as reasonably possible. We would want to
provide tag-checking userspace wrappers for any important calls that
are not checked in the kernel. Is it correct to assume that anything
that goes through copy_from_user  / copy_to_user is checked?

>
> >   * The kernel shall not extend the lifetime of user pointers in ways
> >     that are not clear from the specification of the syscall or
> >     interface to which the pointer is passed (and in any case shall not
> >     extend pointer lifetimes without good reason).
> >
> >     So no clever transparent caching between syscalls, unless it _really_
> >     is transparent in the presence of tags.
>
> Do you have any particular case in mind? If such caching is really valuable, it is
> always possible to access the object while ignoring the tag. For sure, the
> user-provided tag can only be used during the syscall handling itself, not
> asynchronously later on, unless otherwise specified.

For aio* operations it would be nice if the tag was checked at the
time of the actual userspace read/write, either instead of or in
addition to at the time of the system call.

>
> >   * For purposes other than dereference, the kernel shall accept any
> >     legitimately tagged pointer (according to the above rules) as
> >     identifying the associated memory location.
> >
> >     So, mprotect(some_page_aligned_object, ...); is valid irrespective
> >     of where page_aligned_object() came from.  There is no implicit
> >     derefence by the kernel here, hence no tag check.
> >
> >     The kernel does not guarantee to work correctly if the wrong tag
> >     is used, but there is not always a well-defined "right" tag, so
> >     we can't really guarantee to check it.  So a pointer derived by
> >     any reasonable means by userspace has to be treated as equally
> >     valid.
>
> This is a disputed point :) In my opinion, this is the the most reasonable approach.

Yes, it would be nice if the kernel explicitly promised, ex.
mprotect() over a range of differently tagged pages to be allowed
(i.e. address tag should be unchecked).


>
> Cheers,
> Kevin
>
> > We would need to get some cross-arch buy-in for this, otherwise core
> > maintainers might just refuse to maintain the necessary guarantees.
> >
> >
> >>> 2. Allow tagged addressed passed to memory syscalls (as long as (1) is
> >>> satisfied). Do I understand correctly that this means that I need to
> >>> locate all find_vma() callers outside of mm/ and fix them up as well?
> >> Yes (unless anyone as a better idea or objections to this approach).
> > Also, watch out for code that pokes about inside struct vma directly.
> >
> > I'm wondering, could we define an explicit type, say,
> >
> >       struct user_vaddr {
> >               unsigned long addr;
> >       };
> >
> > to replace the unsigned longs in struct vma the mm API?  This would
> > turn ad-hoc (unsigned long) casts into build breaks.  We could have
> > an explicit conversion functions, say,
> >
> >       struct user_vaddr __user_vaddr_unsafe(void __user *);
> >       void __user *__user_ptr_unsafe(struct user_vaddr);
> >
> > that we robotically insert in all the relevant places to mark
> > unaudited code.
> >
> > This allows us to keep the kernel buildable, while flagging things
> > that will need review.  We would also need to warn the mm folks to
> > reject any new code using these unsafe conversions.
> >
> > Of course, it would be a non-trivial effort...
> >
> >> BTW, I'll be off until the new year, so won't be able to follow up.
> > Cheers
> > ---Dave
> >
> > _______________________________________________
> > linux-arm-kernel mailing list
> > linux-arm-kernel@lists.infradead.org
> > http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>


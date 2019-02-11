Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 428B9C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:28:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1DFE2229F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:28:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1DFE2229F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FD2F8E010B; Mon, 11 Feb 2019 12:28:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AE2E8E0108; Mon, 11 Feb 2019 12:28:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6750A8E010B; Mon, 11 Feb 2019 12:28:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0AAC18E0108
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:28:41 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id s50so10038050edd.11
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:28:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=8MHMWROY8YvoxeoW0as3HGxLJbLSDn3hLDmuWl8Gxok=;
        b=pGB8umANn8OOXQAZWVGVvzEW1LN1R7wwlffOSj/PskQ50E3v0PHE1wtJjzVQpe6JB4
         BOAwl+4ILvI3VaRO4tkVDRnU4Zm4XPAfrW9IvnlMMByplwtbPubptoiBLPkdDvIDgkh6
         CqSMz8HCDj/KfZVJypZT+N3or2o0tRBDriGoTuENOzics0Eut39ABQ6YWWDhCYX+0r99
         6oR4yK3dS6pQ15pQKl1fMjL99pTVUszGO3h1h9LojvTwM2LOUTV4D32W7c5tFw4QCllw
         P39vdXOctlieosjr3qLxxWM54/aqF3e1QSgtw1ZS3vbUz5q1l0vAaWV/+VhjgVy+eSpm
         ICvA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
X-Gm-Message-State: AHQUAuZhrmncyCSCQ0ksTUIJ+myEZ1nXQSMm+LqH98e5pVUDxwRZG6g2
	sfXTSvaPDldYZHzqToxL/8M5TLFxa3OrRxNChWjrbGuJ97fe9oYhiyLFOsD4yLm5PNTZqlyvCHI
	YVBuE1nY7lsCoWtlF5J9Q/zz8xSLR4ST8MVzjzOcx+KG5149lG6r8Xe4XJKgN75Y2QA==
X-Received: by 2002:a50:b0a4:: with SMTP id j33mr28403928edd.267.1549906120447;
        Mon, 11 Feb 2019 09:28:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZDSDCaQ0yTc4O1MNfL9MZP+LI2JjY8Yw50J7BFo0c2AsyHipqS2tp9C28L0U541ye7ILqm
X-Received: by 2002:a50:b0a4:: with SMTP id j33mr28403840edd.267.1549906118801;
        Mon, 11 Feb 2019 09:28:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549906118; cv=none;
        d=google.com; s=arc-20160816;
        b=Ozux4p3ICJ0LtqHtz9+B8iXCmYRwOtWBuI0pP82QSgKyPzuEqHrXhupxIJnDk0fvNI
         ZyN6XEanvPiCb20cT5b6tjXX84PCCGiaPtyjyOGnTlLTEdR1Pf2Fl7KjW+c9W68YlKsE
         cPXlsaamVEh3oq6PKUFlG0qfmpKmXYBMafJ7wyfUpGQYwoYsIYYdBpop92xdmrCOmWRP
         n08r3ROQBGO2/ZbO6I3z8p2DqwCEZUtUOkNs0oyfKmDOsHYOqqfs0b9LY3hAHybww3RW
         pKYL/kJ8uNJQS50TNLl/7r7sjo5WhHJLEPWaqUDQETyjWvUFkgv50A1Fj8KrsGzbgTHq
         +sxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=8MHMWROY8YvoxeoW0as3HGxLJbLSDn3hLDmuWl8Gxok=;
        b=SUQhVZv77UzWy4kRSG/7dAsWSooZ4GbS9loK/heV67rbicMSE3IeT8jrNUQypGB+3A
         TnkRY2X7VemXJSeyupyPARayLyOkqo2gXFN1C2/K52TM0zJwYhu1zN6Y3/IgGR5lkv6Z
         aseSfIu8lsJPDm7fMV0uaEp878lF6nA+u6mfXjzbg60Q8XolFwXFFjL6OKId6r5HwIwJ
         j895f4TE0qLwzioRMTHrr4u+HGXgpMu1ykHvUdamNpurKC4Vs4NR478dRsDMVnDhyDXt
         OdIsmZ8dfwu9pRGd2Vu0Libj7oNrg2RjX4TyZlBttJs2vALZZvubFJ+GHTwrohBzV6Sq
         4Gew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f25si4978530edf.442.2019.02.11.09.28.38
        for <linux-mm@kvack.org>;
        Mon, 11 Feb 2019 09:28:38 -0800 (PST)
Received-SPF: pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 940EA80D;
	Mon, 11 Feb 2019 09:28:37 -0800 (PST)
Received: from [10.1.199.35] (e107154-lin.cambridge.arm.com [10.1.199.35])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D61043F675;
	Mon, 11 Feb 2019 09:28:32 -0800 (PST)
From: Kevin Brodsky <kevin.brodsky@arm.com>
Subject: Re: [RFC][PATCH 0/3] arm64 relaxed ABI
To: Dave Martin <Dave.Martin@arm.com>,
 Catalin Marinas <catalin.marinas@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>,
 Kate Stewart <kstewart@linuxfoundation.org>,
 "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
 Will Deacon <will.deacon@arm.com>,
 Linux Memory Management List <linux-mm@kvack.org>,
 "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
 Chintan Pandya <cpandya@codeaurora.org>,
 Vincenzo Frascino <vincenzo.frascino@arm.com>, Shuah Khan
 <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>,
 linux-arch <linux-arch@vger.kernel.org>,
 Jacob Bramley <Jacob.Bramley@arm.com>, Dmitry Vyukov <dvyukov@google.com>,
 Evgenii Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Andrey Konovalov <andreyknvl@google.com>, Lee Smith <Lee.Smith@arm.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 Kostya Serebryany <kcc@google.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 LKML <linux-kernel@vger.kernel.org>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Robin Murphy <robin.murphy@arm.com>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
 Kevin Brodsky <Kevin.Brodsky@arm.com>
References: <cover.1544445454.git.andreyknvl@google.com>
 <20181210143044.12714-1-vincenzo.frascino@arm.com>
 <CAAeHK+xPZ-Z9YUAq=3+hbjj4uyJk32qVaxZkhcSAHYC4mHAkvQ@mail.gmail.com>
 <20181212150230.GH65138@arrakis.emea.arm.com>
 <CAAeHK+zxYJDJ7DJuDAOuOMgGvckFwMAoVUTDJzb6MX3WsXhRTQ@mail.gmail.com>
 <20181218175938.GD20197@arrakis.emea.arm.com>
 <20181219125249.GB22067@e103592.cambridge.arm.com>
Message-ID: <9bbacb1b-6237-f0bb-9bec-b4cf8d42bfc5@arm.com>
Date: Mon, 11 Feb 2019 17:28:31 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20181219125249.GB22067@e103592.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-GB
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 19/12/2018 12:52, Dave Martin wrote:
> On Tue, Dec 18, 2018 at 05:59:38PM +0000, Catalin Marinas wrote:
>> On Tue, Dec 18, 2018 at 04:03:38PM +0100, Andrey Konovalov wrote:
>>> On Wed, Dec 12, 2018 at 4:02 PM Catalin Marinas<catalin.marinas@arm.com>  wrote:
>>>> The summary of our internal discussions (mostly between kernel
>>>> developers) is that we can't properly describe a user ABI that covers
>>>> future syscalls or syscall extensions while not all syscalls accept
>>>> tagged pointers. So we tweaked the requirements slightly to only allow
>>>> tagged pointers back into the kernel *if* the originating address is
>>>> from an anonymous mmap() or below sbrk(0). This should cover some of the
>>>> ioctls or getsockopt(TCP_ZEROCOPY_RECEIVE) where the user passes a
>>>> pointer to a buffer obtained via mmap() on the device operations.
>>>>
>>>> (sorry for not being clear on what Vincenzo's proposal implies)
>>> OK, I see. So I need to make the following changes to my patchset AFAIU.
>>>
>>> 1. Make sure that we only allow tagged user addresses that originate
>>> from an anonymous mmap() or below sbrk(0). How exactly should this
>>> check be performed?
>> I don't think we should perform such checks. That's rather stating that
>> the kernel only guarantees that the tagged pointers work if they
>> originated from these memory ranges.
> I concur.
>
> Really, the kernel should do the expected thing with all "non-weird"
> memory.
>
> In lieu of a proper definition of "non-weird", I think we should have
> some lists of things that are explicitly included, and also excluded:
>
> OK:
> 	kernel-allocated process stack
> 	brk area
> 	MAP_ANONYMOUS | MAP_PRIVATE
> 	MAP_PRIVATE mappings of /dev/zero
>
> Not OK:
> 	MAP_SHARED
> 	mmaps of non-memory-like devices
> 	mmaps of anything that is not a regular file
> 	the VDSO
> 	...
>
> In general, userspace can tag memory that it "owns", and we do not assume
> a transfer of ownership except in the "OK" list above.  Otherwise, it's
> the kernel's memory, or the owner is simply not well defined.

Agreed on the general idea: a process should be able to pass tagged pointers at the 
syscall interface, as long as they point to memory privately owned by the process. I 
think it would be possible to simplify the definition of "non-weird" memory by using 
only this "OK" list:
- mmap() done by the process itself, where either:
   * flags = MAP_PRIVATE | MAP_ANONYMOUS
   * flags = MAP_PRIVATE and fd refers to a regular file or a well-defined list of 
device files (like /dev/zero)
- brk() done by the process itself
- Any memory mapped by the kernel in the new process's address space during execve(), 
with the same restrictions as above ([vdso]/[vvar] are therefore excluded)

> I would also like to see advice for userspace developers, particularly
> things like (strawman, please challenge!):

To some extent, one could call me a userspace developer, so I'll try to help :)

>   * Userspace should set tags at the point of allocation only.

Yes, tags are only supposed to be set at the point of either allocation or 
deallocation/reallocation. However, allocators can in principle be nested, so an 
allocator could  take a region allocated by malloc() as input and subdivide it 
(changing tags in the process). That said, this suballocator must not free() that 
region until all the suballocations themselves have been freed (thereby restoring the 
tags initially set by malloc()).

>   * If you don't know how an object was allocated, you cannot modify the
>     tag, period.

Agreed, allocators that tag memory can only operate on memory with a well-defined 
provenance (for instance anonymous mmap() or malloc()).

>   * A single C object should be accessed using a single, fixed pointer tag
>     throughout its entire lifetime.

Agreed. Allocators themselves may need to be excluded though, depending on how they 
represent their managed memory.

>   * Tags can be changed only when there are no outstanding pointers to
>     the affected object or region that may be used to access the object
>     or region (i.e., if the object were allocated from the C heap and
>     is it safe to realloc() it, then it is safe to change the tag; for
>     other types of allocation, analogous arguments can be applied).

Tags can only be changed at the point of deallocation/reallocation. Pointers to the 
object become invalid and cannot be used after it has been deallocated; memory 
tagging allows to catch such invalid usage.

>   * When the kernel dereferences a pointer on userspace's behalf, it
>     shall behave equivalently to userspace dereferencing the same pointer,
>     including use of the same tag (where passed by userspace).
>
>   * Where the pointer tag affects pointer dereference behaviour (i.e.,
>     with hardware memory colouring) the kernel makes no guarantee to
>     honour pointer tags correctly for every location a buffer based on a
>     pointer passed by userspace to the kernel.
>
>     (This means for example that for a read(fd, buf, size), we can check
>     the tag for a single arbitrary location in *(char (*)[size])buf
>     before passing the buffer to get_user_pages().  Hopefully this could
>     be done in get_user_pages() itself rather than hunting call sites.
>     For userspace, it means that you're on your own if you ask the
>     kernel to operate on a buffer than spans multiple, independently-
>     allocated objects, or a deliberately striped single object.)

I think both points are reasonable. It is very valuable for the kernel to access 
userspace memory using the user-provided tag, because it enables kernel accesses to 
be checked in the same way as user accesses, allowing to detect bugs that are 
potentially hard to find. For instance, if a pointer to an object is passed to the 
kernel after it has been deallocated, this is invalid and should be detected. 
However, you are absolutely right that the kernel cannot *guarantee* that such a 
check is carried out for the entire memory range (or in fact at all); it should be a 
best-effort approach.

>   * The kernel shall not extend the lifetime of user pointers in ways
>     that are not clear from the specification of the syscall or
>     interface to which the pointer is passed (and in any case shall not
>     extend pointer lifetimes without good reason).
>
>     So no clever transparent caching between syscalls, unless it _really_
>     is transparent in the presence of tags.

Do you have any particular case in mind? If such caching is really valuable, it is 
always possible to access the object while ignoring the tag. For sure, the 
user-provided tag can only be used during the syscall handling itself, not 
asynchronously later on, unless otherwise specified.

>   * For purposes other than dereference, the kernel shall accept any
>     legitimately tagged pointer (according to the above rules) as
>     identifying the associated memory location.
>
>     So, mprotect(some_page_aligned_object, ...); is valid irrespective
>     of where page_aligned_object() came from.  There is no implicit
>     derefence by the kernel here, hence no tag check.
>
>     The kernel does not guarantee to work correctly if the wrong tag
>     is used, but there is not always a well-defined "right" tag, so
>     we can't really guarantee to check it.  So a pointer derived by
>     any reasonable means by userspace has to be treated as equally
>     valid.

This is a disputed point :) In my opinion, this is the the most reasonable approach.

Cheers,
Kevin

> We would need to get some cross-arch buy-in for this, otherwise core
> maintainers might just refuse to maintain the necessary guarantees.
>
>
>>> 2. Allow tagged addressed passed to memory syscalls (as long as (1) is
>>> satisfied). Do I understand correctly that this means that I need to
>>> locate all find_vma() callers outside of mm/ and fix them up as well?
>> Yes (unless anyone as a better idea or objections to this approach).
> Also, watch out for code that pokes about inside struct vma directly.
>
> I'm wondering, could we define an explicit type, say,
>
> 	struct user_vaddr {
> 		unsigned long addr;
> 	};
>
> to replace the unsigned longs in struct vma the mm API?  This would
> turn ad-hoc (unsigned long) casts into build breaks.  We could have
> an explicit conversion functions, say,
>
> 	struct user_vaddr __user_vaddr_unsafe(void __user *);
> 	void __user *__user_ptr_unsafe(struct user_vaddr);
>
> that we robotically insert in all the relevant places to mark
> unaudited code.
>
> This allows us to keep the kernel buildable, while flagging things
> that will need review.  We would also need to warn the mm folks to
> reject any new code using these unsafe conversions.
>
> Of course, it would be a non-trivial effort...
>
>> BTW, I'll be off until the new year, so won't be able to follow up.
> Cheers
> ---Dave
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel


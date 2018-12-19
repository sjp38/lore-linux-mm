Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id EBE198E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 07:53:01 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id h4so3168129otg.17
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 04:53:01 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f193si764099oic.59.2018.12.19.04.53.00
        for <linux-mm@kvack.org>;
        Wed, 19 Dec 2018 04:53:00 -0800 (PST)
Date: Wed, 19 Dec 2018 12:52:52 +0000
From: Dave Martin <Dave.Martin@arm.com>
Subject: Re: [RFC][PATCH 0/3] arm64 relaxed ABI
Message-ID: <20181219125249.GB22067@e103592.cambridge.arm.com>
References: <cover.1544445454.git.andreyknvl@google.com>
 <20181210143044.12714-1-vincenzo.frascino@arm.com>
 <CAAeHK+xPZ-Z9YUAq=3+hbjj4uyJk32qVaxZkhcSAHYC4mHAkvQ@mail.gmail.com>
 <20181212150230.GH65138@arrakis.emea.arm.com>
 <CAAeHK+zxYJDJ7DJuDAOuOMgGvckFwMAoVUTDJzb6MX3WsXhRTQ@mail.gmail.com>
 <20181218175938.GD20197@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181218175938.GD20197@arrakis.emea.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, Kostya Serebryany <kcc@google.com>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Evgenii Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Dec 18, 2018 at 05:59:38PM +0000, Catalin Marinas wrote:
> On Tue, Dec 18, 2018 at 04:03:38PM +0100, Andrey Konovalov wrote:
> > On Wed, Dec 12, 2018 at 4:02 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > > The summary of our internal discussions (mostly between kernel
> > > developers) is that we can't properly describe a user ABI that covers
> > > future syscalls or syscall extensions while not all syscalls accept
> > > tagged pointers. So we tweaked the requirements slightly to only allow
> > > tagged pointers back into the kernel *if* the originating address is
> > > from an anonymous mmap() or below sbrk(0). This should cover some of the
> > > ioctls or getsockopt(TCP_ZEROCOPY_RECEIVE) where the user passes a
> > > pointer to a buffer obtained via mmap() on the device operations.
> > >
> > > (sorry for not being clear on what Vincenzo's proposal implies)
> > 
> > OK, I see. So I need to make the following changes to my patchset AFAIU.
> > 
> > 1. Make sure that we only allow tagged user addresses that originate
> > from an anonymous mmap() or below sbrk(0). How exactly should this
> > check be performed?
> 
> I don't think we should perform such checks. That's rather stating that
> the kernel only guarantees that the tagged pointers work if they
> originated from these memory ranges.

I concur.

Really, the kernel should do the expected thing with all "non-weird"
memory.

In lieu of a proper definition of "non-weird", I think we should have
some lists of things that are explicitly included, and also excluded:

OK:
	kernel-allocated process stack
	brk area
	MAP_ANONYMOUS | MAP_PRIVATE
	MAP_PRIVATE mappings of /dev/zero

Not OK:
	MAP_SHARED
	mmaps of non-memory-like devices
	mmaps of anything that is not a regular file
	the VDSO
	...

In general, userspace can tag memory that it "owns", and we do not assume
a transfer of ownership except in the "OK" list above.  Otherwise, it's
the kernel's memory, or the owner is simply not well defined.


I would also like to see advice for userspace developers, particularly
things like (strawman, please challenge!):

 * Userspace should set tags at the point of allocation only.

 * If you don't know how an object was allocated, you cannot modify the
   tag, period.

 * A single C object should be accessed using a single, fixed pointer tag
   throughout its entire lifetime.

 * Tags can be changed only when there are no outstanding pointers to
   the affected object or region that may be used to access the object
   or region (i.e., if the object were allocated from the C heap and
   is it safe to realloc() it, then it is safe to change the tag; for
   other types of allocation, analogous arguments can be applied).

 * When the kernel dereferences a pointer on userspace's behalf, it
   shall behave equivalently to userspace dereferencing the same pointer,
   including use of the same tag (where passed by userspace).

 * Where the pointer tag affects pointer dereference behaviour (i.e.,
   with hardware memory colouring) the kernel makes no guarantee to
   honour pointer tags correctly for every location a buffer based on a
   pointer passed by userspace to the kernel.

   (This means for example that for a read(fd, buf, size), we can check
   the tag for a single arbitrary location in *(char (*)[size])buf
   before passing the buffer to get_user_pages().  Hopefully this could
   be done in get_user_pages() itself rather than hunting call sites.
   For userspace, it means that you're on your own if you ask the
   kernel to operate on a buffer than spans multiple, independently-
   allocated objects, or a deliberately striped single object.)

 * The kernel shall not extend the lifetime of user pointers in ways
   that are not clear from the specification of the syscall or
   interface to which the pointer is passed (and in any case shall not
   extend pointer lifetimes without good reason).

   So no clever transparent caching between syscalls, unless it _really_
   is transparent in the presence of tags.

 * For purposes other than dereference, the kernel shall accept any
   legitimately tagged pointer (according to the above rules) as
   identifying the associated memory location.

   So, mprotect(some_page_aligned_object, ...); is valid irrespective
   of where page_aligned_object() came from.  There is no implicit
   derefence by the kernel here, hence no tag check.

   The kernel does not guarantee to work correctly if the wrong tag
   is used, but there is not always a well-defined "right" tag, so
   we can't really guarantee to check it.  So a pointer derived by
   any reasonable means by userspace has to be treated as equally
   valid.
  

We would need to get some cross-arch buy-in for this, otherwise core
maintainers might just refuse to maintain the necessary guarantees.


> > 2. Allow tagged addressed passed to memory syscalls (as long as (1) is
> > satisfied). Do I understand correctly that this means that I need to
> > locate all find_vma() callers outside of mm/ and fix them up as well?
> 
> Yes (unless anyone as a better idea or objections to this approach).

Also, watch out for code that pokes about inside struct vma directly.

I'm wondering, could we define an explicit type, say,

	struct user_vaddr {
		unsigned long addr;
	};

to replace the unsigned longs in struct vma the mm API?  This would
turn ad-hoc (unsigned long) casts into build breaks.  We could have
an explicit conversion functions, say,

	struct user_vaddr __user_vaddr_unsafe(void __user *);
	void __user *__user_ptr_unsafe(struct user_vaddr);

that we robotically insert in all the relevant places to mark
unaudited code.

This allows us to keep the kernel buildable, while flagging things
that will need review.  We would also need to warn the mm folks to
reject any new code using these unsafe conversions.

Of course, it would be a non-trivial effort...

> 
> BTW, I'll be off until the new year, so won't be able to follow up.

Cheers
---Dave

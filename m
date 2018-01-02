Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 19E586B02BA
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 11:44:45 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id o32so23323131wrf.20
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 08:44:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x10sor23604091edb.55.2018.01.02.08.44.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jan 2018 08:44:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171214173653.s6vsgiwfty3tzyzs@hirez.programming.kicks-ass.net>
References: <20171214112726.742649793@infradead.org> <20171214113851.197682513@infradead.org>
 <CALCETrXzaa8svjHdm3G3=FKvAZoQx-CboE6YecdPsva+Lf_bJg@mail.gmail.com> <20171214173653.s6vsgiwfty3tzyzs@hirez.programming.kicks-ass.net>
From: Dmitry Safonov <0x7f454c46@gmail.com>
Date: Tue, 2 Jan 2018 16:44:22 +0000
Message-ID: <CAJwJo6ZujJah9rTnhogGBR-7B9t7vuXi7vBTn2N=N4bc-FL3hw@mail.gmail.com>
Subject: Re: [PATCH v2 02/17] mm: Exempt special mappings from mlock(),
 mprotect() and madvise()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, crml <criu@openvz.org>

Hi, sorry for the late reply,

2017-12-14 17:36 GMT+00:00 Peter Zijlstra <peterz@infradead.org>:
> On Thu, Dec 14, 2017 at 08:19:36AM -0800, Andy Lutomirski wrote:
>> On Thu, Dec 14, 2017 at 3:27 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>> > It makes no sense to ever prod at special mappings with any of these
>> > syscalls.
>> >
>> > XXX should we include munmap() ?
>>
>> This is an ABI break for the vdso.  Maybe that's okay, but mremap() on
>> the vdso is certainly used, and I can imagine debuggers using
>> mprotect().
>
> *groan*, ok so mremap() will actually still work after this, but yes,
> mprotect() will not. I hadn't figured people would muck with the VDSO
> like that.

mremap() is needed for CRIU, at least.

Please, don't restrict munmap(), as ARCH_MAP_VDSO_* allows to map vdso
iff it's not already mapped.
We don't need +w vdso mapping, but I guess that may break gdb breakpoints
on vdso.

Also, AFAICS, vma_is_special_mapping() has two parameters in linux-next,
and your patches set doesn't change that.

Thanks,
             Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 243546B016A
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 02:41:12 -0400 (EDT)
Received: by bkbzt4 with SMTP id zt4so5831493bkb.14
        for <linux-mm@kvack.org>; Mon, 22 Aug 2011 23:41:06 -0700 (PDT)
Date: Tue, 23 Aug 2011 10:41:01 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [RFC] x86, mm: start mmap allocation for libs from low
 addresses
Message-ID: <20110823064101.GA3780@albatros>
References: <20110812102954.GA3496@albatros>
 <ccea406f-62be-4344-8036-a1b092937fe9@email.android.com>
 <20110816090540.GA7857@albatros>
 <20110822101730.GA3346@albatros>
 <4E5290D6.5050406@zytor.com>
 <20110822201418.GA3176@albatros>
 <4E52B96B.8040404@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E52B96B.8040404@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel-hardening@lists.openwall.com, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Aug 22, 2011 at 13:17 -0700, H. Peter Anvin wrote:
> On 08/22/2011 01:14 PM, Vasiliy Kulikov wrote:
> > 
> >> Code-wise:
> >>
> >> The code is horrific; it is full of open-coded magic numbers;
> > 
> > Agreed, the magic needs macro definition and comments.
> > 
> >> it also
> >> puts a function called arch_get_unmapped_exec_area() in a generic file,
> >> which could best be described as "WTF" -- the arch_ prefix we use
> >> specifically to denote a per-architecture hook function.
> > 
> > Agreed.  But I'd want to leave it in mm/mmap.c as it's likely be used by
> > other archs - the changes are bitness specific, not arch specific.  Is
> > it OK if I do this?
> > 
> > #ifndef HAVE_ARCH_UNMAPPED_EXEC_AREA
> > void *arch_get_unmapped_exec_area(...)
> > {
> >     ...
> > }
> > #endif
> > 
> 
> Only if this is really an architecture-specific function overridden in
> specific architectures.  I'm not so sure that applies here.

It is a more or less generic allocator.  Arch specific constants will be
moved to arch headers, so it will be a 32-bit specific function, not
arch specific (64 bit architectures don't need ASCII shield at all as
mmap addresses already contain a zero byte).  It will not be overriden
by x86 as it is "enough generic" for x86.

I've defined it as arch_* looking at other allocator implementations.
All of them are arch_* and are located in mm/mmap.c with the ability to
override them in architecture specific files.  Probably nobody will
override it, but I tried to make it consistent with the existing code.
If this HAVE_ARCH_*/arch_* logic is not suitable for exec_area, I'll
remove arch_ prefix.


> Furthermore, I'm not even all that sure what this function *does*.

This is a bottom-up allocator, which tries to reuse all holes in the
ASCII-protected region.  It differs from arch_get_unmapped_area() in the
priority of the first 16 Mb - arch_get_unmapped_area() tries to walk
through all vmas in the whole VM space, arch_get_unmapped_exec_area()
tries to reuse all memory from the first 16 Mb and only then allocating
arbitrary addressed by fallbacking to the default allocator (top down in
case of x86).

I'll add the comment for the allocator.

Thank you,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

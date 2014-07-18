Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id EF9406B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 13:28:38 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id ft15so5394766pdb.38
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 10:28:38 -0700 (PDT)
Received: from relay1.mentorg.com (relay1.mentorg.com. [192.94.38.131])
        by mx.google.com with ESMTPS id qd5si6616769pbb.211.2014.07.18.10.28.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 10:28:38 -0700 (PDT)
Message-ID: <53C95932.206@mentor.com>
Date: Fri, 18 Jul 2014 12:28:18 -0500
From: Nathan Lynch <Nathan_Lynch@mentor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] arm64,ia64,ppc,s390,sh,tile,um,x86,mm: Remove default
 gate area
References: <70f331f59e620dc4e66bd3fa095e6f6b744b532b.1405281639.git.luto@amacapital.net> <CALCETrXG6nL4K=Er+kv5-CXBDVa0TLg9yR6iePnMyE2ufXgKkw@mail.gmail.com> <20140718101416.GB1818@arm.com> <53C8F4DF.8020103@nod.at> <CALCETrXve-=N5yzqDw2YQee4BmC6sb8GYWYJcV2780V38OuJiQ@mail.gmail.com>
In-Reply-To: <CALCETrXve-=N5yzqDw2YQee4BmC6sb8GYWYJcV2780V38OuJiQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Richard Weinberger <richard@nod.at>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org, Fenghua Yu <fenghua.yu@intel.com>, X86 ML <x86@kernel.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Ingo Molnar <mingo@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Tony Luck <tony.luck@intel.com>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux390@de.ibm.com" <linux390@de.ibm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Chris Metcalf <cmetcalf@tilera.com>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, Paul Mackerras <paulus@samba.org>, Jeff Dike <jdike@addtoit.com>, "user-mode-linux-devel@lists.sourceforge.net" <user-mode-linux-devel@lists.sourceforge.net>

On 07/18/2014 11:53 AM, Andy Lutomirski wrote:
> 
> On Jul 18, 2014 3:20 AM, "Richard Weinberger" <richard@nod.at
> <mailto:richard@nod.at>> wrote:
>>
>> Am 18.07.2014 12:14, schrieb Will Deacon:
>> > On Tue, Jul 15, 2014 at 03:47:26PM +0100, Andy Lutomirski wrote:
>> >> On Sun, Jul 13, 2014 at 1:01 PM, Andy Lutomirski
> <luto@amacapital.net <mailto:luto@amacapital.net>> wrote:
>> >>> The core mm code will provide a default gate area based on
>> >>> FIXADDR_USER_START and FIXADDR_USER_END if
>> >>> !defined(__HAVE_ARCH_GATE_AREA) && defined(AT_SYSINFO_EHDR).
>> >>>
>> >>> This default is only useful for ia64.  arm64, ppc, s390, sh, tile,
>> >>> 64-bit UML, and x86_32 have their own code just to disable it.  arm,
>> >>> 32-bit UML, and x86_64 have gate areas, but they have their own
>> >>> implementations.
>> >>>
>> >>> This gets rid of the default and moves the code into ia64.
>> >>>
>> >>> This should save some code on architectures without a gate area: it's
>> >>> now possible to inline the gate_area functions in the default case.
>> >>
>> >> Can one of you pull this somewhere?  Otherwise I can put it somewhere
>> >> stable and ask for -next inclusion, but that seems like overkill for a
>> >> single patch.
>>
>> For the um bits:
>> Acked-by: Richard Weinberger <richard@nod.at <mailto:richard@nod.at>>
>>
>> > I'd be happy to take the arm64 part, but it doesn't feel right for mm/*
>> > changes (or changes to other archs) to go via our tree.
>> >
>> > I'm not sure what the best approach is if you want to send this via
> a single
>> > tree. Maybe you could ask akpm nicely?
>>
>> Going though Andrew's tree sounds sane to me.
> 
> Splitting this will be annoying: I'd probably have to add a flag asking
> for the new behavior, update all the arches, then remove the flag.  The
> chance of screwing up bisectability in the process seems pretty high. 
> This seems like overkill for a patch that mostly deletes code.
> 
> Akpm, can you take this?

FWIW:

Acked-by: Nathan Lynch <nathan_lynch@mentor.com>

This patch allows me to avoid adding a bunch of empty hooks to arch/arm
when adding VDSO support:

http://lists.infradead.org/pipermail/linux-arm-kernel/2014-June/268045.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

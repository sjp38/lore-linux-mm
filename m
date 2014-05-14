Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f170.google.com (mail-ve0-f170.google.com [209.85.128.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9F11F6B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 18:23:48 -0400 (EDT)
Received: by mail-ve0-f170.google.com with SMTP id db11so289686veb.1
        for <linux-mm@kvack.org>; Wed, 14 May 2014 15:23:48 -0700 (PDT)
Received: from mail-ve0-f169.google.com (mail-ve0-f169.google.com [209.85.128.169])
        by mx.google.com with ESMTPS id tv3si561371vdc.126.2014.05.14.15.23.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 15:23:48 -0700 (PDT)
Received: by mail-ve0-f169.google.com with SMTP id jx11so281927veb.14
        for <linux-mm@kvack.org>; Wed, 14 May 2014 15:23:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140514221140.GF28328@moon>
References: <53739201.6080604@oracle.com> <20140514132312.573e5d3cf99276c3f0b82980@linux-foundation.org>
 <5373D509.7090207@oracle.com> <20140514140305.7683c1c2f1e4fb0a63085a2a@linux-foundation.org>
 <5373DBE4.6030907@oracle.com> <20140514143124.52c598a2ba8e2539ee76558c@linux-foundation.org>
 <CALCETrXQOPBOBOgE_snjdmJM7zi34Ei8-MUA-U-YVrwubz4sOQ@mail.gmail.com> <20140514221140.GF28328@moon>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 14 May 2014 15:23:27 -0700
Message-ID: <CALCETrUc2CpTEeo=NjLGxXQWHn-HG3uYUo-L3aOU-yVjVx3PGg@mail.gmail.com>
Subject: Re: mm: NULL ptr deref handling mmaping of special mappings
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Wed, May 14, 2014 at 3:11 PM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> On Wed, May 14, 2014 at 02:33:54PM -0700, Andy Lutomirski wrote:
>> On Wed, May 14, 2014 at 2:31 PM, Andrew Morton
>> <akpm@linux-foundation.org> wrote:
>> > On Wed, 14 May 2014 17:11:00 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:
>> >
>> >> > In my linux-next all that code got deleted by Andy's "x86, vdso:
>> >> > Reimplement vdso.so preparation in build-time C" anyway.  What kernel
>> >> > were you looking at?
>> >>
>> >> Deleted? It appears in today's -next. arch/x86/vdso/vma.c:124 .
>> >>
>> >> I don't see Andy's patch removing that code either.
>> >
>> > ah, OK, it got moved from arch/x86/vdso/vdso32-setup.c into
>> > arch/x86/vdso/vma.c.
>> >
>> > Maybe you managed to take a fault against the symbol area between the
>> > _install_special_mapping() and the remap_pfn_range() call, but mmap_sem
>> > should prevent that.
>> >
>> > Or the remap_pfn_range() call never happened.  Should map_vdso() be
>> > running _install_special_mapping() at all if
>> > image->sym_vvar_page==NULL?
>>
>> I'm confused: are we talking about 3.15-rcsomething or linux-next?
>> That code changed.
>>
>> Would this all make more sense if there were just a single vma in
>> here?  cc: Pavel and Cyrill, who might have to deal with this stuff in
>> CRIU
>
> Well, for criu we've not modified any vdso kernel's code (except
> setting VM_SOFTDIRTY for this vdso VMA in _install_special_mapping).
> And never experienced problems Sasha points. Looks like indeed in
> -next code is pretty different from mainline one. To figure out
> why I need to fetch -next branch and get some research. I would
> try to do that tomorrow (still hoping someone more experienced
> in mm system would beat me on that).

I can summarize:

On 3.14 and before, the vdso is just a bunch of ELF headers and
executable data.  When executed by 64-bit binaries, it reads from the
fixmap to do its thing.  That is, it reads from kernel addresses that
don't have vmas.  When executed by 32-bit binaries, it doesn't read
anything, since there was no 32-bit timing code.

On 3.15, the x86_64 vdso is unchanged.  The 32-bit vdso is preceded by
a separate vma containing two pages worth of time-varying read-only
data.  The vdso reads those pages using PIC references.

On linux-next, all vdsos work the same way.  There are two vmas.  The
first vma is executable text, which can be poked at by ptrace, etc
normally.  The second vma contains time-varying state, should not
allow poking, and is accessed by PIC references.

What does CRIU do to restore the vdso?  Will 3.15 and/or linux-next
need to make some concession for CRIU?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

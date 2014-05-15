Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id B41F86B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 15:53:26 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id pv20so1195839lab.41
        for <linux-mm@kvack.org>; Thu, 15 May 2014 12:53:25 -0700 (PDT)
Received: from mail-la0-x22c.google.com (mail-la0-x22c.google.com [2a00:1450:4010:c03::22c])
        by mx.google.com with ESMTPS id x3si3986262lae.41.2014.05.15.12.53.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 May 2014 12:53:24 -0700 (PDT)
Received: by mail-la0-f44.google.com with SMTP id hr17so1215002lab.3
        for <linux-mm@kvack.org>; Thu, 15 May 2014 12:53:24 -0700 (PDT)
Date: Thu, 15 May 2014 23:53:20 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: mm: NULL ptr deref handling mmaping of special mappings
Message-ID: <20140515195320.GR28328@moon>
References: <20140514132312.573e5d3cf99276c3f0b82980@linux-foundation.org>
 <5373D509.7090207@oracle.com>
 <20140514140305.7683c1c2f1e4fb0a63085a2a@linux-foundation.org>
 <5373DBE4.6030907@oracle.com>
 <20140514143124.52c598a2ba8e2539ee76558c@linux-foundation.org>
 <CALCETrXQOPBOBOgE_snjdmJM7zi34Ei8-MUA-U-YVrwubz4sOQ@mail.gmail.com>
 <20140514221140.GF28328@moon>
 <CALCETrUc2CpTEeo=NjLGxXQWHn-HG3uYUo-L3aOU-yVjVx3PGg@mail.gmail.com>
 <20140515084558.GI28328@moon>
 <CALCETrWwWXEoNparvhx4yJB8YmiUBZCuR6yQxJOTjYKuA8AdqQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWwWXEoNparvhx4yJB8YmiUBZCuR6yQxJOTjYKuA8AdqQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Thu, May 15, 2014 at 12:46:34PM -0700, Andy Lutomirski wrote:
> On Thu, May 15, 2014 at 1:45 AM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> > On Wed, May 14, 2014 at 03:23:27PM -0700, Andy Lutomirski wrote:
> >> I can summarize:
> >>
> >> On 3.14 and before, the vdso is just a bunch of ELF headers and
> >> executable data.  When executed by 64-bit binaries, it reads from the
> >> fixmap to do its thing.  That is, it reads from kernel addresses that
> >> don't have vmas.  When executed by 32-bit binaries, it doesn't read
> >> anything, since there was no 32-bit timing code.
> >>
> >> On 3.15, the x86_64 vdso is unchanged.  The 32-bit vdso is preceded by
> >> a separate vma containing two pages worth of time-varying read-only
> >> data.  The vdso reads those pages using PIC references.
> >
> > Andy, could you please point me where is the code which creates a second vma?
> > latest 3.15 master branch
> 
> Search for _install_special_mapping in arch/x86/vdso.  It's in a
> different place in 3.15-rc and -next.

As far as I see _install_special_mapping allocates one vma from cache and

	vma->vm_start = addr;
	vma->vm_end = addr + len;

so where is the second one?

> 
> >
> > [root@fc ~]# cat /proc/self/maps
> > ...
> > 7fff57b6e000-7fff57b8f000 rw-p 00000000 00:00 0                          [stack]
> > 7fff57bff000-7fff57c00000 r-xp 00000000 00:00 0                          [vdso]
> > ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]
> > [root@fc ~]#
> >
> 
> What version and bitness is this?

x86-64, 3.15-rc5

> 
> > Or you mean vsyscall area? If yes, then in criu we don't dump vsyscall zone.
> > On restore we don't touch  vsyscall either but for vdso there are two cases
> 
> vsyscalls are almost gone now :)

Good to know ;)

> 
> >
> >  - if there were no kernel change on vdso contents we simply use vdso provided
> >    by the kernel at the moment of criu startup
> >
> >  - if vdso has been changed and looks different from one saved in image during
> >    checkpoint, we map it from image but then patch (push jmp instruction) so
> >    when application calls for some of vdso function it jumps into vdso code
> >    saved in image and then jumps into vdso mapped by the kernel (ie kind of
> >    proxy calls) This force us to do own Elf parsing inside criu to calculate
> >    proper offsets.
> 
> Yuck :)

Yeah, I know, we simply had no choise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id E3CB56B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 04:46:02 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id w7so532824lbi.37
        for <linux-mm@kvack.org>; Thu, 15 May 2014 01:46:01 -0700 (PDT)
Received: from mail-la0-x233.google.com (mail-la0-x233.google.com [2a00:1450:4010:c03::233])
        by mx.google.com with ESMTPS id na5si1541295lbb.50.2014.05.15.01.46.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 May 2014 01:46:01 -0700 (PDT)
Received: by mail-la0-f51.google.com with SMTP id gf5so548360lab.10
        for <linux-mm@kvack.org>; Thu, 15 May 2014 01:46:00 -0700 (PDT)
Date: Thu, 15 May 2014 12:45:58 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: mm: NULL ptr deref handling mmaping of special mappings
Message-ID: <20140515084558.GI28328@moon>
References: <53739201.6080604@oracle.com>
 <20140514132312.573e5d3cf99276c3f0b82980@linux-foundation.org>
 <5373D509.7090207@oracle.com>
 <20140514140305.7683c1c2f1e4fb0a63085a2a@linux-foundation.org>
 <5373DBE4.6030907@oracle.com>
 <20140514143124.52c598a2ba8e2539ee76558c@linux-foundation.org>
 <CALCETrXQOPBOBOgE_snjdmJM7zi34Ei8-MUA-U-YVrwubz4sOQ@mail.gmail.com>
 <20140514221140.GF28328@moon>
 <CALCETrUc2CpTEeo=NjLGxXQWHn-HG3uYUo-L3aOU-yVjVx3PGg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUc2CpTEeo=NjLGxXQWHn-HG3uYUo-L3aOU-yVjVx3PGg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Wed, May 14, 2014 at 03:23:27PM -0700, Andy Lutomirski wrote:
> I can summarize:
> 
> On 3.14 and before, the vdso is just a bunch of ELF headers and
> executable data.  When executed by 64-bit binaries, it reads from the
> fixmap to do its thing.  That is, it reads from kernel addresses that
> don't have vmas.  When executed by 32-bit binaries, it doesn't read
> anything, since there was no 32-bit timing code.
> 
> On 3.15, the x86_64 vdso is unchanged.  The 32-bit vdso is preceded by
> a separate vma containing two pages worth of time-varying read-only
> data.  The vdso reads those pages using PIC references.

Andy, could you please point me where is the code which creates a second vma?
latest 3.15 master branch

[root@fc ~]# cat /proc/self/maps
...
7fff57b6e000-7fff57b8f000 rw-p 00000000 00:00 0                          [stack]
7fff57bff000-7fff57c00000 r-xp 00000000 00:00 0                          [vdso]
ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]
[root@fc ~]#

Or you mean vsyscall area? If yes, then in criu we don't dump vsyscall zone.
On restore we don't touch  vsyscall either but for vdso there are two cases

 - if there were no kernel change on vdso contents we simply use vdso provided
   by the kernel at the moment of criu startup

 - if vdso has been changed and looks different from one saved in image during
   checkpoint, we map it from image but then patch (push jmp instruction) so
   when application calls for some of vdso function it jumps into vdso code
   saved in image and then jumps into vdso mapped by the kernel (ie kind of
   proxy calls) This force us to do own Elf parsing inside criu to calculate
   proper offsets.

We don't support (and have no plans to support) x86-32 kernels but there
left a case with compatible mode (32bit app on 64bit kernel) which has
not yet been implemented though.

> On linux-next, all vdsos work the same way.  There are two vmas.  The
> first vma is executable text, which can be poked at by ptrace, etc
> normally.  The second vma contains time-varying state, should not
> allow poking, and is accessed by PIC references.
> 
> What does CRIU do to restore the vdso?  Will 3.15 and/or linux-next
> need to make some concession for CRIU?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

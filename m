Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 472246B0006
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 05:04:45 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id l1so1714045pga.1
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 02:04:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l26si1133479pfj.401.2018.02.13.02.04.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Feb 2018 02:04:43 -0800 (PST)
Date: Tue, 13 Feb 2018 11:04:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] elf: enforce MAP_FIXED on overlaying elf segments (was:
 Re: ppc elf_map breakage with MAP_FIXED_NOREPLACE)
Message-ID: <20180213100440.GM3443@dhcp22.suse.cz>
References: <6db9b33d-fd46-c529-b357-3397926f0733@linux.vnet.ibm.com>
 <20180129132235.GE21609@dhcp22.suse.cz>
 <87k1w081e7.fsf@concordia.ellerman.id.au>
 <20180130094205.GS21609@dhcp22.suse.cz>
 <5eccdc1b-6a10-b48a-c63f-295f69473d97@linux.vnet.ibm.com>
 <20180131131937.GA6740@dhcp22.suse.cz>
 <bfecda5e-ae8b-df91-0add-df6322b42a70@linux.vnet.ibm.com>
 <20180201131007.GJ21609@dhcp22.suse.cz>
 <20180201134026.GK21609@dhcp22.suse.cz>
 <CAGXu5j+fo0Z_ax2O10A-3D3puLhnX+o5M4Lp3TBsnE=NtFCjpw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5j+fo0Z_ax2O10A-3D3puLhnX+o5M4Lp3TBsnE=NtFCjpw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mm-commits@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-Next <linux-next@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Mark Brown <broonie@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri 02-02-18 07:55:14, Kees Cook wrote:
> On Fri, Feb 2, 2018 at 12:40 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Thu 01-02-18 14:10:07, Michal Hocko wrote:
> > Thanks a lot to Michael Matz for his background. He has pointed me to
> > the following two segments from your binary[1]
> >   LOAD           0x0000000000000000 0x0000000010000000 0x0000000010000000
> >                  0x0000000000013a8c 0x0000000000013a8c  R E    10000
> >   LOAD           0x000000000001fd40 0x000000001002fd40 0x000000001002fd40
> >                  0x00000000000002c0 0x00000000000005e8  RW     10000
> >   LOAD           0x0000000000020328 0x0000000010030328 0x0000000010030328
> >                  0x0000000000000384 0x00000000000094a0  RW     10000
> >
> > That binary has two RW LOAD segments, the first crosses a page border
> > into the second
> > 0x1002fd40 (LOAD2-vaddr) + 0x5e8 (LOAD2-memlen) == 0x10030328 (LOAD3-vaddr)
> >
> > He says
> > : This is actually an artifact of RELRO machinism.  The first RW mapping
> > : will be remapped as RO after relocations are applied (to increase
> > : security).
> > : Well, to be honest, normal relro binaries also don't have more than
> > : two LOAD segments, so whatever RHEL did to their compilation options,
> > : it's something in addition to just relro (which can be detected by
> > : having a GNU_RELRO program header)
> > : But it definitely has something to do with relro, it's just not the
> > : whole story yet.
> >
> > I am still trying to wrap my head around all this, but it smells rather
> > dubious to map different segments over the same page. Is this something
> > that might happen widely and therefore MAP_FIXED_NOREPLACE is a no-go
> > when loading ELF segments? Or is this a special case we can detect?
> 
> Eww. FWIW, I would expect that to be rare and detectable.

OK, so Anshuman has confirmed [1] that the patch below fixes the issue
for him. I am sending this as an RFC because this is not really my area
and load_elf_binary is obscure as hell. The changelog could see much
more clear wording than I am able to provide. Any help would be highly
appreciated.

[1] http://lkml.kernel.org/r/b0a751c4-9552-87b4-c768-3e1b02c18b5c@linux.vnet.ibm.com

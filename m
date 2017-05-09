Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4FD25280757
	for <linux-mm@kvack.org>; Tue,  9 May 2017 15:36:54 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l9so2542945wre.12
        for <linux-mm@kvack.org>; Tue, 09 May 2017 12:36:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z133si1846863wmb.39.2017.05.09.12.36.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 12:36:52 -0700 (PDT)
Date: Tue, 9 May 2017 21:36:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmalloc: fix vmalloc users tracking properly
Message-ID: <20170509193650.GA16325@dhcp22.suse.cz>
References: <20170509144108.31910-1-mhocko@kernel.org>
 <CAMuHMdV2=PUs64K8tnGw1oPDRjKbx0SRkN-59ToTpj57=CXYdA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAMuHMdV2=PUs64K8tnGw1oPDRjKbx0SRkN-59ToTpj57=CXYdA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tobias Klauser <tklauser@distanz.ch>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 09-05-17 21:01:25, Geert Uytterhoeven wrote:
> Hi Michal,
> 
> On Tue, May 9, 2017 at 4:41 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > From: Michal Hocko <mhocko@suse.com>
> >
> > 1f5307b1e094 ("mm, vmalloc: properly track vmalloc users") has pulled
> > asm/pgtable.h include dependency to linux/vmalloc.h and that turned out
> > to be a bad idea for some architectures. E.g. m68k fails with
> >    In file included from arch/m68k/include/asm/pgtable_mm.h:145:0,
> >                     from arch/m68k/include/asm/pgtable.h:4,
> >                     from include/linux/vmalloc.h:9,
> >                     from arch/m68k/kernel/module.c:9:
> >    arch/m68k/include/asm/mcf_pgtable.h: In function 'nocache_page':
> >>> arch/m68k/include/asm/mcf_pgtable.h:339:43: error: 'init_mm' undeclared (first use in this function)
> >     #define pgd_offset_k(address) pgd_offset(&init_mm, address)
> >
> > as spotted by kernel build bot. nios2 fails for other reason
> > In file included from ./include/asm-generic/io.h:767:0,
> >                  from ./arch/nios2/include/asm/io.h:61,
> >                  from ./include/linux/io.h:25,
> >                  from ./arch/nios2/include/asm/pgtable.h:18,
> >                  from ./include/linux/mm.h:70,
> >                  from ./include/linux/pid_namespace.h:6,
> >                  from ./include/linux/ptrace.h:9,
> >                  from ./arch/nios2/include/uapi/asm/elf.h:23,
> >                  from ./arch/nios2/include/asm/elf.h:22,
> >                  from ./include/linux/elf.h:4,
> >                  from ./include/linux/module.h:15,
> >                  from init/main.c:16:
> > ./include/linux/vmalloc.h: In function '__vmalloc_node_flags':
> > ./include/linux/vmalloc.h:99:40: error: 'PAGE_KERNEL' undeclared (first use in this function); did you mean 'GFP_KERNEL'?
> >
> > which is due to the newly added #include <asm/pgtable.h>, which on nios2
> > includes <linux/io.h> and thus <asm/io.h> and <asm-generic/io.h> which
> > again includes <linux/vmalloc.h>.
> >
> > Tweaking that around just turns out a bigger headache than
> > necessary. This patch reverts 1f5307b1e094 and reimplements the original
> > fix in a different way. __vmalloc_node_flags can stay static inline
> > which will cover vmalloc* functions. We only have one external user
> > (kvmalloc_node) and we can export __vmalloc_node_flags_caller and
> > provide the caller directly. This is much simpler and it doesn't really
> > need any games with header files.
> >
> > Fixes: 1f5307b1e094 ("mm, vmalloc: properly track vmalloc users")
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> FWIW, this did fix the following build failure on m68k in linus/master
> (commit 2868b2513aa732a9 ("Merge tag 'linux-kselftest-4.12-rc1' of
> git://git.kernel.org/pub/scm/linux/kernel/git/shuah/linux-kselftest"):
> 
>     In file included from arch/m68k/include/asm/pgtable_mm.h:148,
>                      from arch/m68k/include/asm/pgtable.h:5,
>                      from include/linux/vmalloc.h:10,
>                      from arch/m68k/kernel/module.c:10:
>     arch/m68k/include/asm/motorola_pgtable.h: In function a??pgd_offseta??:
>     arch/m68k/include/asm/motorola_pgtable.h:198: error: dereferencing
> pointer to incomplete type
>     scripts/Makefile.build:294: recipe for target
> 'arch/m68k/kernel/module.o' failed
> 
> but given the complaints from 0day on this and future versions, I think it's
> better not to provide a Tested-by yet.

FWIW I have already sent a follow up fix
http://lkml.kernel.org/r/20170509153702.GR6481@dhcp22.suse.cz
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C15D06B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 01:24:12 -0500 (EST)
Received: by fxm12 with SMTP id 12so5276371fxm.14
        for <linux-mm@kvack.org>; Mon, 24 Jan 2011 22:24:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110124210752.GA10819@merkur.ravnborg.org>
References: <20110124210813.ba743fc5.yuasa@linux-mips.org>
	<4D3DD366.8000704@mvista.com>
	<20110124124412.69a7c814.akpm@linux-foundation.org>
	<20110124210752.GA10819@merkur.ravnborg.org>
Date: Tue, 25 Jan 2011 07:24:09 +0100
Message-ID: <AANLkTimdgYVpwbCAL96=1F+EtXyNxz5Swv32GN616mqP@mail.gmail.com>
Subject: Re: [PATCH] fix build error when CONFIG_SWAP is not set
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergei Shtylyov <sshtylyov@mvista.com>, Yoichi Yuasa <yuasa@linux-mips.org>, linux-mips <linux-mips@linux-mips.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 24, 2011 at 22:07, Sam Ravnborg <sam@ravnborg.org> wrote:
> On Mon, Jan 24, 2011 at 12:44:12PM -0800, Andrew Morton wrote:
>> On Mon, 24 Jan 2011 22:30:46 +0300
>> Sergei Shtylyov <sshtylyov@mvista.com> wrote:
>> > Yoichi Yuasa wrote:
>> >
>> > > In file included from
>> > > linux-2.6/arch/mips/include/asm/tlb.h:21,
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0from m=
m/pgtable-generic.c:9:
>> > > include/asm-generic/tlb.h: In function 'tlb_flush_mmu':
>> > > include/asm-generic/tlb.h:76: error: implicit declaration of functio=
n
>> > > 'release_pages'
>> > > include/asm-generic/tlb.h: In function 'tlb_remove_page':
>> > > include/asm-generic/tlb.h:105: error: implicit declaration of functi=
on
>> > > 'page_cache_release'
>> > > make[1]: *** [mm/pgtable-generic.o] Error 1
>> > >
>> > > Signed-off-by: Yoichi Yuasa <yuasa@linux-mips.org>
>> > [...]
>> >
>> > > diff --git a/include/linux/swap.h b/include/linux/swap.h
>> > > index 4d55932..92c1be6 100644
>> > > --- a/include/linux/swap.h
>> > > +++ b/include/linux/swap.h
>> > > @@ -8,6 +8,7 @@
>> > > =C2=A0#include <linux/memcontrol.h>
>> > > =C2=A0#include <linux/sched.h>
>> > > =C2=A0#include <linux/node.h>
>> > > +#include <linux/pagemap.h>
>> >
>> > =C2=A0 =C2=A0 Hm, if the errors are in <asm-generic/tlb.h>, why add #i=
nclude in
>> > <linux/swap.h>?
>> >
>>
>> The build error is caused by macros which are defined in swap.h.
>>
>> I worry about the effects of the patch - I don't know which of swap.h
>> and pagemap.h is the "innermost" header file. =C2=A0There's potential fo=
r
>> new build errors due to strange inclusion graphs.
>>
>> err, there's also this, in swap.h:
>>
>> /* only sparc can not include linux/pagemap.h in this file
>> =C2=A0* so leave page_cache_release and release_pages undeclared... */

Yeah, I noticed this too a while ago, when trying to get m68k
allnoconfig "working".
Was wondering whether this was still true...

> I just checked.
> sparc32 with a defconfig barfed out like this:
> =C2=A0CC =C2=A0 =C2=A0 =C2=A0arch/sparc/kernel/traps_32.o
> In file included from /home/sam/kernel/linux-2.6.git/include/linux/pagema=
p.h:7:0,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 from /home/sam/ke=
rnel/linux-2.6.git/include/linux/swap.h:11,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 from /home/sam/ke=
rnel/linux-2.6.git/arch/sparc/include/asm/pgtable_32.h:15,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 from /home/sam/ke=
rnel/linux-2.6.git/arch/sparc/include/asm/pgtable.h:6,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 from /home/sam/ke=
rnel/linux-2.6.git/arch/sparc/kernel/traps_32.c:23:
> /home/sam/kernel/linux-2.6.git/include/linux/mm.h: In function 'is_vmallo=
c_addr':
> /home/sam/kernel/linux-2.6.git/include/linux/mm.h:301:17: error: 'VMALLOC=
_START' undeclared (first use in this function)
> /home/sam/kernel/linux-2.6.git/include/linux/mm.h:301:17: note: each unde=
clared identifier is reported only once for each function it appears in
> /home/sam/kernel/linux-2.6.git/include/linux/mm.h:301:41: error: 'VMALLOC=
_END' undeclared (first use in this function)
> /home/sam/kernel/linux-2.6.git/include/linux/mm.h: In function 'maybe_mkw=
rite':
> /home/sam/kernel/linux-2.6.git/include/linux/mm.h:483:3: error: implicit =
declaration of function 'pte_mkwrite'
>
> When I removed the include it could build again.

... and so it is. Good to know, thanks for checking!

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. Bu=
t
when I'm talking to journalists I just say "programmer" or something like t=
hat.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from parasite.irisa.fr (parasite.irisa.fr [131.254.12.47])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA03501
	for <linux-mm@kvack.org>; Mon, 16 Nov 1998 10:28:03 -0500
Subject: Re: 4M kernel pages
References: <Pine.LNX.3.96.981113150452.4593A-100000@mirkwood.dummy.home> <364FE29E.2CF14EEA@varel.bg> <wd8emr3yfeu.fsf@parate.irisa.fr> <36503F86.FC08594@varel.bg>
From: "David Mentr\\'e" <David.Mentre@irisa.fr>
Date: 16 Nov 1998 16:27:52 +0100
In-Reply-To: Petko Manolov's message of "Mon, 16 Nov 1998 17:06:46 +0200"
Message-ID: <wd8zp9rwtc7.fsf@parate.irisa.fr>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Petko Manolov <petkan@varel.bg>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



Petko Manolov <petkan@varel.bg> writes:

> Yes, i know that. I took a look at 
> linux/arch/i386/mm/init.c - paging_init().
> Yes we rise PSE bit in cr4 but don't rise the PS bit in
> the pade directory entry for the kernel - which means the
> kernel is in 4K pages.

Not exactly. 4MB pages for kernel are setted up _before_ the kernel is
started.
Look at arch/i386/kernel/head.S:


(around line 55 -- for the first CPU I suppose):

/*
 *      New page tables may be in 4Mbyte page mode and may
 *      be using the global pages. 
 *
 *      NOTE! We have to correct for the fact that we're
 *      not yet offset PAGE_OFFSET..
 */
#define cr4_bits mmu_cr4_features-__PAGE_OFFSET
        movl %cr4,%eax          # Turn on 4Mb pages
        orl cr4_bits,%eax
        movl %eax,%cr4
#endif



(around line 214 -- for other SMP CPUs I suppose):

        movb ready,%al          # First CPU if 0
        orb %al,%al
        jz 4f                   # First CPU skip this stuff
----->  movl %cr4,%eax          # Turn on 4Mb pages <------
        orl $16,%eax
        movl %eax,%cr4
        movl %cr3,%eax          # Intel specification clarification says
        movl %eax,%cr3          # to do this. Maybe it makes a difference.
                                # Who knows ?

To be honest, I'm not sure that this is done here, but I'm *sure* that
kernel uses 4Mb pages.

Best regards,
d.
-- 
 David.Mentre@irisa.fr -- http://www.irisa.fr/prive/dmentre/
 Opinions expressed here are only mine.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

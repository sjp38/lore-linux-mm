Message-ID: <3D2DE916.D4B36B80@linux-m68k.org>
Date: Thu, 11 Jul 2002 22:22:46 +0200
From: Roman Zippel <zippel@linux-m68k.org>
MIME-Version: 1.0
Subject: Re: Linux porting: problem with code in head.S
References: <20020711065743.66159.qmail@web8102.in.yahoo.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jitendra Kumar Rai <jkr_u99301@yahoo.co.in>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

Jitendra Kumar Rai wrote:

> We are porting Linux on a 32 bit RISC processor. I
> have seen code of head.S for m68k and, am in the
> process to rewrite the same for our architecture, but
> having some queries in this regard. I need your help
> in solving the queries.I have also gone through the
> same code for i386.  Brief details of architecture
> are:
> 
> It includes data & instruction caches, two independent
> MMUs for data and instruction access. It uses a five
> stage pipelined internal architecture to implement
> single cycle execution.Programmers have to take care
> of resource dependencies, and the effects of delayed
> branching, while writing the assembly programs. For
> multi cycle instructions, the pipeline is frozen for
> the required number of cycles.

I don't mind explaining the m68k head.S code, but what exactly are your
porting problems? This way it might be easier to help you (and not only
by the few people who know the m68k code).

> Q.1 : What is the purpose/meaning  of macro  #define
> L(name), for example
> 
> #define L(name) .L/**/name

Symbols starting with ".L" are local symbols. For debugging they can be
made visible this way.

> Q.2 : Could not understand the pc relative addressing
> used. How can we get the same effective address by
> writing syntax like this each time?
> (while pc is changing always)
> 
> lea     %pc@(L(phys_kernel_start)),%a0

The kernel can be located anywhere in physical memory, this makes it
position independent.

> Q.3 : Why are we doing like this:
> 
>  Save physical start address of kernel
> 
>         lea     %pc@(L(phys_kernel_start)),%a0
>         lea     %pc@(SYMBOL_NAME(_stext)),%a1
>         subl    #SYMBOL_NAME(_stext),%a1
>         movel   %a1,%a0@
> 
> Can we do like this instead of the above:
> 
>         movel   %pc,%a0@

This would result in phys_kernel_start + random offset.

> Q.4 : Why  are we doing like this:
> 
> .text
> ENTRY(_stext)
> 
>         bras    1f      /* Jump over bootinfo version numbers */
>         .....
>         .....
> 1:      jra     SYMBOL_NAME(__start)
> 
> Can we do like this instead of the above:
> 
> .text
> ENTRY(_stext)
>         jra     SYMBOL_NAME(__start)

No, this would confuse the bootloader.

> Q.5 : What is meant by
>         (1) directve used:
>         .chip 68040
> 
>         (2) %bc used in:
>         cinva %bc
> 
>         (3) purpose of: ( in mmu_engage )
>         jmp 1f:l
> 
>         (4) %pcr used in
>         move %d0, %pcr

Some assembly instruction assemble into different opcodes (depending on
the cpu).

> Q.6 : What is done by code written for
> L(mmu_engage_cleanup)
> 
> Q.7 : What is the purpose of following instruction in
> mmu_get_ptr_table_entry?
> 
>         andw    #-PTR_TABLE_SIZE,%d0
> 
> Q.8 : Why the mmu_temp_map is provided?
> 
> Q.9 : Inside mmu_engage:
>         (1) Why the address comparison is made using 1b, like
> this:
> 
>         lea     %pc@(1b),%a0
>         movel   #1b,%a1
>         /* Skip temp mappings if phys == virt */
>         cmpl    %a0,%a1
>         jeq     1f
> 
>          What is the significance of address 1b ?
> 
>         (2) Why mmu_temp_map is called 4 times? or otherwise
> why temporary mapping is provided for two pages?
> 
> Q.10 : What is the purpose of long jmp in mmu_engege?
> 
>         jmp     1f:l
> 1:      nop
> 
>         Why there is only one NOP? ( there should be two nops
> i.e. first for decode & second for fetch stage of the
> pipeline )

Basically all this code prepares the jump from physical addressing to
virtual addressing. For this the code must shortly be visible at two
locations. To really understand this code you should first understand
the m68k mmu. This code is quite complex, because it has to work for
several configurations.

> Q.11 : What are (exactly) the tasks, code in head.S is
> supposed to perform?

Doing the basic cpu setup, so it can call into normal C code, which does
the remaining setup.

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

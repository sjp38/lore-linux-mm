Message-ID: <20020711065743.66159.qmail@web8102.in.yahoo.com>
Date: Thu, 11 Jul 2002 07:57:43 +0100 (BST)
From: =?iso-8859-1?q?Jitendra=20Kumar=20Rai?= <jkr_u99301@yahoo.co.in>
Subject: Linux porting: problem with code in head.S
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello,

We are porting Linux on a 32 bit RISC processor. I
have seen code of head.S for m68k and, am in the
process to rewrite the same for our architecture, but
having some queries in this regard. I need your help
in solving the queries.I have also gone through the
same code for i386.  Brief details of architecture
are:

It includes data & instruction caches, two independent
MMUs for data and instruction access. It uses a five
stage pipelined internal architecture to implement
single cycle execution.Programmers have to take care
of resource dependencies, and the effects of delayed
branching, while writing the assembly programs. For
multi cycle instructions, the pipeline is frozen for
the required number of cycles.

Questions on head.S :(m68k)
********************

Q.1 : What is the purpose/meaning  of macro  #define
L(name), for example

#define L(name) .L/**/name  

Q.2 : Could not understand the pc relative addressing
used. How can we get the same effective address by
writing syntax like this each time? 
(while pc is changing always)

lea	%pc@(L(phys_kernel_start)),%a0	

Q.3 : Why are we doing like this:

 Save physical start address of kernel

	lea	%pc@(L(phys_kernel_start)),%a0
	lea	%pc@(SYMBOL_NAME(_stext)),%a1
	subl	#SYMBOL_NAME(_stext),%a1
	movel	%a1,%a0@

Can we do like this instead of the above:

	movel	%pc,%a0@

Q.4 : Why  are we doing like this:

.text
ENTRY(_stext)

	bras	1f	/* Jump over bootinfo version numbers */
	.....
	.....
1:	jra	SYMBOL_NAME(__start)

Can we do like this instead of the above:

.text
ENTRY(_stext)
	jra	SYMBOL_NAME(__start)

Q.5 : What is meant by 
	(1) directve used:
	.chip 68040

	(2) %bc used in: 
	cinva %bc
	
	(3) purpose of: ( in mmu_engage )
	jmp 1f:l

	(4) %pcr used in
	move %d0, %pcr

Q.6 : What is done by code written for 
L(mmu_engage_cleanup)

Q.7 : What is the purpose of following instruction in
mmu_get_ptr_table_entry?

	andw	#-PTR_TABLE_SIZE,%d0

Q.8 : Why the mmu_temp_map is provided?

Q.9 : Inside mmu_engage:
	(1) Why the address comparison is made using 1b, like
this:

	lea	%pc@(1b),%a0
	movel	#1b,%a1
	/* Skip temp mappings if phys == virt */
	cmpl	%a0,%a1
	jeq	1f

	 What is the significance of address 1b ?

	(2) Why mmu_temp_map is called 4 times? or otherwise
why temporary mapping is provided for two pages?

Q.10 : What is the purpose of long jmp in mmu_engege?

	jmp	1f:l
1:	nop

	Why there is only one NOP? ( there should be two nops
i.e. first for decode & second for fetch stage of the
pipeline )

Q.11 : What are (exactly) the tasks, code in head.S is
supposed to perform?

Thanking you,
Awaiting reply,
JK


________________________________________________________________________
Want to sell your car? advertise on Yahoo Autos Classifieds. It's Free!!
       visit http://in.autos.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

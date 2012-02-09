Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id AB9656B002C
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 01:49:58 -0500 (EST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 8 Feb 2012 23:49:57 -0700
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id DDB0FC9004B
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 01:49:54 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q196nsvU2678818
	for <linux-mm@kvack.org>; Thu, 9 Feb 2012 01:49:54 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q196npi2004688
	for <linux-mm@kvack.org>; Thu, 9 Feb 2012 01:49:54 -0500
Date: Thu, 9 Feb 2012 12:07:45 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: Re: [PATCH v10 3.3-rc2 1/9] uprobes: Install and remove
 breakpoints.
Message-ID: <20120209063745.GB16600@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120202141840.5967.39687.sendpatchset@srdronam.in.ibm.com>
 <20120202141851.5967.68000.sendpatchset@srdronam.in.ibm.com>
 <20120207171707.GA24443@linux.vnet.ibm.com>
 <CAK1hOcOd3hd31vZYw1yAVGK=gMV=vQotL1mRZkVgM=7M8mbMyw@mail.gmail.com>
 <4F3320E5.1050707@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4F3320E5.1050707@hitachi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Denys Vlasenko <vda.linux@googlemail.com>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, yrl.pp-manager.tt@hitachi.com

> 
> No, that is a meaningless operation.
> As I originally said,
> 
> > insn_get_length(insn);
> > if (insn->rex_prefix.nbytes) {
> > 	cursor = uprobe->insn + insn_offset_rex_prefix(insn);
> > 	*cursor &= 0xfe;	/* Clearing REX.B bit */
> > }
> 

I am confused by why we need to call insn_get_length(insn) before
checking insn->rex_prefix.nbytes? Is it needed.



Denys and Masami, can you please confirm if below is fine.


#ifdef CONFIG_X86_64
/*
 * If uprobe->insn doesn't use rip-relative addressing, return
 * immediately.  Otherwise, rewrite the instruction so that it accesses
 * its memory operand indirectly through a scratch register.  Set
 * uprobe->arch_info.fixups and uprobe->arch_info.rip_rela_target_address
 * accordingly.  (The contents of the scratch register will be saved
 * before we single-step the modified instruction, and restored
 * afterward.)
 *
 * We do this because a rip-relative instruction can access only a
 * relatively small area (+/- 2 GB from the instruction), and the XOL
 * area typically lies beyond that area.  At least for instructions
 * that store to memory, we can't execute the original instruction
 * and "fix things up" later, because the misdirected store could be
 * disastrous.
 *
 * Some useful facts about rip-relative instructions:
 * - There's always a modrm byte.
 * - There's never a SIB byte.
 * - The displacement is always 4 bytes.
 */
static void handle_riprel_insn(struct mm_struct *mm, struct uprobe *uprobe,
							struct insn *insn)
{
	u8 *cursor;
	u8 reg;

	if (mm->context.ia32_compat)
		return;

	uprobe->arch_info.rip_rela_target_address = 0x0;
	if (!insn_rip_relative(insn))
		return;

	/* Clear REX.b bit (extension of MODRM.rm field):
	 * we want to encode rax/rcx, not r8/r9.
	 */
	if (insn->rex_prefix.nbytes) {
		cursor = uprobe->insn + insn_offset_rex_prefix(insn);
		*cursor &= 0xfe;
	}

	/*
	 * Point cursor at the modrm byte.  The next 4 bytes are the
	 * displacement.  Beyond the displacement, for some instructions,
	 * is the immediate operand.
	 */
	cursor = uprobe->insn + insn_offset_modrm(insn);
	insn_get_length(insn);

	/*
	 * Convert from rip-relative addressing to indirect addressing
	 * via a scratch register.  Change the r/m field from 0x5 (%rip)
	 * to 0x0 (%rax) or 0x1 (%rcx), and squeeze out the offset field.
	 */
	reg = MODRM_REG(insn);
	if (reg == 0) {
		/*
		 * The register operand (if any) is either the A register
		 * (%rax, %eax, etc.) or (if the 0x4 bit is set in the
		 * REX prefix) %r8.  In any case, we know the C register
		 * is NOT the register operand, so we use %rcx (register
		 * #1) for the scratch register.
		 */
		uprobe->arch_info.fixups = UPROBES_FIX_RIP_CX;
		/* Change modrm from 00 000 101 to 00 000 001. */
		*cursor = 0x1;
	} else {
		/* Use %rax (register #0) for the scratch register. */
		uprobe->arch_info.fixups = UPROBES_FIX_RIP_AX;
		/* Change modrm from 00 xxx 101 to 00 xxx 000 */
		*cursor = (reg << 3);
	}

	/* Target address = address of next instruction + (signed) offset */
	uprobe->arch_info.rip_rela_target_address = (long)insn->length
					+ insn->displacement.value;
	/* Displacement field is gone; slide immediate field (if any) over. */
	if (insn->immediate.nbytes) {
		cursor++;
		memmove(cursor, cursor + insn->displacement.nbytes,
						insn->immediate.nbytes);
	}
	return;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

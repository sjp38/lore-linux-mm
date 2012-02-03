Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 0D1896B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 07:01:46 -0500 (EST)
Message-ID: <4F2BCCA4.7040002@hitachi.com>
Date: Fri, 03 Feb 2012 21:01:40 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH v10 3.3-rc2 1/9] uprobes: Install and remove breakpoints.
References: <20120202141840.5967.39687.sendpatchset@srdronam.in.ibm.com> <20120202141851.5967.68000.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20120202141851.5967.68000.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

(2012/02/02 23:18), Srikar Dronamraju wrote:
> 
> Changelog: (Since v9) : Use insn_offset_modrm as suggested by Masami Hiramatsu.

Would you add REX.B clearing code to handle_riprel_insn() too?
Of course, that might not happen because it's a non-effective bit,
however user can program it and pass it to uprobes.

> +static void handle_riprel_insn(struct mm_struct *mm, struct uprobe *uprobe,
> +							struct insn *insn)
> +{
> +	u8 *cursor;
> +	u8 reg;
> +
> +	if (mm->context.ia32_compat)
> +		return;
> +
> +	uprobe->arch_info.rip_rela_target_address = 0x0;
> +	if (!insn_rip_relative(insn))
> +		return;
> +

So, here you need a REX.B clearing, like below.

insn_get_length(insn);
if (insn->rex_prefix.nbytes) {
	cursor = uprobe->insn + insn_offset_rex_prefix(insn);
	*cursor &= 0xfe;	/* Clearing REX.B bit */
}


> +	/*
> +	 * Point cursor at the modrm byte.  The next 4 bytes are the
> +	 * displacement.  Beyond the displacement, for some instructions,
> +	 * is the immediate operand.
> +	 */
> +	cursor = uprobe->insn + insn_offset_modrm(insn);
> +	insn_get_length(insn);
> +
> +	/*
> +	 * Convert from rip-relative addressing to indirect addressing
> +	 * via a scratch register.  Change the r/m field from 0x5 (%rip)
> +	 * to 0x0 (%rax) or 0x1 (%rcx), and squeeze out the offset field.
> +	 */
> +	reg = MODRM_REG(insn);
> +	if (reg == 0) {
> +		/*
> +		 * The register operand (if any) is either the A register
> +		 * (%rax, %eax, etc.) or (if the 0x4 bit is set in the
> +		 * REX prefix) %r8.  In any case, we know the C register
> +		 * is NOT the register operand, so we use %rcx (register
> +		 * #1) for the scratch register.
> +		 */
> +		uprobe->arch_info.fixups = UPROBES_FIX_RIP_CX;
> +		/* Change modrm from 00 000 101 to 00 000 001. */
> +		*cursor = 0x1;
> +	} else {
> +		/* Use %rax (register #0) for the scratch register. */
> +		uprobe->arch_info.fixups = UPROBES_FIX_RIP_AX;
> +		/* Change modrm from 00 xxx 101 to 00 xxx 000 */
> +		*cursor = (reg << 3);
> +	}
> +
> +	/* Target address = address of next instruction + (signed) offset */
> +	uprobe->arch_info.rip_rela_target_address = (long)insn->length
> +					+ insn->displacement.value;
> +	/* Displacement field is gone; slide immediate field (if any) over. */
> +	if (insn->immediate.nbytes) {
> +		cursor++;
> +		memmove(cursor, cursor + insn->displacement.nbytes,
> +						insn->immediate.nbytes);
> +	}
> +	return;
> +}

Thank you,

-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

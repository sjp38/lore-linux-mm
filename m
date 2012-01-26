Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id EC9676B005C
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 08:45:49 -0500 (EST)
Message-ID: <4F215901.5020602@hitachi.com>
Date: Thu, 26 Jan 2012 22:45:37 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH v9 3.2 1/9] uprobes: Install and remove breakpoints.
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com> <20120110114831.17610.88468.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20120110114831.17610.88468.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

(2012/01/10 20:48), Srikar Dronamraju wrote:
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
> +	/*
> +	 * Point cursor at the modrm byte.  The next 4 bytes are the
> +	 * displacement.  Beyond the displacement, for some instructions,
> +	 * is the immediate operand.
> +	 */
> +	cursor = uprobe->insn + insn->prefixes.nbytes
> +			+ insn->rex_prefix.nbytes + insn->opcode.nbytes;

FYI, insn.h already provide a macro for this purpose.
You can write this as below;

	cursor = uprobe->insn + insn_offset_modrm(insn);

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

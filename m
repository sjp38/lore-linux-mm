Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 593A98D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 10:37:20 -0400 (EDT)
Date: Tue, 15 Mar 2011 15:36:59 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 6/20] 6: x86: analyze instruction and
 determine fixups.
In-Reply-To: <20110314133507.27435.71382.sendpatchset@localhost6.localdomain6>
Message-ID: <alpine.LFD.2.00.1103151529130.2787@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6> <20110314133507.27435.71382.sendpatchset@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, 14 Mar 2011, Srikar Dronamraju wrote:
> +/*
> + * TODO:
> + * - Where necessary, examine the modrm byte and allow only valid instructions
> + * in the different Groups and fpu instructions.
> + */
> +
> +static bool is_prefix_bad(struct insn *insn)
> +{
> +	int i;
> +
> +	for (i = 0; i < insn->prefixes.nbytes; i++) {
> +		switch (insn->prefixes.bytes[i]) {
> +		case 0x26:	 /*INAT_PFX_ES   */
> +		case 0x2E:	 /*INAT_PFX_CS   */
> +		case 0x36:	 /*INAT_PFX_DS   */
> +		case 0x3E:	 /*INAT_PFX_SS   */
> +		case 0xF0:	 /*INAT_PFX_LOCK */
> +			return 1;

  true
  
> +		}
> +	}
> +	return 0;

  false

> +}

> +static int validate_insn_32bits(struct uprobe *uprobe, struct insn *insn)
> +{
> +	insn_init(insn, uprobe->insn, false);
> +
> +	/* Skip good instruction prefixes; reject "bad" ones. */
> +	insn_get_opcode(insn);
> +	if (is_prefix_bad(insn)) {
> +		report_bad_prefix();
> +		return -EPERM;

-ENOTSUPP perhaps. That's not a permission problem

> +	}

> +/**
> + * analyze_insn - instruction analysis including validity and fixups.
> + * @tsk: the probed task.
> + * @uprobe: the probepoint information.
> + * Return 0 on success or a -ve number on error.
> + */
> +int analyze_insn(struct task_struct *tsk, struct uprobe *uprobe)
> +{
> +	int ret;
> +	struct insn insn;
> +
> +	uprobe->fixups = 0;
> +#ifdef CONFIG_X86_64
> +	uprobe->arch_info.rip_rela_target_address = 0x0;
> +#endif

Please get rid of this #ifdef and use inlines (empty for 32bit)

> +
> +	if (is_32bit_app(tsk))
> +		ret = validate_insn_32bits(uprobe, &insn);
> +	else
> +		ret = validate_insn_64bits(uprobe, &insn);
> +	if (ret != 0)
> +		return ret;
> +#ifdef CONFIG_X86_64

Ditto

> +	ret = handle_riprel_insn(uprobe, &insn);
> +	if (ret == -1)
> +		/* rip-relative; can't XOL */
> +		return 0;

So we return -1 from handle_riprel_insn() and return success? Btw how
deals handle_riprel_insn() with 32bit user space ?

> +#endif
> +	prepare_fixups(uprobe, &insn);
> +	return 0;

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

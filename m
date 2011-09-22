Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 565D69000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 21:06:00 -0400 (EDT)
Message-ID: <4E7A89D5.4000001@redhat.com>
Date: Wed, 21 Sep 2011 18:05:25 -0700
From: Josh Stone <jistone@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 3.1.0-rc4-tip 8/26]   x86: analyze instruction and
 determine fixups.
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20110920120127.25326.71509.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20110920120127.25326.71509.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

Hi Srikar,

I noticed that this produces a compiler warning on i686 from test_bit ->
variable_test_bit, that I think must be addressed.  It is similar to
something I fixed earlier in SystemTap's uprobes, but at that time I
didn't fully analyze the issue, so I'll attempt it now.

Masami, please note that what I describe below also happens on kprobes'
bitvector twobyte_is_boostable.


On 09/20/2011 05:01 AM, Srikar Dronamraju wrote:
[...]
> +static const u32 good_insns_64[256 / 32] = {
[...]
> +static const u32 good_insns_32[256 / 32] = {
[...]
> +static const u32 good_2byte_insns[256 / 32] = {
[...]
> +static int validate_insn_32bits(struct uprobe *uprobe, struct insn *insn)
> +{
> +	insn_init(insn, uprobe->insn, false);
> +
> +	/* Skip good instruction prefixes; reject "bad" ones. */
> +	insn_get_opcode(insn);
> +	if (is_prefix_bad(insn))
> +		return -ENOTSUPP;
> +	if (test_bit(OPCODE1(insn), (unsigned long *) good_insns_32))
> +		return 0;
> +	if (insn->opcode.nbytes == 2) {
> +		if (test_bit(OPCODE2(insn),
> +					(unsigned long *) good_2byte_insns))
> +			return 0;
> +	}
> +	return -ENOTSUPP;
> +}

gcc version 4.6.0 20110603 (Red Hat 4.6.0-10) (GCC) says:
>   CC      arch/x86/kernel/uprobes.o
> In file included from include/linux/bitops.h:22:0,
>                  from include/linux/kernel.h:17,
>                  from arch/x86/kernel/uprobes.c:24:
> /home/jistone/linux-2.6/arch/x86/include/asm/bitops.h: In function ?analyze_insn?:
> /home/jistone/linux-2.6/arch/x86/include/asm/bitops.h:319:2: warning: use of memory input without lvalue in asm operand 1 is deprecated [enabled by default]
> /home/jistone/linux-2.6/arch/x86/include/asm/bitops.h:319:2: warning: use of memory input without lvalue in asm operand 1 is deprecated [enabled by default]

That's from variable_test_bit, whose second argument is volatile const
unsigned long *, then referenced with asm "m" (*(unsigned long *)addr).

The fix I used in SystemTap's case was to make the bitvectors volatile
as well.  But now I want to better know *why* this fix works.  There's
no real difference in code-gen:

> @@ -91,8 +91,8 @@ Disassembly of section .text:
>    63:	90                   	nop
>    64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
>    68:	0f b6 45 bc          	movzbl -0x44(%ebp),%eax
> -  6c:	0f a3 05 00 00 00 00 	bt     %eax,0x0
> -			6f: R_386_32	.rodata.cst4
> +  6c:	0f a3 05 20 00 00 00 	bt     %eax,0x20
> +			6f: R_386_32	.data
>    73:	19 c0                	sbb    %eax,%eax
>    75:	85 c0                	test   %eax,%eax
>    77:	75 1c                	jne    95 <analyze_insn+0x95>
> @@ -100,8 +100,8 @@ Disassembly of section .text:
>    7d:	b8 f4 fd ff ff       	mov    $0xfffffdf4,%eax
>    82:	75 d9                	jne    5d <analyze_insn+0x5d>
>    84:	0f b6 55 bd          	movzbl -0x43(%ebp),%edx
> -  88:	0f a3 15 04 00 00 00 	bt     %edx,0x4
> -			8b: R_386_32	.rodata.cst4
> +  88:	0f a3 15 00 00 00 00 	bt     %edx,0x0
> +			8b: R_386_32	.data
>    8f:	19 d2                	sbb    %edx,%edx
>    91:	85 d2                	test   %edx,%edx
>    93:	74 c8                	je     5d <analyze_insn+0x5d>

The volatile makes the bitvectors move from .rodata to .data, not all
that surprising, I guess.  Then I figured out that the former case only
has the first word of good_insns_32 and good_2byte_insns, where the
latter volatile case keeps the whole thing.

as-is:
> Contents of section .rodata.cst4:
>  0000 7f7f7f7f 00c0fffe                    ........

with volatile:
> Contents of section .data:
>  0000 00c0fffe 0fff0e00 ffffffff ffffffc0  ................
>  0010 ffffffff 3fbffffe fffffeff fffffe7f  ....?...........
>  0020 7f7f7f7f bfbfbfbf ffffffff 370fffff  ............7...
>  0030 ffffffff ffffffff ff0fbfff 0f0fecf3  ................
>  0040 3f3f3f3f 3f3f3f3f 0000ffff 380fffff  ????????....8...
>  0050 fbffffff ffffffff cf0f8fff 0f0fecf3  ................

So declaring the bitvectors volatile makes gcc to keep them around in
full.  Otherwise it apparently looks to gcc like only the first word is
used by variable_test_bit's asm statement.

On x86_64, the warning doesn't appear, and even in .rodata the
bitvectors appear in full.  I'm guessing that the pointer aliasing from
u32* to a 64-bit unsigned long* makes gcc forgo the data elision.

I wonder if variable_test_bit() could/should force aliasing to fix this
for all callers.  But for now, marking volatile does the trick.

Thanks,
Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

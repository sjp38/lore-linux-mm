Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id BAED36B004D
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 10:13:52 -0500 (EST)
Received: by wera13 with SMTP id a13so3023629wer.14
        for <linux-mm@kvack.org>; Wed, 25 Jan 2012 07:13:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120110114831.17610.88468.sendpatchset@srdronam.in.ibm.com>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com> <20120110114831.17610.88468.sendpatchset@srdronam.in.ibm.com>
From: Denys Vlasenko <vda.linux@googlemail.com>
Date: Wed, 25 Jan 2012 16:13:29 +0100
Message-ID: <CAK1hOcO3pz+zBLQKfdty3UwQG8zxXwBWo9euFaE+zKawiqTE2g@mail.gmail.com>
Subject: Re: [PATCH v9 3.2 1/9] uprobes: Install and remove breakpoints.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Tue, Jan 10, 2012 at 12:48 PM, Srikar Dronamraju
<srikar@linux.vnet.ibm.com> wrote:
> +/*
> + * If uprobe->insn doesn't use rip-relative addressing, return
> + * immediately. =A0Otherwise, rewrite the instruction so that it accesse=
s
> + * its memory operand indirectly through a scratch register. =A0Set
> + * uprobe->arch_info.fixups and uprobe->arch_info.rip_rela_target_addres=
s
> + * accordingly. =A0(The contents of the scratch register will be saved
> + * before we single-step the modified instruction, and restored
> + * afterward.)
> + *
> + * We do this because a rip-relative instruction can access only a
> + * relatively small area (+/- 2 GB from the instruction), and the XOL
> + * area typically lies beyond that area. =A0At least for instructions
> + * that store to memory, we can't execute the original instruction
> + * and "fix things up" later, because the misdirected store could be
> + * disastrous.
> + *
> + * Some useful facts about rip-relative instructions:
> + * - There's always a modrm byte.
> + * - There's never a SIB byte.
> + * - The displacement is always 4 bytes.
> + */
> +static void handle_riprel_insn(struct mm_struct *mm, struct uprobe *upro=
be,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct insn *insn)
> +{
> + =A0 =A0 =A0 u8 *cursor;
> + =A0 =A0 =A0 u8 reg;
> +
> + =A0 =A0 =A0 if (mm->context.ia32_compat)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 uprobe->arch_info.rip_rela_target_address =3D 0x0;
> + =A0 =A0 =A0 if (!insn_rip_relative(insn))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Point cursor at the modrm byte. =A0The next 4 bytes ar=
e the
> + =A0 =A0 =A0 =A0* displacement. =A0Beyond the displacement, for some ins=
tructions,
> + =A0 =A0 =A0 =A0* is the immediate operand.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 cursor =3D uprobe->insn + insn->prefixes.nbytes
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 + insn->rex_prefix.nbytes +=
 insn->opcode.nbytes;
> + =A0 =A0 =A0 insn_get_length(insn);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Convert from rip-relative addressing to indirect addre=
ssing
> + =A0 =A0 =A0 =A0* via a scratch register. =A0Change the r/m field from 0=
x5 (%rip)
> + =A0 =A0 =A0 =A0* to 0x0 (%rax) or 0x1 (%rcx), and squeeze out the offse=
t field.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 reg =3D MODRM_REG(insn);
> + =A0 =A0 =A0 if (reg =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* The register operand (if any) is eithe=
r the A register
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* (%rax, %eax, etc.) or (if the 0x4 bit =
is set in the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* REX prefix) %r8. =A0In any case, we kn=
ow the C register
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* is NOT the register operand, so we use=
 %rcx (register
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* #1) for the scratch register.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 uprobe->arch_info.fixups =3D UPROBES_FIX_RI=
P_CX;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Change modrm from 00 000 101 to 00 000 0=
01. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *cursor =3D 0x1;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Use %rax (register #0) for the scratch r=
egister. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 uprobe->arch_info.fixups =3D UPROBES_FIX_RI=
P_AX;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Change modrm from 00 xxx 101 to 00 xxx 0=
00 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *cursor =3D (reg << 3);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Target address =3D address of next instruction + (signed=
) offset */
> + =A0 =A0 =A0 uprobe->arch_info.rip_rela_target_address =3D (long)insn->l=
ength
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 + insn->displacement.value;
> + =A0 =A0 =A0 /* Displacement field is gone; slide immediate field (if an=
y) over. */
> + =A0 =A0 =A0 if (insn->immediate.nbytes) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cursor++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memmove(cursor, cursor + insn->displacement=
.nbytes,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 insn->immediate.nbytes);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return;
> +}

It seems to be possible to store RIP value *without displacement*
into AX/CX and convert rip-relative instruction into AX/CX *relative* one.
Example:
c7 05 78 56 34 12 2a 00 00 00 	movl   $0x2a,0x12345678(%rip)
converts to:
c7 81 78 56 34 12 2a 00 00 00 	movl   $0x2a,0x12345678(%rcx)

This way instruction size stays the same and you don't need
to memmove immediate value.

--=20
vda

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

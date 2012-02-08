Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id F2AD96B13F0
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 04:40:51 -0500 (EST)
Received: by wgbdt12 with SMTP id dt12so264922wgb.26
        for <linux-mm@kvack.org>; Wed, 08 Feb 2012 01:40:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120207171707.GA24443@linux.vnet.ibm.com>
References: <20120202141840.5967.39687.sendpatchset@srdronam.in.ibm.com>
 <20120202141851.5967.68000.sendpatchset@srdronam.in.ibm.com> <20120207171707.GA24443@linux.vnet.ibm.com>
From: Denys Vlasenko <vda.linux@googlemail.com>
Date: Wed, 8 Feb 2012 10:40:30 +0100
Message-ID: <CAK1hOcOd3hd31vZYw1yAVGK=gMV=vQotL1mRZkVgM=7M8mbMyw@mail.gmail.com>
Subject: Re: [PATCH v10 3.3-rc2 1/9] uprobes: Install and remove breakpoints.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Tue, Feb 7, 2012 at 6:17 PM, Srikar Dronamraju
<srikar@linux.vnet.ibm.com> wrote:
> Changelog: (Since v10): Add code to clear REX.B prefix pointed out by Den=
ys Vlasenko
> and fix suggested by Masami Hiramatsu.
...
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Point cursor at the modrm byte. =A0The next 4 bytes ar=
e the
> + =A0 =A0 =A0 =A0* displacement. =A0Beyond the displacement, for some ins=
tructions,
> + =A0 =A0 =A0 =A0* is the immediate operand.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 cursor =3D uprobe->insn + insn_offset_modrm(insn);
> + =A0 =A0 =A0 insn_get_length(insn);
> + =A0 =A0 =A0 if (insn->rex_prefix.nbytes)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *cursor &=3D 0xfe; =A0 =A0 =A0 =A0/* Cleari=
ng REX.B bit */

It looks like cursor points to mod/reg/rm byte, not rex byte.
Comment above says it too. You seem to be clearing a bit
in a wrong byte. I think it should be

        /* Clear REX.b bit (extension of MODRM.rm field):
         * we want to encode rax/rcx, not r8/r9.
         */
        if (insn->rex_prefix.nbytes)
                insn->rex_prefix.bytes[0] &=3D 0xfe;

--=20
vda

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

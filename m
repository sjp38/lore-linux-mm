Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 40EE46B0082
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 08:58:35 -0400 (EDT)
Subject: Re: [PATCH v4 3.0-rc2-tip 2/22]  2: uprobes: Breakground page
 replacement.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110613085955.GD27130@linux.vnet.ibm.com>
References: 
	 <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
	 <20110607125835.28590.25476.sendpatchset@localhost6.localdomain6>
	 <1307660609.2497.1773.camel@laptop>
	 <20110613085955.GD27130@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 14 Jun 2011 14:57:29 +0200
Message-ID: <1308056249.19856.34.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, 2011-06-13 at 14:29 +0530, Srikar Dronamraju wrote:
> * Peter Zijlstra <peterz@infradead.org> [2011-06-10 01:03:29]:
>=20
> > On Tue, 2011-06-07 at 18:28 +0530, Srikar Dronamraju wrote:
> > > +       vaddr_old =3D kmap_atomic(old_page, KM_USER0);
> > > +       vaddr_new =3D kmap_atomic(new_page, KM_USER1);
> > > +
> > > +       memcpy(vaddr_new, vaddr_old, PAGE_SIZE);
> > > +       /* poke the new insn in, ASSUMES we don't cross page boundary=
 */
> > > +       addr =3D vaddr;
> > > +       vaddr &=3D ~PAGE_MASK;
> > > +       memcpy(vaddr_new + vaddr, &opcode, uprobe_opcode_sz);
> > > +
> > > +       kunmap_atomic(vaddr_new);
> > > +       kunmap_atomic(vaddr_old);=20
> >=20
> >=20
> > > +       vaddr_new =3D kmap_atomic(page, KM_USER0);
> > > +       vaddr &=3D ~PAGE_MASK;
> > > +       memcpy(opcode, vaddr_new + vaddr, uprobe_opcode_sz);
> > > +       kunmap_atomic(vaddr_new);
> > >=20
>=20
>=20
> >=20
> > Both sequences in resp {write,read}_opcode() assume the opcode doesn't
> > cross page boundaries but don't in fact have any assertions validating
> > this assumption.
> >=20
>=20
> read_opcode and write_opcode reads/writes just one breakpoint instruction
> I had the below note just above the write_opcode definition.
>=20
> /*
>  * NOTE:
>  * Expect the breakpoint instruction to be the smallest size instruction =
for
>  * the architecture. If an arch has variable length instruction and the
>  * breakpoint instruction is not of the smallest length instruction
>  * supported by that architecture then we need to modify read_opcode /
>  * write_opcode accordingly. This would never be a problem for archs that
>  * have fixed length instructions.
>  */

Whoever reads comments anyway? :-)

> Do we have archs which have a breakpoint instruction which isnt of the
> smallest instruction size for that arch. If we do have can we change the
> write_opcode/read_opcode while we support that architecture?

Why not put a simple WARN_ON_ONCE() in there that checks the assumption?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

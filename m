Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3D1266B0069
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 05:53:04 -0500 (EST)
Message-ID: <1322563948.2921.199.camel@twins>
Subject: Re: [PATCH v7 3.2-rc2 3/30] uprobes: register/unregister probes.
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 29 Nov 2011 11:52:28 +0100
In-Reply-To: <20111129074807.GA13445@linux.vnet.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	 <20111118110713.10512.9461.sendpatchset@srdronam.in.ibm.com>
	 <1322494194.2921.147.camel@twins>
	 <20111129074807.GA13445@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

On Tue, 2011-11-29 at 13:18 +0530, Srikar Dronamraju wrote:
> * Peter Zijlstra <peterz@infradead.org> [2011-11-28 16:29:54]:
>=20
> > On Fri, 2011-11-18 at 16:37 +0530, Srikar Dronamraju wrote:
> > > +static void __unregister_uprobe(struct inode *inode, loff_t offset,
> > > +                                               struct uprobe *uprobe=
)
> > > +{
> > > +       struct list_head try_list;
> > > +       struct address_space *mapping;
> > > +       struct vma_info *vi, *tmpvi;
> > > +       struct vm_area_struct *vma;
> > > +       struct mm_struct *mm;
> > > +       loff_t vaddr;
> > > +
> > > +       mapping =3D inode->i_mapping;
> > > +       INIT_LIST_HEAD(&try_list);
> > > +       while ((vi =3D find_next_vma_info(&try_list, offset,
> > > +                                               mapping, false)) !=3D=
 NULL) {
> > > +               if (IS_ERR(vi))
> > > +                       break;
> >=20
> > So what kind of half-assed state are we left in if we try an unregister
> > under memory pressure and how do we deal with that?
> >=20
>=20
> Agree, Even I had this concern and wanted to see if there are ways to
> deal with this.

If you do have this, please mention it in the Changelog and/or put /*
XXX */ in the code or so to point it out that there's a problem here.

> Do you have any other approaches that we could try?

You could use the stuff from patch 29 to effectively disable the uprobe
and return -ENOMEM to whoemever is unregistering. Basically failing the
unreg.

That way you can leave the uprobe in existance and half installed but
functionally fully disabled. Userspace (assuming we go back that far)
can then either re-try the removal later, or even reinstate it by doing
a register again or so.

Its still not pretty, but its better than pretending the unreg
completed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

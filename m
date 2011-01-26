Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 23B8C6B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 05:16:32 -0500 (EST)
Subject: Re: [RFC] [PATCH 2.6.37-rc5-tip 14/20] 14: uprobes: Handing int3
 and singlestep exception.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110126085203.GG19725@linux.vnet.ibm.com>
References: 
	 <20101216095714.23751.52601.sendpatchset@localhost6.localdomain6>
	 <20101216095957.23751.57040.sendpatchset@localhost6.localdomain6>
	 <1295963779.28776.1059.camel@laptop>
	 <20110126085203.GG19725@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 26 Jan 2011 11:17:11 +0100
Message-ID: <1296037031.28776.1146.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2011-01-26 at 14:22 +0530, Srikar Dronamraju wrote:
> * Peter Zijlstra <peterz@infradead.org> [2011-01-25 14:56:19]:
>=20
> > On Thu, 2010-12-16 at 15:29 +0530, Srikar Dronamraju wrote:
> > > +               down_read(&mm->mmap_sem);
> > > +               for (vma =3D mm->mmap; vma; vma =3D vma->vm_next) {
> > > +                       if (!valid_vma(vma))
> > > +                               continue;
> > > +                       if (probept < vma->vm_start || probept > vma-=
>vm_end)
> > > +                               continue;
> > > +                       u =3D find_uprobe(vma->vm_file->f_mapping->ho=
st,
> > > +                                       probept - vma->vm_start);
> > > +                       if (u)
> > > +                               break;
> > > +               }
> > > +               up_read(&mm->mmap_sem);=20
> >=20
> > One has to ask, what's wrong with find_vma() ?
>=20
> Are you looking for something like this.
>=20
>        down_read(&mm->mmap_sem);
> 	for (vma =3D find_vma(mm, probept); ; vma =3D vma->vm_next) {
> 	       if (!valid_vma(vma))
> 		       continue;
> 	       u =3D find_uprobe(vma->vm_file->f_mapping->host,
> 			       probept - vma->vm_start);
> 	       if (u)
> 		       break;
>        }
>        up_read(&mm->mmap_sem);=20

How could you ever need to iterate here? There is only a single vma that
covers the probe point, if that doesn't find a uprobe, there isn't any.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

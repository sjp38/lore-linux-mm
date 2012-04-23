Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id ED3686B004D
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 03:41:00 -0400 (EDT)
Message-ID: <1335166842.28150.92.camel@twins>
Subject: Re: [RFC 0/6] uprobes: kill uprobes_srcu/uprobe_srcu_id
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 23 Apr 2012 09:40:42 +0200
In-Reply-To: <20120423072445.GC8357@linux.vnet.ibm.com>
References: <20120414205200.GA9083@redhat.com>
	 <1334487062.2528.113.camel@twins> <20120415195351.GA22095@redhat.com>
	 <1334526513.28150.23.camel@twins> <20120415234401.GA32662@redhat.com>
	 <1334571419.28150.30.camel@twins> <20120416214707.GA27639@redhat.com>
	 <1334916861.2463.50.camel@laptop> <20120420183718.GA2236@redhat.com>
	 <1335165240.28150.89.camel@twins>
	 <20120423072445.GC8357@linux.vnet.ibm.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On Mon, 2012-04-23 at 12:54 +0530, Srikar Dronamraju wrote:
> * Peter Zijlstra <peterz@infradead.org> [2012-04-23 09:14:00]:
>=20
> > On Fri, 2012-04-20 at 20:37 +0200, Oleg Nesterov wrote:
> > > Say, a user wants to probe /sbin/init only. What if init forks?
> > > We should remove breakpoints from child->mm somehow.=20
> >=20
> > How is that hard? dup_mmap() only copies the VMAs, this doesn't actuall=
y
> > copy the breakpoint. So the child doesn't have a breakpoint to be
> > removed.
> >=20
>=20
> Because the pages are COWED, the breakpoint gets copied over to the
> child. If we dont want the breakpoints to be not visible to the child,
> then we would have to remove them explicitly based on the filter (i.e if
> and if we had inserted breakpoints conditionally based on filter).=20

I thought we didn't COW shared maps since the fault handler will fill in
the pages right and only anon stuff gets copied.

> Once we add the conditional breakpoint insertion (which is tricky),

How so?

>  we have
> to support conditional breakpoint removal in the dup_mmap() thro the
> uprobe_mmap hook (which I think is not that hard).  Conditional removal
> of breakpoints in fork path would just be an extension of the
> conditional breakpoint insertion.

Right, I don't think that removal is particularly hard if needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

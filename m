Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A4FE0900087
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 06:58:54 -0400 (EDT)
Subject: Re: [PATCH v3 2.6.39-rc1-tip 12/26] 12: uprobes: slot allocation
 for uprobes
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110419062654.GB10698@linux.vnet.ibm.com>
References: 
	 <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
	 <20110401143457.15455.64839.sendpatchset@localhost6.localdomain6>
	 <1303145171.32491.886.camel@twins>
	 <20110419062654.GB10698@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 19 Apr 2011 11:11:48 +0200
Message-ID: <1303204308.32491.923.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: James Morris <jmorris@namei.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

(Dropped the systemtap list since its mis-behaving, please leave it out on =
future postings)

On Tue, 2011-04-19 at 11:56 +0530, Srikar Dronamraju wrote:
> > > TODO: On massively threaded processes (or if a huge number of process=
es
> > > share the same mm), there is a possiblilty of running out of slots.
> > > One alternative could be to extend the slots as when slots are requir=
ed.
> >=20
> > As long as you're single stepping things and not using boosted probes
> > you can fully serialize the slot usage. Claim a slot on trap and releas=
e
> > the slot on finish. Claiming can wait on a free slot since you already
> > have the whole SLEEPY thing.
> >=20
>=20
> Yes, thats certainly one approach but that approach makes every
> breakpoint hit contend for spinlock. (Infact we will have to change it
> to mutex lock (as you rightly pointed out) so that we allow threads to
> wait when slots are not free). Assuming a 4K page, we would be taxing
> applications that have less than 32 threads (which is probably the
> default case). If we continue with the current approach, then we
> could only add additional page(s) for apps which has more than 32
> threads and only when more than 32 __live__ threads have actually hit a
> breakpoint.=20

That very much depends on what you do, some folks think its entirely
reasonable for processes to have thousands of threads. Now I completely
agree with you that that is not 'normal', but then I think using Java
isn't normal either ;-)

Anyway, avoiding that spinlock/mutex for each trap isn't hard, avoiding
a process wide cacheline bounce is slightly harder but still not
impossible.=20

With 32 slots in 4k you have 128 bytes to play with, all we need is a
single bit per slot to mark it being in-use. If a task remembers what
slot it used last and tries to claim that using an atomic test and set
for that bit it will, in the 'normal' case, never contend on a process
wide cacheline.

In case it does find the slot taken, it'll have to go the slow route and
scan for a free slot and possibly wait for one to become free.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

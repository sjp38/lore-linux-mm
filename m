Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6056B00E8
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 05:19:57 -0500 (EST)
Subject: Re: [RFC] [PATCH 2.6.37-rc5-tip 8/20]  8: uprobes: mmap and fork
 hooks.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110126090346.GH19725@linux.vnet.ibm.com>
References: 
	 <20101216095714.23751.52601.sendpatchset@localhost6.localdomain6>
	 <20101216095848.23751.73144.sendpatchset@localhost6.localdomain6>
	 <1295957739.28776.717.camel@laptop>
	 <20110126090346.GH19725@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 26 Jan 2011 11:20:39 +0100
Message-ID: <1296037239.28776.1149.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2011-01-26 at 14:33 +0530, Srikar Dronamraju wrote:
>=20
>=20
> I actually dont like to release the write_lock and then reacquire it.
> write_opcode, which is called thro install_uprobe, i.e to insert the
> actual breakpoint instruction takes a read lock on the mmap_sem.
> Hence uprobe_mmap gets called in context with write lock on mmap_sem
> held, I had to release it before calling install_uprobe.=20

Ah, right, so that's going to give you a head-ache ;-)

The moment you release this mmap_sem, the map you're going to install
the probe point in can go away.

The only way to make this work seems to start by holding the mmap_sem
for writing and make a breakpoint install function that assumes its
taken and doesn't try to acquire it again.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

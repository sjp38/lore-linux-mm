Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EE4266B004D
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 07:26:00 -0500 (EST)
Message-ID: <1322655933.2921.271.camel@twins>
Subject: Re: [PATCH v7 3.2-rc2 4/30] uprobes: Define hooks for mmap/munmap.
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 30 Nov 2011 13:25:33 +0100
In-Reply-To: <20111129162237.GA18380@linux.vnet.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	 <20111118110723.10512.66282.sendpatchset@srdronam.in.ibm.com>
	 <1322071812.14799.87.camel@twins>
	 <20111124134742.GH28065@linux.vnet.ibm.com>
	 <1322492384.2921.143.camel@twins>
	 <20111129083322.GD13445@linux.vnet.ibm.com>
	 <1322567326.2921.226.camel@twins>
	 <20111129162237.GA18380@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>, tulasidhard@gmail.com

On Tue, 2011-11-29 at 21:52 +0530, Srikar Dronamraju wrote:
> The rules that I am using are:=20
>=20
> mmap_uprobe() increments the count if=20
>         - it successfully adds a breakpoint.
>         - it not add a breakpoint, but sees that there is a underlying
>           breakpoint (via a read_opcode call).
>=20
> munmap_uprobe() decrements the count if=20
>         - it sees a underlying breakpoint,  (via  a read_opcode call)
>         - Subsequent unregister_uprobe wouldnt find the breakpoint
>           unless a mmap_uprobe kicks in, since the old vma would be
>           dropped just after munmap_uprobe.
>=20
> register_uprobe increments the count if:
>         - it successfully adds a breakpoint.
>=20
> unregister_uprobe decrements the count if:
>         - it sees a underlying breakpoint and removes successfully.=20
>                         (via a read_opcode call)
>         - Subsequent munmap_uprobe wouldnt find the breakpoint
>           since there is no underlying breakpoint after the
>           breakpoint removal.=20

The problem I'm having is that such stuff isn't included in the patch
set.

We've got both comments in the C language and Changelog in our patch
system, yet you consistently fail to use either to convey useful
information on non-trivial bits like this.

This leaves the reviewer wondering if you've actually considered stuff
properly, then me actually finding bugs in there does of course
undermine that even further.

What I really would like is for this patch set not to have such subtle
stuff at all, esp. at first. Once its in and its been used a bit we can
start optimizing and add subtle crap like this.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

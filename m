Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 04EDC6B0098
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 11:35:07 -0500 (EST)
Message-ID: <1322152478.2921.68.camel@twins>
Subject: Re: Fwd: uprobes: register/unregister probes.
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 24 Nov 2011 17:34:38 +0100
In-Reply-To: <20111124145139.GK28065@linux.vnet.ibm.com>
References: <hYuXv-26J-3@gated-at.bofh.it> <hYuXw-26J-5@gated-at.bofh.it>
	 <i0nRU-7eK-11@gated-at.bofh.it>
	 <603b0079-5f54-4299-9a9a-a5e237ccca73@l23g2000pro.googlegroups.com>
	 <20111124070303.GB28065@linux.vnet.ibm.com> <1322128199.2921.3.camel@twins>
	 <20111124145139.GK28065@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, tulasidhard@gmail.com

On Thu, 2011-11-24 at 20:21 +0530, Srikar Dronamraju wrote:
> > No you don't, you check the return value of igrab(), but you crash hard
> > when someone calls register_uprobe(.inode=3DNULL).
> >=20
>=20
> Okay. will add a check for inode before we do the igrab.=20

No!!! its fcking pointless calling this function without a valid inode
argument, don't mess about and try and deal with it.

Same with the consumer thing, if you call it with a NULL consumer you're
an idiot, try memcpy(NULL, foo, size), does that return -EINVAL?

Also, what's the point of all this igrab() nonsense? We don't need extra
references on the inode, the caller of these functions had better made
sure the inode is stable and good to use, otherwise it could be freed
before we do igrab() and we'd still crash.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

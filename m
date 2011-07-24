Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 531996B00EE
	for <linux-mm@kvack.org>; Sun, 24 Jul 2011 14:10:15 -0400 (EDT)
Date: Sun, 24 Jul 2011 20:07:13 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 4/22]  4: Uprobes: register/unregister
	probes.
Message-ID: <20110724180713.GA24599@redhat.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6> <20110607125900.28590.16071.sendpatchset@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110607125900.28590.16071.sendpatchset@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

Hi Srikar,

I still hope some day I'll find the time to read the whole series ;)
Trying to continue from where I have stopped, and it seems that this
patch has a couple more problems.

On 06/07, Srikar Dronamraju wrote:
>
> A probe is specified by a file:offset.  While registering, a breakpoint
> is inserted for the first consumer, On subsequent probes, the consumer
> gets appended to the existing consumers. While unregistering a
> breakpoint is removed if the consumer happens to be the last consumer.
> All other unregisterations, the consumer is deleted from the list of
> consumers.
>
> Probe specifications are maintained in a rb tree. A probe specification
> is converted into a uprobe before store in a rb tree.  A uprobe can be
> shared by many consumers.

register/unregister logic looks racy...

Supose that uprobe U has a single consumer C and register_uprobe()
is called with the same inode/offset, while another thread does
unregister(U,C).

	- register() calls alloc_uprobe(), finds the entry in rb tree,
	  and increments U->ref. But this doesn't add the new consumer.

	- uregister() does del_consumer(), and removes the single
	  consumer C.

	  then it takes uprobes_mutex, sees uprobe->consumers == NULL
	  and calls delete_uprobe()->rb_erase()

	- register() continues, takes uprobes_mutex, re-inserts the
	  breakpoints, finds the new consumer and succeeds.

	  However, this uprobe is not in rb-tree, it was deleted
	  by unregister.



OTOH. Suppose we add the new uprobe. register()->alloc_uprobe() sets
new_uprobe->ref == 2. If something goes wrong after that, register()
does delete_uprobe() + put_uprobe(), new_uprobe->ref becomes 1 and
we leak this uprobe.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7D7106B0082
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 11:43:08 -0400 (EDT)
Date: Tue, 14 Jun 2011 17:40:52 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 2/22]  2: uprobes: Breakground page
	replacement.
Message-ID: <20110614154052.GA22082@redhat.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6> <20110607125835.28590.25476.sendpatchset@localhost6.localdomain6> <20110613170020.GA27137@redhat.com> <1308056477.19856.35.camel@twins> <20110614142710.GB5139@redhat.com> <1308064053.19856.75.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1308064053.19856.75.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On 06/14, Peter Zijlstra wrote:
>
> On Tue, 2011-06-14 at 16:27 +0200, Oleg Nesterov wrote:
> > On 06/14, Peter Zijlstra wrote:
> > >
> > > On Mon, 2011-06-13 at 19:00 +0200, Oleg Nesterov wrote:
> > > >
> > > > Also. This is called under down_read(mmap_sem), can't we race with
> > > > access_process_vm() modifying the same memory?
> > >
> > > Shouldn't matter COW and similar things are serialized using the pte
> > > lock.
> >
> > Yes, but afaics this doesn't matter. Suppose that write_opcode() is
> > called when access_process_vm() does copy_to_user_page(). We can cow
> > the page before memcpy() completes.
>
> access_process_vm() will end up doing a FOLL_WRITE itself when
> copy_to_user_page() is called since write=1 in that case.
>
> At that point we have a COW-race, someone wins, but the other will then
> return the same page.
>
> At this point further PTRACE pokes can indeed race with the memcpy in
> write_opcode().

Currently it can't, write_opcode() does another cow. But that cow can,
and this is the same, yes.

> A possible fix would be to lock_page() around
> copy_to_user_page() (its already done in set_page_dirty_lock(), so
> pulling it out shouldn't matter much).

Yes, or write_opcode() could take mmap_sem for writing as Srikar suggests.

But do we really care? Whatever we do we can race with the other updates
to this memory. Say, someone can write to vma->vm_file.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

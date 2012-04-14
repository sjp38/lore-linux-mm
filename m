Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 8BEEF6B004A
	for <linux-mm@kvack.org>; Sat, 14 Apr 2012 16:52:54 -0400 (EDT)
Date: Sat, 14 Apr 2012 22:52:00 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC 0/6] uprobes: kill uprobes_srcu/uprobe_srcu_id
Message-ID: <20120414205200.GA9083@redhat.com>
References: <20120405222024.GA19154@redhat.com> <1334409396.2528.100.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1334409396.2528.100.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On 04/14, Peter Zijlstra wrote:
>
> On Fri, 2012-04-06 at 00:20 +0200, Oleg Nesterov wrote:
> > Hello.
> >
> > Not for inclusion yet, only for the early review.
> >
> > I didn't even try to test these changes, and I am not expert
> > in this area. And even _if_ this code is correct, I need to
> > re-split these changes anyway, update the changelogs, etc.
> >
> > Questions:
> >
> > 	- does it make sense?
>
> Maybe, upside is reclaiming that int from task_struct, downside is that
> down_write :/ It would be very good not to have to do that.

Yes, down_write() is pessimization, I agree.

> Nor do I
> really see how that works.
>
> > 	- can it work or I missed something "in general" ?
>
> So we insert in the rb-tree before we take mmap_sem, this means we can
> hit a non-uprobe int3 and still find a uprobe there, no?

Yes, but unless I miss something this is "off-topic", this
can happen with or without these changes. If find_uprobe()
succeeds we assume that this bp was inserted by uprobe.

Perhaps uprobe_register() should not "ignore" -EXIST from
install_breakpoint()->is_swbp_insn(), or perhaps we can
add UPROBE_SHARED_BP.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

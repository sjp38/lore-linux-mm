Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 76F706B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 13:56:57 -0400 (EDT)
Date: Wed, 15 Jun 2011 19:54:55 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 2/22]  2: uprobes: Breakground page
	replacement.
Message-ID: <20110615175455.GB12652@redhat.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6> <20110607125835.28590.25476.sendpatchset@localhost6.localdomain6> <20110613170020.GA27137@redhat.com> <20110614123530.GC4952@linux.vnet.ibm.com> <20110614142023.GA5139@redhat.com> <20110615085515.GE4952@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110615085515.GE4952@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On 06/15, Srikar Dronamraju wrote:
>
> > > > > +
> > > > > +	/* Read the page with vaddr into memory */
> > > > > +	ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 1, 1, &old_page, &vma);
> > > >
> > > > Sorry if this was already discussed... But why we are using FOLL_WRITE here?
> > > > We are not going to write into this page, and this provokes the unnecessary
> > > > cow, no?
> > >
> > > Yes, We are not going to write to the page returned by get_user_pages
> > > but a copy of that page.
> >
> > Yes I see. But the page returned by get_user_pages(write => 1) is already
> > a cow'ed copy (this mapping should be read-only).
> >
> > > The idea was if we cow the page then we dont
> > > need to cow it at the replace_page time
> >
> > Yes, replace_page() shouldn't cow.
> >
> > > and since get_user_pages knows
> > > the right way to cow the page, we dont have to write another routine to
> > > cow the page.
> >
> > Confused. write_opcode() allocs another page and does memcpy. This is
> > correct, but I don't understand the first cow.
> >
>
> we decided on get_user_pages(FOLL_WRITE|FOLL_FORCE) based on discussions
> in these threads https://lkml.org/lkml/2010/4/23/327 and
> https://lkml.org/lkml/2010/5/12/119

Failed to Connect.

> Summary of those two sub-threads as I understand was to have
> get_user_pages do the "real" cow for us.
>
> If I understand correctly, your concern is on the extra overhead added
> by the get_user_pages.

No. My main concern is that I do not understand why do we need an extra cow.
This is fine, I am not vm expert. But I think it is not fine that you can't
explain why your code needs it ;)

What this 'get_user_pages do the "real" cow for us' actually means? It does
not do cow for us, __replace_page() does the actual/final cow. It re-installs
the modified copy of the page returned by get_user_pages() at the same pte.

> > Probably I missed something... but could you please explain why we can't
> >
> > 	- ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 1, 1, &old_page, &vma);
> > 	+ ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 0, 0, &old_page, &vma);
> >
> > ?
>
> I tried the code with this change and it works for regular cases.
> I am not sure if it affects cases where programs do mprotect

Hmm... How can mprotect make a difference? This mapping should be read
only, and we are not going to do pte_mkwrite.

> So I am okay to not force cow through get_user_pages.

I am okay either way ;) But, imho, if we use FOLL_WRITE|FOLL_FORCE then
it would be nice to document why it this needed.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

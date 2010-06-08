Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 440796B01DD
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 16:15:32 -0400 (EDT)
Date: Tue, 8 Jun 2010 22:14:03 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch 02/18] oom: introduce find_lock_task_mm() to fix !mm
	false positives
Message-ID: <20100608201403.GA10264@redhat.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061521310.32225@chino.kir.corp.google.com> <20100608124246.9258ccab.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100608124246.9258ccab.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 06/08, Andrew Morton wrote:
>
> On Sun, 6 Jun 2010 15:34:03 -0700 (PDT)
> David Rientjes <rientjes@google.com> wrote:
>
> > [kosaki.motohiro@jp.fujitsu.com: use in badness(), __oom_kill_task()]
> > Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> > Signed-off-by: David Rientjes <rientjes@google.com>
>
> I assume from the above that we should have a Signed-off-by:kosaki
> here.  I didn't make that change yet - please advise.

Yes. The patch mixes 2 changes: find_lock_task_mm patch + "do not forget
about the sub-thread's children". The changelog doesn't match the actual
changes.

> > @@ -115,12 +126,17 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
> >  	 * child is eating the vast majority of memory, adding only half
> >  	 * to the parents will make the child our kill candidate of choice.
> >  	 */
> > -	list_for_each_entry(child, &p->children, sibling) {
> > -		task_lock(child);
> > -		if (child->mm != mm && child->mm)
> > -			points += child->mm->total_vm/2 + 1;
> > -		task_unlock(child);
> > -	}
> > +	t = p;
> > +	do {
> > +		list_for_each_entry(c, &t->children, sibling) {
> > +			child = find_lock_task_mm(c);
> > +			if (child) {
> > +				if (child->mm != p->mm)
> > +					points += child->mm->total_vm/2 + 1;
>
> What if 1000 children share the same mm?  Doesn't this give a grossly
> wrong result?

Can't answer. Obviusly it is hard to explain what is the "right" result here.
But otoh, without this change we can't account children. Kosaki sent this
as a separate change.

> > @@ -256,9 +272,6 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
> >  	for_each_process(p) {
> >  		unsigned long points;
> >
> > -		/* skip tasks that have already released their mm */
> > -		if (!p->mm)
> > -			continue;

We shouldn't remove this without removing OR updating the PF_EXITING check
below. That is why we had another patch.

This change alone allows to trivially disable oom-kill. If we have a process
with the dead leader, select_bad_process() will always return -1.

We either need another patch from Kosaki's series

	- if (p->flags & PF_EXITING)
	+ if (p->flags & PF_EXITING && p->mm)

or remove this check (David objects).

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

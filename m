Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 58A8A6B01F5
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 09:40:55 -0400 (EDT)
Date: Tue, 6 Apr 2010 15:38:47 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH -mm 2/4] oom: select_bad_process: PF_EXITING check
	should take ->mm into account
Message-ID: <20100406133847.GA10039@redhat.com>
References: <20100331204718.GD11635@redhat.com> <alpine.DEB.2.00.1004010133190.6285@chino.kir.corp.google.com> <20100401135927.GA12460@redhat.com> <alpine.DEB.2.00.1004011210380.30661@chino.kir.corp.google.com> <20100402111406.GA4432@redhat.com> <20100402183057.GA31723@redhat.com> <20100402183216.GC31723@redhat.com> <20100406114235.GA3965@desktop> <20100406121811.GA6802@redhat.com> <20100406130518.GB3965@desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100406130518.GB3965@desktop>
Sender: owner-linux-mm@kvack.org
To: anfei <anfei.zhou@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 04/06, anfei wrote:
>
> On Tue, Apr 06, 2010 at 02:18:11PM +0200, Oleg Nesterov wrote:
> >
> > I do not really know what is the "right" solution. Even if we fix this
> > check for mt case, we also have CLONE_VM tasks.
> >
> What about checking mm->mm_users too? If there are any other users,
> just let badness judge.  CLONE_VM tasks but not mt seem rare, and
> badness doesn't consider it too.

Even if we forget about get_task_mm() which increments mm_users, it is not
clear to me how to do this check correctly.

Say, mm_users > 1 but SIGNAL_GROUP_EXIT is set. This means this process is
exiting and (ignoring CLONE_VM task) it is going to release its ->mm. But
otoh mm can be NULL.

Perhaps we can do

	if ((PF_EXITING && thread_group_empty(p) ||
	    (p->signal->flags & SIGNAL_GROUP_EXIT) {
		// OK, it is exiting

		bool has_mm = false;
		do {
			if (t->mm) {
				has_mm = true;
				break;
			}
		} while_each_thread(p, t);
			
		if (!has_mm)
			continue;

		if (p != current)
			return ERR_PTR(-1);
		...
	}

I dunno.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

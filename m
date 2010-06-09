Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3F2246B01B5
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 12:27:12 -0400 (EDT)
Date: Wed, 9 Jun 2010 18:25:23 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch 06/18] oom: avoid sending exiting tasks a SIGKILL
Message-ID: <20100609162523.GA30464@redhat.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061524190.32225@chino.kir.corp.google.com> <20100608202611.GA11284@redhat.com> <alpine.DEB.2.00.1006082330160.30606@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1006082330160.30606@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 06/08, David Rientjes wrote:
>
> On Tue, 8 Jun 2010, Oleg Nesterov wrote:
>
> > > It's unnecessary to SIGKILL a task that is already PF_EXITING
> >
> > This probably needs some explanation. PF_EXITING doesn't necessarily
> > mean this process is exiting.
>
> I hope that my sentence didn't imply that it was, the point is that
> sending a SIGKILL to a PF_EXITING task isn't necessary to make it exit,
> it's already along the right path.

Well, probably this is right...

David, currently I do not know how the code looks with all patches
applied, could you please confirm there is no problem here? I am
looking at Linus's tree,

	mem_cgroup_out_of_memory:

		 p = select_bad_process();
		 oom_kill_process(p);

Now, again, select_bad_process() can return the dead group-leader
of the memory-hog-thread-group.

In that case set_tsk_thread_flag(TIF_MEMDIE) buys nothing, this
thread has aleady exited, but we do want to kill this process.

If this is not true due to other changes - great.

Otherwise, perhaps this needs

	- if (PF_EXITING)
	+ if (PF_EXITING && mm)

too?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

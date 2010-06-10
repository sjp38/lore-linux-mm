Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E32436B01AD
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 21:53:09 -0400 (EDT)
Date: Thu, 10 Jun 2010 03:51:36 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch 06/18] oom: avoid sending exiting tasks a SIGKILL
Message-ID: <20100610015136.GA7595@redhat.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061524190.32225@chino.kir.corp.google.com> <20100608202611.GA11284@redhat.com> <alpine.DEB.2.00.1006082330160.30606@chino.kir.corp.google.com> <20100609162523.GA30464@redhat.com> <alpine.DEB.2.00.1006091241330.26827@chino.kir.corp.google.com> <20100609201430.GA8210@redhat.com> <20100610091547.d2c88d4c.kamezawa.hiroyu@jp.fujitsu.com> <20100610012101.GA5412@redhat.com> <20100610104309.f7559f31.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100610104309.f7559f31.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 06/10, KAMEZAWA Hiroyuki wrote:
>
> > Afaics
> >
> > 	- task_in_mem_cgroup() should use find_lock_task_mm() too
> >
> > 	- oom_kill_process() should check "PF_EXITING && p->mm",
> > 	  like select_bad_process() does.
> >
>
> Hm. I'd like to look into that when the next mmotm is shipped.
> (too many pactches in flight..)

Me too ;)

> The problem is
>
>   for (walking each 'process')
> 	if (task_in_mem_cgroup(p, memcg))
>
>  can't check 'p' containes threads belongs to given memcg because p->mm can
>  be NULL. So, task_in_mem_cgroup should call find_lock_task_mm() when
>  getting "mm" struct.

Yes, this is what I meant. And after we do this change we should tweak
oom_kill_process() too, otherwise we have another problem.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

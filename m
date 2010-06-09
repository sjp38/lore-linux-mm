Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5CEDF6B01AD
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 15:44:48 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o59JigbY012414
	for <linux-mm@kvack.org>; Wed, 9 Jun 2010 12:44:42 -0700
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by wpaz9.hot.corp.google.com with ESMTP id o59JiXtJ032679
	for <linux-mm@kvack.org>; Wed, 9 Jun 2010 12:44:41 -0700
Received: by pzk33 with SMTP id 33so6105490pzk.17
        for <linux-mm@kvack.org>; Wed, 09 Jun 2010 12:44:40 -0700 (PDT)
Date: Wed, 9 Jun 2010 12:44:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 06/18] oom: avoid sending exiting tasks a SIGKILL
In-Reply-To: <20100609162523.GA30464@redhat.com>
Message-ID: <alpine.DEB.2.00.1006091241330.26827@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061524190.32225@chino.kir.corp.google.com> <20100608202611.GA11284@redhat.com> <alpine.DEB.2.00.1006082330160.30606@chino.kir.corp.google.com>
 <20100609162523.GA30464@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 9 Jun 2010, Oleg Nesterov wrote:

> > I hope that my sentence didn't imply that it was, the point is that
> > sending a SIGKILL to a PF_EXITING task isn't necessary to make it exit,
> > it's already along the right path.
> 
> Well, probably this is right...
> 
> David, currently I do not know how the code looks with all patches
> applied, could you please confirm there is no problem here? I am
> looking at Linus's tree,
> 
> 	mem_cgroup_out_of_memory:
> 
> 		 p = select_bad_process();
> 		 oom_kill_process(p);
> 

mem_cgroup_out_of_memory() does this under tasklist_lock:

retry:
	p = select_bad_process(&points, mem, CONSTRAINT_MEMCG, NULL);
	if (!p || PTR_ERR(p) == -1UL)
		goto out;

	if (oom_kill_process(p, gfp_mask, 0, points, mem,
				"Memory cgroup out of memory"))
		goto retry;
out:
	...

> Now, again, select_bad_process() can return the dead group-leader
> of the memory-hog-thread-group.
> 

select_bad_process() already has:

	if ((p->flags & PF_EXITING) && p->mm) {
		if (p != current)
			return ERR_PTR(-1UL);

		chosen = p;
		*ppoints = ULONG_MAX;
	}

so we can disregard the check for p == current in this case since it would 
not be allocating memory without p->mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

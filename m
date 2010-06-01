Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 449E06B0229
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 04:49:45 -0400 (EDT)
Subject: Re: [rfc] forked kernel task and mm structures imbalanced on NUMA
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1275380202.27810.26214.camel@twins>
References: <20100601073343.GQ9453@laptop>
	 <1275380202.27810.26214.camel@twins>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 01 Jun 2010 10:49:54 +0200
Message-ID: <1275382194.27810.26330.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, "Serge E. Hallyn" <serue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-06-01 at 10:16 +0200, Peter Zijlstra wrote:
> I'd have to again look at wth happens to ->cpus_allowed, but I guess
> it should be fixable

Ah, I remember, cgroup_clone was a massive pain, Serge said he'd wanted
to kill that, but I don't think that ever happened.

    copy_process():
      if (current->nsproxy !=3D p->nsproxy)
         ns_cgroup_clone()
           cgroup_clone()
             mutex_lock(inode->i_mutex)
             mutex_lock(cgroup_mutex)
             cgroup_attach_task()
           ss->can_attach()
               ss->attach() [ -> cpuset_attach() ]
                 cpuset_attach_task()
                   set_cpus_allowed_ptr();

was the code path that made set_cpus_allowed_ptr() exclusion against
fork interesting.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

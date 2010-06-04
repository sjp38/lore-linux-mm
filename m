Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BDE696B01B9
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 07:35:49 -0400 (EDT)
Date: Fri, 4 Jun 2010 13:34:25 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] oom: Make coredump interruptible
Message-ID: <20100604113425.GA13801@redhat.com>
References: <20100602185812.4B5894A549@magilla.sf.frob.com> <20100602203827.GA29244@redhat.com> <20100604194635.72D3.A69D9226@jp.fujitsu.com> <20100604112721.GA12582@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100604112721.GA12582@redhat.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Roland McGrath <roland@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 06/04, Oleg Nesterov wrote:
>
> (I'd suggest you to add a note into the changelog, to explain
>  that the new flag makes sense even without coredump problems).

And. May I ask you to add another note into the changelog?

> > @@ -410,6 +409,8 @@ static int __oom_kill_process(struct task_struct *p, struct mem_cgroup *mem,
> >  	 */
> >  	p->rt.time_slice = HZ;
> >  	set_tsk_thread_flag(p, TIF_MEMDIE);
> > +	set_bit(MMF_OOM_KILLED, &p->mm->flags);

I think the changelog should explain that, if we race with fork(),
this flag can't leak into the child's new mm. mm_init() filters
the bits outside of MMF_INIT_MASK.

If we race with exec, it can't leak because mm_alloc() does
memset(0).

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

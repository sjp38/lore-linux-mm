Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DBA716B01B0
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:51:43 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5H1pgjc026016
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 17 Jun 2010 10:51:42 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C7B3F45DE60
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A3AA745DE4D
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E4D21DB803A
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:41 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D20A1DB803F
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 6/9] oom: use same_thread_group instead comparing ->mm
In-Reply-To: <20100616122403.GA5304@redhat.com>
References: <20100616203319.72E6.A69D9226@jp.fujitsu.com> <20100616122403.GA5304@redhat.com>
Message-Id: <20100617101809.FB54.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu, 17 Jun 2010 10:51:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On 06/16, KOSAKI Motohiro wrote:
> >
> > Now, oom are using "child->mm != p->mm" check to distinguish subthread.
> 
> Heh. is it true??? I never undestood what oom_kill_process()->list_for_each_entry()
> is supposed to do.

I guessed. true history was gone long time ago ;)
ok, I'll remove dubious guess.

> > But It's incorrect. vfork() child also have the same ->mm.
> 
> Yes.
> 
> > This patch change to use same_thread_group() instead.
> 
> I don't think we need same_thread_group(). Please note that any children must
> be from the different thread_group.

Agghh. I see.
ok, probably, I've got correct original author intention now.
To be honest, andrea's ancient patch is very hard to understand for me ;)

> 
> So,
> 
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -161,7 +161,7 @@ unsigned long oom_badness(struct task_struct *p, unsigned long uptime)
> >  		list_for_each_entry(c, &t->children, sibling) {
> >  			child = find_lock_task_mm(c);
> >  			if (child) {
> > -				if (child->mm != p->mm)
> > +				if (same_thread_group(p, child))
> >  					points += child->mm->total_vm/2 + 1;
> >  				task_unlock(child);
> >  			}
> > @@ -486,7 +486,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> >  		list_for_each_entry(child, &t->children, sibling) {
> >  			unsigned long child_points;
> >
> > -			if (child->mm == p->mm)
> > +			if (same_thread_group(p, child))
> >  				continue;
> 
> In both cases same_thread_group() must be false.
> 
> This means that the change in oom_badness() doesn't look right,
> "child->mm != p->mm" is the correct check to decide whether we should
> account child->mm.
> 
> The change in oom_kill_process() merely removes this "continue".
> Could someone please explain what this code _should_ do?

I think you are right.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

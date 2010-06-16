Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D2D616B01D7
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 08:25:37 -0400 (EDT)
Date: Wed, 16 Jun 2010 14:24:03 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 6/9] oom: use same_thread_group instead comparing ->mm
Message-ID: <20100616122403.GA5304@redhat.com>
References: <20100616201948.72D7.A69D9226@jp.fujitsu.com> <20100616203319.72E6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100616203319.72E6.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 06/16, KOSAKI Motohiro wrote:
>
> Now, oom are using "child->mm != p->mm" check to distinguish subthread.

Heh. is it true??? I never undestood what oom_kill_process()->list_for_each_entry()
is supposed to do.

> But It's incorrect. vfork() child also have the same ->mm.

Yes.

> This patch change to use same_thread_group() instead.

I don't think we need same_thread_group(). Please note that any children must
be from the different thread_group.

So,

> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -161,7 +161,7 @@ unsigned long oom_badness(struct task_struct *p, unsigned long uptime)
>  		list_for_each_entry(c, &t->children, sibling) {
>  			child = find_lock_task_mm(c);
>  			if (child) {
> -				if (child->mm != p->mm)
> +				if (same_thread_group(p, child))
>  					points += child->mm->total_vm/2 + 1;
>  				task_unlock(child);
>  			}
> @@ -486,7 +486,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  		list_for_each_entry(child, &t->children, sibling) {
>  			unsigned long child_points;
>
> -			if (child->mm == p->mm)
> +			if (same_thread_group(p, child))
>  				continue;

In both cases same_thread_group() must be false.

This means that the change in oom_badness() doesn't look right,
"child->mm != p->mm" is the correct check to decide whether we should
account child->mm.

The change in oom_kill_process() merely removes this "continue".
Could someone please explain what this code _should_ do?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

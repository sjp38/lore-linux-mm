Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 58BC96B007B
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 13:47:53 -0400 (EDT)
Date: Thu, 16 Sep 2010 19:44:33 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 4/4] oom: don't ignore rss in nascent mm
Message-ID: <20100916174433.GA4842@redhat.com>
References: <20100916144930.3BAE.A69D9226@jp.fujitsu.com> <20100916145710.3BBA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100916145710.3BBA.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, oss-security@lists.openwall.com, Solar Designer <solar@openwall.com>, Kees Cook <kees.cook@canonical.com>, Al Viro <viro@zeniv.linux.org.uk>, Neil Horman <nhorman@tuxdriver.com>, linux-fsdevel@vger.kernel.org, pageexec@freemail.hu, Brad Spengler <spender@grsecurity.net>, Eugene Teo <eugene@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On 09/16, KOSAKI Motohiro wrote:
>
> ChangeLog
>  o since v1
>    - Always use thread group leader's ->in_exec_mm.

Confused ;)

> +static unsigned long oom_rss_swap_usage(struct task_struct *p)
> +{
> +	struct task_struct *t = p;
> +	struct task_struct *leader = p->group_leader;
> +	unsigned long points = 0;
> +
> +	do {
> +		task_lock(t);
> +		if (t->mm) {
> +			points += get_mm_rss(t->mm);
> +			points += get_mm_counter(t->mm, MM_SWAPENTS);
> +			task_unlock(t);
> +			break;
> +		}
> +		task_unlock(t);
> +	} while_each_thread(p, t);
> +
> +	/*
> +	 * If the process is in execve() processing, we have to concern
> +	 * about both old and new mm.
> +	 */
> +	task_lock(leader);
> +	if (leader->in_exec_mm) {
> +		points += get_mm_rss(leader->in_exec_mm);
> +		points += get_mm_counter(leader->in_exec_mm, MM_SWAPENTS);
> +	}
> +	task_unlock(leader);
> +
> +	return points;
> +}

This patch relies on fact that we can't race with de_thread() (and btw
the change in de_thread() looks bogus). Then why ->in_exec_mm lives in
task_struct ?

To me, this looks a bit strange. I think we should either do not use
->group_leader to hold ->in_exec_mm like your previous patch did, or
move ->in_exec_mm into signal_struct. The previous 3/4 ensures that
only one thread can set ->in_exec_mm.

And I don't think oom_rss_swap_usage() should replace find_lock_task_mm()
in oom_badness(), I mean something like this:

	static unsigned long oom_rss_swap_usage(struct mm_struct *mm)
	{
		return get_mm_rss(mm) + get_mm_counter(mm, MM_SWAPENTS);
	}

	unsigned int oom_badness(struct task_struct *p, ...)
	{
		int points = 0;

		if (unlikely(p->signal->in_exec_mm)) {
			task_lock(p->group_leader);
			if (p->signal->in_exec_mm)
				points = oom_rss_swap_usage(p->signal->in_exec_mm);
			task_unlock(p->group_leader);
		}

		p = find_lock_task_mm(p);
		if (!p)
			return points;

		...
	}

but this is the matter of taste.

What do you think?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

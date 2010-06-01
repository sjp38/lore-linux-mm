Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7A85D6B01CD
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 15:28:45 -0400 (EDT)
Date: Tue, 1 Jun 2010 21:27:26 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 3/5] oom: Fix child process iteration properly
Message-ID: <20100601192726.GA19120@redhat.com>
References: <20100601144238.243A.A69D9226@jp.fujitsu.com> <20100601144810.2440.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100601144810.2440.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 06/01, KOSAKI Motohiro wrote:
>
> @@ -88,6 +88,7 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
>  {
>  	unsigned long points, cpu_time, run_time;
>  	struct task_struct *c;
> +	struct task_struct *t = p;

This initialization should be moved down to

> +	do {
> +		list_for_each_entry(c, &t->children, sibling) {
> +			child = find_lock_task_mm(c);
> +			if (child) {
> +				if (child->mm != p->mm)
> +					points += child->mm->total_vm/2 + 1;
> +				task_unlock(child);
> +			}
>  		}
> -	}
> +	} while_each_thread(p, t);

this loop. We have "p = find_lock_task_mm(p)" in between which can change p.

Apart from this, I think the whole series is nice.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

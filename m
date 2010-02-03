Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1E76001DA
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 17:55:06 -0500 (EST)
From: Lubos Lunak <l.lunak@suse.cz>
Subject: Re: Improving OOM killer
Date: Wed, 3 Feb 2010 23:55:01 +0100
References: <201002012302.37380.l.lunak@suse.cz> <20100203170127.GH19641@balbir.in.ibm.com> <alpine.DEB.2.00.1002031021190.14088@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1002031021190.14088@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <201002032355.01260.l.lunak@suse.cz>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Wednesday 03 of February 2010, David Rientjes wrote:
> My rewrite for the badness() heuristic is centered on the idea that scores
> should range from 0 to 1000, 0 meaning "never kill this task" and 1000
> meaning "kill this task first."  The baseline for a thread, p, may be
> something like this:
>
> 	unsigned int badness(struct task_struct *p,
> 					unsigned long totalram)
> 	{
> 		struct task_struct *child;
> 		struct mm_struct *mm;
> 		int forkcount = 0;
> 		long points;
>
> 		task_lock(p);
> 		mm = p->mm;
> 		if (!mm) {
> 			task_unlock(p);
> 			return 0;
> 		}
> 		points = (get_mm_rss(mm) +
> 				get_mm_counter(mm, MM_SWAPENTS)) * 1000 /
> 				totalram;
> 		task_unlock(p);
>
> 		list_for_each_entry(child, &p->children, sibling)
> 			/* No lock, child->mm won't be dereferenced */
> 			if (child->mm && child->mm != mm)
> 				forkcount++;
>
> 		/* Forkbombs get penalized 10% of available RAM */
> 		if (forkcount > 500)
> 			points += 100;

 As far as I'm concerned, this is a huge improvement over the current code 
(and, incidentally :), quite close to what I originally wanted). I'd be 
willing to test it in few real-world desktop cases if you provide a patch.

> 		/*
> 		 * /proc/pid/oom_adj ranges from -1000 to +1000 to either
> 		 * completely disable oom killing or always prefer it.
> 		 */
> 		points += p->signal->oom_adj;

 This changes semantics of oom_adj, but given that I expect the above to make 
oom_adj unnecessary on the desktop for the normal cases, I don't really mind.

-- 
 Lubos Lunak
 openSUSE Boosters team, KDE developer
 l.lunak@suse.cz , l.lunak@kde.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

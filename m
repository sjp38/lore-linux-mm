Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BD12E6B0071
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 19:05:13 -0500 (EST)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id o1405991012535
	for <linux-mm@kvack.org>; Thu, 4 Feb 2010 00:05:09 GMT
Received: from pxi14 (pxi14.prod.google.com [10.243.27.14])
	by kpbe13.cbf.corp.google.com with ESMTP id o14057mE014797
	for <linux-mm@kvack.org>; Wed, 3 Feb 2010 18:05:08 -0600
Received: by pxi14 with SMTP id 14so2090558pxi.20
        for <linux-mm@kvack.org>; Wed, 03 Feb 2010 16:05:07 -0800 (PST)
Date: Wed, 3 Feb 2010 16:05:06 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Improving OOM killer
In-Reply-To: <201002032355.01260.l.lunak@suse.cz>
Message-ID: <alpine.DEB.2.00.1002031600490.27918@chino.kir.corp.google.com>
References: <201002012302.37380.l.lunak@suse.cz> <20100203170127.GH19641@balbir.in.ibm.com> <alpine.DEB.2.00.1002031021190.14088@chino.kir.corp.google.com> <201002032355.01260.l.lunak@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lubos Lunak <l.lunak@suse.cz>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Feb 2010, Lubos Lunak wrote:

> > 	unsigned int badness(struct task_struct *p,
> > 					unsigned long totalram)
> > 	{
> > 		struct task_struct *child;
> > 		struct mm_struct *mm;
> > 		int forkcount = 0;
> > 		long points;
> >
> > 		task_lock(p);
> > 		mm = p->mm;
> > 		if (!mm) {
> > 			task_unlock(p);
> > 			return 0;
> > 		}
> > 		points = (get_mm_rss(mm) +
> > 				get_mm_counter(mm, MM_SWAPENTS)) * 1000 /
> > 				totalram;
> > 		task_unlock(p);
> >
> > 		list_for_each_entry(child, &p->children, sibling)
> > 			/* No lock, child->mm won't be dereferenced */
> > 			if (child->mm && child->mm != mm)
> > 				forkcount++;
> >
> > 		/* Forkbombs get penalized 10% of available RAM */
> > 		if (forkcount > 500)
> > 			points += 100;
> 
>  As far as I'm concerned, this is a huge improvement over the current code 
> (and, incidentally :), quite close to what I originally wanted). I'd be 
> willing to test it in few real-world desktop cases if you provide a patch.
> 

There're some things that still need to be worked out, like discounting 
hugetlb pages on each allowed node, respecting current's cpuset mems, 
etc., but I think it gives us a good rough draft of where we might end up.  
I did use the get_mm_rss() that you suggested, but I think it's more 
helpful in the context of a fraction of total memory allowed so the other 
heursitics (forkbomb, root tasks, nice'd tasks, etc) are penalizing the 
points in a known quantity rather than a manipulation of that baseline.

Do you have any comments about the forkbomb detector or its threshold that 
I've put in my heuristic?  I think detecting these scenarios is still an 
important issue that we need to address instead of simply removing it from 
consideration entirely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

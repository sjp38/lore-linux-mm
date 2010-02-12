Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 27D8D6B0078
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 19:15:28 -0500 (EST)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o1C0FP7W015697
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 16:15:25 -0800
Received: from pzk7 (pzk7.prod.google.com [10.243.19.135])
	by wpaz5.hot.corp.google.com with ESMTP id o1C0F98h002933
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 16:15:24 -0800
Received: by pzk7 with SMTP id 7so2156138pzk.12
        for <linux-mm@kvack.org>; Thu, 11 Feb 2010 16:15:23 -0800 (PST)
Date: Thu, 11 Feb 2010 16:15:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/7 -mm] oom: sacrifice child with highest badness score
 for parent
In-Reply-To: <20100212090009.3e5b8738.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002111611520.11711@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com> <alpine.DEB.2.00.1002100228240.8001@chino.kir.corp.google.com> <20100212090009.3e5b8738.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Feb 2010, KAMEZAWA Hiroyuki wrote:

> Maybe better than current logic..but I'm not sure why we have to check children ;)
> 
> BTW,
> ==
>         list_for_each_entry(child, &p->children, sibling) {
>                 task_lock(child);
>                 if (child->mm != mm && child->mm)
>                         points += child->mm->total_vm/2 + 1;
>                 task_unlock(child);
>         }
> ==
> I wonder this part should be
> 	points += (child->total_vm/2) >> child->signal->oom_adj + 1
> 
> If not, in following situation,
> ==
> 	parent (oom_adj = 0)
> 	  -> child (oom_adj=-15, very big memory user)
> ==
> the child may be killd at first, anyway. Today, I have to explain customers
> "When you set oom_adj to a process, please set the same value to all ancestors.
>  Otherwise, your oom_adj value will be ignored."
> 

This is a different change than the forkbomb detection which is rewritten 
in the fourth patch in the series.  We must rely on badness() being able 
to tell us how beneficial it will be to kill a task, so iterating through 
the child list and picking the most beneficial is the goal of this patch.  
It reduces the chances of needlessly killing a child using very little 
memory for no benefit just because it was forked first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

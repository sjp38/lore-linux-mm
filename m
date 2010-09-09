Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AC5736B0082
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 17:01:03 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o89L104K021972
	for <linux-mm@kvack.org>; Thu, 9 Sep 2010 14:01:00 -0700
Received: from pzk32 (pzk32.prod.google.com [10.243.19.160])
	by wpaz21.hot.corp.google.com with ESMTP id o89L0wQE018790
	for <linux-mm@kvack.org>; Thu, 9 Sep 2010 14:00:59 -0700
Received: by pzk32 with SMTP id 32so172003pzk.36
        for <linux-mm@kvack.org>; Thu, 09 Sep 2010 14:00:58 -0700 (PDT)
Date: Thu, 9 Sep 2010 14:00:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -rc] oom: always return a badness score of non-zero for
 eligible tasks
In-Reply-To: <1284061683.7586.8100.camel@nimitz>
Message-ID: <alpine.DEB.2.00.1009091351090.19800@chino.kir.corp.google.com>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org> <1284053081.7586.7910.camel@nimitz> <alpine.DEB.2.00.1009091152090.5556@chino.kir.corp.google.com> <1284061683.7586.8100.camel@nimitz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Sep 2010, Dave Hansen wrote:

> > I'm curious why there are no killable processes on the system; it seems 
> > like the triggering task here, cat, would at least be killable itself.  
> > Could you post the tasklist dump that preceeds this (or, if you've 
> > disabled it try echo 1 > /proc/sys/vm/oom_dump_tasks first)?
> 
> That was one odd part here.  I didn't disable the tasklist dump, and
> there was none in the dump.
> 

Hmm, could you very that /proc/sys/vm/oom_dump_tasks is set?  Perhaps it's 
getting cleared by something else before you use zram.  The sysctl should 
default to on as of 2.6.36-rc1.

> > It's possible that if you have enough swap that none of the eligible tasks 
> > actually have non-zero badness scores either because they are being run as 
> > root or because the amount of RAM or swap is sufficiently high such that 
> > (task's rss + swap) / (total rss + swap) is never non-zero.  And, since 
> > root tasks have a 3% bonus, it's possible these are all root tasks and no 
> > single task uses more than 3% of rss and swap.
> 
> It's a 64GB machine with ~30GB of swap and very little RSS.  Your
> hypothesis seems correct.  Just grepping through /proc/[0-9]*/oom_score
> shows nothing other than 0's.
> 

Presumably you're not using a large amount of swap, either, or that would 
be accounted for in oom_score.

> Trying this again, I just hung the system instead of OOM'ing straight
> away like last time.
> 

with the patch, you should still be calling the oom killer and instead of 
panicking it will go on a serial killing spree because everything that it 
wasn't judging as a candidate before (oom_score of 0) now is if it's truly 
killable (oom_score of 1).  The patch is definitely needed for correctness 
since an oom_score of 0 implies the task is unkillable.

We're apparently hanging in the exit path for the oom killed task or 
something is constantly respawning threads that repeatedly get killed.  It 
appears as though nothing is actually a worthwhile target for the oom 
killer, however, and this is a bad configuration.

> Your patch makes a lot of sense to me in any case where there aren't
> large-RSS tasks around using memory.  That definitely applies here
> because of the amount in the compcache store and might also apply with
> ramfs and hugetlbfs.
> 

Agreed, we'll need to address hugepages specifically because they don't 
get accounted for in rss but do free memory when the task is killed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

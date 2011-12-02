Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E42346B004D
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 14:00:46 -0500 (EST)
Date: Fri, 2 Dec 2011 11:00:19 -0800
From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH v2 RESEND] oom: fix integer overflow of points in
 oom_badness
Message-ID: <20111202190019.GA13283@suse.de>
References: <1320048865-13175-1-git-send-email-fhrbata@redhat.com>
 <20111202174526.GA11483@dhcp-26-164.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111202174526.GA11483@dhcp-26-164.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frantisek Hrbata <fhrbata@redhat.com>
Cc: rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, oleg@redhat.com, minchan.kim@gmail.com, stable@kernel.org, eteo@redhat.com, pmatouse@redhat.com

On Fri, Dec 02, 2011 at 06:45:27PM +0100, Frantisek Hrbata wrote:
> An integer overflow will happen on 64bit archs if task's sum of rss, swapents
> and nr_ptes exceeds (2^31)/1000 value. This was introduced by commit
> 
> f755a04 oom: use pte pages in OOM score
> 
> where the oom score computation was divided into several steps and it's no
> longer computed as one expression in unsigned long(rss, swapents, nr_pte are
> unsigned long), where the result value assigned to points(int) is in
> range(1..1000). So there could be an int overflow while computing
> 
> 176          points *= 1000;
> 
> and points may have negative value. Meaning the oom score for a mem hog task
> will be one.
> 
> 196          if (points <= 0)
> 197                  return 1;
> 
> For example:
> [ 3366]     0  3366 35390480 24303939   5       0             0 oom01
> Out of memory: Kill process 3366 (oom01) score 1 or sacrifice child
> 
> Here the oom1 process consumes more than 24303939(rss)*4096~=92GB physical
> memory, but it's oom score is one.
> 
> In this situation the mem hog task is skipped and oom killer kills another and
> most probably innocent task with oom score greater than one.
> 
> The points variable should be of type long instead of int to prevent the int
> overflow.
> 
> Signed-off-by: Frantisek Hrbata <fhrbata@redhat.com>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Oleg Nesterov <oleg@redhat.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Cc: stable@kernel.org [2.6.36+]

For what it's worth, the stable address has changed to
stable@vger.kernel.org so you might want to fix that up in future
submissions.

I still catch patches that are tagged with this marking, but you will
not end up posting stuff to the list this way :)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

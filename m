Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 670EF6B007B
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 15:48:07 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o89JbkDD020711
	for <linux-mm@kvack.org>; Thu, 9 Sep 2010 13:37:46 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o89Jm5jl212864
	for <linux-mm@kvack.org>; Thu, 9 Sep 2010 13:48:05 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o89Jm4pR018154
	for <linux-mm@kvack.org>; Thu, 9 Sep 2010 13:48:05 -0600
Subject: Re: [patch -rc] oom: always return a badness score of non-zero for
 eligible tasks
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1009091152090.5556@chino.kir.corp.google.com>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
	 <1284053081.7586.7910.camel@nimitz>
	 <alpine.DEB.2.00.1009091152090.5556@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Thu, 09 Sep 2010 12:48:03 -0700
Message-ID: <1284061683.7586.8100.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-09-09 at 12:07 -0700, David Rientjes wrote:
> On Thu, 9 Sep 2010, Dave Hansen wrote:
> 
> > Hi Nitin,
> > 
> > I've been playing with using zram (from -staging) to back some qemu
> > guest memory directly.  Basically mmap()'ing the device in instead of
> > using anonymous memory.  The old code with the backing swap devices
> > seemed to work pretty well, but I'm running into a problem with the new
> > code.
> > 
> > I have plenty of swap on the system, and I'd been running with compcache
> > nicely for a while.  But, I went to go tar up (and gzip) a pretty large
> > directory in my qemu guest.  It panic'd the qemu host system:
> > 
> > [703826.003126] Kernel panic - not syncing: Out of memory and no killable processes...
> > [703826.003127] 
> > [703826.012350] Pid: 25508, comm: cat Not tainted 2.6.36-rc3-00114-g9b9913d #29
> 
> I'm curious why there are no killable processes on the system; it seems 
> like the triggering task here, cat, would at least be killable itself.  
> Could you post the tasklist dump that preceeds this (or, if you've 
> disabled it try echo 1 > /proc/sys/vm/oom_dump_tasks first)?

That was one odd part here.  I didn't disable the tasklist dump, and
there was none in the dump.

> It's possible that if you have enough swap that none of the eligible tasks 
> actually have non-zero badness scores either because they are being run as 
> root or because the amount of RAM or swap is sufficiently high such that 
> (task's rss + swap) / (total rss + swap) is never non-zero.  And, since 
> root tasks have a 3% bonus, it's possible these are all root tasks and no 
> single task uses more than 3% of rss and swap.

It's a 64GB machine with ~30GB of swap and very little RSS.  Your
hypothesis seems correct.  Just grepping through /proc/[0-9]*/oom_score
shows nothing other than 0's.

Trying this again, I just hung the system instead of OOM'ing straight
away like last time.

Your patch makes a lot of sense to me in any case where there aren't
large-RSS tasks around using memory.  That definitely applies here
because of the amount in the compcache store and might also apply with
ramfs and hugetlbfs.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

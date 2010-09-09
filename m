Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 925A56B0087
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 17:46:42 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o89LkOcF015507
	for <linux-mm@kvack.org>; Thu, 9 Sep 2010 14:46:24 -0700
Received: from pzk26 (pzk26.prod.google.com [10.243.19.154])
	by kpbe16.cbf.corp.google.com with ESMTP id o89LjiEB020113
	for <linux-mm@kvack.org>; Thu, 9 Sep 2010 14:46:23 -0700
Received: by pzk26 with SMTP id 26so191181pzk.14
        for <linux-mm@kvack.org>; Thu, 09 Sep 2010 14:46:22 -0700 (PDT)
Date: Thu, 9 Sep 2010 14:40:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -rc] oom: always return a badness score of non-zero for
 eligible tasks
In-Reply-To: <1284066608.7586.8189.camel@nimitz>
Message-ID: <alpine.DEB.2.00.1009091419230.23194@chino.kir.corp.google.com>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org> <1284053081.7586.7910.camel@nimitz> <alpine.DEB.2.00.1009091152090.5556@chino.kir.corp.google.com> <1284061683.7586.8100.camel@nimitz> <alpine.DEB.2.00.1009091351090.19800@chino.kir.corp.google.com>
 <1284066608.7586.8189.camel@nimitz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Sep 2010, Dave Hansen wrote:

> > Hmm, could you very that /proc/sys/vm/oom_dump_tasks is set?  Perhaps it's 
> > getting cleared by something else before you use zram.  The sysctl should 
> > default to on as of 2.6.36-rc1.
> 
> I double-checked.  It defaults to on and remains that way.
> 

Ok, I assume you aren't getting the typical "cat invoked oom-killer..." 
message, the memory state dump, etc., either, so there's something strange 
with your log level such that nothing under KERN_WARNING is getting 
through or you can't access the actual kernel log due to the panic.  I can 
capture all that information with a netdump on panic with 2.6.36-rc3.

> I'll give the patch a shot and see if I get any better behavior.  But, I
> really do think the root cause here is compcache exhausting the system
> when you feed incompressible pages into it.  We can kill all the tasks
> we want, but I think it'll continue to gobble memory up as fast as we
> free it.
> 

That certainly seems to be the case and is the true topic of this thread, 
so I don't want to hijack it any further since it's outside the scope of 
the oom killer :)

But I'm still curious as to why the machine is hanging and not eventually 
panicking when we run out of killable tasks.  It seems as though something 
is hanging in the exit path, meaning memory reserves aren't even safe from 
compcache, or there's something wrong in the oom killer retry logic, or 
you're simply forking more tasks, perhaps as a response to threads getting 
killed by the kernel, than we can kill.

We'd certainly prefer to panic the machine if no work is getting done than 
simply killing everything that gets forked.  The problem before was that 
we panicked too early before we killed anything and now we don't know when 
to panic appropriately.

> > Agreed, we'll need to address hugepages specifically because they don't 
> > get accounted for in rss but do free memory when the task is killed.
> 
> They do sometimes.  But, if they're preallocated, or stuck in a linked
> file on the filesystem, killing the task doesn't do any good.
> 

Indeed you're right, I meant s/hugepages/transparent hugepages/, sorry.  
It appears as though they get included in the rss of the allocating task, 
though, via MM_ANONPAGES, so this is already represented in the task's 
badness score.

Thanks for trying the patch out, Dave, I hope we can add your Tested-by 
line and it can get pushed to the rc-series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

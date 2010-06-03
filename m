Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BA77C6B01E7
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 02:44:46 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o536igL3012989
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 23:44:42 -0700
Received: from pxi10 (pxi10.prod.google.com [10.243.27.10])
	by kpbe19.cbf.corp.google.com with ESMTP id o536ieT9010793
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 23:44:41 -0700
Received: by pxi10 with SMTP id 10so3280280pxi.21
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 23:44:40 -0700 (PDT)
Date: Wed, 2 Jun 2010 23:44:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
In-Reply-To: <20100603090552.1206dfb4.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006022342120.22441@chino.kir.corp.google.com>
References: <20100601074620.GR9453@laptop> <alpine.DEB.2.00.1006011144340.32024@chino.kir.corp.google.com> <20100602222347.F527.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006021421540.32666@chino.kir.corp.google.com>
 <20100603090552.1206dfb4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jun 2010, KAMEZAWA Hiroyuki wrote:

> > > > I'm glad you asked that because some recent conversation has been 
> > > > slightly confusing to me about how this affects the desktop; this rewrite 
> > > > significantly improves the oom killer's response for desktop users.  The 
> > > > core ideas were developed in the thread from this mailing list back in 
> > > > February called "Improving OOM killer" at 
> > > > http://marc.info/?t=126506191200004&r=4&w=2 -- users constantly report 
> > > > that vital system tasks such as kdeinit are killed whenever a memory 
> > > > hogging task is forked either intentionally or unintentionally.  I argued 
> > > > for a while that KDE should be taking proper precautions by adjusting its 
> > > > own oom_adj score and that of its forked children as it's an inherited 
> > > > value, but I was eventually convinced that an overall improvement to the 
> > > > heuristic must be made to kill a task that was known to free a large 
> > > > amount of memory that is resident in RAM and that we have a consistent way 
> > > > of defining oom priorities when a task is run uncontained and when it is a 
> > > > member of a memcg or cpuset (or even mempolicy now), even in the case when 
> > > > it's contained out from under the task's knowledge.  When faced with 
> > > > memory pressure from an out of control or memory hogging task on the 
> > > > desktop, the oom killer now kills it instead of a vital task such as an X 
> > > > server (and oracle, webserver, etc on server platforms) because of the use 
> > > > of the task's rss instead of total_vm statistic.
> > > 
> > > The above story teach us oom-killer need some improvement. but it haven't
> > > prove your patches are correct solution. that's why you got to ask testing way.
> > > 
> > 
> > I would consider what I said above, "when faced with memory pressure from 
> > an out of control or memory hogging task on the desktop, the oom killer 
> > now kills it instead of a vital task such as an X server because of the 
> > use of the task's rss instead of total_vm statistic" as an improvement 
> > over killing X in those cases which it currently does.  How do you 
> > disagree?
> > 
> 
> It was you who disagree using RSS for oom killing in the last winter.
> By what observation did you change your mind ? (Don't take this as criticism.
> I'm just curious.) 
> 

The fact that when I ran the new heuristic it improved the oom killer on 
my desktop to save KDE and kill a memory-hogging task that stressed it.  I 
became supportive of the idea through the discussion that went on 
specifically about using total_vm as a baseline and was convinced that it 
was better to use rss as well as a more powerful user interface so that 
admins could more accurately set their oom kill priorities even when their 
cpuset, memcg, or mempolicy placement was changed out from under it.

> My stand point:
> I don't like the new interface at all but welcome the concept for using RSS .

Using rss is not a new interface.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

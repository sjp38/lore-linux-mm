Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 956586B004D
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 15:24:21 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id n9UJOFs3009221
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 19:24:16 GMT
Received: from pwi18 (pwi18.prod.google.com [10.241.219.18])
	by wpaz33.hot.corp.google.com with ESMTP id n9UJOCWK010850
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 12:24:13 -0700
Received: by pwi18 with SMTP id 18so893905pwi.33
        for <linux-mm@kvack.org>; Fri, 30 Oct 2009 12:24:12 -0700 (PDT)
Date: Fri, 30 Oct 2009 12:24:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Memory overcommit
In-Reply-To: <4AEAF145.3010801@gmail.com>
Message-ID: <alpine.DEB.2.00.0910301218410.31986@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org> <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com> <4AE5CB4E.4090504@gmail.com> <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0910271843510.11372@sister.anvils>
 <alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com> <4AE78B8F.9050201@gmail.com> <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com> <4AE792B8.5020806@gmail.com> <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com>
 <20091028135519.805c4789.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910272205200.7507@chino.kir.corp.google.com> <20091028150536.674abe68.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910272311001.15462@chino.kir.corp.google.com>
 <20091028152015.3d383cd6.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910290136000.11476@chino.kir.corp.google.com> <4AE97861.1070902@gmail.com> <alpine.DEB.2.00.0910291248480.2276@chino.kir.corp.google.com> <4AEAF145.3010801@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: vedran.furac@gmail.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 30 Oct 2009, Vedran Furac wrote:

> > The problem you identified in http://pastebin.com/f3f9674a0, however, is a 
> > forkbomb issue where the badness score should never have been so high for 
> > kdeinit4 compared to "test".  That's directly proportional to adding the 
> > scores of all disjoint child total_vm values into the badness score for 
> > the parent and then killing the children instead.
> 
> Could you explain me why ntpd invoked oom killer? Its parent is init. Or
> syslog-ng?
> 

Because it attempted an order-0 GFP_USER allocation and direct reclaim 
could not free any pages.

The task that invoked the oom killer is simply the unlucky task that tried 
an allocation that couldn't be satisified through direct reclaim.  It's 
usually unrelated to the task chosen for kill unless 
/proc/sys/vm/oom_kill_allocating_task is enabled (which SGI requested to 
avoid excessively long tasklist scans).

> > That's the problem, not using total_vm as a baseline.  Replacing that with 
> > rss is not going to solve the issue and reducing the user's ability to 
> > specify a rough oom priority from userspace is simply not an option.
> 
> OK then, if you have a solution, I would be glad to test your patch. I
> won't care much if you don't change total_vm as a baseline. Just make
> random killing history.
> 

The only randomness is in selecting a task that has a different mm from 
the parent in the order of its child list.  Yes, that can be addressed by 
doing a smarter iteration through the children before killing one of them.

Keep in mind that a heuristic as simple as this:

 - kill the task that was started most recently by the same uid, or

 - kill the task that was started most recently on the system if a root
   task calls the oom killer,

would have yielded perfect results for your testcase but isn't necessarily 
something that we'd ever want to see.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

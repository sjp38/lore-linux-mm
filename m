Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7A97E6B0047
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 23:21:53 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id o883LnNl030931
	for <linux-mm@kvack.org>; Tue, 7 Sep 2010 20:21:50 -0700
Received: from pxi3 (pxi3.prod.google.com [10.243.27.3])
	by kpbe13.cbf.corp.google.com with ESMTP id o883LRLv018938
	for <linux-mm@kvack.org>; Tue, 7 Sep 2010 20:21:48 -0700
Received: by pxi3 with SMTP id 3so1945944pxi.7
        for <linux-mm@kvack.org>; Tue, 07 Sep 2010 20:21:48 -0700 (PDT)
Date: Tue, 7 Sep 2010 20:21:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUGFIX for 2.6.36][RESEND][PATCH 1/2] oom: remove totalpage
 normalization from oom_badness()
In-Reply-To: <20100907114223.C907.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1009072013260.4790@chino.kir.corp.google.com>
References: <20100831181911.87E7.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1009011508440.29305@chino.kir.corp.google.com> <20100907114223.C907.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Sep 2010, KOSAKI Motohiro wrote:

> > > ok, this one got no objection except original patch author.
> > 
> > Would you care to respond to my objections?
> > 
> > I replied to these two patches earlier with my nack, here they are:
> > 
> > 	http://marc.info/?l=linux-mm&m=128273555323993
> > 	http://marc.info/?l=linux-mm&m=128337879310476
> > 
> > Please carry on a useful debate of the issues rather than continually 
> > resending patches and labeling them as bugfixes, which they aren't.
> 
> You are still talking about only your usecase. Why do we care you? Why?

It's an example of how the new interface may be used to represent oom 
killing priorities for an aggregate of tasks competing for the same set of 
resources.

> Why don't you fix the code by yourself? Why? Why do you continue selfish
> development? Why? I can't understand.
> 

I can only reiterate what I've said before (and you can be assured I'll 
only keep it technical and professional even though you've always made 
this personal with me): current users of /proc/pid/oom_adj only polarize a 
task to either disable oom killing (-17 or -16), or always prefer a task 
(+15).  Very, very few users tune it to anything in between, and when it's 
done, it's relative to other oom_adj values.

A single example of a /proc/pid/oom_adj usecase has not been presented 
that shows anybody using it as a function of either an application's 
expected memory usage or of the system capacity.  Those two variables are 
important for oom_adj to make any sense since its old definition was 
basically oom_adj = mm->total_vm << oom_adj for positive oom_adj and 
oom_adj = mm->total_vm >> oom_adj for negative oom_adj.  If an 
application, system daemon, or job scheduler does not tune it without 
consideration to the amount of expected RAM usage or system RAM capacity, 
it doesn't make any sense.  You're welcome to present such a user at this 
time.

That said, I felt it was possible to use the current usecase for 
/proc/pid/oom_adj to expand upon its applicability by introducing 
/proc/pid/oom_score_adj with a much higher resolution and ability to stay 
static based on the relative importance of a task compared to others 
sharing the same resources in a dynamic environment (memcg limits 
changing, cpuset mems added, mempolicy nodes changing, etc).

Thus, my introduction of oom_score_adj causes no regression for real-world 
users of /proc/pid/oom_adj and allows users of cgroups and mempolicies a 
much more powerful interface to tune oom killing priority.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

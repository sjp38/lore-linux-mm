Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5990F900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 14:13:36 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p3EIDUbo001418
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 11:13:31 -0700
Received: from pwi9 (pwi9.prod.google.com [10.241.219.9])
	by wpaz9.hot.corp.google.com with ESMTP id p3EID4qi016595
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 11:13:29 -0700
Received: by pwi9 with SMTP id 9so697531pwi.10
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 11:13:25 -0700 (PDT)
Date: Thu, 14 Apr 2011 11:13:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/4] forkbomb killer
In-Reply-To: <BANLkTikj9EcEQTmz6vDBAW6oGnqyhnCkSQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1104141039590.5878@chino.kir.corp.google.com>
References: <20110329101234.54d5d45a.kamezawa.hiroyu@jp.fujitsu.com> <BANLkTi=pMapbVoUO6+7nUEg1bY4fb844-A@mail.gmail.com> <20110414092033.0809.A69D9226@jp.fujitsu.com> <20110414093549.80539260.kamezawa.hiroyu@jp.fujitsu.com>
 <BANLkTikj9EcEQTmz6vDBAW6oGnqyhnCkSQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Thu, 14 Apr 2011, Minchan Kim wrote:

> Unfortunately, we didn't have a slot to discuss the oom and forkbomb.
> So, personally, I talked it with some guys(who we know very well :) )
> for a moment during lunch time at LSF/MM. It seems he doesn't feel
> strongly we really need it and still I am not sure it, either.
> 

I'm not sure who you're referring to here, but I don't think we should 
ignore forkbomb vulnerabilities that exist in the kernel because you 
talked to a guy and he doesn't think we need it.  I know you have 
particularly taken an interest in this thread, so I also know that's not 
what you're saying, but I'm not sure what you meant by the above.  I think 
we _must_ address forkbomb issues, whether it's in the oom killer or 
elsewhere, if it causes negative effects for other users on the machine as 
it appears is possible in Andrey's test case.

When I was doing the oom killer rewrite, I included my own forkbomb killer 
in early revisions and removed it because there was a thought that it 
would negatively impact webservers or other processes that fork thousands 
of threads for a very legitimate purpose.  The old oom killer also 
attempted to prefer killing children of a forkbomb first, but its method 
was error-prone because it factored the size of each child's VM into the 
parent and that could unfairly penalize the parent for high priority work.

It seems like there are a few common principles that everyone would agree 
with:

 - forkbombs need only be addressed when oom, 

 - forkbombs don't need complex handling when isolated to a memcg,

 - forkbombs should be handled automatically without mandatory 
   intervention by the admin, and

 - forkbombs should result in the entire process tree being killed.

If that's the case, then the appropriate place for such a feature would be 
in the oom killer by extending oom_badness() to detect forkbombs and then 
in oom_kill_process() to kill the parent process and all children instead 
of its default of sacrificing a child first.

The absolute simplest form would be to implement a threshold similar to 
what is done in Kame's patchset where previous history is declared as 
forgotten.  Then, add a jiffies member to struct task_struct and, on 
fork(), one of two things would happen:

 - if the jiffies value is less than a system-wide predefined forkbomb
   threshold, increment a counter in the same struct, or

 - if the jiffies value is greater than the threshold, clear the counter 
   and update the jiffies value.

This is lightweight and approximates how many children a parent has forked 
in the most recent time period.  On oom, a preliminary tasklist scan could 
accumulate all of the counts and charge them up its ancestory as long as 
each successive parent has a jiffies value less than the forkbomb 
threshold.

If a task has a cumulative fork count that exceeds a threshold, it is 
declared as a forkbomb and specially handled.  (Once the forkbomb is 
identified, it would be trivial to SIGKILL it and all of its children to 
limit the damage.)  If no task exceeds the threshold, the forkbomb killer 
is a no-op and the oom killer proceeds as it does today.

The key is to implement the correct thresholds, especially the threshold 
to identify a parent as a forkbomb.  That's not trivial, is 1,000 forks in 
one second a forkbomb?  10,000?  If the system is oom and a process and 
its children have forked 10,000 threads in the past second, I think it 
would be sane to kill it even if another process is using 95% of RAM, for 
example, since the loss of work is relatively small and if we really do 
want to start that thread with 10,000 forks/sec in oom conditions, then it 
places the burden of freeing enough memory to do so on the user instead of 
the kernel where it is more appropriate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

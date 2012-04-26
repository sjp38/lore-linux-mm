Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 107746B0083
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 04:44:41 -0400 (EDT)
Date: Thu, 26 Apr 2012 10:44:37 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, oom: avoid checking set of allowed nodes twice when
 selecting a victim
Message-ID: <20120426084437.GB6867@tiehlicka.suse.cz>
References: <alpine.DEB.2.00.1204031633460.8112@chino.kir.corp.google.com>
 <20120412140137.GA32729@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1204241605570.17792@chino.kir.corp.google.com>
 <20120425080611.GA11068@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1204251346160.29822@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1204251346160.29822@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Wed 25-04-12 13:59:28, David Rientjes wrote:
[...]
> /proc/pid/oom_score certainly doesn't care about cpusets or memcg and 
> exports only oom scores in a global context, anything else would be 
> inconsistent.  It only cares about whether the thread is init or another 
> kthread because they are ineligible. 

OK, your patch makes more sense in this context because the allowed
nodes check is skipped completely (memcg test is disabled already by
memcg==NULL). You are right that this is inconsistent because we did
considered allowed nodes of the process reading the file but we ignored
memcg it belongs to. So it is neither local view of the reading process
nor the global view.
The changelog doesn't mention this side effect and it wasn't obvious to
me.

> So let's leave /proc/pid/oom_score out of this.
> 
> That's the function of oom_badness(): to assign a point value for a 
> specific process to determine the highest priority for oom kill.  It 
> shouldn't care about the context of the oom kill; and that's why 
> /proc/pid/oom_score, which is always global, doesn't care.
> 
> Now tell me what's clearer in terms of the code: calling 
> oom_unkillable_task() to determine the context of the oom kill explicitly 
> where it matters or calling either oom_badness() or __oom_badness() and 
> remembering what the heck the difference between the two is.

OK, fair enough. I was trapped in the mindset where oom_badness took
care of the task filtering as well. That's why I added another layer
(__oom_badness) which only calculates the score. 
But you are right it could end up being more confusing than explicitly
requiring to _always_ check the context before calling oom_badness.

> You're patch also wouldn't compile because you've removed the declaration 
> of "points" from __oom_badness(), which actually uses it, to 
> oom_badness(), which doesn't use it, for no apparent reason.

The patch was just an illustration and I made it explicit by noting it
was untested.

Thanks and I'm sorry if this was a high priority fix that got stalled
just because of my query.
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

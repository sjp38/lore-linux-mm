Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 24CEB6B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 17:01:53 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] oom: skip frozen tasks
Date: Fri, 26 Aug 2011 23:03:38 +0200
References: <20110823073101.6426.77745.stgit@zurg> <20110826085610.GA9083@tiehlicka.suse.cz> <alpine.DEB.2.00.1108260218050.14732@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1108260218050.14732@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201108262303.38923.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Friday, August 26, 2011, David Rientjes wrote:
> On Fri, 26 Aug 2011, Michal Hocko wrote:
> 
> > Let's give all frozen tasks a bonus (OOM_SCORE_ADJ_MAX/2) so that we do
> > not consider them unless really necessary and if we really pick up one
> > then thaw its threads before we try to kill it.
> > 
> 
> I don't like arbitrary heuristics like this because they polluted the old 
> oom killer before it was rewritten and made it much more unpredictable.  
> The only heuristic it includes right now is a bonus for root tasks so that 
> when two processes have nearly the same amount of memory usage (within 3% 
> of available memory), the non-root task is chosen instead.
> 
> This bonus is actually saying that a single frozen task can use up to 50% 
> more of the machine's capacity in a system-wide oom condition than the 
> task that will now be killed instead.  That seems excessive.
> 
> I do like the idea of automatically thawing the task though and if that's 
> possible then I don't think we need to manipulate the badness heuristic at 
> all.  I know that wouldn't be feasible when we've frozen _all_ threads and 
> that's why we have oom_killer_disable(), but we'll have to check with 
> Rafael to see if something like this could work.  Rafael?

That depends a good deal on when the thawing happens and what the thawed
task can do before being killed.  For example, if the thawing happens
while devices are suspended and the thawed task accesses a driver through
ioctl(), for example, the purpose of freezing will be defeated.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

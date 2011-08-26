Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 426866B016B
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 08:59:33 -0400 (EDT)
Date: Fri, 26 Aug 2011 14:59:28 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: skip frozen tasks
Message-ID: <20110826125928.GE9083@tiehlicka.suse.cz>
References: <alpine.DEB.2.00.1108241226550.31357@chino.kir.corp.google.com>
 <20110825091920.GA22564@tiehlicka.suse.cz>
 <20110825151818.GA4003@redhat.com>
 <20110825164758.GB22564@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1108251404130.18747@chino.kir.corp.google.com>
 <20110826070946.GA7280@tiehlicka.suse.cz>
 <20110826085610.GA9083@tiehlicka.suse.cz>
 <4E576F65.5060009@openvz.org>
 <20110826104827.GC9083@tiehlicka.suse.cz>
 <4E579541.6060607@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E579541.6060607@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri 26-08-11 16:44:49, Konstantin Khlebnikov wrote:
> Michal Hocko wrote:
> >On Fri 26-08-11 14:03:17, Konstantin Khlebnikov wrote:
> >>Michal Hocko wrote:
> >>
> >>>@@ -450,6 +459,10 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
> >>>  			pr_err("Kill process %d (%s) sharing same memory\n",
> >>>  				task_pid_nr(q), q->comm);
> >>>  			task_unlock(q);
> >>>+
> >>>+			if (frozen(q))
> >>>+				thaw_process(q);
> >>>+
> >>
> >>We must thaw task strictly after sending SIGKILL.
> >
> >Sounds reasonable.
> >
> >>But anyway I think this is a bad idea.
> >
> >Why?
> 
> Refrigerator may be used for digging in task's internal structures,
> so such digger may be very surprised if somebody suddenly thaws this task.

That is something similar why I mentioned that we probably want to
give it some oom bonus. Nevertheless we have to be carefull about
that. Someone could freeze a memory hog just to hide it from OOM which
would have much worse consequences than if such app disappeared while
somebody is looking at it while it is frozen.
This has to be balanced somehow.

> 
> >
> >>
> >>>  			force_sig(SIGKILL, q);
> >>>  		}
> >>>
> >
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

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

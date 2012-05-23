Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 984206B0083
	for <linux-mm@kvack.org>; Wed, 23 May 2012 18:37:20 -0400 (EDT)
Date: Wed, 23 May 2012 15:37:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch v2] mm, oom: normalize oom scores to oom_score_adj scale
 only for userspace
Message-Id: <20120523153718.b70bb762.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1205230014450.9290@chino.kir.corp.google.com>
References: <20120426193551.GA24968@redhat.com>
	<alpine.DEB.2.00.1204261437470.28376@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1205031513400.1631@chino.kir.corp.google.com>
	<20120503222949.GA13762@redhat.com>
	<alpine.DEB.2.00.1205171432250.6951@chino.kir.corp.google.com>
	<20120517145022.a99f41e8.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1205230014450.9290@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 23 May 2012 00:15:03 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> The oom_score_adj scale ranges from -1000 to 1000 and represents the
> proportion of memory available to the process at allocation time.  This
> means an oom_score_adj value of 300, for example, will bias a process as
> though it was using an extra 30.0% of available memory and a value of
> -350 will discount 35.0% of available memory from its usage.
> 
> The oom killer badness heuristic also uses this scale to report the oom
> score for each eligible process in determining the "best" process to
> kill.  Thus, it can only differentiate each process's memory usage by
> 0.1% of system RAM.
> 
> On large systems, this can end up being a large amount of memory: 256MB
> on 256GB systems, for example.
> 
> This can be fixed by having the badness heuristic to use the actual
> memory usage in scoring threads and then normalizing it to the
> oom_score_adj scale for userspace.  This results in better comparison
> between eligible threads for kill and no change from the userspace
> perspective.
> 
> ...
>
> @@ -367,12 +354,13 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  		}
>  
>  		points = oom_badness(p, memcg, nodemask, totalpages);
> -		if (points > *ppoints) {
> +		if (points > chosen_points) {
>  			chosen = p;
> -			*ppoints = points;
> +			chosen_points = points;
>  		}
>  	} while_each_thread(g, p);
>  
> +	*ppoints = chosen_points * 1000 / totalpages;
>  	return chosen;
>  }
>  

It's still not obvious that we always avoid the divide-by-zero here. 
If there's some weird way of convincing constrained_alloc() to look at
an empty nodemask, or a nodemask which covers only empty nodes then
blam.

Now, it's probably the case that this is a can't-happen but that
guarantee would be pretty convoluted and fragile?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

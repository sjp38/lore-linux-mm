Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 730FC6B004F
	for <linux-mm@kvack.org>; Sun,  4 Dec 2011 17:04:41 -0500 (EST)
Date: Mon, 5 Dec 2011 09:04:36 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [3.2-rc3] OOM killer doesn't kill the obvious memory hog
Message-ID: <20111204220436.GB7046@dastard>
References: <20111201093644.GW7046@dastard>
 <20111201185001.5bf85500.kamezawa.hiroyu@jp.fujitsu.com>
 <20111201124634.GY7046@dastard>
 <alpine.DEB.2.00.1112011432110.27778@chino.kir.corp.google.com>
 <20111202015921.GZ7046@dastard>
 <20111202033148.GA7046@dastard>
 <20111202144441.4c2ff29e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111202144441.4c2ff29e.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 02, 2011 at 02:44:41PM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 2 Dec 2011 14:31:48 +1100
> Dave Chinner <david@fromorbit.com> wrote:
> 
> > So, it's a distro bug - sshd should never be started from from udev
> > context because of this inherited oom_score_adj thing.
> > Interestingly, the ifup ssh restart script says this:
> > 
> > # We'd like to use 'reload' here, but it has some problems; see #502444.
> > if [ -x /usr/sbin/invoke-rc.d ]; then
> >         invoke-rc.d ssh restart >/dev/null 2>&1 || true
> > else
> >         /etc/init.d/ssh restart >/dev/null 2>&1 || true
> > fi
> > 
> > Bug 502444 describes the exact startup race condition that I've just
> > found. It does a ssh server restart because reload causes the sshd
> > server to fail to start if a start is currently in progress.  So,
> > rather than solving the start vs reload race condition, it got a
> > bandaid (use restart to restart sshd from the reload context) and
> > left it as a landmine.....
> > 
> 
> Thank you for chasing. 
> Hm, BTW, do you think this kind of tracepoint is useful for debugging ?
> This patch is just an example.

Definitely a good idea, because not all applications have logging
like sshd does.  Besides, the first thing I went looking for was
tracepoints. ;)

> 
> ==
> From ed565cbf842e0b30827fba7bfdbc724fe21d9d2d Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Fri, 2 Dec 2011 14:10:51 +0900
> Subject: [PATCH] oom_score_adj trace point.
> 
> oom_score_adj is set by some daemon and launch tasks ans inherited
> to applications, sometimes unexpectedly.
> 
> This patch is for debugging oom_score_adj inheritance. This
> adds trace points for oom_score_adj inheritance.
> 
>     bash-2501  [002]   448.860197: oom_score_adj_update: task 2501[bash] updates oom_score_adj=-1000
>     bash-2501  [002]   455.678190: oom_score_adj_inherited: new task 2527 inherited oom_score_adj -1000
>     ls-2527  [007]   455.678683: oom_score_task_rename: task 2527[bash] to [ls] oom_score_adj=-1000
>     bash-2501  [007]   461.632103: oom_score_adj_inherited: new task 2528 inherited oom_score_adj -1000
>     bash-2501  [007]   461.632335: oom_score_adj_inherited: new task 2529 inherited oom_score_adj -1000
>     ls-2528  [003]   461.632983: oom_score_task_rename: task 2528[bash] to [ls] oom_score_adj=-1000
>     less-2529  [005]   461.633086: oom_score_task_rename: task 2529[bash] to [less] oom_score_adj=-1000
>     bash-2501  [004]   474.888710: oom_score_adj_update: task 2501[bash] updates oom_score_adj=0
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Dave Chinner <dchinner@redhat.com>

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

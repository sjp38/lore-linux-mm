Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2E98D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 08:29:02 -0400 (EDT)
Received: by iyf13 with SMTP id 13so5010614iyf.14
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 05:29:00 -0700 (PDT)
Date: Mon, 28 Mar 2011 21:28:47 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/5] Revert "oom: give the dying task a higher priority"
Message-ID: <20110328122847.GB1892@barrios-desktop>
References: <20110322200657.B064.A69D9226@jp.fujitsu.com>
 <20110324152757.GC1938@barrios-desktop>
 <20110328184856.F078.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110328184856.F078.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Mon, Mar 28, 2011 at 06:48:13PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> > @@ -434,9 +452,17 @@ static int oom_kill_task(struct task_struct *p)
> >                 K(get_mm_counter(p->mm, MM_FILEPAGES)));
> >         task_unlock(p);
> >  
> > -       p->rt.time_slice = HZ; <<---- THIS
> > +
> >         set_tsk_thread_flag(p, TIF_MEMDIE);
> >         force_sig(SIGKILL, p);
> > +
> > +       /*
> > +        * We give our sacrificial lamb high priority and access to
> > +        * all the memory it needs. That way it should be able to
> > +        * exit() and clear out its resources quickly...
> > +        */
> > +       boost_dying_task_prio(p, mem);
> > +
> >         return 0;
> >  }
> > 
> > At that time, I thought that routine is meaningless in non-RT scheduler.
> > So I Cced Peter but don't get the answer.
> > I just want to confirm it.
> > 
> > Do you still think it's meaningless? 
> 
> In short, yes.
> 
> 
> > so you remove it when you revert 93b43fa5508?
> > Then, this isn't just revert patch but revert + killing meaningless code patch.
> 
> If you want, I'd like to rename a patch title. That said, we can't revert
> 93b43fa5508 simple cleanly, several patches depend on it. therefore I
> reverted it manualy. and at that time, I don't want to resurrect
> meaningless logic. anyway it's no matter. Luis is preparing new patches.
> therefore we will get the same end result. :)

I don't mind it, either. :)
I just want to make sure the meaningless logic.
Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

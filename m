Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id A03516B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 05:39:44 -0500 (EST)
Received: by mail-oi0-f44.google.com with SMTP id k206so44780329oia.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 02:39:44 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id gw3si11501541obc.14.2016.01.29.02.39.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 29 Jan 2016 02:39:43 -0800 (PST)
Subject: Re: [PATCH 4/3] mm, oom: drop the last allocation attempt before out_of_memory
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
	<1454013603-3682-1-git-send-email-mhocko@kernel.org>
	<20160128213634.GA4903@cmpxchg.org>
	<alpine.DEB.2.10.1601281508380.31035@chino.kir.corp.google.com>
	<20160128235110.GA5805@cmpxchg.org>
In-Reply-To: <20160128235110.GA5805@cmpxchg.org>
Message-Id: <201601291939.FGH00544.MVQOOtOHLFFJFS@I-love.SAKURA.ne.jp>
Date: Fri, 29 Jan 2016 19:39:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, hannes@cmpxchg.org, rientjes@google.com
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, mgorman@suse.de, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Johannes Weiner wrote:
> On Thu, Jan 28, 2016 at 03:19:08PM -0800, David Rientjes wrote:
> > On Thu, 28 Jan 2016, Johannes Weiner wrote:
> >
> > > The check has to happen while holding the OOM lock, otherwise we'll
> > > end up killing much more than necessary when there are many racing
> > > allocations.
> > >
> >
> > Right, we need to try with ALLOC_WMARK_HIGH after oom_lock has been
> > acquired.
> >
> > The situation is still somewhat fragile, however, but I think it's
> > tangential to this patch series.  If the ALLOC_WMARK_HIGH allocation fails
> > because an oom victim hasn't freed its memory yet, and then the TIF_MEMDIE
> > thread isn't visible during the oom killer's tasklist scan because it has
> > exited, we still end up killing more than we should.  The likelihood of
> > this happening grows with the length of the tasklist.
> >
> > Perhaps we should try testing watermarks after a victim has been selected
> > and immediately before killing?  (Aside: we actually carry an internal
> > patch to test mem_cgroup_margin() in the memcg oom path after selecting a
> > victim because we have been hit with this before in the memcg path.)

Yes. Moving final testing to after selecting an OOM victim can reduce the
possibility of killing more OOM victims than we need. But unfortunately, it is
likely that memory becomes available (i.e. get_page_from_freelist() succeeds)
during dump_header() is printing OOM messages using printk(), for printk() is
a slow operation compared to selecting a victim. This happens very much later
counted from the moment the victim cleared TIF_MEMDIE.

We can avoid killing more OOM victims than we need if we move final testing to
after printing OOM messages, but we can't avoid printing OOM messages when we
don't kill a victim. Maybe this is not a problem if we do

  pr_err("But did not kill any process ...")

instead of

  do_send_sig_info(SIGKILL);
  mark_oom_victim();
  pr_err("Killed process %d (%s) ...")

when final testing succeeded.

> >
> > I would think that retrying with ALLOC_WMARK_HIGH would be enough memory
> > to deem that we aren't going to immediately reenter an oom condition so
> > the deferred killing is a waste of time.
> >
> > The downside is how sloppy this would be because it's blurring the line
> > between oom killer and page allocator.  We'd need the oom killer to return
> > the selected victim to the page allocator, try the allocation, and then
> > call oom_kill_process() if necessary.

I assumed that Michal wants to preserve the boundary between the OOM killer
and the page allocator. Therefore, I proposed a patch
( http://lkml.kernel.org/r/201512291559.HGA46749.VFOFSOHLMtFJQO@I-love.SAKURA.ne.jp )
which tries to manage it without returning a victim and without depending on
TIF_MEMDIE or oom_victims.

>
> https://lkml.org/lkml/2015/3/25/40
>
> We could have out_of_memory() wait until the number of outstanding OOM
> victims drops to 0. Then __alloc_pages_may_oom() doesn't relinquish
> the lock until its kill has been finalized:
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 914451a..4dc5b9d 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -892,7 +892,9 @@ bool out_of_memory(struct oom_control *oc)
>  		 * Give the killed process a good chance to exit before trying
>  		 * to allocate memory again.
>  		 */
> -		schedule_timeout_killable(1);
> +		if (!test_thread_flag(TIF_MEMDIE))
> +			wait_event_timeout(oom_victims_wait,
> +					   !atomic_read(&oom_victims), HZ);
>  	}
>  	return true;
>  }
>

oom_victims became 0 does not mean that memory became available (i.e.
get_page_from_freelist() will succeed). I think this patch wants some
effort for trying to reduce possibility of killing more OOM victims
than we need.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

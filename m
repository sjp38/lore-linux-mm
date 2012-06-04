Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 954C66B005C
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 07:39:50 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so7524637pbb.14
        for <linux-mm@kvack.org>; Mon, 04 Jun 2012 04:39:49 -0700 (PDT)
Date: Mon, 4 Jun 2012 04:38:12 -0700
From: Anton Vorontsov <cbouatmailru@gmail.com>
Subject: Re: [PATCH 0/5] Some vmevent fixes...
Message-ID: <20120604113811.GA4291@lizard>
References: <20120507121527.GA19526@lizard>
 <4FA82056.2070706@gmail.com>
 <CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com>
 <CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com>
 <CAOJsxLFAavdDbiLnYRwe+QiuEHSD62+Sz6LJTk+c3J9gnLVQ_w@mail.gmail.com>
 <CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com>
 <CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com>
 <20120601122118.GA6128@lizard>
 <alpine.LFD.2.02.1206032125320.1943@tux.localdomain>
 <4FCC7592.9030403@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4FCC7592.9030403@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Pekka Enberg <penberg@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Mon, Jun 04, 2012 at 05:45:06PM +0900, Minchan Kim wrote:
[...]
> AFAIK, low memory notifier is started for replacing android lowmemory killer.
> At the same time, other folks want use it generally.
> As I look through android low memory killer, it's not too bad except some point.
> 
> 1. It should not depend on shrink_slab. If we need, we can add some hook in vmscan.c directly instead of shrink_slab.
> 2. We can use out_of_memory instead of custom victim selection/killing function. If we need,
>    we can change out_of_memory interface little bit for passing needed information to select victim.
> 3. calculation for available pages
> 
> 1) and 2) would make android low memory killer very general and 3) can meet each folk's requirement, I believe.
> 
> Anton, I expect you already investigated android low memory killer so maybe you know pros and cons of each solution.
> Could you convince us "why we need vmevent" and "why can't android LMK do it?"

Note that 1) and 2) are not problems per se, it's just implementation
details, easy stuff. Vmevent is basically an ABI/API, and I didn't
hear anybody who would object to vmevent ABI idea itself. More than
this, nobody stop us from implementing in-kernel vmevent API, and
make Android Lowmemory killer use it, if we want to.

The real problem is not with vmevent. Today there are two real problems:

a) Gathering proper statistics from the kernel. Both cgroups and vmstat
   have issues. Android lowmemory killer has the same problems w/ the
   statistics as vmevent, it uses vmstat, so by no means Android
   low memory killer is better or easier in this regard.
   (And cgroups has issues w/ slab accounting, plus some folks don't
   want memcg at all, since it has runtime and memory-wise costs.)

b) Interpreting this statistics. We can't provide one, universal
   "low memory" definition that would work for everybody.
   (Btw, your "levels" based low memory grading actually sounds
   the same as mine RECLAIMABLE_CACHE_PAGES and
   RECLAIMABLE_CACHE_PAGES_NOIO idea, i.e.
   http://lkml.indiana.edu/hypermail/linux/kernel/1205.0/02751.html
   so personally I like the idea of level-based approach, based
   on available memory *cost*.)

So, you see, all these issues are valid for vmevent, cgroups and
android low memory killer.

> KOSAKI, AFAIRC, you are a person who hates android low memory killer.
> Why do you hate it? If it solve problems I mentioned, do you have a concern, still?
> If so, please, list up.
> 
> Android low memory killer is proved solution for a long time, at least embedded area(So many android phone already have used it) so I think improving it makes sense to me rather than inventing new wheel.

Yes, nobody throws Android lowmemory killer away. And recently I fixed
a bunch of issues in its tasks traversing and killing code. Now it's
just time to "fix" statistics gathering and interpretation issues,
and I see vmevent as a good way to do just that, and then we
can either turn Android lowmemory killer driver to use the vmevent
in-kernel API (so it will become just a "glue" between notifications
and killing functions), or use userland daemon.

Note that memcg has notifications as well, so it's another proof that
there is a demand for this stuff outside of embedded world, and going
with ad-hoc, custom "low memory killer" is simple and tempting approach,
but it doesn't solve any real problems.

> Frankly speaking, I don't know vmevent's other use cases except low memory notification 

I won't speak for realistic use-cases, but that is what comes to
mind:

- DB can grow its caches/in-memory indexes infinitely, and start dropping
  them on demand (based on internal LRU list, for example). No more
  guessed/static configuration for DB daemons?
- Assuming VPS hosting w/ dynamic resources management, notifications
  would be useful to readjust resources?
- On desktops, apps can drop their caches on demand if they want to
  and can avoid swap activity?

Thanks,

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

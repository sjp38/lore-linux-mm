Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 68C4F6B005A
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 09:02:01 -0400 (EDT)
Date: Fri, 12 Oct 2012 15:01:59 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: oom: fix totalpages calculation for
 memory.swappiness==0
Message-ID: <20121012130159.GB22083@dhcp22.suse.cz>
References: <20121011085038.GA29295@dhcp22.suse.cz>
 <1349945859-1350-1-git-send-email-mhocko@suse.cz>
 <CAHGf_=oC-kptra69KbSPZzrYi5rbEbhwVZ=We1eLDcSV-=HeBw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHGf_=oC-kptra69KbSPZzrYi5rbEbhwVZ=We1eLDcSV-=HeBw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 11-10-12 18:36:26, KOSAKI Motohiro wrote:
> On Thu, Oct 11, 2012 at 4:57 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > oom_badness takes totalpages argument which says how many pages are
> > available and it uses it as a base for the score calculation. The value
> > is calculated by mem_cgroup_get_limit which considers both limit and
> > total_swap_pages (resp. memsw portion of it).
> >
> > This is usually correct but since fe35004f (mm: avoid swapping out
> > with swappiness==0) we do not swap when swappiness is 0 which means
> > that we cannot really use up all the totalpages pages. This in turn
> > confuses oom score calculation if the memcg limit is much smaller than
> > the available swap because the used memory (capped by the limit) is
> > negligible comparing to totalpages so the resulting score is too small
> > if adj!=0 (typically task with CAP_SYS_ADMIN or non zero oom_score_adj).
> > A wrong process might be selected as result.
> >
> > The same issue exists for the global oom killer as well but it is not
> > that problematic as the amount of the RAM is usually much bigger than
> > the swap space.
> >
> > The problem can be worked around by checking mem_cgroup_swappiness==0
> > and not considering swap at all in such a case.
> >
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > Acked-by: David Rientjes <rientjes@google.com>
> > Cc: stable [3.5+]
> 
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

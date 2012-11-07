Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 87D086B004D
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 17:46:43 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id k11so1002305eaa.14
        for <linux-mm@kvack.org>; Wed, 07 Nov 2012 14:46:42 -0800 (PST)
Date: Wed, 7 Nov 2012 23:46:40 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] memcg: oom: fix totalpages calculation for
 memory.swappiness==0
Message-ID: <20121107224640.GE26382@dhcp22.suse.cz>
References: <20121011085038.GA29295@dhcp22.suse.cz>
 <1349945859-1350-1-git-send-email-mhocko@suse.cz>
 <20121015220354.GA11682@dhcp22.suse.cz>
 <20121107141025.2ac62206.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121107141025.2ac62206.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 07-11-12 14:10:25, Andrew Morton wrote:
> On Tue, 16 Oct 2012 00:04:08 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > As Kosaki correctly pointed out, the glogal reclaim doesn't have this
> > issue because we _do_ swap on swappinnes==0 so the swap space has
> > to be considered. So the v2 is just acks + changelog fix.
> > 
> > Changes since v1
> > - drop a note about global swappiness affected as well from the
> >   changelog
> > - stable needs 3.2+ rather than 3.5+ because the fe35004f has been
> >   backported to stable
> > ---
> > >From c2ae4849f09dbfda6b61472c6dd1fd8c2fe8ac81 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Wed, 10 Oct 2012 15:46:54 +0200
> > Subject: [PATCH] memcg: oom: fix totalpages calculation for
> >  memory.swappiness==0
> > 
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
> > The problem can be worked around by checking mem_cgroup_swappiness==0
> > and not considering swap at all in such a case.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > Acked-by: David Rientjes <rientjes@google.com>
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Cc: stable [3.2+]
> 
> That's "Cc: <stable@vger.kernel.org>", please.

Will do next time.

> It's unobvious from the changelog that a -stable backport is really
> needed.  The bug looks pretty obscure and has been there for a long
> time.

Yes but it is not _that_ long since fe35004f made it into stable trees
(e.g. 3.2.29).
The reason why we probably do not see many reports is because people
didn't get used to swappiness==0 really works these days - especially
with memcg where it means _really_ no swapping.

> Realistically, is anyone likely to hurt from this?

The primary motivation for the fix was a real report by a customer.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

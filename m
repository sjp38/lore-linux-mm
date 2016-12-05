Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B0F176B025E
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 07:49:58 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u144so17772618wmu.1
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 04:49:58 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id a5si14838138wji.77.2016.12.05.04.49.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 04:49:57 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id m203so15716550wma.3
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 04:49:57 -0800 (PST)
Date: Mon, 5 Dec 2016 13:49:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmscan: add cond_resched into shrink_node_memcg
Message-ID: <20161205124955.GG30758@dhcp22.suse.cz>
References: <20161202095841.16648-1-mhocko@kernel.org>
 <CAKTCnz=K8QG69tKB8yStiZypBzcvnE=wW+25xuo9f_HZNzPtDg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKTCnz=K8QG69tKB8yStiZypBzcvnE=wW+25xuo9f_HZNzPtDg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Boris Zhmurov <bb@kernelpanic.ru>, "Christopher S. Aker" <caker@theshore.net>, Donald Buczek <buczek@molgen.mpg.de>, Paul Menzel <pmenzel@molgen.mpg.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

[CC Paul - sorry I've tried to save you from more emails...]

On Mon 05-12-16 23:44:27, Balbir Singh wrote:
> >
> > Hi,
> > there were multiple reportes of the similar RCU stalls. Only Boris has
> > confirmed that this patch helps in his workload. Others might see a
> > slightly different issue and that should be investigated if it is the
> > case. As pointed out by Paul [1] cond_resched might be not sufficient
> > to silence RCU stalls because that would require a real scheduling.
> > This is a separate problem, though, and Paul is working with Peter [2]
> > to resolve it.
> >
> > Anyway, I believe that this patch should be a good start because it
> > really seems that nr_taken=0 during the LRU isolation can be triggered
> > in the real life. All reporters are agreeing to start seeing this issue
> > when moving on to 4.8 kernel which might be just a coincidence or a
> > different behavior of some subsystem. Well, MM has moved from zone to
> > node reclaim but I couldn't have found any direct relation to that
> > change.
> >
> > [1] http://lkml.kernel.org/r/20161130142955.GS3924@linux.vnet.ibm.com
> > [2] http://lkml.kernel.org/r/20161201124024.GB3924@linux.vnet.ibm.com
> >
> >  mm/vmscan.c | 2 ++
> >  1 file changed, 2 insertions(+)
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index c05f00042430..c4abf08861d2 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2362,6 +2362,8 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
> >                         }
> >                 }
> >
> > +               cond_resched();
> > +
> 
> I see a cond_resched_rcu_qs() as a part of linux next inside the while
> (nr[..]) loop.

This is a left over from Paul's initial attempt to fix this issue. I
expect him to drop his patch from his tree. He has considered it
experimental anyway.

> Do we need this as well?

Paul is working with Peter to make cond_resched general and cover RCU
stalls even when cond_resched doesn't schedule because there is no
runnable task.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

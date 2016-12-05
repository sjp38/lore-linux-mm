Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 50DD26B0038
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 11:16:33 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id xr1so64773300wjb.7
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 08:16:33 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m76si659861wmi.48.2016.12.05.08.16.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 08:16:31 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB5G8anB101966
	for <linux-mm@kvack.org>; Mon, 5 Dec 2016 11:16:29 -0500
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2759gxr7ra-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 05 Dec 2016 11:16:29 -0500
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 5 Dec 2016 09:16:28 -0700
Date: Mon, 5 Dec 2016 08:16:29 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm, vmscan: add cond_resched into shrink_node_memcg
Reply-To: paulmck@linux.vnet.ibm.com
References: <20161202095841.16648-1-mhocko@kernel.org>
 <CAKTCnz=K8QG69tKB8yStiZypBzcvnE=wW+25xuo9f_HZNzPtDg@mail.gmail.com>
 <20161205124955.GG30758@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161205124955.GG30758@dhcp22.suse.cz>
Message-Id: <20161205161629.GD3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Balbir Singh <bsingharora@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Boris Zhmurov <bb@kernelpanic.ru>, "Christopher S. Aker" <caker@theshore.net>, Donald Buczek <buczek@molgen.mpg.de>, Paul Menzel <pmenzel@molgen.mpg.de>

On Mon, Dec 05, 2016 at 01:49:55PM +0100, Michal Hocko wrote:
> [CC Paul - sorry I've tried to save you from more emails...]
> 
> On Mon 05-12-16 23:44:27, Balbir Singh wrote:
> > >
> > > Hi,
> > > there were multiple reportes of the similar RCU stalls. Only Boris has
> > > confirmed that this patch helps in his workload. Others might see a
> > > slightly different issue and that should be investigated if it is the
> > > case. As pointed out by Paul [1] cond_resched might be not sufficient
> > > to silence RCU stalls because that would require a real scheduling.
> > > This is a separate problem, though, and Paul is working with Peter [2]
> > > to resolve it.
> > >
> > > Anyway, I believe that this patch should be a good start because it
> > > really seems that nr_taken=0 during the LRU isolation can be triggered
> > > in the real life. All reporters are agreeing to start seeing this issue
> > > when moving on to 4.8 kernel which might be just a coincidence or a
> > > different behavior of some subsystem. Well, MM has moved from zone to
> > > node reclaim but I couldn't have found any direct relation to that
> > > change.
> > >
> > > [1] http://lkml.kernel.org/r/20161130142955.GS3924@linux.vnet.ibm.com
> > > [2] http://lkml.kernel.org/r/20161201124024.GB3924@linux.vnet.ibm.com
> > >
> > >  mm/vmscan.c | 2 ++
> > >  1 file changed, 2 insertions(+)
> > >
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index c05f00042430..c4abf08861d2 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -2362,6 +2362,8 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
> > >                         }
> > >                 }
> > >
> > > +               cond_resched();
> > > +
> > 
> > I see a cond_resched_rcu_qs() as a part of linux next inside the while
> > (nr[..]) loop.
> 
> This is a left over from Paul's initial attempt to fix this issue. I
> expect him to drop his patch from his tree. He has considered it
> experimental anyway.

To prevent further confusion, I am dropping these patches from my tree:

80c099e11c19 ("mm: Prevent shrink_node() RCU CPU stall warnings")
34c53f5cd399 ("mm: Prevent shrink_node_memcg() RCU CPU stall warnings")

If you need them, please feel free to pull them in.

Given that I don't have those, I am dropping this one as well:

f2a471ffc8a8 ("rcu: Allow boot-time use of cond_resched_rcu_qs()")

If you need it, please let me know.

> > Do we need this as well?
> 
> Paul is working with Peter to make cond_resched general and cover RCU
> stalls even when cond_resched doesn't schedule because there is no
> runnable task.

And 0day just told me that my current attempt gets a 227% increase in
context switches on the unlink tests in LTP, so back to the drawing
board...

						Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

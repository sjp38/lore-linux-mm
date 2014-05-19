Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 404F56B0036
	for <linux-mm@kvack.org>; Mon, 19 May 2014 11:45:26 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so3773901eei.14
        for <linux-mm@kvack.org>; Mon, 19 May 2014 08:45:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h6si15463477eew.161.2014.05.19.08.45.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 May 2014 08:45:24 -0700 (PDT)
Date: Mon, 19 May 2014 17:45:22 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix swapcache charge from kernel thread context
Message-ID: <20140519154522.GE3017@dhcp22.suse.cz>
References: <1400488076-3820-1-git-send-email-mhocko@suse.cz>
 <20140519144946.GA1714@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140519144946.GA1714@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Branimir Maksimovic <branimir.maksimovic@gmail.com>, Stephan Kulow <coolo@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon 19-05-14 08:49:47, Johannes Weiner wrote:
> On Mon, May 19, 2014 at 10:27:56AM +0200, Michal Hocko wrote:
[...]
> > [1] - http://marc.info/?l=linux-mm&m=139463617808941&w=2
> > 
> > Fixes: 03583f1a631c (3.15-rc1)
> 
> Shouldn't this be the same format as other commit references?
> 
> Fixes: 03583f1a631c ("memcg: remove unnecessary !mm check from try_get_mem_cgroup_from_mm()")

No idea, I just wanted to make clear to which kernel this applies to.
But other users seem to use the long version as above. So I will change
it.

> > Reported-and-tested-by: Stephan Kulow <coolo@suse.com>
> > Reported-by: Branimir Maksimovic <branimir.maksimovic@gmail.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > ---
> >  mm/memcontrol.c | 26 +++++++++++++-------------
> >  1 file changed, 13 insertions(+), 13 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 2cb81478d30c..2248a648a127 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1061,9 +1061,17 @@ static struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
> >  
> >  	rcu_read_lock();
> >  	do {
> > -		memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
> > -		if (unlikely(!memcg))
> > +		/*
> > +		 * Page cache or loopback insertions can happen without an
> > +		 * actual mm context, e.g. during disk probing on boot
> > +		 */
> 
> Please include the other usecases:
> 
> /*
>  * Page cache insertions can happen without an
>  * actual mm context, e.g. during disk probing
>  * on boot, loopback IO, acct() writes etc.
>  */

OK.
 
> Otherwise,
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks!

---

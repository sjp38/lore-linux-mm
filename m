Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id A06556B0253
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 03:09:20 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so34403697pdj.3
        for <linux-mm@kvack.org>; Sat, 11 Jul 2015 00:09:20 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id pw8si18059395pdb.85.2015.07.11.00.09.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Jul 2015 00:09:19 -0700 (PDT)
Date: Sat, 11 Jul 2015 10:09:06 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 7/8] memcg: get rid of mm_struct::owner
Message-ID: <20150711070905.GO2436@esperanza>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
 <1436358472-29137-8-git-send-email-mhocko@kernel.org>
 <20150708173251.GG2436@esperanza>
 <20150709140941.GG13872@dhcp22.suse.cz>
 <20150710075400.GN2436@esperanza>
 <20150710124520.GA29540@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150710124520.GA29540@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 10, 2015 at 02:45:20PM +0200, Michal Hocko wrote:
> On Fri 10-07-15 10:54:00, Vladimir Davydov wrote:
> > On Thu, Jul 09, 2015 at 04:09:41PM +0200, Michal Hocko wrote:
> > > On Wed 08-07-15 20:32:51, Vladimir Davydov wrote:
> > > > On Wed, Jul 08, 2015 at 02:27:51PM +0200, Michal Hocko wrote:
> > [...]
> > > > > @@ -474,7 +519,7 @@ static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
> > > > >  		return;
> > > > >  
> > > > >  	rcu_read_lock();
> > > > > -	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
> > > > > +	memcg = rcu_dereference(mm->memcg);
> > > > >  	if (unlikely(!memcg))
> > > > >  		goto out;
> > > > >  
> > > > 
> > > > If I'm not mistaken, mm->memcg equals NULL for any task in the root
> > > > memory cgroup
> > > 
> > > right
> > > 
> > > > (BTW, it it's true, it's worth mentioning in the comment
> > > > to mm->memcg definition IMO). As a result, we won't account the stats
> > > > for such tasks, will we?
> > > 
> > > well spotted! This is certainly a bug. There are more places which are
> > > checking for mm->memcg being NULL and falling back to root_mem_cgroup. I
> > > think it would be better to simply use root_mem_cgroup right away. We
> > > can setup init_mm.memcg = root_mem_cgroup during initialization and be
> > > done with it. What do you think? The diff is in the very end of the
> > > email (completely untested yet).
> > 
> > I'd prefer initializing init_mm.memcg to root_mem_cgroup. This way we
> > wouldn't have to check whether mm->memcg is NULL or not here and there,
> > which would make the code cleaner IMO.
> 
> So the patch I've posted will not work as a simple boot test told me. We
> are initializing root_mem_cgroup too late. This will be more complicated.
> I will leave this idea outside of this patch series and will come up
> with a separate patch which will clean this up later. I will update the
> doc discouraging any use of mm->memcg outside of memcg and use accessor
> functions instead. There is only one currently (mm/debug.c) and this is
> used only to print the pointer which is safe.

Why can't we make root_mem_cgroup statically allocated? AFAICS it's a
common practice - e.g. see blkcg_root, root_task_group.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

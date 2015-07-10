Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id C94B36B0038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 08:45:25 -0400 (EDT)
Received: by wgxm20 with SMTP id m20so65122640wgx.3
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 05:45:25 -0700 (PDT)
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id c6si3272854wie.78.2015.07.10.05.45.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jul 2015 05:45:24 -0700 (PDT)
Received: by wgjx7 with SMTP id x7so248230242wgj.2
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 05:45:23 -0700 (PDT)
Date: Fri, 10 Jul 2015 14:45:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 7/8] memcg: get rid of mm_struct::owner
Message-ID: <20150710124520.GA29540@dhcp22.suse.cz>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
 <1436358472-29137-8-git-send-email-mhocko@kernel.org>
 <20150708173251.GG2436@esperanza>
 <20150709140941.GG13872@dhcp22.suse.cz>
 <20150710075400.GN2436@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150710075400.GN2436@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 10-07-15 10:54:00, Vladimir Davydov wrote:
> On Thu, Jul 09, 2015 at 04:09:41PM +0200, Michal Hocko wrote:
> > On Wed 08-07-15 20:32:51, Vladimir Davydov wrote:
> > > On Wed, Jul 08, 2015 at 02:27:51PM +0200, Michal Hocko wrote:
> [...]
> > > > @@ -474,7 +519,7 @@ static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
> > > >  		return;
> > > >  
> > > >  	rcu_read_lock();
> > > > -	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
> > > > +	memcg = rcu_dereference(mm->memcg);
> > > >  	if (unlikely(!memcg))
> > > >  		goto out;
> > > >  
> > > 
> > > If I'm not mistaken, mm->memcg equals NULL for any task in the root
> > > memory cgroup
> > 
> > right
> > 
> > > (BTW, it it's true, it's worth mentioning in the comment
> > > to mm->memcg definition IMO). As a result, we won't account the stats
> > > for such tasks, will we?
> > 
> > well spotted! This is certainly a bug. There are more places which are
> > checking for mm->memcg being NULL and falling back to root_mem_cgroup. I
> > think it would be better to simply use root_mem_cgroup right away. We
> > can setup init_mm.memcg = root_mem_cgroup during initialization and be
> > done with it. What do you think? The diff is in the very end of the
> > email (completely untested yet).
> 
> I'd prefer initializing init_mm.memcg to root_mem_cgroup. This way we
> wouldn't have to check whether mm->memcg is NULL or not here and there,
> which would make the code cleaner IMO.

So the patch I've posted will not work as a simple boot test told me. We
are initializing root_mem_cgroup too late. This will be more complicated.
I will leave this idea outside of this patch series and will come up
with a separate patch which will clean this up later. I will update the
doc discouraging any use of mm->memcg outside of memcg and use accessor
functions instead. There is only one currently (mm/debug.c) and this is
used only to print the pointer which is safe.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

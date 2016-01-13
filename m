Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id F4136828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 04:36:04 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id b14so361875226wmb.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 01:36:04 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id cr4si739944wjb.184.2016.01.13.01.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 01:36:04 -0800 (PST)
Received: by mail-wm0-f41.google.com with SMTP id f206so285995140wmf.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 01:36:03 -0800 (PST)
Date: Wed, 13 Jan 2016 10:36:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 2/3] oom: Do not sacrifice already OOM killed children
Message-ID: <20160113093601.GB28942@dhcp22.suse.cz>
References: <1452632425-20191-1-git-send-email-mhocko@kernel.org>
 <1452632425-20191-3-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1601121644250.28831@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1601121644250.28831@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Tue 12-01-16 16:45:35, David Rientjes wrote:
> On Tue, 12 Jan 2016, Michal Hocko wrote:
> 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 2b9dc5129a89..8bca0b1e97f7 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -671,6 +671,63 @@ static bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
> >  }
> >  
> >  #define K(x) ((x) << (PAGE_SHIFT-10))
> > +
> > +/*
> > + * If any of victim's children has a different mm and is eligible for kill,
> > + * the one with the highest oom_badness() score is sacrificed for its
> > + * parent.  This attempts to lose the minimal amount of work done while
> > + * still freeing memory.
> > + */
> > +static struct task_struct *
> > +try_to_sacrifice_child(struct oom_control *oc, struct task_struct *victim,
> > +		       unsigned long totalpages, struct mem_cgroup *memcg)
> > +{
> > +	struct task_struct *child_victim = NULL;
> > +	unsigned int victim_points = 0;
> > +	struct task_struct *t;
> > +
> > +	read_lock(&tasklist_lock);
> > +	for_each_thread(victim, t) {
> > +		struct task_struct *child;
> > +
> > +		list_for_each_entry(child, &t->children, sibling) {
> > +			unsigned int child_points;
> > +
> > +			/*
> > +			 * Skip over already OOM killed children as this hasn't
> > +			 * helped to resolve the situation obviously.
> > +			 */
> > +			if (test_tsk_thread_flag(child, TIF_MEMDIE) ||
> > +					fatal_signal_pending(child) ||
> > +					task_will_free_mem(child))
> > +				continue;
> > +
> 
> What guarantees that child had time to exit after it has been oom killed 
> (better yet, what guarantees that it has even scheduled after it has been 
> oom killed)?  It seems like this would quickly kill many children 
> unnecessarily.

If the child hasn't released any memory after all the allocator attempts to
free a memory, which takes quite some time, then what is the advantage of
waiting even more and possibly get stuck? This is a heuristic, we should
have killed the selected victim but we have chosen to reduce the impact by
selecting the child process instead. If that hasn't led to any
improvement I believe we should move on rather than looping on
potentially unresolvable situation _just because_ of the said heuristic.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

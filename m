Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8E1828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 19:42:35 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id uo6so351096124pac.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 16:42:35 -0800 (PST)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id xe7si5457708pab.3.2016.01.13.16.42.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 16:42:34 -0800 (PST)
Received: by mail-pf0-x229.google.com with SMTP id n128so89791635pfn.3
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 16:42:34 -0800 (PST)
Date: Wed, 13 Jan 2016 16:42:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 2/3] oom: Do not sacrifice already OOM killed children
In-Reply-To: <20160113093601.GB28942@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1601131640090.3406@chino.kir.corp.google.com>
References: <1452632425-20191-1-git-send-email-mhocko@kernel.org> <1452632425-20191-3-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1601121644250.28831@chino.kir.corp.google.com> <20160113093601.GB28942@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Wed, 13 Jan 2016, Michal Hocko wrote:

> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index 2b9dc5129a89..8bca0b1e97f7 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -671,6 +671,63 @@ static bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
> > >  }
> > >  
> > >  #define K(x) ((x) << (PAGE_SHIFT-10))
> > > +
> > > +/*
> > > + * If any of victim's children has a different mm and is eligible for kill,
> > > + * the one with the highest oom_badness() score is sacrificed for its
> > > + * parent.  This attempts to lose the minimal amount of work done while
> > > + * still freeing memory.
> > > + */
> > > +static struct task_struct *
> > > +try_to_sacrifice_child(struct oom_control *oc, struct task_struct *victim,
> > > +		       unsigned long totalpages, struct mem_cgroup *memcg)
> > > +{
> > > +	struct task_struct *child_victim = NULL;
> > > +	unsigned int victim_points = 0;
> > > +	struct task_struct *t;
> > > +
> > > +	read_lock(&tasklist_lock);
> > > +	for_each_thread(victim, t) {
> > > +		struct task_struct *child;
> > > +
> > > +		list_for_each_entry(child, &t->children, sibling) {
> > > +			unsigned int child_points;
> > > +
> > > +			/*
> > > +			 * Skip over already OOM killed children as this hasn't
> > > +			 * helped to resolve the situation obviously.
> > > +			 */
> > > +			if (test_tsk_thread_flag(child, TIF_MEMDIE) ||
> > > +					fatal_signal_pending(child) ||
> > > +					task_will_free_mem(child))
> > > +				continue;
> > > +
> > 
> > What guarantees that child had time to exit after it has been oom killed 
> > (better yet, what guarantees that it has even scheduled after it has been 
> > oom killed)?  It seems like this would quickly kill many children 
> > unnecessarily.
> 
> If the child hasn't released any memory after all the allocator attempts to
> free a memory, which takes quite some time, then what is the advantage of
> waiting even more and possibly get stuck?

No, we don't rely on implicit page allocator behavior or implementation to 
decide when additional processes should randomly be killed.  It is quite 
simple to get dozens of processes oom killed if your patch is introduced, 
just as it is possible to get dozens of processes oom killed unnecessarily 
if you remove TIF_MEMDIE checks from select_bad_process().  If you are 
concerned about the child never exiting, then it is quite simple to 
provide access to memory reserves in the page allocator in such 
situations, this is no different than TIF_MEMDIE threads failing to exit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

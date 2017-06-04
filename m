Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1322D6B02C3
	for <linux-mm@kvack.org>; Sun,  4 Jun 2017 15:44:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id m79so43837244pfg.13
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 12:44:15 -0700 (PDT)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id 59si5229228plb.446.2017.06.04.12.44.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Jun 2017 12:44:14 -0700 (PDT)
Received: by mail-pf0-x229.google.com with SMTP id n23so73303357pfb.2
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 12:44:14 -0700 (PDT)
Date: Sun, 4 Jun 2017 12:44:11 -0700
From: Yu Zhao <yuzhao@google.com>
Subject: Re: [PATCH] memcg: refactor mem_cgroup_resize_limit()
Message-ID: <20170604194411.GB15369@google.com>
References: <20170601230212.30578-1-yuzhao@google.com>
 <7c1be205-837f-30f9-9161-9c8ed4689216@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7c1be205-837f-30f9-9161-9c8ed4689216@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <n.borisov.lkml@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 02, 2017 at 10:32:52AM +0300, Nikolay Borisov wrote:
> 
> 
> On  2.06.2017 02:02, Yu Zhao wrote:
> > mem_cgroup_resize_limit() and mem_cgroup_resize_memsw_limit() have
> > identical logics. Refactor code so we don't need to keep two pieces
> > of code that does same thing.
> > 
> > Signed-off-by: Yu Zhao <yuzhao@google.com>
> > ---
> >  mm/memcontrol.c | 71 +++++++++------------------------------------------------
> >  1 file changed, 11 insertions(+), 60 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 94172089f52f..a4f0daaff704 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2422,13 +2422,14 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
> >  static DEFINE_MUTEX(memcg_limit_mutex);
> >  
> >  static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
> > -				   unsigned long limit)
> > +				   unsigned long limit, bool memsw)
> >  {
> >  	unsigned long curusage;
> >  	unsigned long oldusage;
> >  	bool enlarge = false;
> >  	int retry_count;
> >  	int ret;
> > +	struct page_counter *counter = memsw ? &memcg->memsw : &memcg->memory;
> >  
> >  	/*
> >  	 * For keeping hierarchical_reclaim simple, how long we should retry
> > @@ -2438,58 +2439,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
> >  	retry_count = MEM_CGROUP_RECLAIM_RETRIES *
> >  		      mem_cgroup_count_children(memcg);
> >  
> > -	oldusage = page_counter_read(&memcg->memory);
> > -
> > -	do {
> > -		if (signal_pending(current)) {
> > -			ret = -EINTR;
> > -			break;
> > -		}
> > -
> > -		mutex_lock(&memcg_limit_mutex);
> > -		if (limit > memcg->memsw.limit) {
> > -			mutex_unlock(&memcg_limit_mutex);
> > -			ret = -EINVAL;
> > -			break;
> > -		}
> > -		if (limit > memcg->memory.limit)
> > -			enlarge = true;
> > -		ret = page_counter_limit(&memcg->memory, limit);
> > -		mutex_unlock(&memcg_limit_mutex);
> > -
> > -		if (!ret)
> > -			break;
> > -
> > -		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, true);
> > -
> > -		curusage = page_counter_read(&memcg->memory);
> > -		/* Usage is reduced ? */
> > -		if (curusage >= oldusage)
> > -			retry_count--;
> > -		else
> > -			oldusage = curusage;
> > -	} while (retry_count);
> > -
> > -	if (!ret && enlarge)
> > -		memcg_oom_recover(memcg);
> > -
> > -	return ret;
> > -}
> > -
> > -static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
> > -					 unsigned long limit)
> > -{
> > -	unsigned long curusage;
> > -	unsigned long oldusage;
> > -	bool enlarge = false;
> > -	int retry_count;
> > -	int ret;
> > -
> > -	/* see mem_cgroup_resize_res_limit */
> > -	retry_count = MEM_CGROUP_RECLAIM_RETRIES *
> > -		      mem_cgroup_count_children(memcg);
> > -
> > -	oldusage = page_counter_read(&memcg->memsw);
> > +	oldusage = page_counter_read(counter);
> >  
> >  	do {
> >  		if (signal_pending(current)) {
> > @@ -2498,22 +2448,23 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
> >  		}
> >  
> >  		mutex_lock(&memcg_limit_mutex);
> > -		if (limit < memcg->memory.limit) {
> > +		if (memsw ? limit < memcg->memory.limit :
> > +			    limit > memcg->memsw.limit) {
> 
> No, just no. Please createa a local variable and use that. Using the
> ternary operator in an 'if' statement is just ugly!

Thanks. It is uncommon but seems no aesthetic difference to me. I'll
replace it with an extra variable and resend the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

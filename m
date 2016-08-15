Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9406B0005
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 10:04:43 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 93so119764875qtg.1
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 07:04:43 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id o198si15486113wmd.84.2016.08.15.07.04.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 07:04:41 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id q128so11304964wma.1
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 07:04:41 -0700 (PDT)
Date: Mon, 15 Aug 2016 16:04:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH stable-4.4 1/3] mm: memcontrol: fix cgroup creation
 failure after many small jobs
Message-ID: <20160815140439.GF3360@dhcp22.suse.cz>
References: <1470995779-10064-1-git-send-email-mhocko@kernel.org>
 <1470995779-10064-2-git-send-email-mhocko@kernel.org>
 <20160815123407.GA1153@cmpxchg.org>
 <20160815124615.GD3360@dhcp22.suse.cz>
 <20160815133748.GA3775@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160815133748.GA3775@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Stable tree <stable@vger.kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Nikolay Borisov <kernel@kyup.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon 15-08-16 09:37:48, Johannes Weiner wrote:
> On Mon, Aug 15, 2016 at 02:46:19PM +0200, Michal Hocko wrote:
> > On Mon 15-08-16 08:34:07, Johannes Weiner wrote:
> > > Hi Michal, thanks for doing this. There is only one issue I can see:
> > > 
> > > On Fri, Aug 12, 2016 at 11:56:17AM +0200, Michal Hocko wrote:
> > > > @@ -4171,17 +4211,27 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
> > > >  	if (!memcg)
> > > >  		return NULL;
> > > >  
> > > > +	memcg->id.id = idr_alloc(&mem_cgroup_idr, NULL,
> > > > +				 1, MEM_CGROUP_ID_MAX,
> > > > +				 GFP_KERNEL);
> > > > +	if (memcg->id.id < 0)
> > > > +		goto out_free;
> > > > +
> > > >  	memcg->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
> > > >  	if (!memcg->stat)
> > > > -		goto out_free;
> > > > +		goto out_idr;
> > > >  
> > > >  	if (memcg_wb_domain_init(memcg, GFP_KERNEL))
> > > >  		goto out_free_stat;
> > > >  
> > > > +	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
> > > 
> > > This publishes the memcg object too early. Before 4.5, the memcg is
> > > not fully initialized in mem_cgroup_alloc(). You have to move the
> > > idr_replace() down to that function (and idr_remove() on free_out).
> > 
> > You are right. I am just wondering whether it matters. Nobody should see
> > the id so nobody will be looking it up, no?
> 
> Page cache shadow entries refer to these IDs weakly. It's possible to
> refault with a recently recycled memcg ID and crash. That's why we do
> the whole alloc(NULL) -> replace(memcg) dance in the first place.

Ahh, OK, you are right. So I have moved the idr_replace into
mem_cgroup_css_alloc. Does the following incremental diff looks better?
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 41fb6a0d2d03..7d6ac40efa81 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4239,12 +4239,6 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	if (!memcg)
 		return NULL;
 
-	memcg->id.id = idr_alloc(&mem_cgroup_idr, NULL,
-				 1, MEM_CGROUP_ID_MAX,
-				 GFP_KERNEL);
-	if (memcg->id.id < 0)
-		goto out_free;
-
 	memcg->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
 	if (!memcg->stat)
 		goto out_idr;
@@ -4252,13 +4246,16 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	if (memcg_wb_domain_init(memcg, GFP_KERNEL))
 		goto out_free_stat;
 
-	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
+	memcg->id.id = idr_alloc(&mem_cgroup_idr, NULL,
+				 1, MEM_CGROUP_ID_MAX,
+				 GFP_KERNEL);
+	if (memcg->id.id < 0)
+		goto out_free_stat;
+
 	return memcg;
 
 out_free_stat:
 	free_percpu(memcg->stat);
-out_idr:
-	idr_remove(&mem_cgroup_idr, memcg->id.id);
 out_free:
 	kfree(memcg);
 	return NULL;
@@ -4340,9 +4337,11 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
 #endif
+	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
 	return &memcg->css;
 
 free_out:
+	idr_remove(&mem_cgroup_idr, memcg->id.id);
 	__mem_cgroup_free(memcg);
 	return ERR_PTR(error);
 }

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

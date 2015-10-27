Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 48E9B82F64
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 14:25:12 -0400 (EDT)
Received: by wikq8 with SMTP id q8so224501278wik.1
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 11:25:11 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id 138si3115305wmi.22.2015.10.27.11.25.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 11:25:11 -0700 (PDT)
Received: by wijp11 with SMTP id p11so226941799wij.0
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 11:25:10 -0700 (PDT)
Date: Tue, 27 Oct 2015 19:25:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: Fix thresholds for 32b architectures.
Message-ID: <20151027182508.GA23297@dhcp22.suse.cz>
References: <1445942234-11175-1-git-send-email-mhocko@kernel.org>
 <20151027162331.GA7749@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151027162331.GA7749@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shli@fb.com>, Ben Hutchings <ben@decadent.org.uk>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

On Tue 27-10-15 09:23:31, Johannes Weiner wrote:
[...]
> > Fixes: 424cdc141380 ("memcg: convert threshold to bytes")
> > Fixes: 3e32cb2e0a12 ("mm: memcontrol: lockless page counters")
> > CC: stable@vger.kernel.org
> > Reported-by: Ben Hutchings <ben@decadent.org.uk>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks!

> 
> > +++ b/mm/memcontrol.c
> > @@ -2802,7 +2802,7 @@ static unsigned long tree_stat(struct mem_cgroup *memcg,
> >  	return val;
> >  }
> >  
> > -static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
> > +static inline unsigned long mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
> >  {
> >  	u64 val;
> 
> Minor nit, but this should probably be unsigned long now.

Yeah, I've missed this. Andrew, do you want me to post a new version or
you can fold a trivial update here?
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2823cafc269e..f4c09c4e895f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2804,7 +2804,7 @@ static unsigned long tree_stat(struct mem_cgroup *memcg,
 
 static inline unsigned long mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 {
-	u64 val;
+	unsigned long val;
 
 	if (mem_cgroup_is_root(memcg)) {
 		val = tree_stat(memcg, MEM_CGROUP_STAT_CACHE);

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

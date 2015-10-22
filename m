Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 8D9BA6B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 08:29:49 -0400 (EDT)
Received: by wijp11 with SMTP id p11so29553064wij.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 05:29:49 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id y16si43379864wij.7.2015.10.22.05.29.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 05:29:48 -0700 (PDT)
Date: Thu, 22 Oct 2015 08:29:42 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: eliminate root memory.current
Message-ID: <20151022122942.GA23792@cmpxchg.org>
References: <1445453394-15156-1-git-send-email-hannes@cmpxchg.org>
 <20151022090756.GB26854@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151022090756.GB26854@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

On Thu, Oct 22, 2015 at 11:07:56AM +0200, Michal Hocko wrote:
> On Wed 21-10-15 14:49:54, Johannes Weiner wrote:
> > memory.current on the root level doesn't add anything that wouldn't be
> > more accurate and detailed using system statistics. It already doesn't
> > include slabs, and it'll be a pain to keep in sync when further memory
> > types are accounted in the memory controller. Remove it.
> > 
> > Note that this applies to the new unified hierarchy interface only.
> 
> OK, I can understand your reasoning, other knobs are !root as well.
> 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> After the bug mentioned below is fixed
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> > @@ -5022,7 +5022,7 @@ static void mem_cgroup_bind(struct cgroup_subsys_state *root_css)
> >  static u64 memory_current_read(struct cgroup_subsys_state *css,
> >  			       struct cftype *cft)
> >  {
> > -	return mem_cgroup_usage(mem_cgroup_from_css(css), false);
> > +	return page_counter_read(&mem_cgroup_from_css(css)->memory);
> 
> We want that in bytes though.

Right you are, thanks for catching that.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c71fe40..2cd149e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5022,7 +5022,9 @@ static void mem_cgroup_bind(struct cgroup_subsys_state *root_css)
 static u64 memory_current_read(struct cgroup_subsys_state *css,
 			       struct cftype *cft)
 {
-	return page_counter_read(&mem_cgroup_from_css(css)->memory);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	return (u64)page_counter_read(&memcg->memory) * PAGE_SIZE;
 }
 
 static int memory_low_show(struct seq_file *m, void *v)
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

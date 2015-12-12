Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id B53C46B0038
	for <linux-mm@kvack.org>; Sat, 12 Dec 2015 12:21:07 -0500 (EST)
Received: by wmpp66 with SMTP id p66so11320202wmp.1
        for <linux-mm@kvack.org>; Sat, 12 Dec 2015 09:21:07 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i9si33666884wjx.173.2015.12.12.09.21.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 Dec 2015 09:21:06 -0800 (PST)
Date: Sat, 12 Dec 2015 12:20:57 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/4] mm: memcontrol: reign in the CONFIG space madness
Message-ID: <20151212172057.GA7997@cmpxchg.org>
References: <1449863653-6546-1-git-send-email-hannes@cmpxchg.org>
 <1449863653-6546-2-git-send-email-hannes@cmpxchg.org>
 <20151212163332.GC28521@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151212163332.GC28521@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Sat, Dec 12, 2015 at 07:33:32PM +0300, Vladimir Davydov wrote:
> On Fri, Dec 11, 2015 at 02:54:11PM -0500, Johannes Weiner wrote:
> > What CONFIG_INET and CONFIG_LEGACY_KMEM guard inside the memory
> > controller code is insignificant, having these conditionals is not
> > worth the complication and fragility that comes with them.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> 
> > @@ -4374,17 +4342,11 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
> >  {
> >  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> >  
> > -#ifdef CONFIG_INET
> >  	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
> >  		static_branch_dec(&memcg_sockets_enabled_key);
> > -#endif
> > -
> > -	memcg_free_kmem(memcg);
> 
> I wonder where the second call to memcg_free_kmem comes from. Luckily,
> it couldn't result in a breakage. And now it's removed.

Lol, I had to double check my trees to see what's going on as I don't
remember this being part of the patch. But it looks like the double
free came from the "net: drop tcp_memcontrol.c" patch and I must have
removed it again during conflict resolution when rebasing this patch
on top of yours. I must have thought git's auto-merge added it.

However, this causes an underflow of the kmem static branch, so we
will have to fix this directly in "net: drop tcp_memcontrol.c".

Andrew, could you please pick this up? However, it's important to also
then remove the hunk above from THIS patch, the one that deletes the
excessive memcg_free_kmem(). We need exactly one memcg_free_kmem() in
mem_cgroup_css_free(). :-)

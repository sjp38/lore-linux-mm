Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8B39482F7D
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 18:11:40 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id u7so66630943pfb.1
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 15:11:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f7si5359517pat.37.2015.12.22.15.11.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 15:11:39 -0800 (PST)
Date: Tue, 22 Dec 2015 15:11:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/4] mm: memcontrol: reign in the CONFIG space madness
Message-Id: <20151222151138.0c35816e53b0f0ad940568bb@linux-foundation.org>
In-Reply-To: <20151212172057.GA7997@cmpxchg.org>
References: <1449863653-6546-1-git-send-email-hannes@cmpxchg.org>
	<1449863653-6546-2-git-send-email-hannes@cmpxchg.org>
	<20151212163332.GC28521@esperanza>
	<20151212172057.GA7997@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Sat, 12 Dec 2015 12:20:57 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Sat, Dec 12, 2015 at 07:33:32PM +0300, Vladimir Davydov wrote:
> > On Fri, Dec 11, 2015 at 02:54:11PM -0500, Johannes Weiner wrote:
> > > What CONFIG_INET and CONFIG_LEGACY_KMEM guard inside the memory
> > > controller code is insignificant, having these conditionals is not
> > > worth the complication and fragility that comes with them.
> > > 
> > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > 
> > Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> > 
> > > @@ -4374,17 +4342,11 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
> > >  {
> > >  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> > >  
> > > -#ifdef CONFIG_INET
> > >  	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
> > >  		static_branch_dec(&memcg_sockets_enabled_key);
> > > -#endif
> > > -
> > > -	memcg_free_kmem(memcg);
> > 
> > I wonder where the second call to memcg_free_kmem comes from. Luckily,
> > it couldn't result in a breakage. And now it's removed.
> 
> Lol, I had to double check my trees to see what's going on as I don't
> remember this being part of the patch. But it looks like the double
> free came from the "net: drop tcp_memcontrol.c" patch and I must have
> removed it again during conflict resolution when rebasing this patch
> on top of yours. I must have thought git's auto-merge added it.
> 
> However, this causes an underflow of the kmem static branch, so we
> will have to fix this directly in "net: drop tcp_memcontrol.c".
> 
> Andrew, could you please pick this up? However, it's important to also
> then remove the hunk above from THIS patch, the one that deletes the
> excessive memcg_free_kmem(). We need exactly one memcg_free_kmem() in
> mem_cgroup_css_free(). :-)

So you want to retain
mm-memcontrol-reign-in-the-config-space-madness.patch's removal of the
ifdef CONFIG_INET?


What I have is

Against net-drop-tcp_memcontrolc.patch:

--- a/mm/memcontrol.c~net-drop-tcp_memcontrolc-fix
+++ a/mm/memcontrol.c
@@ -4421,8 +4421,6 @@ static void mem_cgroup_css_free(struct c
 		static_branch_dec(&memcg_sockets_enabled_key);
 #endif
 
-	memcg_free_kmem(memcg);
-
 	__mem_cgroup_free(memcg);
 }
 

and against mm-memcontrol-reign-in-the-config-space-madness.patch:

--- a/mm/memcontrol.c~mm-memcontrol-reign-in-the-config-space-madness-fix
+++ a/mm/memcontrol.c
@@ -4380,6 +4380,8 @@ static void mem_cgroup_css_free(struct c
 	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
 		static_branch_dec(&memcg_sockets_enabled_key);
 
+	memcg_free_kmem(memcg);
+
 	if (memcg->tcp_mem.active)
 		static_branch_dec(&memcg_sockets_enabled_key);
 

Producing

static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
{
	struct mem_cgroup *memcg = mem_cgroup_from_css(css);

	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
		static_branch_dec(&memcg_sockets_enabled_key);

	memcg_free_kmem(memcg);

	if (memcg->tcp_mem.active)
		static_branch_dec(&memcg_sockets_enabled_key);

	__mem_cgroup_free(memcg);
}

And I did s/reign/rein/;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

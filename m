Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7FADF6B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 09:18:31 -0500 (EST)
Received: by mail-lb0-f182.google.com with SMTP id l4so7207463lbv.13
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 06:18:30 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p16si2690764wiw.104.2015.01.23.06.18.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jan 2015 06:18:29 -0800 (PST)
Date: Fri, 23 Jan 2015 09:18:17 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mmotm 2015-01-22-15-04: qemu failure due to 'mm: memcontrol:
 remove unnecessary soft limit tree node test'
Message-ID: <20150123141817.GA22926@phnom.home.cmpxchg.org>
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org>
 <20150123050802.GB22751@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150123050802.GB22751@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, cl@linux.com

Hi Guenter,

CC'ing Christoph for slub-stuff:

On Thu, Jan 22, 2015 at 09:08:02PM -0800, Guenter Roeck wrote:
> On Thu, Jan 22, 2015 at 03:05:17PM -0800, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2015-01-22-15-04 has been uploaded to
> > 
> >    http://www.ozlabs.org/~akpm/mmotm/
> > 
> qemu test for ppc64 fails with
> 
> Unable to handle kernel paging request for data at address 0x0000af50
> Faulting instruction address: 0xc00000000089d5d4
> Oops: Kernel access of bad area, sig: 11 [#1]
> 
> with the following call stack:
> 
> Call Trace:
> [c00000003d32f920] [c00000000089d588] .__slab_alloc.isra.44+0x7c/0x6f4
> (unreliable)
> [c00000003d32fa90] [c00000000020cf8c] .kmem_cache_alloc_node_trace+0x12c/0x3b0
> [c00000003d32fb60] [c000000000bceeb4] .mem_cgroup_init+0x128/0x1b0
> [c00000003d32fbf0] [c00000000000a2b4] .do_one_initcall+0xd4/0x260
> [c00000003d32fce0] [c000000000ba26a8] .kernel_init_freeable+0x244/0x32c
> [c00000003d32fdb0] [c00000000000ac24] .kernel_init+0x24/0x140
> [c00000003d32fe30] [c000000000009564] .ret_from_kernel_thread+0x58/0x74
> 
> bisect log:

[...]

> # first bad commit: [a40d0d2cf21e2714e9a6c842085148c938bf36ab] mm: memcontrol: remove unnecessary soft limit tree node test

The change in question is this:

    mm: memcontrol: remove unnecessary soft limit tree node test
    
    kzalloc_node() automatically falls back to nodes with suitable memory.
    
    Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
    Acked-by: Michal Hocko <mhocko@suse.cz>
    Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fb9788af4a3e..10db4a654d68 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4539,13 +4539,10 @@ static void __init mem_cgroup_soft_limit_tree_init(void)
 {
        struct mem_cgroup_tree_per_node *rtpn;
        struct mem_cgroup_tree_per_zone *rtpz;
-       int tmp, node, zone;
+       int node, zone;
 
        for_each_node(node) {
-               tmp = node;
-               if (!node_state(node, N_NORMAL_MEMORY))
-                       tmp = -1;
-               rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, tmp);
+               rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, node);
                BUG_ON(!rtpn);
 
                soft_limit_tree.rb_tree_per_node[node] = rtpn;

--

Is the assumption of this patch wrong?  Does the specified node have
to be online for the fallback to work?

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

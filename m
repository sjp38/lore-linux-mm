Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 575A16B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 11:09:32 -0400 (EDT)
Received: by wwj40 with SMTP id 40so283927wwj.26
        for <linux-mm@kvack.org>; Wed, 20 Jul 2011 08:09:29 -0700 (PDT)
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1107200950270.1472@router.home>
References: <20110720121612.28888.38970.stgit@localhost6>
	 <alpine.DEB.2.00.1107201611010.3528@tiger> <20110720134342.GK5349@suse.de>
	 <alpine.DEB.2.00.1107200854390.32737@router.home>
	 <1311170893.2338.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1107200950270.1472@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Jul 2011 17:09:22 +0200
Message-ID: <1311174562.2338.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>

Le mercredi 20 juillet 2011 A  09:52 -0500, Christoph Lameter a A(C)crit :
> On Wed, 20 Jul 2011, Eric Dumazet wrote:
> 
> > > Slab's kmem_cache is configured with an array of NR_CPUS which is the
> > > maximum nr of cpus supported. Some distros support 4096 cpus in order to
> > > accomodate SGI machines. That array then will have the size of 4096 * 8 =
> > > 32k
> >
> > We currently support a dynamic schem for the possible nodes :
> >
> > cache_cache.buffer_size = offsetof(struct kmem_cache, nodelists) +
> > 	nr_node_ids * sizeof(struct kmem_list3 *);
> >
> > We could have a similar trick to make the real size both depends on
> > nr_node_ids and nr_cpu_ids.
> >
> > (struct kmem_cache)->array would become a pointer.
> 
> We should be making it a per cpu pointer like slub then. I looked at what
> it would take to do so a couple of month ago but it was quite invasive.
> 

Lets try this first patch, simple enough : No need to setup percpu data
for a one time use structure...

[PATCH] slab: remove one NR_CPUS dependency

Reduce high order allocations in do_tune_cpucache() for some setups.
(NR_CPUS=4096 -> we need 64KB)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Pekka Enberg <penberg@kernel.org>
CC: Christoph Lameter <cl@linux.com>
---
 mm/slab.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index d96e223..862bd12 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3933,7 +3933,7 @@ fail:
 
 struct ccupdate_struct {
 	struct kmem_cache *cachep;
-	struct array_cache *new[NR_CPUS];
+	struct array_cache *new[0];
 };
 
 static void do_ccupdate_local(void *info)
@@ -3955,7 +3955,8 @@ static int do_tune_cpucache(struct kmem_cache *cachep, int limit,
 	struct ccupdate_struct *new;
 	int i;
 
-	new = kzalloc(sizeof(*new), gfp);
+	new = kzalloc(sizeof(*new) + nr_cpu_ids * sizeof(struct array_cache *),
+		      gfp);
 	if (!new)
 		return -ENOMEM;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

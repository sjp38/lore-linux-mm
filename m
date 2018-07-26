Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 312C16B0010
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 19:25:16 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id r2-v6so1829138pgp.3
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 16:25:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u21-v6si2204421pgm.230.2018.07.26.16.25.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 16:25:14 -0700 (PDT)
Date: Thu, 26 Jul 2018 16:25:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: Remove memcg_cgroup::id from IDR on
 mem_cgroup_css_alloc() failure
Message-Id: <20180726162512.6056b5d7c1d2a5fbff6ce214@linux-foundation.org>
In-Reply-To: <20180413125101.GO17484@dhcp22.suse.cz>
References: <ed75d18c-f516-2feb-53a8-6d2836e1da59@virtuozzo.com>
	<20180413110200.GG17484@dhcp22.suse.cz>
	<06931a83-91d2-3dcf-31cf-0b98d82e957f@virtuozzo.com>
	<20180413112036.GH17484@dhcp22.suse.cz>
	<6dbc33bb-f3d5-1a46-b454-13c6f5865fcd@virtuozzo.com>
	<20180413113855.GI17484@dhcp22.suse.cz>
	<8a81c801-35c8-767d-54b0-df9f1ca0abc0@virtuozzo.com>
	<20180413115454.GL17484@dhcp22.suse.cz>
	<abfd4903-c455-fac2-7ed6-73707cda64d1@virtuozzo.com>
	<20180413121433.GM17484@dhcp22.suse.cz>
	<20180413125101.GO17484@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, hannes@cmpxchg.org, vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 13 Apr 2018 14:51:01 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 13-04-18 14:14:33, Michal Hocko wrote:
> [...]
> > Well, this is probably a matter of taste. I will not argue. I will not
> > object if Johannes is OK with your patch. But the whole thing confused
> > hell out of me so I would rather un-clutter it...
> 
> In other words, this
> 

This discussion has rather petered out.  afaict we're waiting for
hannes to offer an opinion?


From: Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: memcg: remove memcg_cgroup::id from IDR on mem_cgroup_css_alloc() failure

In case of memcg_online_kmem() failure, memcg_cgroup::id remains hashed in
mem_cgroup_idr even after memcg memory is freed.  This leads to leak of ID
in mem_cgroup_idr.

This patch adds removal into mem_cgroup_css_alloc(), which fixes the
problem.  For better readability, it adds a generic helper which is used
in mem_cgroup_alloc() and mem_cgroup_id_put_many() as well.

Link: http://lkml.kernel.org/r/152354470916.22460.14397070748001974638.stgit@localhost.localdomain
Fixes 73f576c04b94 ("mm: memcontrol: fix cgroup creation failure after many small jobs")
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memcontrol.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff -puN mm/memcontrol.c~memcg-remove-memcg_cgroup-id-from-idr-on-mem_cgroup_css_alloc-failure mm/memcontrol.c
--- a/mm/memcontrol.c~memcg-remove-memcg_cgroup-id-from-idr-on-mem_cgroup_css_alloc-failure
+++ a/mm/memcontrol.c
@@ -4037,6 +4037,14 @@ static struct cftype mem_cgroup_legacy_f
 
 static DEFINE_IDR(mem_cgroup_idr);
 
+static void mem_cgroup_id_remove(struct mem_cgroup *memcg)
+{
+	if (memcg->id.id > 0) {
+		idr_remove(&mem_cgroup_idr, memcg->id.id);
+		memcg->id.id = 0;
+	}
+}
+
 static void mem_cgroup_id_get_many(struct mem_cgroup *memcg, unsigned int n)
 {
 	VM_BUG_ON(atomic_read(&memcg->id.ref) <= 0);
@@ -4047,8 +4055,7 @@ static void mem_cgroup_id_put_many(struc
 {
 	VM_BUG_ON(atomic_read(&memcg->id.ref) < n);
 	if (atomic_sub_and_test(n, &memcg->id.ref)) {
-		idr_remove(&mem_cgroup_idr, memcg->id.id);
-		memcg->id.id = 0;
+		mem_cgroup_id_remove(memcg);
 
 		/* Memcg ID pins CSS */
 		css_put(&memcg->css);
@@ -4185,8 +4192,7 @@ static struct mem_cgroup *mem_cgroup_all
 	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
 	return memcg;
 fail:
-	if (memcg->id.id > 0)
-		idr_remove(&mem_cgroup_idr, memcg->id.id);
+	mem_cgroup_id_remove(memcg);
 	__mem_cgroup_free(memcg);
 	return NULL;
 }
@@ -4245,6 +4251,7 @@ mem_cgroup_css_alloc(struct cgroup_subsy
 
 	return &memcg->css;
 fail:
+	mem_cgroup_id_remove(memcg);
 	mem_cgroup_free(memcg);
 	return ERR_PTR(-ENOMEM);
 }
_

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1BF216B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 03:56:51 -0500 (EST)
Date: Thu, 15 Jan 2009 17:51:31 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH] memcg: get/put parents at create/free
Message-Id: <20090115175131.9542ae59.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090115172336.0ed780bb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090113184533.6ffd2af9.nishimura@mxp.nes.nec.co.jp>
	<20090114175121.275ecd59.nishimura@mxp.nes.nec.co.jp>
	<7602a77a9fc6b1e8757468048fde749a.squirrel@webmail-b.css.fujitsu.com>
	<20090115100330.37d89d3d.nishimura@mxp.nes.nec.co.jp>
	<20090115110044.3a863af8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115111420.8559bdb3.nishimura@mxp.nes.nec.co.jp>
	<20090115133814.a52460fa.nishimura@mxp.nes.nec.co.jp>
	<20090115164537.d402e95f.nishimura@mxp.nes.nec.co.jp>
	<20090115165453.271848d9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115171315.965da4e3.nishimura@mxp.nes.nec.co.jp>
	<20090115172336.0ed780bb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Jan 2009 17:23:36 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 15 Jan 2009 17:13:15 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > mem_cgroup_get ensures that the memcg that has been got can be accessed
> > even after the directory has been removed, but it doesn't ensure that parents
> > of it can be accessed: parents might have been freed already by rmdir.
> > 
> > This causes a bug in case of use_hierarchy==1, because res_counter_uncharge
> > climb up the tree.
> > 
> > This patch tries to fix this probrem by getting the parent at create, and
> > putting it at freeing.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> Seems very simple and promissive.
Thanks.

> But one nitpick
> 
> > ---
> >  mm/memcontrol.c |   29 ++++++++++++++++++++++++++++-
> >  1 files changed, 28 insertions(+), 1 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index fb62b43..a80ba68 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -202,6 +202,8 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
> >  
> >  static void mem_cgroup_get(struct mem_cgroup *mem);
> >  static void mem_cgroup_put(struct mem_cgroup *mem);
> > +static void mem_cgroup_get_parent(struct mem_cgroup *mem);
> > +static void mem_cgroup_put_parent(struct mem_cgroup *mem);
> >  
> >  static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
> >  					 struct page_cgroup *pc,
> > @@ -2185,10 +2187,34 @@ static void mem_cgroup_get(struct mem_cgroup *mem)
> >  
> >  static void mem_cgroup_put(struct mem_cgroup *mem)
> >  {
> > -	if (atomic_dec_and_test(&mem->refcnt))
> > +	if (atomic_dec_and_test(&mem->refcnt)) {
> > +		mem_cgroup_put_parent(mem);
> >  		__mem_cgroup_free(mem);
> > +	}
> > +}
> 
> Here, parent is freed before children is freed. Then,
> 
> ==
> 	if (atomic_dec_and_test(&mem->refcnt)) {
> 		struct mem_cgroup *parent = parent_mem_cgroup(mem);
> 		__mem_cgroup_free(mem);
> 		mem_cgroup_put(parent);
> 	}
> ==
> 
> Is maybe usual way.
> 
I see.

Thank you for your patient reviews.

Daisuke Nishimura.
===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

mem_cgroup_get ensures that the memcg that has been got can be accessed
even after the directory has been removed, but it doesn't ensure that parents
of it can be accessed: parents might have been freed already by rmdir.

This causes a bug in case of use_hierarchy==1, because res_counter_uncharge
climb up the tree.

This patch tries to fix this probrem by getting the parent at create, and
putting it at freeing.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   23 ++++++++++++++++++++++-
 1 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fb62b43..45e1b51 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -202,6 +202,8 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
 
 static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
+static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
+static void mem_cgroup_get_parent(struct mem_cgroup *mem);
 
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
 					 struct page_cgroup *pc,
@@ -2185,10 +2187,28 @@ static void mem_cgroup_get(struct mem_cgroup *mem)
 
 static void mem_cgroup_put(struct mem_cgroup *mem)
 {
-	if (atomic_dec_and_test(&mem->refcnt))
+	if (atomic_dec_and_test(&mem->refcnt)) {
+		struct mem_cgroup *parent = parent_mem_cgroup(mem);
 		__mem_cgroup_free(mem);
+		if (parent)
+			mem_cgroup_put(parent);
+	}
+}
+
+static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem)
+{
+	if (!mem->res.parent)
+		return NULL;
+	return mem_cgroup_from_res_counter(mem->res.parent, res);
 }
 
+static void mem_cgroup_get_parent(struct mem_cgroup *mem)
+{
+	struct mem_cgroup *parent = parent_mem_cgroup(mem);
+
+	if (parent)
+		mem_cgroup_get(parent);
+}
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 static void __init enable_swap_cgroup(void)
@@ -2237,6 +2257,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	if (parent)
 		mem->swappiness = get_swappiness(parent);
 	atomic_set(&mem->refcnt, 1);
+	mem_cgroup_get_parent(mem);
 	return &mem->css;
 free_out:
 	__mem_cgroup_free(mem);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

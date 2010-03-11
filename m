Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CDAB76B0099
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 23:35:09 -0500 (EST)
Date: Thu, 11 Mar 2010 13:31:23 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH mmotm 2.5/4] memcg: disable irq at page cgroup lock (Re:
 [PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
 infrastructure)
Message-Id: <20100311133123.ab10183c.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100310035624.GP3073@balbir.in.ibm.com>
References: <20100308105641.e2e714f4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308111724.3e48aee3.nishimura@mxp.nes.nec.co.jp>
	<20100308113711.d7a249da.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308170711.4d8b02f0.nishimura@mxp.nes.nec.co.jp>
	<20100308173100.b5997fd4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100309001252.GB13490@linux>
	<20100309091914.4b5f6661.kamezawa.hiroyu@jp.fujitsu.com>
	<20100309102928.9f36d2bb.nishimura@mxp.nes.nec.co.jp>
	<20100309045058.GX3073@balbir.in.ibm.com>
	<20100310104309.c5f9c9a9.nishimura@mxp.nes.nec.co.jp>
	<20100310035624.GP3073@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Thu__11_Mar_2010_13_31_23_+0900_=lGnYCVdpPo+vYmd"
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Andrea Righi <arighi@develer.com>, linux-kernel@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, Vivek Goyal <vgoyal@redhat.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

--Multipart=_Thu__11_Mar_2010_13_31_23_+0900_=lGnYCVdpPo+vYmd
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Wed, 10 Mar 2010 09:26:24 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2010-03-10 10:43:09]:
> 
> > > Please please measure the performance overhead of this change.
> > > 
> > 
> > here.
> > 
> > > > > > > > I made a patch below and measured the time(average of 10 times) of kernel build
> > > > > > > > on tmpfs(make -j8 on 8 CPU machine with 2.6.33 defconfig).
> > > > > > > > 
> > > > > > > > <before>
> > > > > > > > - root cgroup: 190.47 sec
> > > > > > > > - child cgroup: 192.81 sec
> > > > > > > > 
> > > > > > > > <after>
> > > > > > > > - root cgroup: 191.06 sec
> > > > > > > > - child cgroup: 193.06 sec
> > > > > > > > 
> > 
> > <after2(local_irq_save/restore)>
> > - root cgroup: 191.42 sec
> > - child cgroup: 193.55 sec
> > 
> > hmm, I think it's in error range, but I can see a tendency by testing several times
> > that it's getting slower as I add additional codes. Using local_irq_disable()/enable()
> > except in mem_cgroup_update_file_mapped(it can be the only candidate to be called
> > with irq disabled in future) might be the choice.
> >
> 
> Error range would depend on things like standard deviation and
> repetition. It might be good to keep update_file_mapped and see the
> impact. My concern is with large systems, the difference might be
> larger.
>  
> -- 
> 	Three Cheers,
> 	Balbir
I made a patch(attached) using both local_irq_disable/enable and local_irq_save/restore.
local_irq_save/restore is used only in mem_cgroup_update_file_mapped.

And I attached a histogram graph of 30 times kernel build in root cgroup for each.

  before_root: no irq operation(original)
  after_root: local_irq_disable/enable for all
  after2_root: local_irq_save/restore for all
  after3_root: mixed version(attached)

hmm, there seems to be a tendency that before < after < after3 < after2 ?
Should I replace save/restore version to mixed version ?


Thanks,
Daisuke Nishimura.
===
 include/linux/page_cgroup.h |   28 ++++++++++++++++++++++++++--
 mm/memcontrol.c             |   36 ++++++++++++++++++------------------
 2 files changed, 44 insertions(+), 20 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 30b0813..c0aca62 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -83,16 +83,40 @@ static inline enum zone_type page_cgroup_zid(struct page_cgroup *pc)
 	return page_zonenum(pc->page);
 }
 
-static inline void lock_page_cgroup(struct page_cgroup *pc)
+static inline void __lock_page_cgroup(struct page_cgroup *pc)
 {
 	bit_spin_lock(PCG_LOCK, &pc->flags);
 }
 
-static inline void unlock_page_cgroup(struct page_cgroup *pc)
+static inline void __unlock_page_cgroup(struct page_cgroup *pc)
 {
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
 }
 
+#define lock_page_cgroup_irq(pc)			\
+	do {						\
+		local_irq_disable();			\
+		__lock_page_cgroup(pc);			\
+	} while (0)
+
+#define unlock_page_cgroup_irq(pc)			\
+	do {						\
+		__unlock_page_cgroup(pc);		\
+		local_irq_enable();			\
+	} while (0)
+
+#define lock_page_cgroup_irqsave(pc, flags)		\
+	do {						\
+		local_irq_save(flags);			\
+		__lock_page_cgroup(pc);			\
+	} while (0)
+
+#define unlock_page_cgroup_irqrestore(pc, flags)	\
+	do {						\
+		__unlock_page_cgroup(pc);		\
+		local_irq_restore(flags);		\
+	} while (0)
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct page_cgroup;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 02ea959..11d483e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1354,12 +1354,13 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
 {
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
+	unsigned long flags;
 
 	pc = lookup_page_cgroup(page);
 	if (unlikely(!pc))
 		return;
 
-	lock_page_cgroup(pc);
+	lock_page_cgroup_irqsave(pc, flags);
 	mem = pc->mem_cgroup;
 	if (!mem)
 		goto done;
@@ -1373,7 +1374,7 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
 	__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED], val);
 
 done:
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup_irqrestore(pc, flags);
 }
 
 /*
@@ -1711,7 +1712,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 	VM_BUG_ON(!PageLocked(page));
 
 	pc = lookup_page_cgroup(page);
-	lock_page_cgroup(pc);
+	lock_page_cgroup_irq(pc);
 	if (PageCgroupUsed(pc)) {
 		mem = pc->mem_cgroup;
 		if (mem && !css_tryget(&mem->css))
@@ -1725,7 +1726,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 			mem = NULL;
 		rcu_read_unlock();
 	}
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup_irq(pc);
 	return mem;
 }
 
@@ -1742,9 +1743,9 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
 	if (!mem)
 		return;
 
-	lock_page_cgroup(pc);
+	lock_page_cgroup_irq(pc);
 	if (unlikely(PageCgroupUsed(pc))) {
-		unlock_page_cgroup(pc);
+		unlock_page_cgroup_irq(pc);
 		mem_cgroup_cancel_charge(mem);
 		return;
 	}
@@ -1774,7 +1775,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
 
 	mem_cgroup_charge_statistics(mem, pc, true);
 
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup_irq(pc);
 	/*
 	 * "charge_statistics" updated event counter. Then, check it.
 	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
@@ -1844,12 +1845,12 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
 		struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
 {
 	int ret = -EINVAL;
-	lock_page_cgroup(pc);
+	lock_page_cgroup_irq(pc);
 	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
 		__mem_cgroup_move_account(pc, from, to, uncharge);
 		ret = 0;
 	}
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup_irq(pc);
 	/*
 	 * check events
 	 */
@@ -1977,16 +1978,15 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 	if (!(gfp_mask & __GFP_WAIT)) {
 		struct page_cgroup *pc;
 
-
 		pc = lookup_page_cgroup(page);
 		if (!pc)
 			return 0;
-		lock_page_cgroup(pc);
+		lock_page_cgroup_irq(pc);
 		if (PageCgroupUsed(pc)) {
-			unlock_page_cgroup(pc);
+			unlock_page_cgroup_irq(pc);
 			return 0;
 		}
-		unlock_page_cgroup(pc);
+		unlock_page_cgroup_irq(pc);
 	}
 
 	if (unlikely(!mm && !mem))
@@ -2182,7 +2182,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	if (unlikely(!pc || !PageCgroupUsed(pc)))
 		return NULL;
 
-	lock_page_cgroup(pc);
+	lock_page_cgroup_irq(pc);
 
 	mem = pc->mem_cgroup;
 
@@ -2221,7 +2221,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	 */
 
 	mz = page_cgroup_zoneinfo(pc);
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup_irq(pc);
 
 	memcg_check_events(mem, page);
 	/* at swapout, this memcg will be accessed to record to swap */
@@ -2231,7 +2231,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	return mem;
 
 unlock_out:
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup_irq(pc);
 	return NULL;
 }
 
@@ -2424,12 +2424,12 @@ int mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
 		return 0;
 
 	pc = lookup_page_cgroup(page);
-	lock_page_cgroup(pc);
+	lock_page_cgroup_irq(pc);
 	if (PageCgroupUsed(pc)) {
 		mem = pc->mem_cgroup;
 		css_get(&mem->css);
 	}
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup_irq(pc);
 
 	if (mem) {
 		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);



--Multipart=_Thu__11_Mar_2010_13_31_23_+0900_=lGnYCVdpPo+vYmd
Content-Type: application/octet-stream;
 name="root_cgroup.bmp.gz"
Content-Disposition: attachment;
 filename="root_cgroup.bmp.gz"
Content-Transfer-Encoding: base64

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
AAApjQQAkHoAAJD4/0ZfnV7WIw8A

--Multipart=_Thu__11_Mar_2010_13_31_23_+0900_=lGnYCVdpPo+vYmd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

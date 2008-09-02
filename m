Date: Tue, 2 Sep 2008 20:09:05 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 14/14]memcg: mem+swap accounting
Message-Id: <20080902200905.cb18cce0.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080901185347.cfbc1817.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
	<20080822204455.922f87dc.kamezawa.hiroyu@jp.fujitsu.com>
	<20080901161501.2cba948e.nishimura@mxp.nes.nec.co.jp>
	<20080901165827.e21f9104.kamezawa.hiroyu@jp.fujitsu.com>
	<20080901175302.737bca2e.nishimura@mxp.nes.nec.co.jp>
	<20080901185347.cfbc1817.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 1 Sep 2008 18:53:47 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 1 Sep 2008 17:53:02 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Mon, 1 Sep 2008 16:58:27 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Mon, 1 Sep 2008 16:15:01 +0900
> > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > 
> > > > Hi, Kamezawa-san.
> > > > 
> > > > I'm testing these patches on mmotm-2008-08-29-01-08
> > > > (with some trivial fixes I've reported and some debug codes),
> > This problem happens on the kernel without debug codes I added.
> > 
> > > > but swap_in_bytes sometimes becomes very huge(it seems that
> > > > over uncharge is happening..) and I can see OOM
> > > > if I've set memswap_limit.
> > > > 
> > > > I'm digging this now, but have you also ever seen it?
> > > > 
> > > I didn't see that.
> > I see, thanks.
> > 
> > > But, as you say, maybe over-uncharge. Hmm..
> > > What kind of test ? Just use swap ? and did you use shmem or tmpfs ?
> > > 
> > I don't do anything special, and this can happen without shmem/tmpfs
> > (can happen with shmem/tmpfs, too).
> > 
> > For example:
> > 
> > - make swap out/in activity for a while(I used page01 of ltp).
> > - stop the test.
> > 
> > [root@localhost ~]# cat /cgroup/memory/01/memory.swap_in_bytes
> > 4096
> > 
> > - swapoff
> > 
> > [root@localhost ~]# swapoff -a
> > [root@localhost ~]# cat /cgroup/memory/01/memory.swap_in_bytes
> > 18446744073709395968
> > 
> > 
> Hmm ? can happen without swapoff ?
> It seems "accounted" flag is on by mistake.
> 
I found the cause of this problem.

If __mem_cgroup_uncharge_common() in __swap_cgroup_delete_swapcache() fails,
res.swaps would not be incremented while the swap_cgroup.count remains on.
This causes over-uncharging of res.swaps.

This patch fixes this problem(it works well so far).


Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 59ad6d8..ab62a95 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1015,14 +1015,15 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *m
 /*
  * uncharge if !page_mapped(page)
  */
-static void
+static int
 __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 {
        struct page_cgroup *pc;
        struct mem_cgroup *mem;
+       int ret = 0;

        if (mem_cgroup_subsys.disabled)
-               return;
+               return ret;

        /*
         * Check if our page_cgroup is valid
@@ -1039,6 +1040,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type cty
                    (page->mapping && !PageAnon(page)))
                        goto out;

+       ret = 1;
        mem = pc->mem_cgroup;
        SetPcgObsolete(pc);
        page_assign_page_cgroup(page, NULL);
@@ -1051,7 +1053,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type cty

 out:
        rcu_read_unlock();
-       return;
+       return ret;
 }

 void mem_cgroup_uncharge_page(struct page *page)
@@ -1869,9 +1871,10 @@ void swap_cgroup_delete_swapcache(struct page *page, swp_entry_t en
        if (!pc)
                return;

-       if (swap_cgroup_account(pc->mem_cgroup, entry, true))
-               __mem_cgroup_uncharge_common(page,
-                               MEM_CGROUP_CHARGE_TYPE_SWAPOUT);
+       if (swap_cgroup_account(pc->mem_cgroup, entry, true)
+               && !__mem_cgroup_uncharge_common(page,
+                               MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
+               WARN_ON(!swap_cgroup_account(pc->mem_cgroup, entry, false));
        else if (page->mapping && !PageAnon(page))
                __mem_cgroup_uncharge_common(page,
                                MEM_CGROUP_CHARGE_TYPE_CACHE);
@@ -1889,8 +1892,8 @@ void swap_cgroup_delete_swap(swp_entry_t entry)
        ret = swap_cgroup_record_info(NULL, entry, true);
        if (ret) {
                mem = mem_cgroup_id_lookup(ret);
-               if (mem)
-                       mem_counter_uncharge_swap(mem);
+               VM_BUG_ON(!mem);
+               mem_counter_uncharge_swap(mem);
        }
 }



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

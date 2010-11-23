Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EBD2E6B0087
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:03:18 -0500 (EST)
Date: Tue, 23 Nov 2010 22:02:55 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] [BUG] memcg: fix false positive VM_BUG on non-SMP
Message-ID: <20101123210255.GA22484@cmpxchg.org>
References: <1290520130-9990-1-git-send-email-kirill@shutemov.name>
 <20101123121606.c07197e5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101123121606.c07197e5.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutsemov" <kirill@shutemov.name>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 23, 2010 at 12:16:06PM -0800, Andrew Morton wrote:
> On Tue, 23 Nov 2010 15:48:50 +0200
> "Kirill A. Shutsemov" <kirill@shutemov.name> wrote:
> 
> > ------------[ cut here ]------------
> > kernel BUG at mm/memcontrol.c:2155!
> 
> This bug has been there for a year, from which I conclude people don't
> run memcg on uniprocessor machines a lot.
> 
> Which is a bit sad, really.  Small machines need resource control too,
> perhaps more than large ones..

Admittedly, this patch is compile-tested on UP only, but it should be
obvious enough.

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] memcg: fix page cgroup lock assert on UP

Page cgroup locking primitives use the bit spinlock API functions,
which do nothing on UP.

Thus, checking the lock state can not be done by looking at the bit
directly, but one has to go through the bit spinlock API as well.

This fixes a guaranteed UP bug, where asserting the page cgroup lock
bit as a sanity check crashes the kernel.

Reported-by: "Kirill A. Shutsemov" <kirill@shutemov.name>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/page_cgroup.h |    7 +++++--
 mm/memcontrol.c             |    2 +-
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 5bb13b3..6c1ac38 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -59,8 +59,6 @@ static inline void ClearPageCgroup##uname(struct page_cgroup *pc)	\
 static inline int TestClearPageCgroup##uname(struct page_cgroup *pc)	\
 	{ return test_and_clear_bit(PCG_##lname, &pc->flags);  }
 
-TESTPCGFLAG(Locked, LOCK)
-
 /* Cache flag is set only once (at allocation) */
 TESTPCGFLAG(Cache, CACHE)
 CLEARPCGFLAG(Cache, CACHE)
@@ -104,6 +102,11 @@ static inline void unlock_page_cgroup(struct page_cgroup *pc)
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
 }
 
+static inline int page_cgroup_is_locked(struct page_cgroup *pc)
+{
+	return bit_spin_is_locked(PCG_LOCK, &pc->flags);
+}
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct page_cgroup;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2efa8ea..5d5015b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2152,7 +2152,7 @@ static void __mem_cgroup_move_account(struct page_cgroup *pc,
 {
 	VM_BUG_ON(from == to);
 	VM_BUG_ON(PageLRU(pc->page));
-	VM_BUG_ON(!PageCgroupLocked(pc));
+	VM_BUG_ON(!page_cgroup_is_locked(pc));
 	VM_BUG_ON(!PageCgroupUsed(pc));
 	VM_BUG_ON(pc->mem_cgroup != from);
 
-- 
1.7.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

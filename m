Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 845428D0039
	for <linux-mm@kvack.org>; Sat,  5 Feb 2011 04:05:01 -0500 (EST)
Date: Sat, 5 Feb 2011 10:04:51 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch fixup] memcg: remove direct page_cgroup-to-page pointer fix
Message-ID: <20110205090451.GA2315@cmpxchg.org>
References: <201102042349.p14NnQEm025834@imap1.linux-foundation.org>
 <20110204183810.76baf8f0.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110204183810.76baf8f0.randy.dunlap@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Fri, Feb 04, 2011 at 06:38:10PM -0800, Randy Dunlap wrote:
> On Fri, 04 Feb 2011 15:15:17 -0800 akpm@linux-foundation.org wrote:
> 
> > The mm-of-the-moment snapshot 2011-02-04-15-15 has been uploaded to
> > 
> >    http://userweb.kernel.org/~akpm/mmotm/
> > 
> > and will soon be available at
> > 
> >    git://zen-kernel.org/kernel/mmotm.git
> > 
> > It contains the following patches against 2.6.38-rc3:
> 
> 
> Lots of these warnings in some kernel configs:
> 
> mmotm-2011-0204-1515/include/linux/page_cgroup.h:144: warning: left shift count >= width of type
> mmotm-2011-0204-1515/include/linux/page_cgroup.h:145: warning: left shift count >= width of type
> mmotm-2011-0204-1515/include/linux/page_cgroup.h:150: warning: right shift count >= width of type

Thanks for the report, Randy, and sorry for the breakage.  Here is the
fixup:

---
Since the non-flags field for pc array ids in pc->flags is offset from
the end of the word, we end up with a shift count of BITS_PER_LONG in
case the field width is zero.

This results in a compiler warning as we shift in both directions a
long int by BITS_PER_LONG.

There is no real harm -- the mask is zero -- but fix up the compiler
warning by also making the shift count zero for a non-existant field.

Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 05d8618..f5de21d 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -123,31 +123,36 @@ static inline void move_unlock_page_cgroup(struct page_cgroup *pc,
 }
 
 #ifdef CONFIG_SPARSEMEM
-#define PCG_ARRAYID_SHIFT	SECTIONS_SHIFT
+#define PCG_ARRAYID_WIDTH	SECTIONS_SHIFT
 #else
-#define PCG_ARRAYID_SHIFT	NODES_SHIFT
+#define PCG_ARRAYID_WIDTH	NODES_SHIFT
 #endif
 
-#if (PCG_ARRAYID_SHIFT > BITS_PER_LONG - NR_PCG_FLAGS)
+#if (PCG_ARRAYID_WIDTH > BITS_PER_LONG - NR_PCG_FLAGS)
 #error Not enough space left in pc->flags to store page_cgroup array IDs
 #endif
 
 /* pc->flags: ARRAY-ID | FLAGS */
 
-#define PCG_ARRAYID_MASK	((1UL << PCG_ARRAYID_SHIFT) - 1)
+#define PCG_ARRAYID_MASK	((1UL << PCG_ARRAYID_WIDTH) - 1)
 
-#define PCG_ARRAYID_OFFSET	(sizeof(unsigned long) * 8 - PCG_ARRAYID_SHIFT)
+#define PCG_ARRAYID_OFFSET	(BITS_PER_LONG - PCG_ARRAYID_WIDTH)
+/*
+ * Zero the shift count for non-existant fields, to prevent compiler
+ * warnings and ensure references are optimized away.
+ */
+#define PCG_ARRAYID_SHIFT	(PCG_ARRAYID_OFFSET * (PCG_ARRAYID_WIDTH != 0))
 
 static inline void set_page_cgroup_array_id(struct page_cgroup *pc,
 					    unsigned long id)
 {
-	pc->flags &= ~(PCG_ARRAYID_MASK << PCG_ARRAYID_OFFSET);
-	pc->flags |= (id & PCG_ARRAYID_MASK) << PCG_ARRAYID_OFFSET;
+	pc->flags &= ~(PCG_ARRAYID_MASK << PCG_ARRAYID_SHIFT);
+	pc->flags |= (id & PCG_ARRAYID_MASK) << PCG_ARRAYID_SHIFT;
 }
 
 static inline unsigned long page_cgroup_array_id(struct page_cgroup *pc)
 {
-	return (pc->flags >> PCG_ARRAYID_OFFSET) & PCG_ARRAYID_MASK;
+	return (pc->flags >> PCG_ARRAYID_SHIFT) & PCG_ARRAYID_MASK;
 }
 
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

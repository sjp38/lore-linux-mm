Return-Path: <linux-kernel-owner@vger.kernel.org>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH V6 1/4] mm/cma: Add PF flag to force non cma alloc
Date: Tue,  8 Jan 2019 10:21:07 +0530
In-Reply-To: <20190108045110.28597-1-aneesh.kumar@linux.ibm.com>
References: <20190108045110.28597-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190108045110.28597-2-aneesh.kumar@linux.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, David Gibson <david@gibson.dropbear.id.au>, Andrea Arcangeli <aarcange@redhat.com>, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch add PF_MEMALLOC_NOCMA which make sure any allocation in that context
is marked non movable and hence cannot be satisfied by CMA region.

This is useful with get_user_pages_cma_migrate where we take a page pin by
migrating pages from CMA region. Marking the section PF_MEMALLOC_NOCMA ensures
that we avoid uncessary page migration later.

Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 include/linux/sched.h    |  1 +
 include/linux/sched/mm.h | 36 ++++++++++++++++++++++++++++--------
 2 files changed, 29 insertions(+), 8 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 89541d248893..047c8c469774 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1406,6 +1406,7 @@ extern struct pid *cad_pid;
 #define PF_RANDOMIZE		0x00400000	/* Randomize virtual address space */
 #define PF_SWAPWRITE		0x00800000	/* Allowed to write to swap */
 #define PF_MEMSTALL		0x01000000	/* Stalled due to lack of memory */
+#define PF_MEMALLOC_NOCMA	0x02000000	/* All allocation request will have _GFP_MOVABLE cleared */
 #define PF_NO_SETAFFINITY	0x04000000	/* Userland is not allowed to meddle with cpus_allowed */
 #define PF_MCE_EARLY		0x08000000      /* Early kill for mce process policy */
 #define PF_MUTEX_TESTER		0x20000000	/* Thread belongs to the rt mutex tester */
diff --git a/include/linux/sched/mm.h b/include/linux/sched/mm.h
index 3bfa6a0cbba4..b336e7e2ca49 100644
--- a/include/linux/sched/mm.h
+++ b/include/linux/sched/mm.h
@@ -148,17 +148,24 @@ static inline bool in_vfork(struct task_struct *tsk)
  * Applies per-task gfp context to the given allocation flags.
  * PF_MEMALLOC_NOIO implies GFP_NOIO
  * PF_MEMALLOC_NOFS implies GFP_NOFS
+ * PF_MEMALLOC_NOCMA implies no allocation from CMA region.
  */
 static inline gfp_t current_gfp_context(gfp_t flags)
 {
-	/*
-	 * NOIO implies both NOIO and NOFS and it is a weaker context
-	 * so always make sure it makes precedence
-	 */
-	if (unlikely(current->flags & PF_MEMALLOC_NOIO))
-		flags &= ~(__GFP_IO | __GFP_FS);
-	else if (unlikely(current->flags & PF_MEMALLOC_NOFS))
-		flags &= ~__GFP_FS;
+	if (unlikely(current->flags &
+		     (PF_MEMALLOC_NOIO | PF_MEMALLOC_NOFS | PF_MEMALLOC_NOCMA))) {
+		/*
+		 * NOIO implies both NOIO and NOFS and it is a weaker context
+		 * so always make sure it makes precedence
+		 */
+		if (current->flags & PF_MEMALLOC_NOIO)
+			flags &= ~(__GFP_IO | __GFP_FS);
+		else if (current->flags & PF_MEMALLOC_NOFS)
+			flags &= ~__GFP_FS;
+
+		if (current->flags & PF_MEMALLOC_NOCMA)
+			flags &= ~__GFP_MOVABLE;
+	}
 	return flags;
 }
 
@@ -248,6 +255,19 @@ static inline void memalloc_noreclaim_restore(unsigned int flags)
 	current->flags = (current->flags & ~PF_MEMALLOC) | flags;
 }
 
+static inline unsigned int memalloc_nocma_save(void)
+{
+	unsigned int flags = current->flags & PF_MEMALLOC_NOCMA;
+
+	current->flags |= PF_MEMALLOC_NOCMA;
+	return flags;
+}
+
+static inline void memalloc_nocma_restore(unsigned int flags)
+{
+	current->flags = (current->flags & ~PF_MEMALLOC_NOCMA) | flags;
+}
+
 #ifdef CONFIG_MEMCG
 /**
  * memalloc_use_memcg - Starts the remote memcg charging scope.
-- 
2.20.1

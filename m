Date: Tue, 18 Nov 2008 21:08:38 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH mmotm] memcg: unmap KM_USER0 at shmem_map_and_free_swp if
 do_swap_account
Message-Id: <20081118210838.c99887fd.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081118192135.300803ec.nishimura@mxp.nes.nec.co.jp>
References: <20081118180721.cb2fe744.nishimura@mxp.nes.nec.co.jp>
	<20081118182637.97ae0e48.kamezawa.hiroyu@jp.fujitsu.com>
	<20081118192135.300803ec.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Li Zefan <lizf@cn.fujitsu.com>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

memswap controller uses KM_USER0 at swap_cgroup_record and lookup_swap_cgroup.

But delete_from_swap_cache, which eventually calls swap_cgroup_record, can be
called with KM_USER0 mapped in case of shmem.

So it should be unmapped before calling it.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
After this patch, I think memswap controller of x86_32 will be
on near level with that of x86_64.

 mm/shmem.c |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index bee8612..09447b9 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -171,6 +171,28 @@ static inline void shmem_unacct_size(unsigned long flags, loff_t size)
 		vm_unacct_memory(VM_ACCT(size));
 }
 
+#if defined(CONFIG_CGROUP_MEM_RES_CTLR_SWAP) && defined(CONFIG_HIGHMEM)
+/*
+ * memswap controller uses KM_USER0, so dir should be unmapped
+ * before calling delete_from_swap_cache.
+ */
+static inline void swap_cgroup_map_prepare(struct page ***dir)
+{
+	if (!do_swap_account)
+		return;
+
+	if (*dir) {
+		shmem_dir_unmap(*dir);
+		*dir = NULL;
+	}
+}
+#else
+static inline void swap_cgroup_map_prepare(struct page ***dir)
+{
+	return;
+}
+#endif
+
 /*
  * ... whereas tmpfs objects are accounted incrementally as
  * pages are allocated, in order to allow huge sparse files.
@@ -474,6 +496,7 @@ static int shmem_map_and_free_swp(struct page *subdir, int offset,
 	swp_entry_t *ptr;
 	int freed = 0;
 
+	swap_cgroup_map_prepare(dir);
 	ptr = shmem_swp_map(subdir);
 	for (; offset < limit; offset += LATENCY_LIMIT) {
 		int size = limit - offset;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

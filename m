Date: Sun, 16 Nov 2008 20:52:22 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH mmotm] memcg: handle swap caches build fix
Message-ID: <Pine.LNX.4.64.0811162046080.5813@blonde.site>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-2118584039-1226868742=:5813"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--8323584-2118584039-1226868742=:5813
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

Fix to build error when CONFIG_SHMEM=3Dy but CONFIG_SWAP is not set:
mm/shmem.c: In function =E2=80=98shmem_unuse_inode=E2=80=99:
mm/shmem.c:927: error: implicit declaration of function =E2=80=98mem_cgroup=
_cache_charge_swapin=E2=80=99

Yes, there's a lot of code in mm/shmem.c which only comes into play when
CONFIG_SWAP=3Dy: better than this quick fix would be to restructure shmem.c
with all swap stuff in a separate file; that's on my mind, but now is not
the moment for it.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
Fix should follow or be merged into memcg-handle-swap-caches.patch

 include/linux/swap.h |    6 ++++++
 1 file changed, 6 insertions(+)

--- mmotm/include/linux/swap.h=092008-11-16 17:33:25.000000000 +0000
+++ linux/include/linux/swap.h=092008-11-16 20:18:27.000000000 +0000
@@ -442,6 +442,12 @@ static inline swp_entry_t get_swap_page(
 #define has_swap_token(x) 0
 #define disable_swap_token() do { } while(0)
=20
+static inline int mem_cgroup_cache_charge_swapin(struct page *page,
+=09=09=09struct mm_struct *mm, gfp_t mask, bool locked)
+{
+=09return 0;
+}
+
 #endif /* CONFIG_SWAP */
 #endif /* __KERNEL__*/
 #endif /* _LINUX_SWAP_H */
--8323584-2118584039-1226868742=:5813--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

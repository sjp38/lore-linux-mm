Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 25F7E6B004D
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 20:32:47 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id 10so11318678ied.14
        for <linux-mm@kvack.org>; Mon, 05 Nov 2012 17:32:46 -0800 (PST)
Date: Mon, 5 Nov 2012 17:32:41 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] tmpfs: fix shmem_getpage_gfp VM_BUG_ON
In-Reply-To: <alpine.LNX.2.00.1211021606580.11106@eggly.anvils>
Message-ID: <alpine.LNX.2.00.1211051729590.963@eggly.anvils>
References: <20121025023738.GA27001@redhat.com> <alpine.LNX.2.00.1210242121410.1697@eggly.anvils> <20121101191052.GA5884@redhat.com> <alpine.LNX.2.00.1211011546090.19377@eggly.anvils> <20121101232030.GA25519@redhat.com> <alpine.LNX.2.00.1211011627120.19567@eggly.anvils>
 <20121102014336.GA1727@redhat.com> <alpine.LNX.2.00.1211021606580.11106@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Fuzzing with trinity hit the "impossible" VM_BUG_ON(error)
(which Fedora has converted to WARNING) in shmem_getpage_gfp():

WARNING: at mm/shmem.c:1151 shmem_getpage_gfp+0xa5c/0xa70()
Pid: 29795, comm: trinity-child4 Not tainted 3.7.0-rc2+ #49
Call Trace:
 [<ffffffff8107100f>] warn_slowpath_common+0x7f/0xc0
 [<ffffffff8107106a>] warn_slowpath_null+0x1a/0x20
 [<ffffffff811903fc>] shmem_getpage_gfp+0xa5c/0xa70
 [<ffffffff81190e4f>] shmem_fault+0x4f/0xa0
 [<ffffffff8119f391>] __do_fault+0x71/0x5c0
 [<ffffffff811a2767>] handle_pte_fault+0x97/0xae0
 [<ffffffff811a4a39>] handle_mm_fault+0x289/0x350
 [<ffffffff816d091e>] __do_page_fault+0x18e/0x530
 [<ffffffff816d0ceb>] do_page_fault+0x2b/0x50
 [<ffffffff816cd3b8>] page_fault+0x28/0x30
 [<ffffffff816d5688>] tracesys+0xe1/0xe6

Thanks to Johannes for pointing to truncation: free_swap_and_cache()
only does a trylock on the page, so the page lock we've held since
before confirming swap is not enough to protect against truncation.

What cleanup is needed in this case?  Just delete_from_swap_cache(),
which takes care of the memcg uncharge.

Reported-by: Dave Jones <davej@redhat.com>
Hypothesis-by: Johannes Weiner <hannes@cmpxchg.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org
---

 mm/shmem.c |   18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

--- 3.7-rc4/mm/shmem.c	2012-10-14 16:16:58.361309122 -0700
+++ linux/mm/shmem.c	2012-11-01 14:31:04.288185742 -0700
@@ -1145,8 +1145,22 @@ repeat:
 		if (!error) {
 			error = shmem_add_to_page_cache(page, mapping, index,
 						gfp, swp_to_radix_entry(swap));
-			/* We already confirmed swap, and make no allocation */
-			VM_BUG_ON(error);
+			/*
+			 * We already confirmed swap under page lock, and make
+			 * no memory allocation here, so usually no possibility
+			 * of error; but free_swap_and_cache() only trylocks a
+			 * page, so it is just possible that the entry has been
+			 * truncated or holepunched since swap was confirmed.
+			 * shmem_undo_range() will have done some of the
+			 * unaccounting, now delete_from_swap_cache() will do
+			 * the rest (including mem_cgroup_uncharge_swapcache).
+			 * Reset swap.val? No, leave it so "failed" goes back to
+			 * "repeat": reading a hole and writing should succeed.
+			 */
+			if (error) {
+				VM_BUG_ON(error != -ENOENT);
+				delete_from_swap_cache(page);
+			}
 		}
 		if (error)
 			goto failed;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

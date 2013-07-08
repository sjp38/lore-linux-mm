Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 0AB266B0034
	for <linux-mm@kvack.org>; Mon,  8 Jul 2013 14:10:37 -0400 (EDT)
Date: Mon, 8 Jul 2013 20:05:01 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 1/1] mm: mempolicy: fix mbind_range() && vma_adjust()
	interaction
Message-ID: <20130708180501.GB6490@redhat.com>
References: <1372901537-31033-1-git-send-email-ccross@android.com> <20130704202232.GA19287@redhat.com> <CAMbhsRRjGjo_-zSigmdsDvY-kfBhmP49bDQzsgHfj5N-y+ZAdw@mail.gmail.com> <20130708180424.GA6490@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130708180424.GA6490@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Hampson, Steven T" <steven.t.hampson@intel.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Arnd Bergmann <arnd@arndb.de>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rusty Russell <rusty@rustcorp.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>

vma_adjust() does vma_set_policy(vma, vma_policy(next)) and this
is doubly wrong:

1. This leaks vma->vm_policy if it is not NULL and not equal to
   next->vm_policy.

   This can happen if vma_merge() expands "area", not prev (case 8).

2. This sets the wrong policy if vma_merge() joins prev and area,
   area is the vma the caller needs to update and it still has the
   old policy.

Revert 1444f92c "mm: merging memory blocks resets mempolicy" which
introduced these problems.

Change mbind_range() to recheck mpol_equal() after vma_merge() to
fix the problem 1444f92c tried to address.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
Cc: <stable@vger.kernel.org>
---
 mm/mempolicy.c |    6 +++++-
 mm/mmap.c      |    2 +-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 7431001..4baf12e 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -732,7 +732,10 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 		if (prev) {
 			vma = prev;
 			next = vma->vm_next;
-			continue;
+			if (mpol_equal(vma_policy(vma), new_pol))
+				continue;
+			/* vma_merge() joined vma && vma->next, case 8 */
+			goto replace;
 		}
 		if (vma->vm_start != vmstart) {
 			err = split_vma(vma->vm_mm, vma, vmstart, 1);
@@ -744,6 +747,7 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 			if (err)
 				goto out;
 		}
+ replace:
 		err = vma_replace_policy(vma, new_pol);
 		if (err)
 			goto out;
diff --git a/mm/mmap.c b/mm/mmap.c
index 7fe7f0b..42234b8 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -865,7 +865,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 		if (next->anon_vma)
 			anon_vma_merge(vma, next);
 		mm->map_count--;
-		vma_set_policy(vma, vma_policy(next));
+		mpol_put(vma_policy(next));
 		kmem_cache_free(vm_area_cachep, next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

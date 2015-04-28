Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9F1666B0038
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 08:12:12 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so149017319wgy.2
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 05:12:12 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b5si38097315wjs.195.2015.04.28.05.12.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 05:12:11 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 1/3] mm: mmap make MAP_LOCKED really mlock semantic
Date: Tue, 28 Apr 2015 14:11:49 +0200
Message-Id: <1430223111-14817-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1430223111-14817-1-git-send-email-mhocko@suse.cz>
References: <20150114095019.GC4706@dhcp22.suse.cz>
 <1430223111-14817-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Cyril Hrubis <chrubis@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michael Kerrisk <mtk.manpages@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

Cyril has encountered one of the LTP tests failing after 3.12 kernel.
To quote him:
"
What the test does is to set memory limit inside of memcg to PAGESIZE by
writing to memory.limit_in_bytes, then runs a subprocess that uses
mmap() with MAP_LOCKED which allocates 2 * PAGESIZE and expects that
it's killed by OOM. This does not happen and the call to mmap() returns
a correct pointer to a memory region, that when accessed finally causes
the OOM.
"

The difference came from the memcg OOM killer rework because OOM killer
is triggered only from the page fault path since 519e52473ebe (mm:
memcg: enable memcg OOM killer only for user faults). The rationale is
described in 3812c8c8f395 (mm: memcg: do not trap chargers with full
callstack on OOM).

This is _not_ the primary _issue_, though. It has just made a long
standing issue visible. The same is possible even without memcg but it
is much less likely (it might get more visible once we start failing
GFP_KERNEL small allocations). The primary issue is that mmap doesn't
report a failure if MAP_LOCKED fails to populate the area.

The man page however says
"
MAP_LOCKED (since Linux 2.5.37)
      Lock the pages of the mapped region into memory in the manner of
      mlock(2).  This flag is ignored in older kernels.
"

and mlock is required to fail if the population fails.
"
       mlock() locks pages in the address range starting at addr and
       continuing for len bytes.  All pages that contain a part of the
       specified address range are guaranteed to be resident in RAM when
       the call returns successfully; the pages are guaranteed to stay
       in RAM until later unlocked.
"

According to the git history this has alaways been the case so it
doesn't look like anything new. Most applications probably even do not
care because they do not explicitly require the population at the mmap
call time. If the application cannot tolerate later pagefault this would
be an unexpected and potentially silent failure though.

This patch fixes the behavior to really mimic mlock so mmap fails
if the population is not successful. The only issue here is that
we cannot leave the already created VMA behind and so it has to be
unmapped which as an operation which might fail.

 There are basically two potential reasons for a failure. Either the
map count limit could have been reached after we have dropped mmap_sem
for write when doing do_mmap_pgoff or any of the allocations during vma
splitting fails.

The first one is easy to solve because we can elevate map_count while we
are still holding mmap_sem before calling do_mmap_pgoff when MAP_LOCKED
is specified. In the worst case do_munmap would need to split VMA in the
middle and we would simply consume a cached map_count.

The allocation failure down the do_munmap path is the tricky one, albeit
only theoretical one right now because small allocations do not fail yet
(this sounds like something that might change in the future though). There
are more allocations places (e.g. in __split_vma) and those are allowed to fail.
Let's keep retrying do_munmap, drop the semaphore each round to allow other
threads to make a progress (e.g. madvise to free some memory) and hope we will
be able to do it sooner or later.

An alternative would be making all of do_munmap allocations non failing
by using __GFP_NOFAIL or killing the task but that sounds too harsh.

Reported-by: Cyril Hrubis <chrubis@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/util.c | 66 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 59 insertions(+), 7 deletions(-)

diff --git a/mm/util.c b/mm/util.c
index 0c7f65e7ef5e..fbffefa3b812 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -290,16 +290,68 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long ret;
 	struct mm_struct *mm = current->mm;
 	unsigned long populate;
+	bool need_map_count_fix = false;
 
 	ret = security_mmap_file(file, prot, flag);
-	if (!ret) {
-		down_write(&mm->mmap_sem);
-		ret = do_mmap_pgoff(file, addr, len, prot, flag, pgoff,
-				    &populate);
-		up_write(&mm->mmap_sem);
-		if (populate)
-			mm_populate(ret, populate);
+	if (ret)
+		return ret;
+
+	down_write(&mm->mmap_sem);
+	/*
+	 * Reserve one slot for a cleanup should __mm_populate fail
+	 * and we would need to split VMA in the middle.
+	 */
+	if (flag & MAP_LOCKED) {
+		mm->map_count++;
+		need_map_count_fix = true;
+	}
+	ret = do_mmap_pgoff(file, addr, len, prot, flag, pgoff,
+			    &populate);
+	up_write(&mm->mmap_sem);
+
+	if (populate) {
+		int error;
+
+		error = __mm_populate(ret, populate, 0);
+		if (!error)
+			return ret;
+
+		/*
+		 * MAP_LOCKED has a mlock semantic so we have to
+		 * fail mmap call if the population fails.
+		 * Regular MAP_POPULATE can tolerate the failure
+		 * though.
+		 */
+		if (flag & MAP_LOCKED) {
+			down_write(&mm->mmap_sem);
+			while (!fatal_signal_pending(current)) {
+				mm->map_count--;
+				need_map_count_fix = false;
+				if (!do_munmap(mm, ret, populate))
+					break;
+
+				/*
+				 * Do not block other threads to make a progress
+				 * e.g. madvise
+				 */
+				mm->map_count++;
+				need_map_count_fix = true;
+				up_write(&mm->mmap_sem);
+				cond_resched();
+				down_write(&mm->mmap_sem);
+			}
+			up_write(&mm->mmap_sem);
+
+			ret = -ENOMEM;
+		}
+	}
+
+	if (need_map_count_fix) {
+		down_read(&mm->mmap_sem);
+		mm->map_count--;
+		up_read(&mm->mmap_sem);
 	}
+
 	return ret;
 }
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

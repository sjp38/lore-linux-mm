Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id C6B956B005D
	for <linux-mm@kvack.org>; Tue, 29 May 2012 13:16:03 -0400 (EDT)
Date: Tue, 29 May 2012 19:15:26 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00/35] AutoNUMA alpha14
Message-ID: <20120529171526.GI21339@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <20120529133627.GA7637@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120529133627.GA7637@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

Hi Kirill,

The anon page was munmapped just after get_page_unless_zero obtained a
refcount in knuma_migrated. This can happen for example if a big
process exits while knuma_migrated starts to migrate the page. In that
case split_huge_page would do nothing but when it does nothing it
notifies the caller returning 1. When it returns 1, we just need to
put_page and bail out (the page isn't splitted in that case and it's
pointless to try to migrate a freed page).

I also made the code more strict now, to be sure the reason of the bug
wasn't an hugepage in the LRU that wasn't Anon, such a thing must not
exist, but this will verify it just in case.

I'll push it to the origin/autonuma branch of aa.git shortly
(rebased), could you try if it helps?

diff --git a/mm/autonuma.c b/mm/autonuma.c
index 3d4c2a7..c2a5a82 100644
--- a/mm/autonuma.c
+++ b/mm/autonuma.c
@@ -840,9 +840,17 @@ static int isolate_migratepages(struct list_head *migratepages,
 
 		VM_BUG_ON(nid != page_to_nid(page));
 
-		if (PageAnon(page) && PageTransHuge(page))
+		if (PageTransHuge(page)) {
+			VM_BUG_ON(!PageAnon(page));
 			/* FIXME: remove split_huge_page */
-			split_huge_page(page);
+			if (unlikely(split_huge_page(page))) {
+				autonuma_printk("autonuma migrate THP free\n");
+				__autonuma_migrate_page_remove(page,
+							       page_autonuma);
+				put_page(page);
+				continue;
+			}
+		}
 
 		__autonuma_migrate_page_remove(page, page_autonuma);
 

Thanks a lot,
Andrea

BTW, interesting the knuma_migrated0 runs on CPU24, just in case, you
may also want to verify that it's correct with numactl --hardware, in
my case the highest cpuid in node0 is 17. It's not related to the
above, which is needed anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

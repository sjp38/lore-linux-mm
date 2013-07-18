Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 10E0B6B0036
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 21:54:07 -0400 (EDT)
Date: Wed, 17 Jul 2013 21:53:53 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 15/18] fix compilation with !CONFIG_NUMA_BALANCING
Message-ID: <20130717215353.57333a69@annuminas.surriel.com>
In-Reply-To: <1373901620-2021-16-git-send-email-mgorman@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
	<1373901620-2021-16-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 15 Jul 2013 16:20:17 +0100
Mel Gorman <mgorman@suse.de> wrote:

> Ideally it would be possible to distinguish between NUMA hinting faults that
> are private to a task and those that are shared. If treated identically
> there is a risk that shared pages bounce between nodes depending on

Your patch 15 breaks the compile with !CONFIG_NUMA_BALANCING.

This little patch fixes it:


The code in change_pte_range unconditionally calls nidpid_to_pid,
even when CONFIG_NUMA_SCHED is disabled.  Returning -1 keeps the
value of last_nid at "don't care" and should result in the mprotect
code doing nothing NUMA-related when CONFIG_NUMA_SCHED is disabled.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/mm.h | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 668f03c..0e0d190 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -731,6 +731,26 @@ static inline int page_nidpid_last(struct page *page)
 	return page_to_nid(page);
 }
 
+static inline int nidpid_to_nid(int nidpid)
+{
+	return -1;
+}
+
+static inline int nidpid_to_pid(int nidpid)
+{
+	return -1;
+}
+
+static inline int nid_pid_to_nidpid(int nid, int pid)
+{
+	return -1;
+}
+
+static inline bool nidpid_pid_unset(int nidpid)
+{
+	return 1;
+}
+
 static inline void page_nidpid_reset_last(struct page *page)
 {
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

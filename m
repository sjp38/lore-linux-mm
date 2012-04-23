Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 6E5AF6B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 18:45:40 -0400 (EDT)
Date: Mon, 23 Apr 2012 15:45:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -V6 12/14] memcg: move HugeTLB resource count to parent
 cgroup on memcg removal
Message-Id: <20120423154537.675d490c.akpm@linux-foundation.org>
In-Reply-To: <1334573091-18602-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1334573091-18602-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1334573091-18602-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Mon, 16 Apr 2012 16:14:49 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> This add support for memcg removal with HugeTLB resource usage.

include/linux/memcontrol.h:504: warning: 'struct cgroup' declared inside parameter list
include/linux/memcontrol.h:504: warning: its scope is only this definition or declaration, which is probably not what you want
include/linux/memcontrol.h:509: warning: 'struct cgroup' declared inside parameter list

Documentation/SubmitChecklist, section 2.  Please do these things -
what you have done here is to send untested code, for some
configuration options.


I'll try this:

 include/linux/hugetlb.h    |    6 +-----
 include/linux/memcontrol.h |   11 -----------
 2 files changed, 1 insertion(+), 16 deletions(-)

--- a/include/linux/memcontrol.h~memcg-move-hugetlb-resource-count-to-parent-cgroup-on-memcg-removal-fix
+++ a/include/linux/memcontrol.h
@@ -499,17 +499,6 @@ static inline int mem_cgroup_hugetlb_fil
 	return 0;
 }
 
-static inline int
-mem_cgroup_move_hugetlb_parent(int idx, struct cgroup *cgroup,
-			       struct page *page)
-{
-	return 0;
-}
-
-static inline bool mem_cgroup_have_hugetlb_usage(struct cgroup *cgroup)
-{
-	return 0;
-}
 #endif  /* CONFIG_MEM_RES_CTLR_HUGETLB */
 #endif /* _LINUX_MEMCONTROL_H */
 
--- a/include/linux/hugetlb.h~memcg-move-hugetlb-resource-count-to-parent-cgroup-on-memcg-removal-fix
+++ a/include/linux/hugetlb.h
@@ -337,10 +337,6 @@ static inline unsigned int pages_per_hug
 
 #ifdef CONFIG_MEM_RES_CTLR_HUGETLB
 extern int hugetlb_force_memcg_empty(struct cgroup *cgroup);
-#else
-static inline int hugetlb_force_memcg_empty(struct cgroup *cgroup)
-{
-	return 0;
-}
 #endif
+
 #endif /* _LINUX_HUGETLB_H */
_
 

We shouldn't be calling these functions if CONFIG_MEM_RES_CTLR_HUGETLB=n?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

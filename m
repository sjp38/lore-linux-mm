Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m27HYZLp005635
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 12:34:35 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m27HZOB3177682
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 10:35:24 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m27HZNtb032506
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 10:35:24 -0700
Date: Fri, 7 Mar 2008 09:35:37 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] Mempolicy:  make dequeue_huge_page_vma() obey
	MPOL_BIND nodemask rework
Message-ID: <20080307173537.GA24778@us.ibm.com>
References: <20080227214734.6858.9968.sendpatchset@localhost> <20080228133247.6a7b626f.akpm@linux-foundation.org> <20080229145030.GD6045@csn.ul.ie> <1204300094.5311.50.camel@localhost> <20080304180145.GB9051@csn.ul.ie> <1204733195.5026.20.camel@localhost> <20080305180322.GA9795@us.ibm.com> <1204743774.6244.6.camel@localhost> <20080306010440.GE28746@us.ibm.com> <1204838693.5294.102.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1204838693.5294.102.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, agl@us.ibm.com, wli@holomorphy.com, clameter@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, rientjes@google.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On 06.03.2008 [16:24:53 -0500], Lee Schermerhorn wrote:
> 
> Fix for earlier patch:
> "mempolicy-make-dequeue_huge_page_vma-obey-bind-policy"
> 
> Against: 2.6.25-rc3-mm1 atop the above patch.
> 
> As suggested by Nish Aravamudan, remove the mpol_bind_nodemask()
> helper and return a pointer to the policy node mask from
> huge_zonelist for MPOL_BIND.  This hides more of the mempolicy
> quirks from hugetlb.
> 
> In making this change, I noticed that the huge_zonelist() stub
> for !NUMA wasn't nulling out the mpol.  Added that as well.

Hrm, I was thinking more of the following (on top of this patch):

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4c5d41d..3790f5a 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1298,9 +1298,7 @@ struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
 
 	*mpol = NULL;		/* probably no unref needed */
 	*nodemask = NULL;	/* assume !MPOL_BIND */
-	if (pol->policy == MPOL_BIND) {
-			*nodemask = &pol->v.nodes;
-	} else if (pol->policy == MPOL_INTERLEAVE) {
+	if (pol->policy == MPOL_INTERLEAVE) {
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
@@ -1310,10 +1308,12 @@ struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
 
 	zl = zonelist_policy(GFP_HIGHUSER, pol);
 	if (unlikely(pol != &default_policy && pol != current->mempolicy)) {
-		if (pol->policy != MPOL_BIND)
+		if (pol->policy != MPOL_BIND) {
 			__mpol_free(pol);	/* finished with pol */
-		else
+		} else {
 			*mpol = pol;	/* unref needed after allocation */
+			*nodemask = &pol->v.nodes;
+		}
 	}
 	return zl;
 }

but perhaps that won't do the right thing if pol == current->mempolicy
and pol->policy == MPOL_BIND. So something like:


diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4c5d41d..7eb77e0 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1298,9 +1298,7 @@ struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
 
 	*mpol = NULL;		/* probably no unref needed */
 	*nodemask = NULL;	/* assume !MPOL_BIND */
-	if (pol->policy == MPOL_BIND) {
-			*nodemask = &pol->v.nodes;
-	} else if (pol->policy == MPOL_INTERLEAVE) {
+	if (pol->policy == MPOL_INTERLEAVE) {
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
@@ -1309,11 +1307,12 @@ struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
 	}
 
 	zl = zonelist_policy(GFP_HIGHUSER, pol);
-	if (unlikely(pol != &default_policy && pol != current->mempolicy)) {
-		if (pol->policy != MPOL_BIND)
-			__mpol_free(pol);	/* finished with pol */
-		else
+	if (unlikely(pol != &default_policy && pol != current->mempolicy
+						&& pol->policy != MPOL_BIND))
+		__mpol_free(pol);	/* finished with pol */
+	if (pol->policy == MPOL_BIND) {
 			*mpol = pol;	/* unref needed after allocation */
+			*nodemask = &pol->v.nodes;
 	}
 	return zl;
 }

Still not quite as clean, but I think it's best to keep the *mpol and
*nodemask assignments together, as if *mpol is being assigned, that's
the only time we should need to set *nodemask, right?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

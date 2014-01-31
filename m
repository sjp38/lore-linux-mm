Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f51.google.com (mail-oa0-f51.google.com [209.85.219.51])
	by kanga.kvack.org (Postfix) with ESMTP id DB7166B0039
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 12:37:05 -0500 (EST)
Received: by mail-oa0-f51.google.com with SMTP id h16so5490082oag.24
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 09:37:05 -0800 (PST)
Received: from g1t0026.austin.hp.com (g1t0026.austin.hp.com. [15.216.28.33])
        by mx.google.com with ESMTPS id si5si5208296oeb.22.2014.01.31.09.37.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 31 Jan 2014 09:37:05 -0800 (PST)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH v2 4/6] mm, hugetlb: remove resv_map_put
Date: Fri, 31 Jan 2014 09:36:44 -0800
Message-Id: <1391189806-13319-5-git-send-email-davidlohr@hp.com>
In-Reply-To: <1391189806-13319-1-git-send-email-davidlohr@hp.com>
References: <1391189806-13319-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com
Cc: riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, js1304@gmail.com, liwanp@linux.vnet.ibm.com, n-horiguchi@ah.jp.nec.com, dhillf@gmail.com, rientjes@google.com, davidlohr@hp.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

This is a preparation patch to unify the use of vma_resv_map() regardless
of the map type. This patch prepares it by removing resv_map_put(), which
only works for HPAGE_RESV_OWNER's resv_map, not for all resv_maps.

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
[Updated changelog]
Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 mm/hugetlb.c | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3c03c7f..dfe81b4 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2275,15 +2275,6 @@ static void hugetlb_vm_op_open(struct vm_area_struct *vma)
 		kref_get(&resv->refs);
 }
 
-static void resv_map_put(struct vm_area_struct *vma)
-{
-	struct resv_map *resv = vma_resv_map(vma);
-
-	if (!resv)
-		return;
-	kref_put(&resv->refs, resv_map_release);
-}
-
 static void hugetlb_vm_op_close(struct vm_area_struct *vma)
 {
 	struct hstate *h = hstate_vma(vma);
@@ -2300,7 +2291,7 @@ static void hugetlb_vm_op_close(struct vm_area_struct *vma)
 		reserve = (end - start) -
 			region_count(resv, start, end);
 
-		resv_map_put(vma);
+		kref_put(&resv->refs, resv_map_release);
 
 		if (reserve) {
 			hugetlb_acct_memory(h, -reserve);
@@ -3249,8 +3240,8 @@ int hugetlb_reserve_pages(struct inode *inode,
 		region_add(resv_map, from, to);
 	return 0;
 out_err:
-	if (vma)
-		resv_map_put(vma);
+	if (vma && is_vma_resv_set(vma, HPAGE_RESV_OWNER))
+		kref_put(&resv_map->refs, resv_map_release);
 	return ret;
 }
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

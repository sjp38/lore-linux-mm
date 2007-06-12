Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5C230h1030870
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 22:03:00 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5C22xx9218644
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 20:02:59 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5C22xnJ006007
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 20:02:59 -0600
Date: Mon, 11 Jun 2007 19:02:57 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
Message-ID: <20070612020257.GF3798@us.ibm.com>
References: <20070611202728.GD9920@us.ibm.com> <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com> <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <20070611225213.GB14458@us.ibm.com> <Pine.LNX.4.64.0706111559490.21107@schroedinger.engr.sgi.com> <20070611234155.GG14458@us.ibm.com> <Pine.LNX.4.64.0706111642450.24042@schroedinger.engr.sgi.com> <20070612000705.GH14458@us.ibm.com> <Pine.LNX.4.64.0706111740280.24389@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706111740280.24389@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [17:41:15 -0700], Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> > > No need to initialize if we do not use it. You may to #ifdef it out
> > > by moving the definition. Please sent a diff against the earlier patch 
> > > since Andrew already merged it.
> > 
> > We will be using it (it == node_populated_mask) later in my sysfs patch
> > and in the fix hugepage allocation patch.
> 
> But not in the !NUMA case. So the definition of the node_populated_mask 
> can be moved into an #ifdef CONFIG_NUMA chunk in page_alloc.c and we can 
> have fallback functions.

No, see:

[PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 858c0b3..97ae1a3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -105,13 +105,22 @@ static void free_huge_page(struct page *page)

 static int alloc_fresh_huge_page(void)
 {
-       static int nid = 0;
+       static int nid = -1;
        struct page *page;
-       page = alloc_pages_node(nid, htlb_alloc_mask|__GFP_COMP|__GFP_NOWARN,
-                                       HUGETLB_PAGE_ORDER);
-       nid = next_node(nid, node_online_map);
-       if (nid == MAX_NUMNODES)
-               nid = first_node(node_online_map);
+       int start_nid;
+
+       if (nid < 0)
+               nid = first_node(node_populated_map);
+       start_nid = nid;
+
+       do {
+               page = alloc_pages_node(nid,
+                               GFP_HIGHUSER|__GFP_COMP|GFP_THISNODE,
+                               HUGETLB_PAGE_ORDER);
+               nid = next_node(nid, node_populated_map);
+               if (nid >= nr_node_ids)
+                       nid = first_node(node_populated_map);
+       } while (!page && nid != start_nid);
        if (page) {
                set_compound_page_dtor(page, free_huge_page);
                spin_lock(&hugetlb_lock);

wherein alloc_huge_page() checks node_populated_map for each invocation of
alloc_huge_page_node(). And alloc_huge_page() does not depend on CONFIG_NUMA in
any way.

If you would prefer, I could make it use node_online_map like before and check
if the node is populated every time, but that seems silly if it's one line to
make the node_populated_map sensible in both NUMA and !NUMA cases, similar to
node_online_map.

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

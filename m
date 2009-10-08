Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F181B6B005D
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 16:32:16 -0400 (EDT)
Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id n98KWErD023454
	for <linux-mm@kvack.org>; Thu, 8 Oct 2009 13:32:14 -0700
Received: from pzk40 (pzk40.prod.google.com [10.243.19.168])
	by spaceape23.eur.corp.google.com with ESMTP id n98KVVJQ002016
	for <linux-mm@kvack.org>; Thu, 8 Oct 2009 13:32:11 -0700
Received: by pzk40 with SMTP id 40so6390498pzk.7
        for <linux-mm@kvack.org>; Thu, 08 Oct 2009 13:32:10 -0700 (PDT)
Date: Thu, 8 Oct 2009 13:32:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/12] hugetlb:  add nodemask arg to huge page alloc, free
 and surplus adjust fcns
In-Reply-To: <20091008162515.23192.48252.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.1.00.0910081330190.6998@chino.kir.corp.google.com>
References: <20091008162454.23192.91832.sendpatchset@localhost.localdomain> <20091008162515.23192.48252.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Andi Kleen <andi@firstfloor.org>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 8 Oct 2009, Lee Schermerhorn wrote:

> @@ -1144,14 +1156,15 @@ static void __init report_hugepages(void
>  }
>  
>  #ifdef CONFIG_HIGHMEM
> -static void try_to_free_low(struct hstate *h, unsigned long count)
> +static void try_to_free_low(struct hstate *h, unsigned long count,
> +						nodemask_t *nodes_allowed)
>  {
>  	int i;
>  
>  	if (h->order >= MAX_ORDER)
>  		return;
>  
> -	for (i = 0; i < MAX_NUMNODES; ++i) {
> +	for_each_node_mask(node, nodes_allowed_) {
>  		struct page *page, *next;
>  		struct list_head *freel = &h->hugepage_freelists[i];
>  		list_for_each_entry_safe(page, next, freel, lru) {

That's not looking good for i386, Andrew please fold the following into 
this patch when it's merged into -mm:

[rientjes@google.com: fix HIGHMEM compile error]

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/hugetlb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1166,7 +1166,7 @@ static void try_to_free_low(struct hstate *h, unsigned long count,
 	if (h->order >= MAX_ORDER)
 		return;
 
-	for_each_node_mask(node, nodes_allowed_) {
+	for_each_node_mask(i, *nodes_allowed) {
 		struct page *page, *next;
 		struct list_head *freel = &h->hugepage_freelists[i];
 		list_for_each_entry_safe(page, next, freel, lru) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

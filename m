Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC7C6B0085
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 05:01:01 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so35041117pab.1
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 02:01:01 -0700 (PDT)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id ml1si15453672pab.24.2015.06.19.02.00.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Jun 2015 02:01:00 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 19 Jun 2015 14:30:57 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 9B083125805B
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 14:33:27 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t5J90meg60293360
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 14:30:50 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t5J90kDk012811
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 14:30:47 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm, thp: respect MPOL_PREFERRED policy with non-local node
In-Reply-To: <1434639273-9527-1-git-send-email-vbabka@suse.cz>
References: <1434639273-9527-1-git-send-email-vbabka@suse.cz>
Date: Fri, 19 Jun 2015 14:30:43 +0530
Message-ID: <871th89io4.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.cz>

Vlastimil Babka <vbabka@suse.cz> writes:

> Since commit 077fcf116c8c ("mm/thp: allocate transparent hugepages on local
> node"), we handle THP allocations on page fault in a special way - for
> non-interleave memory policies, the allocation is only attempted on the node
> local to the current CPU, if the policy's nodemask allows the node.
>
> This is motivated by the assumption that THP benefits cannot offset the cost
> of remote accesses, so it's better to fallback to base pages on the local node
> (which might still be available, while huge pages are not due to
> fragmentation) than to allocate huge pages on a remote node.
>
> The nodemask check prevents us from violating e.g. MPOL_BIND policies where
> the local node is not among the allowed nodes. However, the current
> implementation can still give surprising results for the MPOL_PREFERRED policy
> when the preferred node is different than the current CPU's local node.
>
> In such case we should honor the preferred node and not use the local node,
> which is what this patch does. If hugepage allocation on the preferred node
> fails, we fall back to base pages and don't try other nodes, with the same
> motivation as is done for the local node hugepage allocations.
> The patch also moves the MPOL_INTERLEAVE check around to simplify the hugepage
> specific test.
>
> The difference can be demonstrated using in-tree transhuge-stress test on the
> following 2-node machine where half memory on one node was occupied to show
> the difference.
>
>
.....

> Without -p parameter, hugepage restriction to CPU-local node works as before.
>
> Fixes: 077fcf116c8c ("mm/thp: allocate transparent hugepages on local node")
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Michal Hocko <mhocko@suse.cz>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
  

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

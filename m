Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1D2CF6B0035
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 20:54:23 -0400 (EDT)
Received: by mail-ie0-f175.google.com with SMTP id x19so1827386ier.34
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 17:54:22 -0700 (PDT)
Received: from mail-ie0-x229.google.com (mail-ie0-x229.google.com [2607:f8b0:4001:c03::229])
        by mx.google.com with ESMTPS id h16si16458398igt.43.2014.07.16.17.54.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 17:54:22 -0700 (PDT)
Received: by mail-ie0-f169.google.com with SMTP id tp5so1857619ieb.28
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 17:54:22 -0700 (PDT)
Date: Wed, 16 Jul 2014 17:54:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, tmp: only collapse hugepages to nodes with affinity
 for zone_reclaim_mode
In-Reply-To: <53C69C7B.1010709@suse.cz>
Message-ID: <alpine.DEB.2.02.1407161754000.23892@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1407141807030.8808@chino.kir.corp.google.com> <alpine.DEB.2.02.1407151712520.12279@chino.kir.corp.google.com> <53C69C7B.1010709@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Bob Liu <bob.liu@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 16 Jul 2014, Vlastimil Babka wrote:

> I wonder if you could do this here?
> 
> if (khugepaged_node_load[nid])
> 	return false;
> 
> If the condition is true, it means you already checked the 'nid' node against
> all other nodes present in the pmd in a previous khugepaged_scan_pmd iteration.
> And if it passed then, it would also pass now. If meanwhile a new node was found
> and recorded, it was also checked against everything present at that point,
> including 'nid'. So it should be safe?
> 
> The worst case (perfect interleaving page per page, so that "node != last_node"
> is true in each iteration) complexity then reduces from O(HPAGE_PMD_NR *
> MAX_NUMNODES) to O(HPAGE_PMD_NR + MAX_NUMNODES) iterations.
> 

Excellent suggestion, thanks Vlastimil!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

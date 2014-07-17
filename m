Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3DD1F6B0035
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 20:49:40 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id tp5so1825363ieb.9
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 17:49:40 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id x10si27953819igg.53.2014.07.16.17.49.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 17:49:39 -0700 (PDT)
Received: by mail-ig0-f170.google.com with SMTP id h3so4888327igd.5
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 17:49:39 -0700 (PDT)
Date: Wed, 16 Jul 2014 17:49:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, tmp: only collapse hugepages to nodes with affinity
 for zone_reclaim_mode
In-Reply-To: <53C69E92.70608@suse.cz>
Message-ID: <alpine.DEB.2.02.1407161748400.23892@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1407141807030.8808@chino.kir.corp.google.com> <alpine.DEB.2.02.1407151712520.12279@chino.kir.corp.google.com> <53C5D3D2.8080000@oracle.com> <53C69E92.70608@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Bob Liu <bob.liu@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 16 Jul 2014, Vlastimil Babka wrote:

> >> @@ -2545,6 +2571,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
> >>  		 * hit record.
> >>  		 */
> >>  		node = page_to_nid(page);
> >> +		if (node != last_node) {
> >> +			if (khugepaged_scan_abort(node))
> >> +				goto out_unmap;
> > 
> > Nitpick: How about not break the loop but only reset the related
> > khugepaged_node_load[] to zero. E.g. modify khugepaged_scan_abort() like
> > this:
> > if (node_distance(nid, i) > RECLAIM_DISTANCE)
> >    khugepaged_node_load[i] = 0;
> > 
> > By this way, we may have a chance to find a more suitable node.
> 
> Hm theoretically there might be a suitable node, but this approach wouldn't
> work. By resetting it to zero you forget that there ever was node 'i'. If there
> is no more base page from node 'i', the load remains zero and the next call with
> 'nid' will think that 'nid' is OK.
> 

Right, the suggestion is wrong because we do not want to ever collapse to 
a node when the distance from the source page is > RECLAIM_DISTANCE, 
that's the entire point of the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

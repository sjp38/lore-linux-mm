Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 967B06B0035
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 00:47:18 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fb1so6646947pad.0
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 21:47:18 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id mm9si10769608pbc.151.2014.07.14.21.47.16
        for <linux-mm@kvack.org>;
        Mon, 14 Jul 2014 21:47:16 -0700 (PDT)
Message-ID: <53C4B251.5000505@intel.com>
Date: Mon, 14 Jul 2014 21:47:13 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, thp: only collapse hugepages to nodes with affinity
References: <alpine.DEB.2.02.1407141807030.8808@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1407141807030.8808@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Bob Liu <bob.liu@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/14/2014 06:09 PM, David Rientjes wrote:
> +		if (node == NUMA_NO_NODE) {
> +			node = page_to_nid(page);
> +		} else {
> +			int distance = node_distance(page_to_nid(page), node);
> +
> +			/*
> +			 * Do not migrate to memory that would not be reclaimed
> +			 * from.
> +			 */
> +			if (distance > RECLAIM_DISTANCE)
> +				goto out_unmap;
> +		}

Isn't the reclaim behavior based on zone_reclaim_mode and not
RECLAIM_DISTANCE directly?  And isn't that reclaim behavior disabled by
default?

I think you should at least be consulting zone_reclaim_mode.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

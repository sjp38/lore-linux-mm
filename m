Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 78E1E8D003F
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 16:22:01 -0500 (EST)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p1MLLwI1009016
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 13:21:58 -0800
Received: from pzk7 (pzk7.prod.google.com [10.243.19.135])
	by hpaq7.eem.corp.google.com with ESMTP id p1MLLSFI016490
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 13:21:56 -0800
Received: by pzk7 with SMTP id 7so506875pzk.8
        for <linux-mm@kvack.org>; Tue, 22 Feb 2011 13:21:52 -0800 (PST)
Date: Tue, 22 Feb 2011 13:21:48 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/5] pagewalk: only split huge pages when necessary
In-Reply-To: <20110222015339.0C9A2212@kernel>
Message-ID: <alpine.DEB.2.00.1102221316400.5929@chino.kir.corp.google.com>
References: <20110222015338.309727CA@kernel> <20110222015339.0C9A2212@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>

On Mon, 21 Feb 2011, Dave Hansen wrote:

> 
> v2 - rework if() block, and remove  now redundant split_huge_page()
> 
> Right now, if a mm_walk has either ->pte_entry or ->pmd_entry
> set, it will unconditionally split any transparent huge pages
> it runs in to.  In practice, that means that anyone doing a
> 
> 	cat /proc/$pid/smaps
> 
> will unconditionally break down every huge page in the process
> and depend on khugepaged to re-collapse it later.  This is
> fairly suboptimal.
> 
> This patch changes that behavior.  It teaches each ->pmd_entry
> handler (there are five) that they must break down the THPs
> themselves.  Also, the _generic_ code will never break down
> a THP unless a ->pte_entry handler is actually set.
> 
> This means that the ->pmd_entry handlers can now choose to
> deal with THPs without breaking them down.
> 
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

Thanks for adding the comment about ->pmd_entry() being required to split 
the pages in include/linux/mm.h!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

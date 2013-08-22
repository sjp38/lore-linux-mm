Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 0B1456B0034
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 02:50:31 -0400 (EDT)
Date: Thu, 22 Aug 2013 15:50:38 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 03/20] mm, hugetlb: fix subpool accounting handling
Message-ID: <20130822065038.GA13415@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1376040398-11212-4-git-send-email-iamjoonsoo.kim@lge.com>
 <87vc2zgzpn.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87vc2zgzpn.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

Hello, Aneesh.

First of all, thank you for review!

On Wed, Aug 21, 2013 at 02:58:20PM +0530, Aneesh Kumar K.V wrote:
> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> 
> > If we alloc hugepage with avoid_reserve, we don't dequeue reserved one.
> > So, we should check subpool counter when avoid_reserve.
> > This patch implement it.
> 
> Can you explain this better ? ie, if we don't have a reservation in the
> area chg != 0. So why look at avoid_reserve. 

We don't consider avoid_reserve when chg != 0.
Look at following code.

+       if (chg || avoid_reserve)
+               if (hugepage_subpool_get_pages(spool, 1))

It means that if chg != 0, we skip to check avoid_reserve.

> 
> Also the code will become if you did
> 
> if (!chg && avoid_reserve)
>    chg = 1;
> 
> and then rest of the code will be able to handle the case.


We still pass avoid_reserve to dequeue_huge_page_vma() and check avoid_reserve
there, so maintaining avoid_reserve and checking it separately is better
to understand a logic. And it doesn't matter at all since I eventually unify
these in patch 13.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

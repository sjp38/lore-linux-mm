Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 9B3AF6B0032
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 04:44:33 -0400 (EDT)
Date: Wed, 4 Sep 2013 17:44:30 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 19/20] mm, hugetlb: retry if failed to allocate and
 there is concurrent user
Message-ID: <20130904084430.GD16355@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1376040398-11212-20-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1376040398-11212-20-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Fri, Aug 09, 2013 at 06:26:37PM +0900, Joonsoo Kim wrote:
> If parallel fault occur, we can fail to allocate a hugepage,
> because many threads dequeue a hugepage to handle a fault of same address.
> This makes reserved pool shortage just for a little while and this cause
> faulting thread who can get hugepages to get a SIGBUS signal.
> 
> To solve this problem, we already have a nice solution, that is,
> a hugetlb_instantiation_mutex. This blocks other threads to dive into
> a fault handler. This solve the problem clearly, but it introduce
> performance degradation, because it serialize all fault handling.
> 
> Now, I try to remove a hugetlb_instantiation_mutex to get rid of
> performance degradation. For achieving it, at first, we should ensure that
> no one get a SIGBUS if there are enough hugepages.
> 
> For this purpose, if we fail to allocate a new hugepage when there is
> concurrent user, we return just 0, instead of VM_FAULT_SIGBUS. With this,
> these threads defer to get a SIGBUS signal until there is no
> concurrent user, and so, we can ensure that no one get a SIGBUS if there
> are enough hugepages.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 

Hello, David.
May I ask to you to review this one?
I guess that you already thought about the various race condition,
so I think that you are the most appropriate reviewer to this patch. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

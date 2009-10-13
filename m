Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BDD4C6B00B6
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 01:50:49 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.1/8.13.1) with ESMTP id n9D5odhs005739
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 05:50:39 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9D5oc2E3485728
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 07:50:39 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n9D5ob84001461
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 07:50:38 +0200
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: oomkiller over-ambitious after "vmscan: make mapped executable pages the first class citizen" (bisected)
Date: Tue, 13 Oct 2009 07:50:36 +0200
References: <200910122244.19666.borntraeger@de.ibm.com> <20091013022650.GB7345@localhost>
In-Reply-To: <20091013022650.GB7345@localhost>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200910130750.36392.borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Am Dienstag 13 Oktober 2009 04:26:50 schrieb Wu Fengguang:
[...]

> Can you try this patch? Thanks!

Yes, this patch solves the problem. In fact, my test case was a reduced version
of KVM on s390 and it helps there as well.

Since the problem also affects 2.6.31 I added stable.

I agree with Rik, that this patch should go to Linus quickly, what is the best 
way? Andrew?

> ---
> vmscan: limit VM_EXEC protection to file pages
> 
> It is possible to have !Anon but SwapBacked pages, and some apps could
> create huge number of such pages with MAP_SHARED|MAP_ANONYMOUS. These
> pages go into the ANON lru list, and hence shall not be protected: we
> only care mapped executable files. Failing to do so may trigger OOM.
> 
> Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Tested-by: Christian Borntraeger <borntraeger@de.ibm.com>

> ---
>  mm/vmscan.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux.orig/mm/vmscan.c	2009-10-13 09:49:05.000000000 +0800
> +++ linux/mm/vmscan.c	2009-10-13 09:49:37.000000000 +0800
> @@ -1356,7 +1356,7 @@ static void shrink_active_list(unsigned
>  			 * IO, plus JVM can create lots of anon VM_EXEC pages,
>  			 * so we ignore them here.
>  			 */
> -			if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
> +			if ((vm_flags & VM_EXEC) && page_is_file_cache(page)) {
>  				list_add(&page->lru, &l_active);
>  				continue;
>  			}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

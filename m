Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 37DE76B0099
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 22:33:09 -0400 (EDT)
Message-ID: <4AD3E6C4.805@redhat.com>
Date: Mon, 12 Oct 2009 22:32:36 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: oomkiller over-ambitious after "vmscan: make mapped executable
 pages the first class citizen" (bisected)
References: <200910122244.19666.borntraeger@de.ibm.com> <20091013022650.GB7345@localhost>
In-Reply-To: <20091013022650.GB7345@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:

> vmscan: limit VM_EXEC protection to file pages
> 
> It is possible to have !Anon but SwapBacked pages, and some apps could
> create huge number of such pages with MAP_SHARED|MAP_ANONYMOUS. These
> pages go into the ANON lru list, and hence shall not be protected: we
> only care mapped executable files. Failing to do so may trigger OOM.

Good catch!  The MAP_SHARED|MAP_ANONYMOUS segments may
be backed by anonymous tmpfs files, instead of by
actual anonymous memory!

If this patch solves Christian's problem, I believe
it should get merged into Linus's tree ASAP.

> Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

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


-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

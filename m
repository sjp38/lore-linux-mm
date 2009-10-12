Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A65286B005D
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 17:18:09 -0400 (EDT)
Subject: Re: oomkiller over-ambitious after "vmscan: make mapped executable
 pages the first class citizen" (bisected)
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <200910122244.19666.borntraeger@de.ibm.com>
References: <200910122244.19666.borntraeger@de.ibm.com>
Content-Type: text/plain
Date: Mon, 12 Oct 2009 23:17:45 +0200
Message-Id: <1255382265.8967.620.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-10-12 at 22:44 +0200, Christian Borntraeger wrote:
> In fact, applying this patch makes the problem go away:

> --- linux-2.6.orig/mm/vmscan.c
> +++ linux-2.6/mm/vmscan.c
> @@ -1345,22 +1345,8 @@ static void shrink_active_list(unsigned 
>  
>                 /* page_referenced clears PageReferenced */
>                 if (page_mapping_inuse(page) &&
> -                   page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
> +                   page_referenced(page, 0, sc->mem_cgroup, &vm_flags))
>                         nr_rotated++;
> -                       /*
> -                        * Identify referenced, file-backed active pages and
> -                        * give them one more trip around the active list. So
> -                        * that executable code get better chances to stay in
> -                        * memory under moderate memory pressure.  Anon pages
> -                        * are not likely to be evicted by use-once streaming
> -                        * IO, plus JVM can create lots of anon VM_EXEC pages,
> -                        * so we ignore them here.
> -                        */
> -                       if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
> -                               list_add(&page->lru, &l_active);
> -                               continue;
> -                       }
> -               }
>  
>                 ClearPageActive(page);  /* we are de-activating */
>                 list_add(&page->lru, &l_inactive);

> the interesting part is, that s390x in the default configuration has no no-
> execute feature, resulting in the following map 
> c0000000-1c04cd000 rwxs 00000000 00:04 18517        /dev/zero (deleted)
> As you can see, this area looks file mapped (/dev/zero) and executable. On the 
> other hand, the !PageAnon clause should cover this case. I am lost.
> 
> Does anybody on the CC (taken from the original patch) has an idea what the 
> problem is and how to fix this properly?

One thing that sprung out to me is that s390 has the young bit in the
storage key and not in the page-tables.

Hence it has a NOP ptep_clear_flush_young(), which makes
page_referenced_one() very unlikely to set vm_flags. This would make the
above condition even harder to trigger though, so I'm not sure what good
this observation is.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

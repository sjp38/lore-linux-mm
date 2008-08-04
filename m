Date: Mon, 4 Aug 2008 13:05:11 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] Update Unevictable LRU and Mlocked Pages documentation
Message-Id: <20080804130511.4a04a289.randy.dunlap@oracle.com>
In-Reply-To: <1217452439.7676.26.camel@lts-notebook>
References: <1217452439.7676.26.camel@lts-notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jul 2008 17:13:59 -0400 Lee Schermerhorn wrote:

> Against:  [27-rc1+]mmotm-080730-0356
> 
> Update to: doc-unevictable-lru-and-mlocked-pages-documentation.patch
> 
> Update unevictable lru documentation based on review and testing
> rework and fixes.
> 
> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> 
>  Documentation/vm/unevictable-lru.txt |  170 +++++++++++++++++------------------
>  1 file changed, 84 insertions(+), 86 deletions(-)
> 
> Index: linux-2.6.27-rc1-mmotm-30jul/Documentation/vm/unevictable-lru.txt
> ===================================================================
> --- linux-2.6.27-rc1-mmotm-30jul.orig/Documentation/vm/unevictable-lru.txt	2008-07-30 16:17:07.000000000 -0400
> +++ linux-2.6.27-rc1-mmotm-30jul/Documentation/vm/unevictable-lru.txt	2008-07-30 16:37:31.000000000 -0400

> @@ -44,14 +44,21 @@ it indicates on which LRU list a page re
>  unevictable LRU list is source configurable based on the UNEVICTABLE_LRU Kconfig
>  option.
>  
> -Why maintain unevictable pages on an additional LRU list?  The Linux memory
> -management subsystem has well established protocols for managing pages on the
> -LRU.  Vmscan is based on LRU lists.  LRU list exist per zone, and we want to
> -maintain pages relative to their "home zone".  All of these make the use of
> -an additional list, parallel to the LRU active and inactive lists, a natural
> -mechanism to employ.  Note, however, that the unevictable list does not
> -differentiate between file backed and swap backed [anon] pages.  This
> -differentiation is only important while the pages are, in fact, evictable.
> +Why maintain unevictable pages on an additional LRU list?  Primarily because
> +we want to be able to migrate unevictable pages between nodes--for memory
> +deframentation, workload management and memory hotplug.  The linux kernel can

   defragmentation

> +only migrate pages that it can successfully isolate from the lru lists.
> +Therefore, we want to keep the unevictable pages on an lru-like list, where
> +they can be found by isolate_lru_page().
> +
> +Secondarily, the Linux memory management subsystem has well established
> +protocols for managing pages on the LRU.  Vmscan is based on LRU lists.
> +LRU list exist per zone, and we want to maintain pages relative to their

       lists

> +"home zone".  All of these make the use of an additional list, parallel to
> +the LRU active and inactive lists, a natural mechanism to employ.  Note,
> +however, that the unevictable list does not differentiate between file backed
> +and swap backed [anon] pages.  This differentiation is only important while
> +the pages are, in fact, evictable.
>  
>  The unevictable LRU list benefits from the "arrayification" of the per-zone
>  LRU lists and statistics originally proposed and posted by Christoph Lameter.

> @@ -133,22 +140,30 @@ whether any VM_LOCKED vmas map the page 
>  If try_to_munlock() returns SWAP_MLOCK, shrink_page_list() will cull the page
>  without consuming swap space.  try_to_munlock() will be described below.
>  
> +To "cull" an unevictable page, vmscan simply puts the page back on the lru
> +list using putback_lru_page()--the inverse operation to isolate_lru_page()--
> +after dropping the page lock.  Because the condition which makes the page
> +unevictable may change once the page is unlocked, putback_lru_page() will
> +recheck the unevictable state of a page that it places on the unevictable lru
> +list.  If the page has become unevictable, putback_lru_page() removes it from
> +the list and retries, including the page_unevictable() test.  Because such a
> +race is a rare event and movement of pages onto the unevictable list should be
> +rare, these extra evictabilty checks should not occur in the majority of calls
> +to putback_lru_page().
> +
>  
>  Mlocked Page:  Prior Work
>  
> -The "Unevictable Mlocked Pages" infrastructure is based on work originally posted
> -by Nick Piggin in an RFC patch entitled "mm: mlocked pages off LRU".  Nick's
> -posted his patch as an alternative to a patch posted by Christoph Lameter to
> -achieve the same objective--hiding mlocked pages from vmscan.  In Nick's patch,
> -he used one of the struct page lru list link fields as a count of VM_LOCKED
> -vmas that map the page.  This use of the link field for a count prevent the
> -management of the pages on an LRU list.  When Nick's patch was integrated with
> -the Unevictable LRU work, the count was replaced by walking the reverse map to
> -determine whether any VM_LOCKED vmas mapped the page.  More on this below.
> -The primary reason for wanting to keep mlocked pages on an LRU list is that
> -mlocked pages are migratable, and the LRU list is used to arbitrate tasks
> -attempting to migrate the same page.  Whichever task succeeds in "isolating"
> -the page from the LRU performs the migration.
> +The "Unevictable Mlocked Pages" infrastructure is based on work originally
> +posted by Nick Piggin in an RFC patch entitled "mm: mlocked pages off LRU".
> +Nick's posted his patch as an alternative to a patch posted by Christoph

   Nick posted

> +Lameter to achieve the same objective--hiding mlocked pages from vmscan.
> +In Nick's patch, he used one of the struct page lru list link fields as a count
> +of VM_LOCKED vmas that map the page.  This use of the link field for a count
> +prevent the management of the pages on an LRU list.  When Nick's patch was

   prevents / prevented (?)

> +integrated with the Unevictable LRU work, the count was replaced by walking the
> +reverse map to determine whether any VM_LOCKED vmas mapped the page.  More on
> +this below.
>  
>  
>  Mlocked Pages:  Basic Management


---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

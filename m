Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9E75190013D
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 20:27:24 -0400 (EDT)
Date: Wed, 24 Aug 2011 02:27:17 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp: tail page refcounting fix
Message-ID: <20110824002717.GI23870@redhat.com>
References: <1313740111-27446-1-git-send-email-walken@google.com>
 <20110822213347.GF2507@redhat.com>
 <CANN689HE=TKyr-0yDQgXEoothGJ0Cw0HLB2iOvCKrOXVF2DNww@mail.gmail.com>
 <20110824000914.GH23870@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110824000914.GH23870@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Wed, Aug 24, 2011 at 02:09:14AM +0200, Andrea Arcangeli wrote:
> That's an optimization I can look into agreed. I guess I just added
> one line and not even think too much at optimizing this,
> split_huge_page isn't in a fast path.

So this would more or less be the optimization (untested):

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1169,8 +1169,8 @@ static void __split_huge_page_refcount(s
 		atomic_sub(page_mapcount(page_tail), &page->_count);
 		BUG_ON(atomic_read(&page->_count) <= 0);
 		BUG_ON(atomic_read(&page_tail->_count) != 0);
-		atomic_add(page_mapcount(page) + 1, &page_tail->_count);
-		atomic_add(page_mapcount(page_tail), &page_tail->_count);
+		atomic_add(page_mapcount(page) + page_mapcount(page_tail) + 1,
+			   &page_tail->_count);
 
 		/* after clearing PageTail the gup refcount can be released */
 		smp_mb();

This might also be possible but I'm scared by it because the value
would be set by the C language without locked op, and I wonder then
what happens with get_page_unless_zero runs. Now we relay on atomic
(without lock prefix) writes from C for all pagetable updates
already. So I guess this might actually work ok too in
practice. get_page_unless_zero not incrementing anything sounds
unlikely, and it's hard to see how it could increment zero or a random
value if the "long" write is done in a single asm insn (like we relay
in other places). But still the above is obviously safe, the below far
less obvious and generally one always is forced to use locked ops on
any region of memory concurrently modified to have a deterministic
result. And there's nothing anywhere doing atomic_set on page->_count
except at boot where there are no races before the pages are visible
to the buddy allocator. So for now I'll stick to the above version
unless somebody can guarantee the safety of the below (which I can't).
Comments welcome..

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1169,8 +1169,8 @@ static void __split_huge_page_refcount(s
 		atomic_sub(page_mapcount(page_tail), &page->_count);
 		BUG_ON(atomic_read(&page->_count) <= 0);
 		BUG_ON(atomic_read(&page_tail->_count) != 0);
-		atomic_add(page_mapcount(page) + 1, &page_tail->_count);
-		atomic_add(page_mapcount(page_tail), &page_tail->_count);
+		atomic_set(&page_tail->_count,
+			   page_mapcount(page) + page_mapcount(page_tail) + 1);
 
 		/* after clearing PageTail the gup refcount can be released */
 		smp_mb();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [patch] mm: dont mark_page_accessed in fault path
References: <20081021072555.GA3237@wotan.suse.de>
Date: Tue, 21 Oct 2008 12:27:14 +0200
In-Reply-To: <20081021072555.GA3237@wotan.suse.de> (Nick Piggin's message of
	"Tue, 21 Oct 2008 09:25:55 +0200")
Message-ID: <87hc76gs59.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> writes:

> Doing a mark_page_accessed at fault-time, then doing SetPageReferenced at
> unmap-time if the pte is young has a number of problems.
>
> mark_page_accessed is supposed to be roughly the equivalent of a young pte
> for unmapped references. Unfortunately it doesn't come with any context:
> after being called, reclaim doesn't know who or why the page was touched.
>
> So calling mark_page_accessed not only adds extra lru or PG_referenced
> manipulations for pages that are already going to have pte_young ptes anyway,
> but it also adds these references which are difficult to work with from the
> context of vma specific references (eg. MADV_SEQUENTIAL pte_young may not
> wish to contribute to the page being referenced).
>
> Then, simply doing SetPageReferenced when zapping a pte and finding it is
> young, is not a really good solution either. SetPageReferenced does not
> correctly promote the page to the active list for example. So after removing
> mark_page_accessed from the fault path, several mmap()+touch+munmap() would
> have a very different result from several read(2) calls for example, which
> is not really desirable.
>
> Signed-off-by: Nick Piggin <npiggin@suse.de>

  Acked-by: Johannes Weiner <hannes@saeurebad.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

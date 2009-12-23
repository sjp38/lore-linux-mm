Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6A62A620002
	for <linux-mm@kvack.org>; Tue, 22 Dec 2009 19:07:49 -0500 (EST)
Date: Wed, 23 Dec 2009 01:06:40 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 25 of 28] transparent hugepage core
Message-ID: <20091223000640.GI6429@random.random>
References: <patchbomb.1261076403@v2.random>
 <4d96699c8fb89a4a22eb.1261076428@v2.random>
 <20091218200345.GH21194@csn.ul.ie>
 <20091219164143.GC29790@random.random>
 <20091221203149.GD23345@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091221203149.GD23345@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, Paul Mundt <lethal@linux-sh.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 21, 2009 at 08:31:50PM +0000, Mel Gorman wrote:
> My vague worry is that multiple huge page sizes are currently supported in
> hugetlbfs but transparent support is obviously tied to the page-table level
> it's implemented for. In the future, the term "huge" could be ambiguous . How
> about instead of things like HUGE_MASK, it would be HUGE_PMD_MASK? It's not
> something I feel very strongly about as eventually I'll remember what sort of
> "huge" is meant in each context.

Ok this naming seems to be a little troublesome. HUGE_PMD_MASK would
then require HUGE_PMD_SIZE. That is confusing a little to me, that is
the size of the page not of the pmd... Maybe HPAGE_PMD_SIZE is better?
Overall this is just one #define and search and replace, I can do that
if people likes it more than HPAGE_SIZE.

> /*
>  * Currently uses  __GFP_REPEAT during allocation. Should be implemented
>  * using page migration in the future
>  */

Done! thanks.

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -75,6 +75,11 @@ static ssize_t enabled_store(struct kobj
 static struct kobj_attribute enabled_attr =
 	__ATTR(enabled, 0644, enabled_show, enabled_store);
 
+/*
+ * Currently uses __GFP_REPEAT during allocation. Should be
+ * implemented using page migration and real defrag algorithms in
+ * future VM.
+ */
 static ssize_t defrag_show(struct kobject *kobj,
 			   struct kobj_attribute *attr, char *buf)
 {

> do_huge_pmd_anonymous_page makes sense.

Agreed, I already changed all methods called from memory.c to
huge_memory.c with a "huge_pmd" prefix instead of just "huge".

> IA-64 can't in its currently implementation. Due to the page table format
> they use, huge pages can only be mapped at specific ranges in the virtual
> address space. If the long-format version of the page table was used, they

Hmm ok, so it sounds like hugetlbfs limitations are a software feature
for ia64 too.

> would be able to but I bet it's not happening any time soon. The best bet
> for other architectures supporting this would be sparc and maybe sh.
> It might be worth poking Paul Mundt in particular because he expressed
> an interest in transparent support of some sort in the past for sh.

I added him to CC.

> Because huge pages cannot move. If the MOVABLE zone has been set up to
> guarantee memory hot-plug removal, they don't want huge pages to be
> getting in the way. To allow unconditional use of GFP_HIGHUSER_MOVABLE,
> memory hotplug would have to know it can demote all the transparent huge
> pages and migrate them that way.

It should already do. migrate.c calls try_to_unmap that will split
them and migrate them just fine. If they can't be migrated I will
remove GFP_HIGHUSER_MOVABLE but I think they can already. migrate.c
can't notice the difference.

> My preference would be to move the alloc_mask into common code or at
> least make it available via mm/internal.h because otherwise this will
> collide with memory hot-remove in the future.

We can do that. But what I don't understand is why do_anonymous_page
ses an unconditional GFP_HIGHUSER_MOVABLE. If there's no benefit to
do_anonymous_page to turn off the gfp movable flag, I don't see why it
could be beneficial to turn it off on hugepages. If there's good
reason for that we surely can make it conditional into common code. I
didn't look too hard for it, but what is the reason there is this flag
in hugetlbfs?

> I would prefer pmd to be added to the huge names. However, this was
> mostly to aid comprehension of the patchset when I was taking a quick

That is neutral to me... it's just that HPAGE_SIZE already existed so
I tried to avoid adding unnecessary things but I'm not against
HPAGE_PMD_SIZE, that will make it more clearer this is the size of a
hugepage mapped by a pmd (and not a gigapage mapped by pud).

Thanks for the help! (we'll need more of your help in the defrag area
too according to comment added above ;)

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

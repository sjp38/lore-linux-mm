Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 5E3DA6B0069
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 07:31:43 -0400 (EDT)
Date: Fri, 5 Oct 2012 13:31:14 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 29/33] autonuma: page_autonuma
Message-ID: <20121005113114.GF6793@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <1349308275-2174-30-git-send-email-aarcange@redhat.com>
 <506DED04.6090706@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <506DED04.6090706@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Hi KOSAKI,

On Thu, Oct 04, 2012 at 04:09:40PM -0400, KOSAKI Motohiro wrote:
> > +struct page_autonuma *lookup_page_autonuma(struct page *page)
> > +{
> > +	unsigned long pfn = page_to_pfn(page);
> > +	unsigned long offset;
> > +	struct page_autonuma *base;
> > +
> > +	base = NODE_DATA(page_to_nid(page))->node_page_autonuma;
> > +#ifdef CONFIG_DEBUG_VM
> > +	/*
> > +	 * The sanity checks the page allocator does upon freeing a
> > +	 * page can reach here before the page_autonuma arrays are
> > +	 * allocated when feeding a range of pages to the allocator
> > +	 * for the first time during bootup or memory hotplug.
> > +	 */
> > +	if (unlikely(!base))
> > +		return NULL;
> > +#endif
> 
> When using CONFIG_DEBUG_VM, please just use BUG_ON instead of additional
> sanity check. Otherwise only MM people might fault to find a real bug.

Agreed. But I just tried to stick to the page_cgroup.c model. I
suggest you send a patch to fix it in mm/page_cgroup.c, then I'll
synchronize mm/page_autonuma.c with whatever lands in page_cgroup.c.

The idea is that in the future it'd be nice to unify those with a
common implementation. And the closer page_cgroup.c and
page_autonuma.c are, the less work it'll be to update them to use a
common framework. And if it's never going to be worth it to unify it
(if it generates more code than it saves), well then keeping the code
as similar as possible, is still beneficial so it's easier to review both.

> And I have additional question here. What's happen if memory hotplug occur
> and several autonuma_last_nid will point to invalid node id? My quick skimming
> didn't find hotplug callback code.

last_nid is statistical info so if it's random it's ok (I didn't add
bugchecks to trap uninitialized cases to it, maybe I should?).

sparse_init_one_section also initializes it, and that's invoked by
sparse_add_one_section.

Also those fields are also initialized when the page is freed the
first time to add it to the buddy, but I didn't want to depend on
that, I thought an explicit init post-allocation would be more robust.

By reviewing it the only thing I found is that I was wasting a bit of
.text for 32bit builds (CONFIG_SPARSEMEM=n).

diff --git a/mm/page_autonuma.c b/mm/page_autonuma.c
index d400d7f..303b427 100644
--- a/mm/page_autonuma.c
+++ b/mm/page_autonuma.c
@@ -14,7 +14,7 @@ void __meminit page_autonuma_map_init(struct page *page,
 		page_autonuma->autonuma_last_nid = -1;
 }
 
-static void __meminit __pgdat_autonuma_init(struct pglist_data *pgdat)
+static void __paginginit __pgdat_autonuma_init(struct pglist_data *pgdat)
 {
 	spin_lock_init(&pgdat->autonuma_migrate_lock);
 	pgdat->autonuma_migrate_nr_pages = 0;
@@ -29,7 +29,7 @@ static void __meminit __pgdat_autonuma_init(struct pglist_data *pgdat)
 
 static unsigned long total_usage;
 
-void __meminit pgdat_autonuma_init(struct pglist_data *pgdat)
+void __paginginit pgdat_autonuma_init(struct pglist_data *pgdat)
 {
 	__pgdat_autonuma_init(pgdat);
 	pgdat->node_page_autonuma = NULL;
@@ -131,7 +131,7 @@ struct page_autonuma *lookup_page_autonuma(struct page *page)
 	return section->section_page_autonuma + pfn;
 }
 
-void __meminit pgdat_autonuma_init(struct pglist_data *pgdat)
+void __paginginit pgdat_autonuma_init(struct pglist_data *pgdat)
 {
 	__pgdat_autonuma_init(pgdat);
 }


So those can be freed if it's a non sparsemem build. The caller has
__paginging init too so it should be ok.


The other page_autonuma.c places invoked only by sparsemem hotplug
code are using meminit so in theory it should work (I haven't tested
it yet).

Thanks for the review!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

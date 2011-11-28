Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 81B846B002D
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 04:34:57 -0500 (EST)
Date: Mon, 28 Nov 2011 10:34:35 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 4/8] mm: memcg: lookup_page_cgroup (almost) never returns
 NULL
Message-ID: <20111128093435.GC9356@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
 <1322062951-1756-5-git-send-email-hannes@cmpxchg.org>
 <20111124095251.GD26036@tiehlicka.suse.cz>
 <20111124100549.GH6843@cmpxchg.org>
 <20111124102606.GF26036@tiehlicka.suse.cz>
 <20111128091518.GA9356@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111128091518.GA9356@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 28, 2011 at 10:15:18AM +0100, Johannes Weiner wrote:
> On Thu, Nov 24, 2011 at 11:26:06AM +0100, Michal Hocko wrote:
> > On Thu 24-11-11 11:05:49, Johannes Weiner wrote:
> > > On Thu, Nov 24, 2011 at 10:52:51AM +0100, Michal Hocko wrote:
> > > > On Wed 23-11-11 16:42:27, Johannes Weiner wrote:
> > > > > From: Johannes Weiner <jweiner@redhat.com>
> > > > > 
> > > > > Pages have their corresponding page_cgroup descriptors set up before
> > > > > they are used in userspace, and thus managed by a memory cgroup.
> > > > > 
> > > > > The only time where lookup_page_cgroup() can return NULL is in the
> > > > > page sanity checking code that executes while feeding pages into the
> > > > > page allocator for the first time.
> > > > > 
> > > > > Remove the NULL checks against lookup_page_cgroup() results from all
> > > > > callsites where we know that corresponding page_cgroup descriptors
> > > > > must be allocated.
> > > > 
> > > > OK, shouldn't we add
> > > > 
> > > > diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> > > > index 2d123f9..cb93f64 100644
> > > > --- a/mm/page_cgroup.c
> > > > +++ b/mm/page_cgroup.c
> > > > @@ -35,8 +35,7 @@ struct page_cgroup *lookup_page_cgroup(struct page *page)
> > > >  	struct page_cgroup *base;
> > > >  
> > > >  	base = NODE_DATA(page_to_nid(page))->node_page_cgroup;
> > > > -	if (unlikely(!base))
> > > > -		return NULL;
> > > > +	BUG_ON(!base);
> > > >  
> > > >  	offset = pfn - NODE_DATA(page_to_nid(page))->node_start_pfn;
> > > >  	return base + offset;
> > > > @@ -112,8 +111,7 @@ struct page_cgroup *lookup_page_cgroup(struct page *page)
> > > >  	unsigned long pfn = page_to_pfn(page);
> > > >  	struct mem_section *section = __pfn_to_section(pfn);
> > > >  
> > > > -	if (!section->page_cgroup)
> > > > -		return NULL;
> > > > +	BUG_ON(!section->page_cgroup);
> > > >  	return section->page_cgroup + pfn;
> > > >  }
> > > >  
> > > > just to make it explicit?
> > > 
> > > No, see the last hunk in this patch.  It's actually possible for this
> > > to run, although only while feeding fresh pages into the allocator:
> > 
> > Bahh. Yes, I have noticed the hunk but then I started thinking about
> > how to make the NULL case explicit and totally forgot about that.
> > Sorry about the noise.
> > 
> > > 
> > > > > @@ -3326,6 +3321,7 @@ static struct page_cgroup *lookup_page_cgroup_used(struct page *page)
> > > > >  	struct page_cgroup *pc;
> > > > >  
> > > > >  	pc = lookup_page_cgroup(page);
> > > > > +	/* Can be NULL while bootstrapping the page allocator */
> > > > >  	if (likely(pc) && PageCgroupUsed(pc))
> > > > >  		return pc;
> > > > >  	return NULL;
> > > 
> > > We could add a lookup_page_cgroup_safe() for this DEBUG_VM-only
> > > callsite as an optimization separately and remove the NULL check from
> > > lookup_page_cgroup() itself.  But this patch was purely about removing
> > > the actively misleading checks.
> > 
> > Yes, but I am not sure whether code duplication is worth it. Let's just
> > stick with current form. Maybe just move the comment when it can be NULL
> > to the lookup_page_cgroup directly?
> 
> Don't underestimate it, this function is used quite heavily while the
> case of the array being NULL is a minor fraction of all calls.  But
> it's for another patch, anyway.

Hm, how about this?

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index a14655d..58405ca 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -28,9 +28,16 @@ struct page_cgroup *lookup_page_cgroup(struct page *page)
 	struct page_cgroup *base;
 
 	base = NODE_DATA(page_to_nid(page))->node_page_cgroup;
+#ifdef CONFIG_DEBUG_VM
+	/*
+	 * The sanity checks the page allocator does upon freeing a
+	 * page can reach here before the page_cgroup arrays are
+	 * allocated when feeding a range of pages to the allocator
+	 * for the first time during bootup or memory hotplug.
+	 */
 	if (unlikely(!base))
 		return NULL;
-
+#endif
 	offset = pfn - NODE_DATA(page_to_nid(page))->node_start_pfn;
 	return base + offset;
 }
@@ -87,9 +94,16 @@ struct page_cgroup *lookup_page_cgroup(struct page *page)
 {
 	unsigned long pfn = page_to_pfn(page);
 	struct mem_section *section = __pfn_to_section(pfn);
-
+#ifdef CONFIG_DEBUG_VM
+	/*
+	 * The sanity checks the page allocator does upon freeing a
+	 * page can reach here before the page_cgroup arrays are
+	 * allocated when feeding a range of pages to the allocator
+	 * for the first time during bootup or memory hotplug.
+	 */
 	if (!section->page_cgroup)
 		return NULL;
+#endif
 	return section->page_cgroup + pfn;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

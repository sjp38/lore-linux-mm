Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 077C56003C1
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 10:31:42 -0500 (EST)
Date: Tue, 26 Jan 2010 16:30:40 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 02 of 31] compound_lock
Message-ID: <20100126153040.GJ30452@random.random>
References: <patchbomb.1264513915@v2.random>
 <1037f5f6264364a9e4cc.1264513917@v2.random>
 <4B5F0179.6070005@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B5F0179.6070005@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi Rik,

On Tue, Jan 26, 2010 at 09:51:37AM -0500, Rik van Riel wrote:
> On 01/26/2010 08:51 AM, Andrea Arcangeli wrote:
> > From: Andrea Arcangeli<aarcange@redhat.com>
> >
> > Add a new compound_lock() needed to serialize put_page against
> > __split_huge_page_refcount().
> >
> > Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>
> 
> > diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> > --- a/include/linux/page-flags.h
> > +++ b/include/linux/page-flags.h
> > @@ -108,6 +108,7 @@ enum pageflags {
> >   #ifdef CONFIG_MEMORY_FAILURE
> >   	PG_hwpoison,		/* hardware poisoned page. Don't touch */
> >   #endif
> > +	PG_compound_lock,
> 
> Maybe this should be under an #ifdef so it does not take
> up a bit flag on 32 bit systems where it isn't compiled?

yes, on 32bit in fact it won't fit anymore... I already updated this
on #7 compound_get_put:

+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
        PG_compound_lock,
+#endif


+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
        bit_spin_lock(PG_compound_lock, &page->flags);
+#endif
 }
 
 static inline void compound_unlock(struct page *page)
 {
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
        bit_spin_unlock(PG_compound_lock, &page->flags);
+#endif


Maybe I should have folded those changes into compound_lock patch
instead of compound_get_put, end result is the same...

I already eliminated the atomoc op at compile time when the feature is
disabled and for archs not using the feature, but I'm still
considering if to return to the entire old get/put_page code when
feature is disabled at compile time or at runtime for hugetlbfs
only... I think removing the atomic op is the most important but it's
done at compile time not at runtime right now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

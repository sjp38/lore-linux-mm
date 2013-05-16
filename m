Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 620EF6B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 10:29:48 -0400 (EDT)
Date: Thu, 16 May 2013 15:29:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/4] mm: pagevec: Defer deciding what LRU to add a page
 to until pagevec drain time
Message-ID: <20130516142941.GK11497@suse.de>
References: <1368440482-27909-1-git-send-email-mgorman@suse.de>
 <1368440482-27909-3-git-send-email-mgorman@suse.de>
 <20130515155330.35036978515a6d8e0fe98feb@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130515155330.35036978515a6d8e0fe98feb@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>, Theodore Tso <tytso@mit.edu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>

On Wed, May 15, 2013 at 03:53:30PM -0700, Andrew Morton wrote:
> On Mon, 13 May 2013 11:21:20 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > mark_page_accessed cannot activate an inactive page that is located on
> > an inactive LRU pagevec. Hints from filesystems may be ignored as a
> > result. In preparation for fixing that problem, this patch removes the
> > per-LRU pagevecs and leaves just one pagevec. The final LRU the page is
> > added to is deferred until the pagevec is drained.
> > 
> > This means that fewer pagevecs are available and potentially there is
> > greater contention on the LRU lock. However, this only applies in the case
> > where there is an almost perfect mix of file, anon, active and inactive
> > pages being added to the LRU. In practice I expect that we are adding
> > stream of pages of a particular time and that the changes in contention
> > will barely be measurable.
> > 
> > ...
> >
> > index c612a6a..0911579 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -39,7 +39,7 @@
> >  /* How many pages do we try to swap or page in/out together? */
> >  int page_cluster;
> >  
> > -static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
> > +static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
> >  static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
> >  static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
> >  
> > @@ -460,13 +460,18 @@ EXPORT_SYMBOL(mark_page_accessed);
> >   */
> 
> The comment preceding __lru_cache_add() needs an update.
> 

This?

---8<---
diff --git a/mm/swap.c b/mm/swap.c
index 05944d4..ac23602 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -489,12 +489,10 @@ void mark_page_accessed(struct page *page)
 EXPORT_SYMBOL(mark_page_accessed);
 
 /*
- * Order of operations is important: flush the pagevec when it's already
- * full, not when adding the last page, to make sure that last page is
- * not added to the LRU directly when passed to this function. Because
- * mark_page_accessed() (called after this when writing) only activates
- * pages that are on the LRU, linear writes in subpage chunks would see
- * every PAGEVEC_SIZE page activated, which is unexpected.
+ * Queue the page for addition to the LRU via pagevec. The decision on whether
+ * to add the page to the [in]active [file|anon] list is deferred until the
+ * pagevec is drained. This gives a chance for the caller of __lru_cache_add()
+ * have the page added to the active list using mark_page_accessed().
  */
 void __lru_cache_add(struct page *page)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

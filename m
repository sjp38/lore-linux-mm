Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 13AF76B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 05:33:49 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t69so3200667wmt.7
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 02:33:49 -0700 (PDT)
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id l3si419887edb.74.2017.10.19.02.33.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 02:33:47 -0700 (PDT)
Received: from mail.blacknight.com (unknown [81.17.255.152])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id 278231C35C3
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 10:33:47 +0100 (IST)
Date: Thu, 19 Oct 2017 10:33:46 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 4/8] mm: Only drain per-cpu pagevecs once per pagevec
 usage
Message-ID: <20171019093346.ylahzdpzmoriyf4v@techsingularity.net>
References: <20171018075952.10627-1-mgorman@techsingularity.net>
 <20171018075952.10627-5-mgorman@techsingularity.net>
 <a9f2fc7c-906d-a49e-8e8f-d1024dc754ac@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <a9f2fc7c-906d-a49e-8e8f-d1024dc754ac@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>

On Thu, Oct 19, 2017 at 11:12:52AM +0200, Vlastimil Babka wrote:
> On 10/18/2017 09:59 AM, Mel Gorman wrote:
> > When a pagevec is initialised on the stack, it is generally used multiple
> > times over a range of pages, looking up entries and then releasing them.
> > On each pagevec_release, the per-cpu deferred LRU pagevecs are drained
> > on the grounds the page being released may be on those queues and the
> > pages may be cache hot. In many cases only the first drain is necessary
> > as it's unlikely that the range of pages being walked is racing against
> > LRU addition.  Even if there is such a race, the impact is marginal where
> > as constantly redraining the lru pagevecs costs.
> 
> Right, the drain is only to a local cpu, not all of them, so that kind
> of "racing" shouldn't be even possible.
> 

Potentially the user of the pagevec can be preempted and another process
modify the per-cpu pagevecs in parallel. Note even that users of a pagevec
in a loop may call cond_resched so preemption is not even necessary if
the pagevec is being used for a large enough number of operations. The
risk is still marginal.

> > This patch ensures that pagevec is only drained once in a given lifecycle
> > without increasing the cache footprint of the pagevec structure. Only
> 
> Well, strictly speaking it does prevent decreasing the cache footprint
> by removing the 'cold' field later :)
> 

Debatable. Even freeing a cold page if it was handled properly still has
a cache footprint impact because the struct page fields are accessed.
Maybe that's not what you meant and you are referring to the size of the
structure itself. If so, note that I change the type of the two fields so
they should fit in the same size as an unsigned long in many cases.

As an aside, I did at one point have a patch that removed the drained
field as well and increased the number of pagevec entries but it didn't
work out in terms of overall performance so I dropped it.

> > sparsetruncate tiny is shown here as large files have many exceptional
> > entries and calls pagecache_release less frequently.
> > 
> > sparsetruncate (tiny)
> >                               4.14.0-rc4             4.14.0-rc4
> >                         batchshadow-v1r1          onedrain-v1r1
> > Min          Time      141.00 (   0.00%)      141.00 (   0.00%)
> > 1st-qrtle    Time      142.00 (   0.00%)      142.00 (   0.00%)
> > 2nd-qrtle    Time      142.00 (   0.00%)      142.00 (   0.00%)
> > 3rd-qrtle    Time      143.00 (   0.00%)      143.00 (   0.00%)
> > Max-90%      Time      144.00 (   0.00%)      144.00 (   0.00%)
> > Max-95%      Time      146.00 (   0.00%)      145.00 (   0.68%)
> > Max-99%      Time      198.00 (   0.00%)      194.00 (   2.02%)
> > Max          Time      254.00 (   0.00%)      208.00 (  18.11%)
> > Amean        Time      145.12 (   0.00%)      144.30 (   0.56%)
> > Stddev       Time       12.74 (   0.00%)        9.62 (  24.49%)
> > Coeff        Time        8.78 (   0.00%)        6.67 (  24.06%)
> > Best99%Amean Time      144.29 (   0.00%)      143.82 (   0.32%)
> > Best95%Amean Time      142.68 (   0.00%)      142.31 (   0.26%)
> > Best90%Amean Time      142.52 (   0.00%)      142.19 (   0.24%)
> > Best75%Amean Time      142.26 (   0.00%)      141.98 (   0.20%)
> > Best50%Amean Time      141.90 (   0.00%)      141.71 (   0.13%)
> > Best25%Amean Time      141.80 (   0.00%)      141.43 (   0.26%)
> > 
> > The impact on bonnie is marginal and within the noise because a significant
> > percentage of the file being truncated has been reclaimed and consists of
> > shadow entries which reduce the hotness of the pagevec_release path.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > ---
> >  include/linux/pagevec.h | 4 +++-
> >  mm/swap.c               | 5 ++++-
> >  2 files changed, 7 insertions(+), 2 deletions(-)
> > 
> > diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
> > index 4dcd5506f1ed..4231979be982 100644
> > --- a/include/linux/pagevec.h
> > +++ b/include/linux/pagevec.h
> > @@ -16,7 +16,8 @@ struct address_space;
> >  
> >  struct pagevec {
> >  	unsigned long nr;
> > -	unsigned long cold;
> > +	bool cold;
> > +	bool drained;
> 
> 'drained' sounds a bit misleading to me, I would expect it to refer to
> *this* pagevec. What about e.g. "lru_drained"?
> 

It's not draining the LRU as such. How about the following patch on top
of the series? If another full series repost is necessary, I'll fold it
in.

---8<---
mm, pagevec: Rename pagevec drained field

According to Vlastimil Babka, the drained field in pagevec is potentially
misleading because it might be interpreted as draining this pagevec instead
of the percpu lru pagevecs. Rename the field for clarity.

Suggested-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/pagevec.h | 4 ++--
 mm/swap.c               | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index 8dcde51e80ff..ba5dc27ef6bb 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -16,7 +16,7 @@ struct address_space;
 
 struct pagevec {
 	unsigned long nr;
-	bool drained;
+	bool percpu_pvec_drained;
 	struct page *pages[PAGEVEC_SIZE];
 };
 
@@ -52,7 +52,7 @@ static inline unsigned pagevec_lookup_tag(struct pagevec *pvec,
 static inline void pagevec_init(struct pagevec *pvec)
 {
 	pvec->nr = 0;
-	pvec->drained = false;
+	pvec->percpu_pvec_drained = false;
 }
 
 static inline void pagevec_reinit(struct pagevec *pvec)
diff --git a/mm/swap.c b/mm/swap.c
index b480279c760c..38e1b6374a97 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -833,9 +833,9 @@ EXPORT_SYMBOL(release_pages);
  */
 void __pagevec_release(struct pagevec *pvec)
 {
-	if (!pvec->drained) {
+	if (!pvec->percpu_pvec_drained) {
 		lru_add_drain();
-		pvec->drained = true;
+		pvec->percpu_pvec_drained = true;
 	}
 	release_pages(pvec->pages, pagevec_count(pvec));
 	pagevec_reinit(pvec);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

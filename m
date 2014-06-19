Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id D4D7E6B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 21:02:06 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so1245188pde.31
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 18:02:06 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id da4si3848820pbb.222.2014.06.18.18.02.04
        for <linux-mm@kvack.org>;
        Wed, 18 Jun 2014 18:02:06 -0700 (PDT)
Date: Thu, 19 Jun 2014 10:02:39 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/vmscan.c: fix an implementation flaw in proportional
 scanning
Message-ID: <20140619010239.GA2071@bbox>
References: <1402980902-6345-1-git-send-email-slaoub@gmail.com>
 <20140618152751.283deda95257cc32ccea8f20@linux-foundation.org>
 <1403136272.12954.4.camel@debian>
 <20140618174001.a5de7668.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140618174001.a5de7668.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chen Yucong <slaoub@gmail.com>, mgorman@suse.de, hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Andrew,

On Wed, Jun 18, 2014 at 05:40:01PM -0700, Andrew Morton wrote:
> On Thu, 19 Jun 2014 08:04:32 +0800 Chen Yucong <slaoub@gmail.com> wrote:
> 
> > On Wed, 2014-06-18 at 15:27 -0700, Andrew Morton wrote:
> > > On Tue, 17 Jun 2014 12:55:02 +0800 Chen Yucong <slaoub@gmail.com> wrote:
> > > 
> > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > > index a8ffe4e..2c35e34 100644
> > > > --- a/mm/vmscan.c
> > > > +++ b/mm/vmscan.c
> > > > @@ -2087,8 +2086,8 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
> > > >  	blk_start_plug(&plug);
> > > >  	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
> > > >  					nr[LRU_INACTIVE_FILE]) {
> > > > -		unsigned long nr_anon, nr_file, percentage;
> > > > -		unsigned long nr_scanned;
> > > > +		unsigned long nr_anon, nr_file, file_percent, anon_percent;
> > > > +		unsigned long nr_to_scan, nr_scanned, percentage;
> > > >  
> > > >  		for_each_evictable_lru(lru) {
> > > >  			if (nr[lru]) {
> > > 
> > > The increased stack use is a slight concern - we can be very deep here.
> > > I suspect the "percent" locals are more for convenience/clarity, and
> > > they could be eliminated (in a separate patch) at some cost of clarity?
> > > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index a8ffe4e..2c35e34 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2057,8 +2057,7 @@ out:
> >  static void shrink_lruvec(struct lruvec *lruvec, struct scan_control
> > *sc)
> >  {
> >         unsigned long nr[NR_LRU_LISTS];
> > -       unsigned long targets[NR_LRU_LISTS];
> > -       unsigned long nr_to_scan;
> > +       unsigned long file_target, anon_target;
> > 
> > >From the above snippet, we can know that the "percent" locals come from
> > targets[NR_LRU_LISTS]. So this fix does not increase the stack.
> 
> OK.  But I expect the stack use could be decreased by using more
> complex expressions.

I didn't look at this patch yet but want to say.

The expression is not easy to follow since several people already
confused/discuss/fixed a bit so I'd like to put more concern to clarity
rather than stack footprint. I'm not saying stack footprint is not
important but I'd like to remain it last resort.
That's why I posted below for clarity.
https://lkml.org/lkml/2014/6/16/750

If we really want to reduce stack, we could do a little bit by below.

My 2 cents

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 9b61b9bf81ac..ddae227fd1ec 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -164,13 +164,15 @@ enum lru_list {
 	LRU_ACTIVE_ANON = LRU_BASE + LRU_ACTIVE,
 	LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE,
 	LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE,
+	NR_EVICTABLE_LRU_LISTS = LRU_UNEVICTABLE,
 	LRU_UNEVICTABLE,
 	NR_LRU_LISTS
 };
 
 #define for_each_lru(lru) for (lru = 0; lru < NR_LRU_LISTS; lru++)
 
-#define for_each_evictable_lru(lru) for (lru = 0; lru <= LRU_ACTIVE_FILE; lru++)
+#define for_each_evictable_lru(lru) for (lru = 0; \
+		lru <= NR_EVICTABLE_LRU_LISTS; lru++)
 
 static inline int is_file_lru(enum lru_list lru)
 {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a9c74b409681..11f57a017131 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2012,8 +2012,8 @@ out:
  */
 static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 {
-	unsigned long nr[NR_LRU_LISTS];
-	unsigned long targets[NR_LRU_LISTS];
+	unsigned long nr[NR_EVICTABLE_LRU_LISTS];
+	unsigned long targets[NR_EVICTABLE_LRU_LISTS];
 	unsigned long nr_to_scan;
 	enum lru_list lru;
 	unsigned long nr_reclaimed = 0;
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

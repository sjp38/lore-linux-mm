Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0D5F56B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 02:22:48 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id rp16so4104242pbb.24
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 23:22:48 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id ja1si9786626pbb.218.2014.06.15.23.22.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 15 Jun 2014 23:22:48 -0700 (PDT)
Received: by mail-pa0-f52.google.com with SMTP id eu11so4151625pac.39
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 23:22:47 -0700 (PDT)
Message-ID: <1402899678.5426.21.camel@debian>
Subject: Re: [PATCH] mm/vmscan.c: avoid recording the original scan targets
 in shrink_lruvec()
From: Chen Yucong <slaoub@gmail.com>
Date: Mon, 16 Jun 2014 14:21:18 +0800
In-Reply-To: <alpine.LSU.2.11.1406151742290.26073@eggly.anvils>
References: <1402320436-22270-1-git-send-email-slaoub@gmail.com>
	 <20140610163338.5b463c5884c4c7e3f1b948e2@linux-foundation.org>
	 <1402456897.28433.46.camel@debian>
	 <alpine.LSU.2.11.1406151742290.26073@eggly.anvils>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, mhocko@suse.cz, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 2014-06-15 at 17:47 -0700, Hugh Dickins wrote:
> On Wed, 11 Jun 2014, Chen Yucong wrote:
> > On Tue, 2014-06-10 at 16:33 -0700, Andrew Morton wrote:
> > > >                       break;
> > > >  
> > > >               if (nr_file > nr_anon) {
> > > > -                     unsigned long scan_target =
> > > targets[LRU_INACTIVE_ANON] +
> > > >
> > > -                                             targets[LRU_ACTIVE_ANON]
> > > + 1;
> > > > +                     nr_to_scan = nr_file - ratio * nr_anon;
> > > > +                     percentage = nr[LRU_FILE] * 100 / nr_file;
> > > 
> > > here, nr_file and nr_anon are derived from the contents of nr[].  But
> > > nr[] was modified in the for_each_evictable_lru() loop, so its
> > > contents
> > > now may differ from what was in targets[]? 
> > 
> > nr_to_scan is used for recording the number of pages that should be
> > scanned to keep original *ratio*.
> > 
> > We can assume that the value of (nr_file > nr_anon) is true, nr_to_scan
> > should be distribute to nr[LRU_ACTIVE_FILE] and nr[LRU_INACTIVE_FILE] in
> > proportion.
> > 
> >     nr_file = nr[LRU_ACTIVE_FILE] + nr[LRU_INACTIVE_FILE];
> >     percentage = nr[LRU_FILE] / nr_file;
> > 
> > Note that in comparison with *old* percentage, the "new" percentage has
> > the different meaning. It is just used to divide nr_so_scan pages
> > appropriately.
> 
> [PATCH] mm-vmscanc-avoid-recording-the-original-scan-targets-in-shrink_lruvec-fix.patch
> 
> I have not reviewed your logic at all, but soon hit a divide-by-zero
> crash on mmotm: it needs some such fix as below.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> 
>  mm/vmscan.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> --- mmotm/mm/vmscan.c	2014-06-12 17:46:36.632008452 -0700
> +++ linux/mm/vmscan.c	2014-06-12 18:55:18.832425713 -0700
> @@ -2122,11 +2122,12 @@ static void shrink_lruvec(struct lruvec
>  			nr_to_scan = nr_file - ratio * nr_anon;
>  			percentage = nr[LRU_FILE] * 100 / nr_file;
>  			lru = LRU_BASE;
> -		} else {
> +		} else if (ratio) {
>  			nr_to_scan = nr_anon - nr_file / ratio;
>  			percentage = nr[LRU_BASE] * 100 / nr_anon;
>  			lru = LRU_FILE;
> -		}
> +		} else
> +			break;
>  
>  		/* Stop scanning the smaller of the LRU */
>  		nr[lru] = 0;

I think I made a terrible mistake. If the value of
     (nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE]) <
     (nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON])
is true , the ratio will always be zero in original patch. This is too
terrible. It is unfair for anon list. Although the above fix can avoid
hitting a divide-by-zero crash, it can not solve the problem of
fairness.

The following fix can solve divide-by-zero and unfair problems
simultaneously. But it needs to introduce a new variable for saving the
ratio of anon to file and relative operations.

thx!
cyc


Signed-off-by: Chen Yucong <slaoub@gmail.com>
---
 mm/vmscan.c |   30 +++++++++++-------------------
 1 file changed, 11 insertions(+), 19 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a8ffe4e..cf8d0a3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2057,8 +2057,7 @@ out:
 static void shrink_lruvec(struct lruvec *lruvec, struct scan_control
*sc)
 {
 	unsigned long nr[NR_LRU_LISTS];
-	unsigned long targets[NR_LRU_LISTS];
-	unsigned long nr_to_scan;
+	unsigned long nr_to_scan, ratio_file_to_anon, ratio_anon_to_file;
 	enum lru_list lru;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
@@ -2067,8 +2066,10 @@ static void shrink_lruvec(struct lruvec *lruvec,
struct scan_control *sc)
 
 	get_scan_count(lruvec, sc, nr);
 
-	/* Record the original scan target for proportional adjustments later
*/
-	memcpy(targets, nr, sizeof(nr));
+	ratio_file_to_anon = (nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE] +
1) /
+			     (nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON] + 1);
+	ratio_anon_to_file = (nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON] +
1) /
+			     (nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE] + 1);
 
 	/*
 	 * Global reclaiming within direct reclaim at DEF_PRIORITY is a normal
@@ -2088,7 +2089,6 @@ static void shrink_lruvec(struct lruvec *lruvec,
struct scan_control *sc)
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
 		unsigned long nr_anon, nr_file, percentage;
-		unsigned long nr_scanned;
 
 		for_each_evictable_lru(lru) {
 			if (nr[lru]) {
@@ -2123,15 +2123,13 @@ static void shrink_lruvec(struct lruvec *lruvec,
struct scan_control *sc)
 			break;
 
 		if (nr_file > nr_anon) {
-			unsigned long scan_target = targets[LRU_INACTIVE_ANON] +
-						targets[LRU_ACTIVE_ANON] + 1;
+			nr_to_scan = nr_file - ratio_file_to_anon * nr_anon;
+			percentage = nr[LRU_FILE] * 100 / nr_file;
 			lru = LRU_BASE;
-			percentage = nr_anon * 100 / scan_target;
 		} else {
-			unsigned long scan_target = targets[LRU_INACTIVE_FILE] +
-						targets[LRU_ACTIVE_FILE] + 1;
+			nr_to_scan = nr_anon - ratio_anon_to_file * nr_file;
+			percentage = nr[LRU_BASE] * 100 / nr_anon;
 			lru = LRU_FILE;
-			percentage = nr_file * 100 / scan_target;
 		}
 
 		/* Stop scanning the smaller of the LRU */
@@ -2143,14 +2141,8 @@ static void shrink_lruvec(struct lruvec *lruvec,
struct scan_control *sc)
 		 * scan target and the percentage scanning already complete
 		 */
 		lru = (lru == LRU_FILE) ? LRU_BASE : LRU_FILE;
-		nr_scanned = targets[lru] - nr[lru];
-		nr[lru] = targets[lru] * (100 - percentage) / 100;
-		nr[lru] -= min(nr[lru], nr_scanned);
-
-		lru += LRU_ACTIVE;
-		nr_scanned = targets[lru] - nr[lru];
-		nr[lru] = targets[lru] * (100 - percentage) / 100;
-		nr[lru] -= min(nr[lru], nr_scanned);
+		nr[lru] = nr_to_scan * percentage / 100;
+		nr[lru + LRU_ACTIVE] = nr_to_scan - nr[lru];
 
 		scan_adjusted = true;
 	}
-- 
1.7.10.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

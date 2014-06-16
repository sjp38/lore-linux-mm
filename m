Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id AB8796B0039
	for <linux-mm@kvack.org>; Sun, 15 Jun 2014 20:48:38 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id hz1so688558pad.38
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 17:48:38 -0700 (PDT)
Received: from mail-pb0-x230.google.com (mail-pb0-x230.google.com [2607:f8b0:400e:c01::230])
        by mx.google.com with ESMTPS id ld16si11791105pab.173.2014.06.15.17.48.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 15 Jun 2014 17:48:37 -0700 (PDT)
Received: by mail-pb0-f48.google.com with SMTP id rq2so1791669pbb.35
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 17:48:37 -0700 (PDT)
Date: Sun, 15 Jun 2014 17:47:16 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm/vmscan.c: avoid recording the original scan targets
 in shrink_lruvec()
In-Reply-To: <1402456897.28433.46.camel@debian>
Message-ID: <alpine.LSU.2.11.1406151742290.26073@eggly.anvils>
References: <1402320436-22270-1-git-send-email-slaoub@gmail.com> <20140610163338.5b463c5884c4c7e3f1b948e2@linux-foundation.org> <1402456897.28433.46.camel@debian>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, mhocko@suse.cz, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 11 Jun 2014, Chen Yucong wrote:
> On Tue, 2014-06-10 at 16:33 -0700, Andrew Morton wrote:
> > >                       break;
> > >  
> > >               if (nr_file > nr_anon) {
> > > -                     unsigned long scan_target =
> > targets[LRU_INACTIVE_ANON] +
> > >
> > -                                             targets[LRU_ACTIVE_ANON]
> > + 1;
> > > +                     nr_to_scan = nr_file - ratio * nr_anon;
> > > +                     percentage = nr[LRU_FILE] * 100 / nr_file;
> > 
> > here, nr_file and nr_anon are derived from the contents of nr[].  But
> > nr[] was modified in the for_each_evictable_lru() loop, so its
> > contents
> > now may differ from what was in targets[]? 
> 
> nr_to_scan is used for recording the number of pages that should be
> scanned to keep original *ratio*.
> 
> We can assume that the value of (nr_file > nr_anon) is true, nr_to_scan
> should be distribute to nr[LRU_ACTIVE_FILE] and nr[LRU_INACTIVE_FILE] in
> proportion.
> 
>     nr_file = nr[LRU_ACTIVE_FILE] + nr[LRU_INACTIVE_FILE];
>     percentage = nr[LRU_FILE] / nr_file;
> 
> Note that in comparison with *old* percentage, the "new" percentage has
> the different meaning. It is just used to divide nr_so_scan pages
> appropriately.

[PATCH] mm-vmscanc-avoid-recording-the-original-scan-targets-in-shrink_lruvec-fix.patch

I have not reviewed your logic at all, but soon hit a divide-by-zero
crash on mmotm: it needs some such fix as below.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/vmscan.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- mmotm/mm/vmscan.c	2014-06-12 17:46:36.632008452 -0700
+++ linux/mm/vmscan.c	2014-06-12 18:55:18.832425713 -0700
@@ -2122,11 +2122,12 @@ static void shrink_lruvec(struct lruvec
 			nr_to_scan = nr_file - ratio * nr_anon;
 			percentage = nr[LRU_FILE] * 100 / nr_file;
 			lru = LRU_BASE;
-		} else {
+		} else if (ratio) {
 			nr_to_scan = nr_anon - nr_file / ratio;
 			percentage = nr[LRU_BASE] * 100 / nr_anon;
 			lru = LRU_FILE;
-		}
+		} else
+			break;
 
 		/* Stop scanning the smaller of the LRU */
 		nr[lru] = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

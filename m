Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 87D446B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 20:07:14 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id et14so1264460pad.27
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 17:07:14 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id cc2si3736489pbb.208.2014.06.18.17.07.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Jun 2014 17:07:13 -0700 (PDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so1259591pad.7
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 17:07:13 -0700 (PDT)
Message-ID: <1403136272.12954.4.camel@debian>
Subject: Re: [PATCH] mm/vmscan.c: fix an implementation flaw in proportional
 scanning
From: Chen Yucong <slaoub@gmail.com>
Date: Thu, 19 Jun 2014 08:04:32 +0800
In-Reply-To: <20140618152751.283deda95257cc32ccea8f20@linux-foundation.org>
References: <1402980902-6345-1-git-send-email-slaoub@gmail.com>
	 <20140618152751.283deda95257cc32ccea8f20@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: minchan@kernel.org, mgorman@suse.de, hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2014-06-18 at 15:27 -0700, Andrew Morton wrote:
> On Tue, 17 Jun 2014 12:55:02 +0800 Chen Yucong <slaoub@gmail.com> wrote:
> 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index a8ffe4e..2c35e34 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2087,8 +2086,8 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
> >  	blk_start_plug(&plug);
> >  	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
> >  					nr[LRU_INACTIVE_FILE]) {
> > -		unsigned long nr_anon, nr_file, percentage;
> > -		unsigned long nr_scanned;
> > +		unsigned long nr_anon, nr_file, file_percent, anon_percent;
> > +		unsigned long nr_to_scan, nr_scanned, percentage;
> >  
> >  		for_each_evictable_lru(lru) {
> >  			if (nr[lru]) {
> 
> The increased stack use is a slight concern - we can be very deep here.
> I suspect the "percent" locals are more for convenience/clarity, and
> they could be eliminated (in a separate patch) at some cost of clarity?
> 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a8ffe4e..2c35e34 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2057,8 +2057,7 @@ out:
 static void shrink_lruvec(struct lruvec *lruvec, struct scan_control
*sc)
 {
        unsigned long nr[NR_LRU_LISTS];
-       unsigned long targets[NR_LRU_LISTS];
-       unsigned long nr_to_scan;
+       unsigned long file_target, anon_target;

>From the above snippet, we can know that the "percent" locals come from
targets[NR_LRU_LISTS]. So this fix does not increase the stack.

thx!
cyc


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

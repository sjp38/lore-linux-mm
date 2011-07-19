Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EB01D6B00EC
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 16:10:26 -0400 (EDT)
Received: by wwj40 with SMTP id 40so3800991wwj.26
        for <linux-mm@kvack.org>; Tue, 19 Jul 2011 13:10:20 -0700 (PDT)
Date: Tue, 19 Jul 2011 23:08:26 +0300
From: Dan Carpenter <error27@gmail.com>
Subject: re: vmscan: shrinker->nr updates race and go wrong
Message-ID: <20110719200826.GC6445@shale.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dchinner@redhat.com
Cc: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Hi Dave,

There is a sign error in e5b94d7463e0 "vmscan: shrinker->nr updates
race and go wrong"

mm/vmscan.c +274 shrink_slab(41)
	warn: unsigned 'total_scan' is never less than zero.

   268                  total_scan = nr;
   269                  max_pass = do_shrinker_shrink(shrinker, shrink, 0);
   270                  delta = (4 * nr_pages_scanned) / shrinker->seeks;
   271                  delta *= max_pass;
   272                  do_div(delta, lru_pages + 1);
   273                  total_scan += delta;
   274                  if (total_scan < 0) {
                            ^^^^^^^^^^^^^^
total_scan is unsigned so it's never less than zero here.

   275                          printk(KERN_ERR "shrink_slab: %pF negative objects to "
   276                                 "delete nr=%ld\n",
   277                                 shrinker->shrink, total_scan);
   278                          total_scan = max_pass;
   279                  }

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E861D6B027C
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 23:14:03 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id y10so40544246qty.2
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 20:14:03 -0700 (PDT)
Received: from cmta17.telus.net (cmta17.telus.net. [209.171.16.90])
        by mx.google.com with ESMTP id r55si3687342qta.62.2016.09.27.20.14.03
        for <linux-mm@kvack.org>;
        Tue, 27 Sep 2016 20:14:03 -0700 (PDT)
From: "Doug Smythies" <dsmythies@telus.net>
References: <bug-172981-27@https.bugzilla.kernel.org/> <20160927111059.282a35c89266202d3cb2f953@linux-foundation.org> p4E0bHJB4CNDxp4E5bcDDz
In-Reply-To: p4E0bHJB4CNDxp4E5bcDDz
Subject: RE: [Bug 172981] New: [bisected] SLAB: extreme load averages and over 2000 kworker threads
Date: Tue, 27 Sep 2016 20:13:58 -0700
Message-ID: <002a01d21936$5ca792a0$15f6b7e0$@net>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: en-ca
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Vladimir Davydov' <vdavydov.dev@gmail.com>
Cc: 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Doug Smythies <dsmythies@telus.net>

By the way, I can eliminate the problem by doing this:
(see also: https://bugzilla.kernel.org/show_bug.cgi?id=172991)

diff --git a/mm/slab.c b/mm/slab.c
index b672710..a4edbfa 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -965,7 +965,7 @@ static int setup_kmem_cache_node(struct kmem_cache *cachep,
         * freed after synchronize_sched().
         */
        if (force_change)
-               synchronize_sched();
+               kick_all_cpus_sync();

 fail:
        kfree(old_shared);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

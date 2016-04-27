Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DFB1A6B0253
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:24:48 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r12so37271899wme.0
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 05:24:48 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id o19si30459966wmg.25.2016.04.27.05.24.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 05:24:46 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 44C951C1578
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 13:24:46 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/4] Optimise page alloc/free fast paths followup v1
Date: Wed, 27 Apr 2016 13:24:41 +0100
Message-Id: <1461759885-17163-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

This is a follow-up series based on Vlastimil Babka's review feedback.
It should be taking into account the changes in mmotm already made although
that did involve some guesswork. It should be relatively easy to merge
into the correct places. However, if there are major conflicts then let
me know and I'll respin the entire series.

There is a marginal impact to the series but it's within the noise and
necessary to address the problems.

pagealloc
                                           4.6.0-rc4                  4.6.0-rc4
                                      mmotm-20150422              followup-v1r1
Min      alloc-odr0-1               317.00 (  0.00%)           318.00 ( -0.32%)
Min      alloc-odr0-2               232.00 (  0.00%)           233.00 ( -0.43%)
Min      alloc-odr0-4               192.00 (  0.00%)           194.00 ( -1.04%)
Min      alloc-odr0-8               167.00 (  0.00%)           168.00 ( -0.60%)
Min      alloc-odr0-16              154.00 (  0.00%)           155.00 ( -0.65%)
Min      alloc-odr0-32              148.00 (  0.00%)           149.00 ( -0.68%)
Min      alloc-odr0-64              145.00 (  0.00%)           146.00 ( -0.69%)
Min      alloc-odr0-128             143.00 (  0.00%)           144.00 ( -0.70%)
Min      alloc-odr0-256             152.00 (  0.00%)           154.00 ( -1.32%)
Min      alloc-odr0-512             164.00 (  0.00%)           166.00 ( -1.22%)
Min      alloc-odr0-1024            172.00 (  0.00%)           172.00 (  0.00%)
Min      alloc-odr0-2048            178.00 (  0.00%)           178.00 (  0.00%)
Min      alloc-odr0-4096            184.00 (  0.00%)           184.00 (  0.00%)
Min      alloc-odr0-8192            187.00 (  0.00%)           186.00 (  0.53%)
Min      alloc-odr0-16384           188.00 (  0.00%)           187.00 (  0.53%)
Min      free-odr0-1                178.00 (  0.00%)           177.00 (  0.56%)
Min      free-odr0-2                125.00 (  0.00%)           126.00 ( -0.80%)
Min      free-odr0-4                 98.00 (  0.00%)            99.00 ( -1.02%)
Min      free-odr0-8                 84.00 (  0.00%)            86.00 ( -2.38%)
Min      free-odr0-16                79.00 (  0.00%)            80.00 ( -1.27%)
Min      free-odr0-32                75.00 (  0.00%)            76.00 ( -1.33%)
Min      free-odr0-64                73.00 (  0.00%)            74.00 ( -1.37%)
Min      free-odr0-128               72.00 (  0.00%)            73.00 ( -1.39%)
Min      free-odr0-256               88.00 (  0.00%)            89.00 ( -1.14%)
Min      free-odr0-512              108.00 (  0.00%)           110.00 ( -1.85%)
Min      free-odr0-1024             117.00 (  0.00%)           117.00 (  0.00%)
Min      free-odr0-2048             125.00 (  0.00%)           125.00 (  0.00%)
Min      free-odr0-4096             131.00 (  0.00%)           130.00 (  0.76%)
Min      free-odr0-8192             131.00 (  0.00%)           131.00 (  0.00%)
Min      free-odr0-16384            131.00 (  0.00%)           131.00 (  0.00%)
Min      total-odr0-1               495.00 (  0.00%)           495.00 (  0.00%)
Min      total-odr0-2               357.00 (  0.00%)           360.00 ( -0.84%)
Min      total-odr0-4               290.00 (  0.00%)           293.00 ( -1.03%)
Min      total-odr0-8               251.00 (  0.00%)           254.00 ( -1.20%)
Min      total-odr0-16              233.00 (  0.00%)           235.00 ( -0.86%)
Min      total-odr0-32              223.00 (  0.00%)           225.00 ( -0.90%)
Min      total-odr0-64              218.00 (  0.00%)           220.00 ( -0.92%)
Min      total-odr0-128             215.00 (  0.00%)           217.00 ( -0.93%)
Min      total-odr0-256             240.00 (  0.00%)           243.00 ( -1.25%)
Min      total-odr0-512             272.00 (  0.00%)           276.00 ( -1.47%)
Min      total-odr0-1024            289.00 (  0.00%)           289.00 (  0.00%)
Min      total-odr0-2048            303.00 (  0.00%)           303.00 (  0.00%)
Min      total-odr0-4096            315.00 (  0.00%)           314.00 (  0.32%)
Min      total-odr0-8192            318.00 (  0.00%)           317.00 (  0.31%)
Min      total-odr0-16384           319.00 (  0.00%)           318.00 (  0.31%)

 mm/page_alloc.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC90D6B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 10:57:25 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y84so40053677lfc.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 07:57:25 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id q2si4831045wjp.213.2016.04.27.07.57.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 07:57:24 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id CBB621C1315
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 15:57:23 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/6] Optimise page alloc/free fast paths followup v2
Date: Wed, 27 Apr 2016 15:57:17 +0100
Message-Id: <1461769043-28337-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

This is a follow-up series based on Vlastimil Babka's review feedback.
The first change is that the second patch in the previous series was dropped
as the patch "mm, page_alloc: inline the fast path of the zonelist iterator"
is fine. The nodemask pointer is the same between cpuset retries. If the
zonelist changes due to ALLOC_NO_WATERMARKS *and* it races with a cpuset
change then there is a second harmless pass through the page allocator.

Patches 1-3 are fixes for patches in mmotm. They should be taking into
account the changes in mmotm already made although that did involve
some guesswork. It should be relatively easy to merge into the correct
places. However, if there are major conflicts then let me know and I'll
respin the entire series.

Patches 4-6 are from Vlastimil with only minor modifications.

There is a marginal impact to the series but it's within the noise and
necessary to address the problems.

pagealloc
                                           4.6.0-rc4                  4.6.0-rc4
                                      mmotm-20150422              followup-v1r1
Min      alloc-odr0-1               317.00 (  0.00%)           319.00 ( -0.63%)
Min      alloc-odr0-2               232.00 (  0.00%)           231.00 (  0.43%)
Min      alloc-odr0-4               192.00 (  0.00%)           193.00 ( -0.52%)
Min      alloc-odr0-8               167.00 (  0.00%)           168.00 ( -0.60%)
Min      alloc-odr0-16              154.00 (  0.00%)           155.00 ( -0.65%)
Min      alloc-odr0-32              148.00 (  0.00%)           148.00 (  0.00%)
Min      alloc-odr0-64              145.00 (  0.00%)           145.00 (  0.00%)
Min      alloc-odr0-128             143.00 (  0.00%)           144.00 ( -0.70%)
Min      alloc-odr0-256             152.00 (  0.00%)           156.00 ( -2.63%)
Min      alloc-odr0-512             164.00 (  0.00%)           165.00 ( -0.61%)
Min      alloc-odr0-1024            172.00 (  0.00%)           175.00 ( -1.74%)
Min      alloc-odr0-2048            178.00 (  0.00%)           180.00 ( -1.12%)
Min      alloc-odr0-4096            184.00 (  0.00%)           186.00 ( -1.09%)
Min      alloc-odr0-8192            187.00 (  0.00%)           189.00 ( -1.07%)
Min      alloc-odr0-16384           188.00 (  0.00%)           189.00 ( -0.53%)
Min      free-odr0-1                178.00 (  0.00%)           177.00 (  0.56%)
Min      free-odr0-2                125.00 (  0.00%)           125.00 (  0.00%)
Min      free-odr0-4                 98.00 (  0.00%)            97.00 (  1.02%)
Min      free-odr0-8                 84.00 (  0.00%)            84.00 (  0.00%)
Min      free-odr0-16                79.00 (  0.00%)            80.00 ( -1.27%)
Min      free-odr0-32                75.00 (  0.00%)            75.00 (  0.00%)
Min      free-odr0-64                73.00 (  0.00%)            73.00 (  0.00%)
Min      free-odr0-128               72.00 (  0.00%)            72.00 (  0.00%)
Min      free-odr0-256               88.00 (  0.00%)            93.00 ( -5.68%)
Min      free-odr0-512              108.00 (  0.00%)           107.00 (  0.93%)
Min      free-odr0-1024             117.00 (  0.00%)           116.00 (  0.85%)
Min      free-odr0-2048             125.00 (  0.00%)           124.00 (  0.80%)
Min      free-odr0-4096             131.00 (  0.00%)           128.00 (  2.29%)
Min      free-odr0-8192             131.00 (  0.00%)           129.00 (  1.53%)
Min      free-odr0-16384            131.00 (  0.00%)           129.00 (  1.53%)
Min      total-odr0-1               495.00 (  0.00%)           496.00 ( -0.20%)
Min      total-odr0-2               357.00 (  0.00%)           356.00 (  0.28%)
Min      total-odr0-4               290.00 (  0.00%)           290.00 (  0.00%)
Min      total-odr0-8               251.00 (  0.00%)           252.00 ( -0.40%)
Min      total-odr0-16              233.00 (  0.00%)           235.00 ( -0.86%)
Min      total-odr0-32              223.00 (  0.00%)           223.00 (  0.00%)
Min      total-odr0-64              218.00 (  0.00%)           218.00 (  0.00%)
Min      total-odr0-128             215.00 (  0.00%)           216.00 ( -0.47%)
Min      total-odr0-256             240.00 (  0.00%)           249.00 ( -3.75%)
Min      total-odr0-512             272.00 (  0.00%)           272.00 (  0.00%)
Min      total-odr0-1024            289.00 (  0.00%)           291.00 ( -0.69%)
Min      total-odr0-2048            303.00 (  0.00%)           304.00 ( -0.33%)
Min      total-odr0-4096            315.00 (  0.00%)           314.00 (  0.32%)
Min      total-odr0-8192            318.00 (  0.00%)           318.00 (  0.00%)
Min      total-odr0-16384           319.00 (  0.00%)           318.00 (  0.31%)

 mm/page_alloc.c | 69 +++++++++++++++++++++++----------------------------------
 1 file changed, 28 insertions(+), 41 deletions(-)

-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7C04D6B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 14:03:00 -0400 (EDT)
Received: by ykfr66 with SMTP id r66so26948419ykf.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 11:03:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m65si4376732ykm.145.2015.06.10.11.02.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 11:02:59 -0700 (PDT)
Message-ID: <55787BCA.5000605@redhat.com>
Date: Wed, 10 Jun 2015 14:02:50 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] mm, compaction: more robust check for scanners meeting
References: <1433928754-966-1-git-send-email-vbabka@suse.cz> <1433928754-966-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1433928754-966-2-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

On 06/10/2015 05:32 AM, Vlastimil Babka wrote:
> Compaction should finish when the migration and free scanner meet, i.e. they
> reach the same pageblock. Currently however, the test in compact_finished()
> simply just compares the exact pfns, which may yield a false negative when the
> free scanner position is in the middle of a pageblock and the migration scanner
> reaches the beginning of the same pageblock.
> 
> This hasn't been a problem until commit e14c720efdd7 ("mm, compaction: remember
> position within pageblock in free pages scanner") allowed the free scanner
> position to be in the middle of a pageblock between invocations.  The hot-fix
> 1d5bfe1ffb5b ("mm, compaction: prevent infinite loop in compact_zone")
> prevented the issue by adding a special check in the migration scanner to
> satisfy the current detection of scanners meeting.
> 
> However, the proper fix is to make the detection more robust. This patch
> introduces the compact_scanners_met() function that returns true when the free
> scanner position is in the same or lower pageblock than the migration scanner.
> The special case in isolate_migratepages() introduced by 1d5bfe1ffb5b is
> removed.
> 
> Suggested-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

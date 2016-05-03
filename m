Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 697276B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 18:16:48 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e201so31899469wme.1
        for <linux-mm@kvack.org>; Tue, 03 May 2016 15:16:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 81si895483wma.1.2016.05.03.15.16.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 May 2016 15:16:47 -0700 (PDT)
Subject: Re: kcompactd hang during memory offlining
References: <20160503170247.GA4239@arbab-laptop.austin.ibm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5729234A.1080502@suse.cz>
Date: Wed, 4 May 2016 00:16:42 +0200
MIME-Version: 1.0
In-Reply-To: <20160503170247.GA4239@arbab-laptop.austin.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/03/2016 07:02 PM, Reza Arbab wrote:
> Assume memory47 is the last online block left in node1. This will hang:
> 
> # echo offline > /sys/devices/system/node/node1/memory47/state
> 
> After a couple of minutes, the following pops up in dmesg:
> 
> INFO: task bash:957 blocked for more than 120 seconds.

Damn, can you test this patch? I hope it's just the simple mistake and kcompactd is
waiting for the kcompactd_max_order > 0 when it's woken up to actually exit.
No idea what happens if memory actually gets offlined during compaction's pfn scan...
but that wouldn't be new or specific to kcompactd...

----8<----
diff --git a/mm/compaction.c b/mm/compaction.c
index 481004c73c90..0e28981d4510 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1852,7 +1852,7 @@ void compaction_unregister_node(struct node *node)
 
 static inline bool kcompactd_work_requested(pg_data_t *pgdat)
 {
-       return pgdat->kcompactd_max_order > 0;
+       return pgdat->kcompactd_max_order > 0 || kthread_should_stop();
 }
 
 static bool kcompactd_node_suitable(pg_data_t *pgdat)
@@ -1916,6 +1916,8 @@ static void kcompactd_do_work(pg_data_t *pgdat)
                INIT_LIST_HEAD(&cc.freepages);
                INIT_LIST_HEAD(&cc.migratepages);
 
+               if (kthread_should_stop())
+                       return;
                status = compact_zone(zone, &cc);
 
                if (zone_watermark_ok(zone, cc.order, low_wmark_pages(zone),

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

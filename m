Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9A3756B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 01:08:04 -0400 (EDT)
Date: Tue, 28 Sep 2010 13:08:01 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: zone state overhead
Message-ID: <20100928050801.GA29021@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: cl@linux.com
List-ID: <linux-mm.kvack.org>

In a 4 socket 64 CPU system, zone_nr_free_pages() takes about 5% ~ 10% cpu time
according to perf when memory pressure is high. The workload does something
like:
for i in `seq 1 $nr_cpu`
do
        create_sparse_file $SPARSE_FILE-$i $((10 * mem / nr_cpu))
        $USEMEM -f $SPARSE_FILE-$i -j 4096 --readonly $((10 * mem / nr_cpu)) &
done
this simply reads a sparse file for each CPU. Apparently the
zone->percpu_drift_mark is too big, and guess zone_page_state_snapshot() makes
a lot of cache bounce for ->vm_stat_diff[]. below is the zoneinfo for reference.
Is there any way to reduce the overhead?

Node 3, zone   Normal
pages free     2055926
        min      1441
        low      1801
        high     2161
        scanned  0
        spanned  2097152
        present  2068480
  vm stats threshold: 98

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Subject: Performance of Readv and the Cost of Revesemaps Under Heavy DB Workloads
Message-ID: <OFB460955F.DB2A4AF7-ON85256C2F.006CDBB2@pok.ibm.com>
From: "Peter Wong" <wpeter@us.ibm.com>
Date: Mon, 9 Sep 2002 15:07:08 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: riel@nl.linux.org, akpm@zip.com.au, mjbligh@us.ibm.com, wli@holomorphy.com, dmccr@us.ibm.comgh@us.ibm.com, Bill Hartner <bhartner@us.ibm.com>, Troy C Wilson <wilsont@us.ibm.com>
List-ID: <linux-mm.kvack.org>

All,

     I have measured a decision support workload using 2.4.17-based
kernel, 2.5.31-based kernel, and 2.5.32-based kernel, all of which
use the readv patch made available by Janet Morgan. Janet's patch is
also included in Andrew Morton's mm patch, which can be found at
http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.32/2.5.32-mm2/.
I got the following results.

---------------------------------------------------------------
Database Size: 100 GB

2417RV:    2.4.17 (kernel.org)
           + lse04-rc1.diffs
             - bounce patch by Jens Axboe
             - io_reqeust_lock patch by Jonathan Lahr
             - rawvary patch by Badari Pulavarty
             - readv patches by Janet Morgan
           + TASK_UNMAPPED_BASE = 0x10000000
           + PAGE_OFFSET        = 0xD0000000

2531RV:    2.5.31 (kernel.org)
           + readv patch from Janet Morgan
           + TASK_UNMAPPED_BASE = 0x10000000
           + PAGE_OFFSET        = 0xC0000000

2532RV:    2.5.32 (kernel.org)
           + mm-2 patch from Andrew Morton which
             includes Janet's readv patch
           + TASK_UNMAPPED_BASE = 0x10000000
           + PAGE_OFFSET        = 0xC0000000

     Based upon the throughput rate,
          2531RV is 99.8% of 2417RV;
          2532RV is  100% of 2417RV.

      There are 110 prefetchers for the runs, and ~2 GB of shared
memory space used by the database, i.e., ~500,000 pages. With Andrew's
mm patch, the maximum number of reversemaps reaches 43.7 millions. That
is, each page is used by ~87 processes. With 8 bytes per reversemap,
it costs ~350MB of the kernel memory, which is quite significant. Note
that the database system used forks processes and does not use
pthreads.

Regards,
Peter

Peter Wai Yee Wong
IBM Linux Technology Center, Performance Analysis
email: wpeter@us.ibm.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

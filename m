Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 88ACC6B0036
	for <linux-mm@kvack.org>; Tue, 20 May 2014 11:49:08 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id d17so730009eek.16
        for <linux-mm@kvack.org>; Tue, 20 May 2014 08:49:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s1si3635333eew.138.2014.05.20.08.49.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 May 2014 08:49:06 -0700 (PDT)
Date: Tue, 20 May 2014 16:49:00 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: non-atomically mark page accessed during page cache
 allocation where possible -fix
Message-ID: <20140520154900.GO23991@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-19-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1399974350-11089-19-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

Prabhakar Lad reported the following problem

  I see following issue on DA850 evm,
  git bisect points me to
  commit id: 975c3a671f11279441006a29a19f55ccc15fb320
  ( mm: non-atomically mark page accessed during page cache allocation
  where possible)

  Unable to handle kernel paging request at virtual address 30e03501
  pgd = c68cc000
  [30e03501] *pgd=00000000
  Internal error: Oops: 1 [#1] PREEMPT ARM
  Modules linked in:
  CPU: 0 PID: 1015 Comm: network.sh Not tainted 3.15.0-rc5-00323-g975c3a6 #9
  task: c70c4e00 ti: c73d0000 task.ti: c73d0000
  PC is at init_page_accessed+0xc/0x24
  LR is at shmem_write_begin+0x54/0x60
  pc : [<c0088aa0>]    lr : [<c00923e8>]    psr: 20000013
  sp : c73d1d90  ip : c73d1da0  fp : c73d1d9c
  r10: c73d1dec  r9 : 00000000  r8 : 00000000
  r7 : c73d1e6c  r6 : c694d7bc  r5 : ffffffe4  r4 : c73d1dec
  r3 : c73d0000  r2 : 00000001  r1 : 00000000  r0 : 30e03501
  Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
  Control: 0005317f  Table: c68cc000  DAC: 00000015
  Process network.sh (pid: 1015, stack limit = 0xc73d01c0)

pagep is set but not pointing to anywhere valid as it's an uninitialised
stack variable. This patch is a fix to
mm-non-atomically-mark-page-accessed-during-page-cache-allocation-where-possible.patch

Reported-by: Prabhakar Lad <prabhakar.csengg@gmail.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/filemap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 2a7b9d1..0691481 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2459,7 +2459,7 @@ ssize_t generic_perform_write(struct file *file,
 		flags |= AOP_FLAG_UNINTERRUPTIBLE;
 
 	do {
-		struct page *page;
+		struct page *page = NULL;
 		unsigned long offset;	/* Offset into pagecache page */
 		unsigned long bytes;	/* Bytes to write to page */
 		size_t copied;		/* Bytes copied from user */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

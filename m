Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AD35C6B0069
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 07:21:29 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id a192so3014831pge.1
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 04:21:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u70si6291297pfk.350.2017.11.03.04.21.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Nov 2017 04:21:28 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH] mm: Handle 0 flags in _calc_vm_trans() macro
Date: Fri,  3 Nov 2017 12:21:21 +0100
Message-Id: <20171103112121.23597-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>

_calc_vm_trans() does not handle the situation when some of the passed
flags are 0 (which can happen if these VM flags do not make sense for
the architecture). Improve the _calc_vm_trans() macro to return 0 in
such situation. Since all passed flags are constant, this does not add
any runtime overhead.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/mman.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Dan, can you please prepend this patch before my series so that we don't
break bisectability? This fixes the reported problem for me when arch
does not define MAP_SYNC. Thanks!

diff --git a/include/linux/mman.h b/include/linux/mman.h
index 8f7cc87828e6..3427bf3daef5 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -105,8 +105,9 @@ static inline bool arch_validate_prot(unsigned long prot)
  * ("bit1" and "bit2" must be single bits)
  */
 #define _calc_vm_trans(x, bit1, bit2) \
+  ((!(bit1) || !(bit2)) ? 0 : \
   ((bit1) <= (bit2) ? ((x) & (bit1)) * ((bit2) / (bit1)) \
-   : ((x) & (bit1)) / ((bit1) / (bit2)))
+   : ((x) & (bit1)) / ((bit1) / (bit2))))
 
 /*
  * Combine the mmap "prot" argument into "vm_flags" used internally.
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

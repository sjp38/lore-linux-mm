Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6BA66900021
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 04:45:18 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id hn18so778956igb.0
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 01:45:18 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u5si5847732igh.62.2014.10.29.01.45.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Oct 2014 01:45:17 -0700 (PDT)
Date: Wed, 29 Oct 2014 11:45:04 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] percpu: off by one in BUG_ON()
Message-ID: <20141029084504.GD8939@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

The unit_map[] array has "nr_cpu_ids" number of elements.  It's
allocated a few lines earlier in the function.  So this test should be
>= instead of >.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Static checker stuff.  Not tested.

diff --git a/mm/percpu.c b/mm/percpu.c
index 014bab6..d39e2f4 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1591,7 +1591,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 			if (cpu == NR_CPUS)
 				continue;
 
-			PCPU_SETUP_BUG_ON(cpu > nr_cpu_ids);
+			PCPU_SETUP_BUG_ON(cpu >= nr_cpu_ids);
 			PCPU_SETUP_BUG_ON(!cpu_possible(cpu));
 			PCPU_SETUP_BUG_ON(unit_map[cpu] != UINT_MAX);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

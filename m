Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f49.google.com (mail-qe0-f49.google.com [209.85.128.49])
	by kanga.kvack.org (Postfix) with ESMTP id C0F816B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 04:39:06 -0500 (EST)
Received: by mail-qe0-f49.google.com with SMTP id k5so237174qej.22
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 01:39:06 -0800 (PST)
Received: from e9.ny.us.ibm.com (e9.ny.us.ibm.com. [32.97.182.139])
        by mx.google.com with ESMTPS id fz9si2676322qab.68.2014.01.21.01.39.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 01:39:05 -0800 (PST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <hanpt@linux.vnet.ibm.com>;
	Tue, 21 Jan 2014 04:39:04 -0500
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 1822F6E803A
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 04:38:59 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0L9d3LR9699642
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 09:39:03 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0L9d2mi032078
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 04:39:02 -0500
Date: Tue, 21 Jan 2014 17:38:59 +0800
From: Han Pingtian <hanpt@linux.vnet.ibm.com>
Subject: [RFC] restore user defined min_free_kbytes when disabling thp
Message-ID: <20140121093859.GA7546@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>

The testcase 'thp04' of LTP will enable THP, do some testing, then
disable it if it wasn't enabled. But this will leave a different value
of min_free_kbytes if it has been set by admin. So I think it's better
to restore the user defined value after disabling THP.

---

thp increases the value of min_free_kbytes in initialization. This will
change the user defined value of min_free_kbytes. So try to restore the
value when disabling thp.

Signed-off-by: Han Pingtian <hanpt@linux.vnet.ibm.com>
---
 mm/huge_memory.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 94a824f..276180b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -164,6 +164,15 @@ static int start_khugepaged(void)
 	} else if (khugepaged_thread) {
 		kthread_stop(khugepaged_thread);
 		khugepaged_thread = NULL;
+
+		if (user_min_free_kbytes >= 0) {
+			pr_info("restore min_free_kbytes from %d to user "
+				"defined %d when stopping khugepaged\n",
+				min_free_kbytes, user_min_free_kbytes);
+
+			min_free_kbytes = user_min_free_kbytes;
+			setup_per_zone_wmarks();
+		}
 	}
 
 	return err;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

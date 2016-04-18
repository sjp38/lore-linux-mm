Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D25F76B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 11:17:59 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e190so333495460pfe.3
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 08:17:59 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id u4si5953785par.185.2016.04.18.08.17.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Apr 2016 08:17:59 -0700 (PDT)
From: Vinayak Menon <vinmenon@codeaurora.org>
Subject: [PATCH] mm: make fault_around_bytes configurable
Date: Mon, 18 Apr 2016 20:47:16 +0530
Message-Id: <1460992636-711-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mgorman@suse.de, vbabka@suse.cz, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, hughd@google.com, Vinayak Menon <vinmenon@codeaurora.org>

Mapping pages around fault is found to cause performance degradation
in certain use cases. The test performed here is launch of 10 apps
one by one, doing something with the app each time, and then repeating
the same sequence once more, on an ARM 64-bit Android device with 2GB
of RAM. The time taken to launch the apps is found to be better when
fault around feature is disabled by setting fault_around_bytes to page
size (4096 in this case).

The tests were done on 3.18 kernel. 4 extra vmstat counters were added
for debugging. pgpgoutclean accounts the clean pages reclaimed via
__delete_from_page_cache. pageref_activate, pageref_activate_vm_exec,
and pageref_keep accounts the mapped file pages activated and retained
by page_check_references.

=== Without swap ===
                          3.18             3.18-fault_around_bytes=4096
-----------------------------------------------------------------------
workingset_refault        691100           664339
workingset_activate       210379           179139
pgpgin                    4676096          4492780
pgpgout                   163967           96711
pgpgoutclean              1090664          990659
pgalloc_dma               3463111          3328299
pgfree                    3502365          3363866
pgactivate                568134           238570
pgdeactivate              752260           392138
pageref_activate          315078           121705
pageref_activate_vm_exec  162940           55815
pageref_keep              141354           51011
pgmajfault                24863            23633
pgrefill_dma              1116370          544042
pgscan_kswapd_dma         1735186          1234622
pgsteal_kswapd_dma        1121769          1005725
pgscan_direct_dma         12966            1090
pgsteal_direct_dma        6209             967
slabs_scanned             1539849          977351
pageoutrun                1260             1333
allocstall                47               7

=== With swap ===
                          3.18             3.18-fault_around_bytes=4096
-----------------------------------------------------------------------
workingset_refault        597687           878109
workingset_activate       167169           254037
pgpgin                    4035424          5157348
pgpgout                   162151           85231
pgpgoutclean              928587           1225029
pswpin                    46033            17100
pswpout                   237952           127686
pgalloc_dma               3305034          3542614
pgfree                    3354989          3592132
pgactivate                626468           355275
pgdeactivate              990205           771902
pageref_activate          294780           157106
pageref_activate_vm_exec  141722           63469
pageref_keep              121931           63028
pgmajfault                67818            45643
pgrefill_dma              1324023          977192
pgscan_kswapd_dma         1825267          1720322
pgsteal_kswapd_dma        1181882          1365500
pgscan_direct_dma         41957            9622
pgsteal_direct_dma        25136            6759
slabs_scanned             689575           542705
pageoutrun                1234             1538
allocstall                110              26

Looks like with fault_around, there is more pressure on reclaim because
of the presence of more mapped pages, resulting in more IO activity,
more faults, more swapping, and allocstalls.

Make fault_around_bytes configurable so that it can be tuned to avoid
performance degradation.

Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
---
 mm/Kconfig  | 10 ++++++++++
 mm/memory.c |  2 +-
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index f644106..e3476fd 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -681,6 +681,16 @@ config ZONE_DEVICE
 
 	  If FS_DAX is enabled, then say Y.
 
+config FAULT_AROUND_BYTES
+	int
+	range 4096 65536
+	default 65536
+	help
+	  The number of bytes to be mapped around the fault. The default
+	  value of 64 kilobytes effectively disables faultaround on
+	  architectures with page size >= 64k, considering the fact that
+	  the feature is less relevant when page size is bigger than 4k.
+
 config FRAME_VECTOR
 	bool
 
diff --git a/mm/memory.c b/mm/memory.c
index 758b0b4..be06714 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2939,7 +2939,7 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 }
 
 static unsigned long fault_around_bytes __read_mostly =
-	rounddown_pow_of_two(65536);
+	rounddown_pow_of_two(CONFIG_FAULT_AROUND_BYTES);
 
 #ifdef CONFIG_DEBUG_FS
 static int fault_around_bytes_get(void *data, u64 *val)
-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

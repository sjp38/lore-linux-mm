Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF1698E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 11:34:47 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h65-v6so1239452pfk.18
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 08:34:47 -0700 (PDT)
Received: from mail5.wrs.com (mail5.windriver.com. [192.103.53.11])
        by mx.google.com with ESMTPS id j64-v6si16769326pgc.88.2018.09.18.08.34.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Sep 2018 08:34:46 -0700 (PDT)
From: <zhe.he@windriver.com>
Subject: [PATCH] mm/page_alloc: Fix panic caused by passing debug_guardpage_minorder or kernelcore to command line
Date: Tue, 18 Sep 2018 23:33:08 +0800
Message-ID: <1537284788-428784-1-git-send-email-zhe.he@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, osalvador@suse.de, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: zhe.he@windriver.com

From: He Zhe <zhe.he@windriver.com>

debug_guardpage_minorder_setup and cmdline_parse_kernelcore do not check
input argument before using it. The argument would be a NULL pointer if
"debug_guardpage_minorder" or "kernelcore", without its value, is set in
command line and thus causes the following panic.

PANIC: early exception 0xe3 IP 10:ffffffffa08146f1 error 0 cr2 0x0
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.19.0-rc4-yocto-standard+ #1
[    0.000000] RIP: 0010:parse_option_str+0x11/0x90
...
[    0.000000] Call Trace:
[    0.000000]  cmdline_parse_kernelcore+0x19/0x41
[    0.000000]  do_early_param+0x57/0x8e
[    0.000000]  parse_args+0x208/0x320
[    0.000000]  ? rdinit_setup+0x30/0x30
[    0.000000]  parse_early_options+0x29/0x2d
[    0.000000]  ? rdinit_setup+0x30/0x30
[    0.000000]  parse_early_param+0x36/0x4d
[    0.000000]  setup_arch+0x336/0x99e
[    0.000000]  start_kernel+0x6f/0x4ee
[    0.000000]  x86_64_start_reservations+0x24/0x26
[    0.000000]  x86_64_start_kernel+0x6f/0x72
[    0.000000]  secondary_startup_64+0xa4/0xb0

This patch adds a check to prevent the panic and adds KBUILD_MODNAME to
prints.

Signed-off-by: He Zhe <zhe.he@windriver.com>
Cc: stable@vger.kernel.org
Cc: akpm@linux-foundation.org
Cc: mhocko@suse.com
Cc: vbabka@suse.cz
Cc: pasha.tatashin@oracle.com
Cc: mgorman@techsingularity.net
Cc: aaron.lu@intel.com
Cc: osalvador@suse.de
Cc: iamjoonsoo.kim@lge.com
---
 mm/page_alloc.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 89d2a2a..d4cda06 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -14,6 +14,8 @@
  *          (lots of bits borrowed from Ingo Molnar & Andrew Morton)
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/stddef.h>
 #include <linux/mm.h>
 #include <linux/swap.h>
@@ -630,6 +632,11 @@ static int __init debug_guardpage_minorder_setup(char *buf)
 {
 	unsigned long res;
 
+	if (!buf) {
+		pr_err("Config string not provided\n");
+		return -EINVAL;
+	}
+
 	if (kstrtoul(buf, 10, &res) < 0 ||  res > MAX_ORDER / 2) {
 		pr_err("Bad debug_guardpage_minorder value\n");
 		return 0;
@@ -6952,6 +6959,11 @@ static int __init cmdline_parse_core(char *p, unsigned long *core,
  */
 static int __init cmdline_parse_kernelcore(char *p)
 {
+	if (!p) {
+		pr_err("Config string not provided\n");
+		return -EINVAL;
+	}
+
 	/* parse kernelcore=mirror */
 	if (parse_option_str(p, "mirror")) {
 		mirrored_kernelcore = true;
-- 
2.7.4

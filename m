Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f50.google.com (mail-oa0-f50.google.com [209.85.219.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3C7DD6B0055
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:02:53 -0400 (EDT)
Received: by mail-oa0-f50.google.com with SMTP id o6so13328761oag.9
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 10:02:52 -0700 (PDT)
Received: from g6t1526.atlanta.hp.com (g6t1526.atlanta.hp.com. [15.193.200.69])
        by mx.google.com with ESMTPS id o7si23187072oei.13.2014.09.10.10.02.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 10:02:51 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v2 6/6] x86, pat: Update documentation for WT changes
Date: Wed, 10 Sep 2014 10:51:50 -0600
Message-Id: <1410367910-6026-7-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Toshi Kani <toshi.kani@hp.com>

This patch updates the PAT documentation file to cover the new
WT mapping interfaces.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 Documentation/x86/pat.txt |   14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/Documentation/x86/pat.txt b/Documentation/x86/pat.txt
index cf08c9f..445caab 100644
--- a/Documentation/x86/pat.txt
+++ b/Documentation/x86/pat.txt
@@ -12,7 +12,7 @@ virtual addresses.
 
 PAT allows for different types of memory attributes. The most commonly used
 ones that will be supported at this time are Write-back, Uncached,
-Write-combined and Uncached Minus.
+Write-combined, Write-through and Uncached Minus.
 
 
 PAT APIs
@@ -38,12 +38,17 @@ ioremap_nocache        |    --    |    UC-     |       UC-        |
                        |          |            |                  |
 ioremap_wc             |    --    |    --      |       WC         |
                        |          |            |                  |
+ioremap_wt             |    --    |    --      |       WT         |
+                       |          |            |                  |
 set_memory_uc          |    UC-   |    --      |       --         |
  set_memory_wb         |          |            |                  |
                        |          |            |                  |
 set_memory_wc          |    WC    |    --      |       --         |
  set_memory_wb         |          |            |                  |
                        |          |            |                  |
+set_memory_wt          |    *1    |    --      |       WT         |
+ set_memory_wb         |          |            |                  |
+                       |          |            |                  |
 pci sysfs resource     |    --    |    --      |       UC-        |
                        |          |            |                  |
 pci sysfs resource_wc  |    --    |    --      |       WC         |
@@ -79,6 +84,7 @@ pci proc               |    --    |    --      |       WC         |
  MTRR says !WB         |          |            |                  |
                        |          |            |                  |
 -------------------------------------------------------------------
+*1: -EINVAL due to the current limitation in reserve_memtype().
 
 Advanced APIs for drivers
 -------------------------
@@ -115,8 +121,8 @@ can be more restrictive, in case of any existing aliasing for that address.
 For example: If there is an existing uncached mapping, a new ioremap_wc can
 return uncached mapping in place of write-combine requested.
 
-set_memory_[uc|wc] and set_memory_wb should be used in pairs, where driver will
-first make a region uc or wc and switch it back to wb after use.
+set_memory_[uc|wc|wt] and set_memory_wb should be used in pairs, where driver
+will first make a region uc, wc or wt and switch it back to wb after use.
 
 Over time writes to /proc/mtrr will be deprecated in favor of using PAT based
 interfaces. Users writing to /proc/mtrr are suggested to use above interfaces.
@@ -126,6 +132,8 @@ types.
 
 Drivers should use set_memory_[uc|wc] to set access type for RAM ranges.
 
+Drivers may map the entire NV-DIMM range with ioremap_cache and then change
+a specific range to wt with set_memory_wt.
 
 PAT debugging
 -------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

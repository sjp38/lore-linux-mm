Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 85A286B025E
	for <linux-mm@kvack.org>; Sat,  1 Oct 2016 00:43:17 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id bv10so233224076pad.2
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 21:43:17 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id u63si18378107pfa.1.2016.09.30.21.43.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Sep 2016 21:43:16 -0700 (PDT)
From: Robert Ho <robert.hu@intel.com>
Subject: [PATCH v4 2/2] Dcumentation/filesystems/proc.txt: Add more description for maps/smaps
Date: Sat,  1 Oct 2016 12:42:38 +0800
Message-Id: <1475296958-27652-2-git-send-email-robert.hu@intel.com>
In-Reply-To: <1475296958-27652-1-git-send-email-robert.hu@intel.com>
References: <1475296958-27652-1-git-send-email-robert.hu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pbonzini@redhat.com, akpm@linux-foundation.org, mhocko@suse.com, oleg@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com
Cc: guangrong.xiao@linux.intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com, Robert Ho <robert.hu@intel.com>

Add some more description on the limitations for smaps/maps readings, as well
as some guaruntees we can make.

Changelog:
v2:
	Adopt Dave Hansen's revision from v1 as the description.

Signed-off-by: Robert Ho <robert.hu@intel.com>
---
 Documentation/filesystems/proc.txt | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 68080ad..daa096f 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -515,6 +515,18 @@ be vanished or the reverse -- new added.
 This file is only present if the CONFIG_MMU kernel configuration option is
 enabled.
 
+Note: reading /proc/PID/maps or /proc/PID/smaps is inherently racy (consistent
+output can be achieved only in the single read call).
+This typically manifests when doing partial reads of these files while the
+memory map is being modified.  Despite the races, we do provide the following
+guarantees:
+
+1) The mapped addresses never go backwards, which implies no two
+   regions will ever overlap.
+2) If there is something at a given vaddr during the entirety of the
+   life of the smaps/maps walk, there will be some output for it.
+
+
 The /proc/PID/clear_refs is used to reset the PG_Referenced and ACCESSED/YOUNG
 bits on both physical and virtual pages associated with a process, and the
 soft-dirty bit on pte (see Documentation/vm/soft-dirty.txt for details).
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

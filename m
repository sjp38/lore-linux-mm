Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6CB342802FF
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 14:47:47 -0400 (EDT)
Received: by lagw2 with SMTP id w2so48769973lag.3
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 11:47:46 -0700 (PDT)
Received: from forward-corp1g.mail.yandex.net (forward-corp1g.mail.yandex.net. [95.108.253.251])
        by mx.google.com with ESMTPS id az11si7697475lab.27.2015.07.16.11.47.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 11:47:45 -0700 (PDT)
Subject: [PATCH] pagemap: update documentation
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Thu, 16 Jul 2015 21:47:42 +0300
Message-ID: <20150716184742.8858.14639.stgit@buzz>
In-Reply-To: <20150714152516.29844.69929.stgit@buzz>
References: <20150714152516.29844.69929.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Notes about recent changes.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 Documentation/vm/pagemap.txt |   14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
index 3cfbbb333ea1..aab39aa7dd8f 100644
--- a/Documentation/vm/pagemap.txt
+++ b/Documentation/vm/pagemap.txt
@@ -16,12 +16,17 @@ There are three components to pagemap:
     * Bits 0-4   swap type if swapped
     * Bits 5-54  swap offset if swapped
     * Bit  55    pte is soft-dirty (see Documentation/vm/soft-dirty.txt)
-    * Bit  56    page exlusively mapped
+    * Bit  56    page exclusively mapped (since 4.2)
     * Bits 57-60 zero
-    * Bit  61    page is file-page or shared-anon
+    * Bit  61    page is file-page or shared-anon (since 3.5)
     * Bit  62    page swapped
     * Bit  63    page present
 
+   Since Linux 4.0 only users with the CAP_SYS_ADMIN capability can get PFNs:
+   for unprivileged users from 4.0 till 4.2 open fails with -EPERM, starting
+   from from 4.2 PFN field is zeroed if user has no CAP_SYS_ADMIN capability.
+   Reason: information about PFNs helps in exploiting Rowhammer vulnerability.
+
    If the page is not present but in swap, then the PFN contains an
    encoding of the swap file number and the page's offset into the
    swap. Unmapped pages return a null PFN. This allows determining
@@ -160,3 +165,8 @@ Other notes:
 Reading from any of the files will return -EINVAL if you are not starting
 the read on an 8-byte boundary (e.g., if you sought an odd number of bytes
 into the file), or if the size of the read is not a multiple of 8 bytes.
+
+Before Linux 3.11 pagemap bits 55-60 were used for "page-shift" (which is
+always 12 at most architectures). Since Linux 3.11 their meaning changes
+after first clear of soft-dirty bits. Since Linux 4.2 they are used for
+flags unconditionally.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

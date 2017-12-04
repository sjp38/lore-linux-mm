Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 521A26B0033
	for <linux-mm@kvack.org>; Sun,  3 Dec 2017 21:14:19 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id f7so11680734pfa.21
        for <linux-mm@kvack.org>; Sun, 03 Dec 2017 18:14:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q4sor2714748plb.144.2017.12.03.18.14.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Dec 2017 18:14:18 -0800 (PST)
From: john.hubbard@gmail.com
Subject: [PATCH v2] mmap.2: MAP_FIXED updated documentation
Date: Sun,  3 Dec 2017 18:14:11 -0800
Message-Id: <20171204021411.4786-1-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: linux-man <linux-man@vger.kernel.org>, linux-api@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Jann Horn <jannh@google.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

Previously, MAP_FIXED was "discouraged", due to portability
issues with the fixed address. In fact, there are other, more
serious issues. Also, in some limited cases, this option can
be used safely.

Expand the documentation to discuss both the hazards, and how
to use it safely.

The "Portability issues" wording is lifted directly from
Matthew Wilcox's review. The notes about other libraries
creating mappings is also from Matthew (lightly edited).

The suggestion to explain how to use MAP_FIXED safely is
from Jann Horn.

Suggested-by: Matthew Wilcox <willy@infradead.org>
Suggested-by: Jann Horn <jannh@google.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---

Changed from v1:

    -- Covered topics recommended by Matthew Wilcox
       and Jann Horn, in their recent review: the hazards
       of overwriting pre-exising mappings, and some notes
       about how to use MAP_FIXED safely.

    -- Rewrote the commit description accordingly.

 man2/mmap.2 | 38 ++++++++++++++++++++++++++++++++++++--
 1 file changed, 36 insertions(+), 2 deletions(-)

diff --git a/man2/mmap.2 b/man2/mmap.2
index 385f3bfd5..9038256d4 100644
--- a/man2/mmap.2
+++ b/man2/mmap.2
@@ -222,8 +222,42 @@ part of the existing mapping(s) will be discarded.
 If the specified address cannot be used,
 .BR mmap ()
 will fail.
-Because requiring a fixed address for a mapping is less portable,
-the use of this option is discouraged.
+.IP
+This option is extremely hazardous (when used on its own) and moderately
+non-portable.
+.IP
+Portability issues: a process's memory map may change significantly from one
+run to the next, depending on library versions, kernel versions and random
+numbers.
+.IP
+Hazards: this option forcibly removes pre-existing mappings, making it easy
+for a multi-threaded process to corrupt its own address space.
+.IP
+For example, thread A looks through /proc/<pid>/maps and locates an available
+address range, while thread B simultaneously acquires part or all of that same
+address range. Thread A then calls mmap(MAP_FIXED), effectively overwriting
+thread B's mapping.
+.IP
+Thread B need not create a mapping directly; simply making a library call
+that, internally, uses dlopen(3) to load some other shared library, will
+suffice. The dlopen(3) call will map the library into the process's address
+space. Furthermore, almost any library call may be implemented using this
+technique.
+Examples include brk(2), malloc(3), pthread_create(3), and the PAM libraries
+(http://www.linux-pam.org).
+.IP
+Given the above limitations, one of the very few ways to use this option
+safely is: mmap() a region, without specifying MAP_FIXED. Then, within that
+region, call mmap(MAP_FIXED) to suballocate regions. This avoids both the
+portability problem (because the first mmap call lets the kernel pick the
+address), and the address space corruption problem (because the region being
+overwritten is already owned by the calling thread).
+.IP
+Newer kernels
+(Linux 4.16 and later) have a
+.B MAP_FIXED_SAFE
+option that avoids the corruption problem; if available, MAP_FIXED_SAFE
+should be preferred over MAP_FIXED.
 .TP
 .B MAP_GROWSDOWN
 This flag is used for stacks.
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

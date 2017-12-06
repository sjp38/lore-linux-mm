Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id EB8466B032A
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 22:14:39 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id t9so1783395pgu.1
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 19:14:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p13sor46222plo.99.2017.12.05.19.14.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Dec 2017 19:14:38 -0800 (PST)
From: john.hubbard@gmail.com
Subject: [PATCH v4] mmap.2: MAP_FIXED updated documentation
Date: Tue,  5 Dec 2017 19:14:34 -0800
Message-Id: <20171206031434.29087-1-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: linux-man <linux-man@vger.kernel.org>, linux-api@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Jann Horn <jannh@google.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Cyril Hrubis <chrubis@suse.cz>, Michal Hocko <mhocko@suse.com>, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

Previously, MAP_FIXED was "discouraged", due to portability
issues with the fixed address. In fact, there are other, more
serious issues. Also, alignment requirements were a bit vague.
So:

    -- Expand the documentation to discuss the hazards in
       enough detail to allow avoiding them.

    -- Mention the upcoming MAP_FIXED_SAFE flag.

    -- Enhance the alignment requirement slightly.

Some of the wording is lifted from Matthew Wilcox's review
(the "Portability issues" section). The alignment requirements
section uses Cyril Hrubis' wording, with light editing applied.

Suggested-by: Matthew Wilcox <willy@infradead.org>
Suggested-by: Cyril Hrubis <chrubis@suse.cz>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---

Changes since v3:

    -- Removed the "how to use this safely" part, and
       the SHMLBA part, both as a result of Michal Hocko's
       review.

    -- A few tiny wording fixes, at the not-quite-typo level.

Changes since v2:

    -- Fixed up the "how to use safely" example, in response
       to Mike Rapoport's review.

    -- Changed the alignment requirement from system page
       size, to SHMLBA. This was inspired by (but not yet
       recommended by) Cyril Hrubis' review.

    -- Formatting: underlined /proc/<pid>/maps 

Changes since v1:

    -- Covered topics recommended by Matthew Wilcox
       and Jann Horn, in their recent review: the hazards
       of overwriting pre-exising mappings, and some notes
       about how to use MAP_FIXED safely.

    -- Rewrote the commit description accordingly.

 man2/mmap.2 | 40 ++++++++++++++++++++++++++++++++++++----
 1 file changed, 36 insertions(+), 4 deletions(-)

diff --git a/man2/mmap.2 b/man2/mmap.2
index 385f3bfd5..56b05cff1 100644
--- a/man2/mmap.2
+++ b/man2/mmap.2
@@ -212,8 +212,9 @@ Don't interpret
 .I addr
 as a hint: place the mapping at exactly that address.
 .I addr
-must be a multiple of the page size.
-If the memory region specified by
+must be suitably aligned: for most architectures a multiple of page
+size is sufficient; however, some architectures may impose additional
+restrictions. If the memory region specified by
 .I addr
 and
 .I len
@@ -222,8 +223,39 @@ part of the existing mapping(s) will be discarded.
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
+For example, thread A looks through
+.I /proc/<pid>/maps
+and locates an available
+address range, while thread B simultaneously acquires part or all of that same
+address range. Thread A then calls mmap(MAP_FIXED), effectively overwriting
+the mapping that thread B created.
+.IP
+Thread B need not create a mapping directly; simply making a library call
+that, internally, uses
+.I dlopen(3)
+to load some other shared library, will
+suffice. The dlopen(3) call will map the library into the process's address
+space. Furthermore, almost any library call may be implemented using this
+technique.
+Examples include brk(2), malloc(3), pthread_create(3), and the PAM libraries
+(http://www.linux-pam.org).
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

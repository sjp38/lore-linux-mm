Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D316C6B0023
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:12 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id f16so3067547wre.0
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:23:12 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s53si1993432edd.112.2018.03.21.12.23.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 12:23:11 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2LJIbxl009168
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:10 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gut8117gb-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:09 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 21 Mar 2018 19:23:07 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 01/32] docs/vm: active_mm.txt convert to ReST format
Date: Wed, 21 Mar 2018 21:22:17 +0200
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1521660168-14372-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Just add a label for cross-referencing and indent the text to make it
``literal``

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/active_mm.txt | 174 +++++++++++++++++++++--------------------
 1 file changed, 91 insertions(+), 83 deletions(-)

diff --git a/Documentation/vm/active_mm.txt b/Documentation/vm/active_mm.txt
index dbf4581..c84471b 100644
--- a/Documentation/vm/active_mm.txt
+++ b/Documentation/vm/active_mm.txt
@@ -1,83 +1,91 @@
-List:       linux-kernel
-Subject:    Re: active_mm
-From:       Linus Torvalds <torvalds () transmeta ! com>
-Date:       1999-07-30 21:36:24
-
-Cc'd to linux-kernel, because I don't write explanations all that often,
-and when I do I feel better about more people reading them.
-
-On Fri, 30 Jul 1999, David Mosberger wrote:
->
-> Is there a brief description someplace on how "mm" vs. "active_mm" in
-> the task_struct are supposed to be used?  (My apologies if this was
-> discussed on the mailing lists---I just returned from vacation and
-> wasn't able to follow linux-kernel for a while).
-
-Basically, the new setup is:
-
- - we have "real address spaces" and "anonymous address spaces". The
-   difference is that an anonymous address space doesn't care about the
-   user-level page tables at all, so when we do a context switch into an
-   anonymous address space we just leave the previous address space
-   active.
-
-   The obvious use for a "anonymous address space" is any thread that
-   doesn't need any user mappings - all kernel threads basically fall into
-   this category, but even "real" threads can temporarily say that for
-   some amount of time they are not going to be interested in user space,
-   and that the scheduler might as well try to avoid wasting time on
-   switching the VM state around. Currently only the old-style bdflush
-   sync does that.
-
- - "tsk->mm" points to the "real address space". For an anonymous process,
-   tsk->mm will be NULL, for the logical reason that an anonymous process
-   really doesn't _have_ a real address space at all.
-
- - however, we obviously need to keep track of which address space we
-   "stole" for such an anonymous user. For that, we have "tsk->active_mm",
-   which shows what the currently active address space is.
-
-   The rule is that for a process with a real address space (ie tsk->mm is
-   non-NULL) the active_mm obviously always has to be the same as the real
-   one.
-
-   For a anonymous process, tsk->mm == NULL, and tsk->active_mm is the
-   "borrowed" mm while the anonymous process is running. When the
-   anonymous process gets scheduled away, the borrowed address space is
-   returned and cleared.
-
-To support all that, the "struct mm_struct" now has two counters: a
-"mm_users" counter that is how many "real address space users" there are,
-and a "mm_count" counter that is the number of "lazy" users (ie anonymous
-users) plus one if there are any real users.
-
-Usually there is at least one real user, but it could be that the real
-user exited on another CPU while a lazy user was still active, so you do
-actually get cases where you have a address space that is _only_ used by
-lazy users. That is often a short-lived state, because once that thread
-gets scheduled away in favour of a real thread, the "zombie" mm gets
-released because "mm_users" becomes zero.
-
-Also, a new rule is that _nobody_ ever has "init_mm" as a real MM any
-more. "init_mm" should be considered just a "lazy context when no other
-context is available", and in fact it is mainly used just at bootup when
-no real VM has yet been created. So code that used to check
-
-	if (current->mm == &init_mm)
-
-should generally just do
-
-	if (!current->mm)
-
-instead (which makes more sense anyway - the test is basically one of "do
-we have a user context", and is generally done by the page fault handler
-and things like that).
-
-Anyway, I put a pre-patch-2.3.13-1 on ftp.kernel.org just a moment ago,
-because it slightly changes the interfaces to accommodate the alpha (who
-would have thought it, but the alpha actually ends up having one of the
-ugliest context switch codes - unlike the other architectures where the MM
-and register state is separate, the alpha PALcode joins the two, and you
-need to switch both together).
-
-(From http://marc.info/?l=linux-kernel&m=93337278602211&w=2)
+.. _active_mm:
+
+=========
+Active MM
+=========
+
+::
+
+ List:       linux-kernel
+ Subject:    Re: active_mm
+ From:       Linus Torvalds <torvalds () transmeta ! com>
+ Date:       1999-07-30 21:36:24
+
+ Cc'd to linux-kernel, because I don't write explanations all that often,
+ and when I do I feel better about more people reading them.
+
+ On Fri, 30 Jul 1999, David Mosberger wrote:
+ >
+ > Is there a brief description someplace on how "mm" vs. "active_mm" in
+ > the task_struct are supposed to be used?  (My apologies if this was
+ > discussed on the mailing lists---I just returned from vacation and
+ > wasn't able to follow linux-kernel for a while).
+
+ Basically, the new setup is:
+
+  - we have "real address spaces" and "anonymous address spaces". The
+    difference is that an anonymous address space doesn't care about the
+    user-level page tables at all, so when we do a context switch into an
+    anonymous address space we just leave the previous address space
+    active.
+
+    The obvious use for a "anonymous address space" is any thread that
+    doesn't need any user mappings - all kernel threads basically fall into
+    this category, but even "real" threads can temporarily say that for
+    some amount of time they are not going to be interested in user space,
+    and that the scheduler might as well try to avoid wasting time on
+    switching the VM state around. Currently only the old-style bdflush
+    sync does that.
+
+  - "tsk->mm" points to the "real address space". For an anonymous process,
+    tsk->mm will be NULL, for the logical reason that an anonymous process
+    really doesn't _have_ a real address space at all.
+
+  - however, we obviously need to keep track of which address space we
+    "stole" for such an anonymous user. For that, we have "tsk->active_mm",
+    which shows what the currently active address space is.
+
+    The rule is that for a process with a real address space (ie tsk->mm is
+    non-NULL) the active_mm obviously always has to be the same as the real
+    one.
+
+    For a anonymous process, tsk->mm == NULL, and tsk->active_mm is the
+    "borrowed" mm while the anonymous process is running. When the
+    anonymous process gets scheduled away, the borrowed address space is
+    returned and cleared.
+
+ To support all that, the "struct mm_struct" now has two counters: a
+ "mm_users" counter that is how many "real address space users" there are,
+ and a "mm_count" counter that is the number of "lazy" users (ie anonymous
+ users) plus one if there are any real users.
+
+ Usually there is at least one real user, but it could be that the real
+ user exited on another CPU while a lazy user was still active, so you do
+ actually get cases where you have a address space that is _only_ used by
+ lazy users. That is often a short-lived state, because once that thread
+ gets scheduled away in favour of a real thread, the "zombie" mm gets
+ released because "mm_users" becomes zero.
+
+ Also, a new rule is that _nobody_ ever has "init_mm" as a real MM any
+ more. "init_mm" should be considered just a "lazy context when no other
+ context is available", and in fact it is mainly used just at bootup when
+ no real VM has yet been created. So code that used to check
+
+ 	if (current->mm == &init_mm)
+
+ should generally just do
+
+ 	if (!current->mm)
+
+ instead (which makes more sense anyway - the test is basically one of "do
+ we have a user context", and is generally done by the page fault handler
+ and things like that).
+
+ Anyway, I put a pre-patch-2.3.13-1 on ftp.kernel.org just a moment ago,
+ because it slightly changes the interfaces to accommodate the alpha (who
+ would have thought it, but the alpha actually ends up having one of the
+ ugliest context switch codes - unlike the other architectures where the MM
+ and register state is separate, the alpha PALcode joins the two, and you
+ need to switch both together).
+
+ (From http://marc.info/?l=linux-kernel&m=93337278602211&w=2)
-- 
2.7.4

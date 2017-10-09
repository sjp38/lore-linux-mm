Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id B343E6B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 18:46:13 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id 103so17006910uas.3
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 15:46:13 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id a10si1613168qtg.183.2017.10.09.15.46.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 15:46:12 -0700 (PDT)
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Subject: [PATCH v2] Userfaultfd: Add description for UFFD_FEATURE_SIGBUS
Date: Mon,  9 Oct 2017 15:45:51 -0700
Message-Id: <1507589151-27430-1-git-send-email-prakash.sangappa@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com, rppt@linux.vnet.ibm.com, mhocko@suse.com, prakash.sangappa@oracle.com

Userfaultfd feature UFFD_FEATURE_SIGBUS was merged recently and should
be available in Linux 4.14 release. This patch is for the manpage
changes documenting this API.

Documents the following commit:

commit 2d6d6f5a09a96cc1fec7ed992b825e05f64cb50e
Author: Prakash Sangappa <prakash.sangappa@oracle.com>
Date: Wed Sep 6 16:23:39 2017 -0700

     mm: userfaultfd: add feature to request for a signal delivery

Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>
---
v2: Incorporated review feedback changes.
---
 man2/ioctl_userfaultfd.2 |  9 +++++++++
 man2/userfaultfd.2       | 23 +++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/man2/ioctl_userfaultfd.2 b/man2/ioctl_userfaultfd.2
index 60fd29b..32f0744 100644
--- a/man2/ioctl_userfaultfd.2
+++ b/man2/ioctl_userfaultfd.2
@@ -196,6 +196,15 @@ with the
 flag set,
 .BR memfd_create (2),
 and so on.
+.TP
+.B UFFD_FEATURE_SIGBUS
+Since Linux 4.14, If this feature bit is set, no page-fault events
+.B (UFFD_EVENT_PAGEFAULT)
+will be delivered, instead a
+.B SIGBUS
+signal will be sent to the faulting process. Applications using this
+feature will not require the use of a userfaultfd monitor for processing
+memory accesses to the regions registered with userfaultfd.
 .IP
 The returned
 .I ioctls
diff --git a/man2/userfaultfd.2 b/man2/userfaultfd.2
index 1741ee3..3c5b9c0 100644
--- a/man2/userfaultfd.2
+++ b/man2/userfaultfd.2
@@ -172,6 +172,29 @@ or
 .BR ioctl (2)
 operations to resolve the page fault.
 .PP
+Starting from Linux 4.14, if application sets
+.B UFFD_FEATURE_SIGBUS
+feature bit using
+.B UFFDIO_API
+.BR ioctl (2),
+no page fault notification will be forwarded to
+the user-space, instead a
+.B SIGBUS
+signal is delivered to the faulting process. With this feature,
+userfaultfd can be used for robustness purpose to simply catch
+any access to areas within the registered address range that do not
+have pages allocated, without having to listen to userfaultfd events.
+No userfaultfd monitor will be required for dealing with such memory
+accesses. For example, this feature can be useful for applications that
+want to prevent the kernel from automatically allocating pages and filling
+holes in sparse files when the hole is accessed thru mapped address.
+.PP
+The
+.B UFFD_FEATURE_SIGBUS
+feature is implicitly inherited through fork() if used in combination with
+.BR UFFD_FEATURE_FORK .
+
+.PP
 Details of the various
 .BR ioctl (2)
 operations can be found in
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

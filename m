Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 58F7D6B0387
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 17:34:03 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id e137so208927449itc.0
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 14:34:03 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c26si42392itd.6.2017.02.21.14.34.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Feb 2017 14:34:02 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1LMSZCX055731
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 17:34:01 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28rshfvnw3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 17:34:01 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 21 Feb 2017 22:33:59 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] userfaultfd: documentation update
Date: Wed, 22 Feb 2017 00:33:51 +0200
Message-Id: <1487716431-5551-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Add documentation about new userfaultfd features and events

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
---
 Documentation/vm/userfaultfd.txt | 89 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 89 insertions(+)

diff --git a/Documentation/vm/userfaultfd.txt b/Documentation/vm/userfaultfd.txt
index 5a86192..0e5543a 100644
--- a/Documentation/vm/userfaultfd.txt
+++ b/Documentation/vm/userfaultfd.txt
@@ -54,6 +54,26 @@ uffdio_api.features and uffdio_api.ioctls two 64bit bitmasks of
 respectively all the available features of the read(2) protocol and
 the generic ioctl available.
 
+The uffdio_api.features bitmask returned by the UFFDIO_API ioctl
+defines what memory types are supported by the userfaultfd and what
+events, except page fault notifications, may be generated.
+
+If the kernel supports registering userfaultfd ranges on hugetlbfs
+virtual memory areas, UFFD_FEATURE_MISSING_HUGETLBFS will be set in
+uffdio_api.features. Similarly, UFFD_FEATURE_MISSING_SHMEM will be
+set if the kernel supports registering userfaultfd ranges on shared
+memory (covering all shmem APIs, i.e. tmpfs, IPCSHM, /dev/zero
+MAP_SHARED, memfd_create, etc).
+
+The userland application that wants to use userfaultfd with hugetlbfs
+or shared memory need to set the corresponding flag in
+uffdio_api.features to enable those features.
+
+If the userland desires to receive notifications for events other than
+page faults, it has to verify that uffdio_api.features has appropriate
+UFFD_FEATURE_EVENT_* bits set. These events are described in more
+detail below in "Non-cooperative userfaultfd" section.
+
 Once the userfaultfd has been enabled the UFFDIO_REGISTER ioctl should
 be invoked (if present in the returned uffdio_api.ioctls bitmask) to
 register a memory range in the userfaultfd by setting the
@@ -142,3 +162,72 @@ course the bitmap is updated accordingly. It's also useful to avoid
 sending the same page twice (in case the userfault is read by the
 postcopy thread just before UFFDIO_COPY|ZEROPAGE runs in the migration
 thread).
+
+== Non-cooperative userfaultfd ==
+
+When the userfaultfd is monitored by an external manager, the manager
+must be able to track changes in the process virtual memory
+layout. Userfaultfd can notify the manager about such changes using
+the same read(2) protocol as for the page fault notifications. The
+manager has to explicitly enable these events by setting appropriate
+bits in uffdio_api.features passed to UFFDIO_API ioctl:
+
+UFFD_FEATURE_EVENT_EXIT - enable notification about exit() of the
+non-cooperative process. When the monitored process exits, the uffd
+manager will get UFFD_EVENT_EXIT.
+
+UFFD_FEATURE_EVENT_FORK - enable userfaultfd hooks for fork(). When
+this feature is enabled, the userfaultfd context of the parent process
+is duplicated into the newly created process. The manager receives
+UFFD_EVENT_FORK with file descriptor of the new userfaultfd context in
+the uffd_msg.fork.
+
+UFFD_FEATURE_EVENT_REMAP - enable notifications about mremap()
+calls. When the non-cooperative process moves a virtual memory area to
+a different location, the manager will receive UFFD_EVENT_REMAP. The
+uffd_msg.remap will contain the old and new addresses of the area and
+its original length.
+
+UFFD_FEATURE_EVENT_REMOVE - enable notifications about
+madvise(MADV_REMOVE) and madvise(MADV_DONTNEED) calls. The event
+UFFD_EVENT_REMOVE will be generated upon these calls to madvise. The
+uffd_msg.remove will contain start and end addresses of the removed
+area.
+
+UFFD_FEATURE_EVENT_UNMAP - enable notifications about memory
+unmapping. The manager will get UFFD_EVENT_UNMAP with uffd_msg.remove
+containing start and end addresses of the unmapped area.
+
+Although the UFFD_FEATURE_EVENT_REMOVE and UFFD_FEATURE_EVENT_UNMAP
+are pretty similar, they quite differ in the action expected from the
+userfaultfd manager. In the former case, the virtual memory is
+removed, but the area is not, the area remains monitored by the
+userfaultfd, and if a page fault occurs in that area it will be
+delivered to the manager. The proper resolution for such page fault is
+to zeromap the faulting address. However, in the latter case, when an
+area is unmapped, either explicitly (with munmap() system call), or
+implicitly (e.g. during mremap()), the area is removed and in turn the
+userfaultfd context for such area disappears too and the manager will
+not get further userland page faults from the removed area. Still, the
+notification is required in order to prevent manager from using
+UFFDIO_COPY on the unmapped area.
+
+Unlike userland page faults which have to be synchronous and require
+explicit or implicit wakeup, all the events are delivered
+asynchronously and the non-cooperative process resumes execution as
+soon as manager executes read(). The userfaultfd manager should
+carefully synchronize calls to UFFDIO_COPY with the events
+processing. To aid the synchronization, the UFFDIO_COPY ioctl will
+return -ENOSPC when the monitored process exits at the time of
+UFFDIO_COPY, and -ENOENT, when the non-cooperative process has changed
+its virtual memory layout simultaneously with outstanding UFFDIO_COPY
+operation.
+
+The current asynchronous model of the event delivery is optimal for
+single threaded non-cooperative userfaultfd manager implementations. A
+synchronous event delivery model can be added later as a new
+userfaultfd feature to facilitate multithreading enhancements of the
+non cooperative manager, for example to allow UFFDIO_COPY ioctls to
+run in parallel to the event reception. Single threaded
+implementations should continue to use the current async event
+delivery model instead.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

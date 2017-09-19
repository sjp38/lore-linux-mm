Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA3676B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 17:42:48 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id b1so1107102qtc.4
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 14:42:48 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 17si327500qtu.237.2017.09.19.14.42.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Sep 2017 14:42:47 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [patch v2] mremap.2: Add description of old_size == 0 functionality
Date: Tue, 19 Sep 2017 14:42:24 -0700
Message-Id: <20170919214224.19561-1-mike.kravetz@oracle.com>
In-Reply-To: <a5d279cb-a015-f74c-2e40-a231aa7f7a8c@redhat.com>
References: <a5d279cb-a015-f74c-2e40-a231aa7f7a8c@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: linux-man@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Jann Horn <jannh@google.com>, Florian Weimer <fweimer@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>

v2: Fix incorrect wording noticed by Jann Horn.
    Remove deprecated and memfd_create discussion as suggested
    by Florian Weimer.

Since at least the 2.6 time frame, mremap would create a new mapping
of the same pages if 'old_size == 0'.  It would also leave the original
mapping.  This was used to create a 'duplicate mapping'.

A recent change was made to mremap so that an attempt to create a
duplicate a private mapping will fail.

Document the 'old_size == 0' behavior and new return code from
below commit.

commit dba58d3b8c5045ad89c1c95d33d01451e3964db7
Author: Mike Kravetz <mike.kravetz@oracle.com>
Date:   Wed Sep 6 16:20:55 2017 -0700

    mm/mremap: fail map duplication attempts for private mappings

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 man2/mremap.2 | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/man2/mremap.2 b/man2/mremap.2
index 98643c640..235984a96 100644
--- a/man2/mremap.2
+++ b/man2/mremap.2
@@ -58,6 +58,20 @@ may be provided; see the description of
 .B MREMAP_FIXED
 below.
 .PP
+If the value of \fIold_size\fP is zero, and \fIold_address\fP refers to
+a shareable mapping (see
+.BR mmap (2)
+.BR MAP_SHARED )
+, then
+.BR mremap ()
+will create a new mapping of the same pages. \fInew_size\fP
+will be the size of the new mapping and the location of the new mapping
+may be specified with \fInew_address\fP, see the description of
+.B MREMAP_FIXED
+below.  If a new mapping is requested via this method, then the
+.B MREMAP_MAYMOVE
+flag must also be specified.
+.PP
 In Linux the memory is divided into pages.
 A user process has (one or)
 several linear virtual memory segments.
@@ -174,7 +188,12 @@ and
 or
 .B MREMAP_FIXED
 was specified without also specifying
-.BR MREMAP_MAYMOVE .
+.BR MREMAP_MAYMOVE ;
+or \fIold_size\fP was zero and \fIold_address\fP does not refer to a
+shareable mapping;
+or \fIold_size\fP was zero and the
+.BR MREMAP_MAYMOVE
+flag was not specified.
 .TP
 .B ENOMEM
 The memory area cannot be expanded at the current virtual address, and the
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

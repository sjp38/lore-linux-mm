Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 001896B0631
	for <linux-mm@kvack.org>; Thu, 10 May 2018 13:46:23 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id o23-v6so1572154pll.12
        for <linux-mm@kvack.org>; Thu, 10 May 2018 10:46:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k3-v6sor334388pgq.418.2018.05.10.10.46.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 May 2018 10:46:22 -0700 (PDT)
Date: Thu, 10 May 2018 23:18:27 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH v2] include: mm: Adding new inline function vmf_error
Message-ID: <20180510174826.GA14268@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, willy@infradead.org
Cc: linux-mm@kvack.org

Many places in drivers/ file systems, error was handled
in a common way like below -
ret = (ret == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS;
This new inline function vmf_error() will replace this
and return vm_fault_t type err.

A lot of drivers and filesystems currently have a rather
complex mapping of errno-to-VM_FAULT code. We have been
able to eliminate a lot of it by just returning VM_FAULT
codes directly from functions which are called exclusively
from the fault handling path.

Some functions can be called both from the fault handler
and other context which are expecting an errno, so they
have to continue to return an errno. Some users still need
to choose different behaviour for different errnos, but
vmf_error() captures the essential error translation
that's common to all users, and those that need to handle
additional errors can handle them first.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
---
v2: Addressed Andrew's comment. Updated the change log.
    Modified vmf_error() to less verbose

 include/linux/mm.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a4d8853..6ef5d94 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2453,6 +2453,13 @@ static inline vm_fault_t vmf_insert_pfn(struct vm_area_struct *vma,
 	return VM_FAULT_NOPAGE;
 }
 
+static inline vm_fault_t vmf_error(int err)
+{
+	if (err == -ENOMEM)
+		return VM_FAULT_OOM;
+	return VM_FAULT_SIGBUS;
+}
+
 struct page *follow_page_mask(struct vm_area_struct *vma,
 			      unsigned long address, unsigned int foll_flags,
 			      unsigned int *page_mask);
-- 
1.9.1

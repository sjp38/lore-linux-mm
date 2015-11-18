Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id AA9846B0256
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 18:50:05 -0500 (EST)
Received: by wmww144 with SMTP id w144so94374754wmw.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 15:50:05 -0800 (PST)
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com. [195.75.94.103])
        by mx.google.com with ESMTPS id m2si7541595wje.1.2015.11.18.15.50.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Nov 2015 15:50:04 -0800 (PST)
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Wed, 18 Nov 2015 23:50:03 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 7D1E12190067
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 23:49:55 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tAINo07W11338012
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 23:50:00 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tAINnxVJ019693
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 16:50:00 -0700
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 1/2] mm: fixup_userfault returns VM_FAULT_RETRY if asked
Date: Thu, 19 Nov 2015 00:49:57 +0100
Message-Id: <1447890598-56860-2-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1447890598-56860-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1447890598-56860-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-s390@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Eric B Munson <emunson@akamai.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, "Jason J. Herne" <jjherne@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

When calling fixup_userfault with FAULT_FLAG_ALLOW_RETRY, fixup_userfault
didn't care about VM_FAULT_RETRY and returned 0. If the VM_FAULT_RETRY flag is
set we will return the complete result of handle_mm_fault.

Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 mm/gup.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/gup.c b/mm/gup.c
index deafa2c..2af3b31 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -609,6 +609,8 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 			return -EFAULT;
 		BUG();
 	}
+	if (ret & VM_FAULT_RETRY)
+		return ret;
 	if (tsk) {
 		if (ret & VM_FAULT_MAJOR)
 			tsk->maj_flt++;
-- 
2.3.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2794B6B0255
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 12:27:23 -0500 (EST)
Received: by wmec201 with SMTP id c201so30550923wme.1
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 09:27:22 -0800 (PST)
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com. [195.75.94.101])
        by mx.google.com with ESMTPS id e9si4810085wma.115.2015.11.26.09.27.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Nov 2015 09:27:22 -0800 (PST)
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Thu, 26 Nov 2015 17:27:21 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 7C40417D805A
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 17:27:43 +0000 (GMT)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tAQHRH2C8716662
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 17:27:17 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tAQHR8Nm001704
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 10:27:14 -0700
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH v2 0/2] Allow gmap fault to retry 
Date: Thu, 26 Nov 2015 18:27:00 +0100
Message-Id: <1448558822-41358-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, "Jason J. Herne" <jjherne@linux.vnet.ibm.com>, linux-s390@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Eric B Munson <emunson@akamai.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Heiko Carstens <heiko.carstens@de.ibm.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, linux-kernel@vger.kernel.org

Hello,

during Jasons work with postcopy migration support for s390 a problem regarding
gmap faults was discovered.

The gmap code will call fixup_userfault which will end up always in
handle_mm_fault. Till now we never cared about retries, but as the userfaultfd
code kind of relies on it, this needs some fix.

Thanks,
    Dominik

v1 -> v2:
- Instead of passing the VM_FAULT_RETRY from fixup_user_fault we do retries
  within fixup_user_fault, like get_user_pages_locked do.
- gmap code will now take retry if fixup_user_fault drops the lock

Dominik Dingel (2):
  mm: bring in additional flag for fixup_user_fault to signal unlock
  s390/mm: enable fixup_user_fault retrying

 arch/s390/mm/pgtable.c | 31 ++++++++++++++++++++++++++++---
 include/linux/mm.h     |  5 +++--
 kernel/futex.c         |  2 +-
 mm/gup.c               | 25 +++++++++++++++++++++----
 4 files changed, 53 insertions(+), 10 deletions(-)

-- 
2.3.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

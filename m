Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8EC686B0007
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 06:20:07 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id u188so142889699wmu.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 03:20:07 -0800 (PST)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id w14si112779282wmd.108.2016.01.04.03.20.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Jan 2016 03:20:05 -0800 (PST)
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Mon, 4 Jan 2016 11:20:04 -0000
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH v3 0/2] Allow gmap fault to retry
Date: Mon,  4 Jan 2016 12:19:53 +0100
Message-Id: <1451906395-80878-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, "Jason J. Herne" <jjherne@linux.vnet.ibm.com>, linux-s390@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Eric B Munson <emunson@akamai.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Heiko Carstens <heiko.carstens@de.ibm.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, linux-kernel@vger.kernel.org

Hello,

sorry for the delay since the last version.

During Jasons work with postcopy migration support for s390 a problem regarding
gmap faults was discovered.

The gmap code will call fixup_user_fault which will end up always in
handle_mm_fault. Till now we never cared about retries, but as the userfaultfd
code kind of relies on it. this needs some fix.

This patchset does not take care of the futex code. I will now look closer at
this.

Thanks,
    Dominik

v2 -> v3:
- In case of retrying check vma again
- Do the accounting of major/minor faults once

v1 -> v2:
- Instread of passing the VM_FAULT_RETRY from fixup_user_fault we do retries
  within fixup_user_fault, like get_user_pages_locked do.
- gmap code will now take retry if fixup_user_fault drops the lock.

Dominik Dingel (2):
  mm: bring in additional flag for fixup_user_fault to signal unlock
  s390/mm: enable fixup_user_fault retrying

 arch/s390/mm/pgtable.c | 31 ++++++++++++++++++++++++++++---
 include/linux/mm.h     |  5 +++--
 kernel/futex.c         |  2 +-
 mm/gup.c               | 30 +++++++++++++++++++++++++-----
 4 files changed, 57 insertions(+), 11 deletions(-)

-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id B44036B0257
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 18:50:07 -0500 (EST)
Received: by wmww144 with SMTP id w144so94375568wmw.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 15:50:07 -0800 (PST)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id kn4si7457218wjb.205.2015.11.18.15.50.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Nov 2015 15:50:04 -0800 (PST)
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Wed, 18 Nov 2015 23:50:03 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 03ACA1B0806E
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 23:50:21 +0000 (GMT)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tAINo0xI14090282
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 23:50:00 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tAINnx4i017992
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 16:50:00 -0700
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 0/2] Allow gmap fault to retry 
Date: Thu, 19 Nov 2015 00:49:56 +0100
Message-Id: <1447890598-56860-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-s390@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Eric B Munson <emunson@akamai.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, "Jason J. Herne" <jjherne@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

Hello,

during Jasons work with postcopy migration support for s390 a problem regarding
gmap faults was discovered.

The gmap code will call fixup_userfault which will end up always in
handle_mm_fault. Till now we never cared about retries, but as the userfaultfd
code kind of relies on it, this needed some fix. This patchset includes the
retry logic fory gmap fault scenarios, as well as passing back VM_FAULT_RETRY
from fixup_userfault.

Thanks,
    Dominik

Dominik Dingel (2):
  mm: fixup_userfault returns VM_FAULT_RETRY if asked
  s390/mm: allow gmap code to retry on faulting in guest memory

 arch/s390/mm/pgtable.c | 28 ++++++++++++++++++++++++----
 mm/gup.c               |  2 ++
 2 files changed, 26 insertions(+), 4 deletions(-)

-- 
2.3.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

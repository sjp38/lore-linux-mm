Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id B20C96B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 17:26:19 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id gw7so79011258pac.0
        for <linux-mm@kvack.org>; Wed, 11 May 2016 14:26:19 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id v15si12186640pfa.20.2016.05.11.14.26.18
        for <linux-mm@kvack.org>;
        Wed, 11 May 2016 14:26:18 -0700 (PDT)
Date: Wed, 11 May 2016 17:26:16 -0400
From: Mike Marciniszyn <mike.marciniszyn@intel.com>
Subject: Re: [1/1] mm: thp: calculate the mapcount correctly for THP pages during WP faults
Message-ID: <20160511212552.GA20578@phlsvsds.ph.intel.com>
References: <1462908082-12657-1-git-send-email-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1462908082-12657-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org

>
>Reviewed-by: "Kirill A. Shutemov" <kirill@shutemov.name>
>Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
>

Our RDMA tests are seeing an issue with memory locking that bisects to
commit 61f5d698cc97 ("mm: re-enable THP").

The test program registers two rather large MRs (512M) and RDMA writes
data to a passive peer using the first and RDMA reads it back into the
second MR and compares that data.  The sizes are chosen randomly between
0 and 1024 bytes.

The test will get through a few (<= 4 iterations) and then gets a compare error.

Tracing indicates the kernel logical addresses associated with the individual
pages at registration ARE correct , the data in the "RDMA read response only"
packets ARE correct.

The a??corruptiona?? occurs when the packet crosse two pages that are not
physically contiguous.   The second page reads back as zero in the program.

It looks like the user VA at the point of the compare error no longer points
to the same physical address as was registered.  

This patch totally resolves the issue!

Tested-by: Mike Marciniszyn <mike.marciniszy@intel.com>
Tested-by: Josh Collier <josh.d.collier@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

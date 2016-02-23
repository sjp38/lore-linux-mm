Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id CC95D828DF
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:49:54 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id g62so206957402wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 07:49:54 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id n4si40314143wmg.71.2016.02.23.07.49.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 07:49:53 -0800 (PST)
Received: by mail-wm0-x22a.google.com with SMTP id g62so229017403wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 07:49:53 -0800 (PST)
Date: Tue, 23 Feb 2016 18:49:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: THP race?
Message-ID: <20160223154950.GA22449@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org

Hi Andrea,

I suspect there's race with THP in __handle_mm_fault(). It's pure
theoretical and race window is small, but..

Consider following scenario:

  - THP got allocated by other thread just before "pmd_none() &&
    __pte_alloc()" check, so pmd_none() is false and we don't
    allocate the page table.

  - But before pmd_trans_huge() check the page got unmap by
    MADV_DONTNEED in other thread.

  - At this point we will call pte_offset_map() for pmd which is
    pmd_none().

Nothing pleasant would happen after this...

Do you see anything what would prevent this scenario?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

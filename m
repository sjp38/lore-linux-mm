Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 91D9A6B0009
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 05:32:57 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id g62so64286952wme.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 02:32:57 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id p3si15155331wjb.157.2016.02.26.02.32.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 02:32:56 -0800 (PST)
Received: by mail-wm0-x22e.google.com with SMTP id g62so66886532wme.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 02:32:56 -0800 (PST)
Date: Fri, 26 Feb 2016 13:32:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/1] mm: thp: Redefine default THP defrag behaviour
 disable it by default
Message-ID: <20160226103253.GA22450@node.shutemov.name>
References: <1456420339-29709-1-git-send-email-mgorman@techsingularity.net>
 <20160225190144.GE1180@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160225190144.GE1180@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Feb 25, 2016 at 08:01:44PM +0100, Andrea Arcangeli wrote:
> Another problem is that khugepaged isn't able to collapse shared
> readonly anon pages, mostly because of the rmap complexities.  I agree
> with Kirill we should be looking into how make this work, although I
> doubt the simpler refcounting is going to help much in this regard as
> the problem is in dealing with rmap, not so much with refcounts.

Could you elaborate on problems with rmap? I have looked into this deeply
yet.

Do you see anything what would prevent following basic scheme:

 - Identify series of small pages as candidate for collapsing into
   a compound page. Not sure how difficult it would be. I guess it can be
   done by looking for adjacent pages which belong to the same anon_vma.

 - Setup migration entries for pte which maps these pages.

 - Collapse small pages into compound page. IIUC, it only will be possible
   if these pages are not pinned.

 - Replace migration entries with ptes which point to subpages of the new
   compound page.

 - Scan over all vmas mapping this compound page, looking for VMA suitable
   for huge page. We cannot collapse it right away due lock inversion of
   anon_vma->rwsem vs. mmap_sem.

 - For found VMAs, collapse page table into PMD one VMA a time under
   down_write(mmap_sem).

Even if would fail to create any PMDs, we would reduce LRU pressure by
collapsing small pages into compound one.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

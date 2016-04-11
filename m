Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id BF97A6B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 06:35:11 -0400 (EDT)
Received: by mail-wm0-f48.google.com with SMTP id a140so6885106wma.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 03:35:11 -0700 (PDT)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id p77si17658375wmd.43.2016.04.11.03.35.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 03:35:10 -0700 (PDT)
Received: by mail-wm0-x22c.google.com with SMTP id v188so80421191wme.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 03:35:10 -0700 (PDT)
Date: Mon, 11 Apr 2016 13:35:08 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 09/10] huge pagecache: mmap_sem is unlocked when
 truncation splits pmd
Message-ID: <20160411103508.GC22996@node.shutemov.name>
References: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
 <alpine.LSU.2.11.1604051352540.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1604051352540.5965@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Matthew Wilcox <willy@linux.intel.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Apr 05, 2016 at 01:55:23PM -0700, Hugh Dickins wrote:
> zap_pmd_range()'s CONFIG_DEBUG_VM !rwsem_is_locked(&mmap_sem) BUG()
> will be invalid with huge pagecache, in whatever way it is implemented:
> truncation of a hugely-mapped file to an unhugely-aligned size would
> easily hit it.
> 
> (Although anon THP could in principle apply khugepaged to private file
> mappings, which are not excluded by the MADV_HUGEPAGE restrictions, in
> practice there's a vm_ops check which excludes them, so it never hits
> this BUG() - there's no interface to "truncate" an anonymous mapping.)
> 
> We could complicate the test, to check i_mmap_rwsem also when there's a
> vm_file; but my inclination was to make zap_pmd_range() more readable by
> simply deleting this check.  A search has shown no report of the issue in
> the years since commit e0897d75f0b2 ("mm, thp: print useful information
> when mmap_sem is unlocked in zap_pmd_range") expanded it from VM_BUG_ON()
> - though I cannot point to what commit I would say then fixed the issue.
> 
> But there are a couple of other patches now floating around, neither
> yet in the tree: let's agree to retain the check as a VM_BUG_ON_VMA(),
> as Matthew Wilcox has done; but subject to a vma_is_anonymous() check,
> as Kirill Shutemov has done.  And let's get this in, without waiting
> for any particular huge pagecache implementation to reach the tree.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

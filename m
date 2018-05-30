Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B91E06B0005
	for <linux-mm@kvack.org>; Wed, 30 May 2018 06:27:55 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e3-v6so10687732pfe.15
        for <linux-mm@kvack.org>; Wed, 30 May 2018 03:27:55 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id x14-v6si8510410pll.37.2018.05.30.03.27.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 03:27:54 -0700 (PDT)
Date: Wed, 30 May 2018 13:27:50 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] mm/huge_memory.c: __split_huge_page() use atomic
 ClearPageDirty()
Message-ID: <20180530102750.6mmlmypt35w4xaei@black.fi.intel.com>
References: <alpine.LSU.2.11.1805291841070.3197@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1805291841070.3197@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Nicholas Piggin <npiggin@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 01:50:22AM +0000, Hugh Dickins wrote:
> Swapping load on huge=always tmpfs (with khugepaged tuned up to be very
> eager, but I'm not sure that is relevant) soon hung uninterruptibly,
> waiting for page lock in shmem_getpage_gfp()'s find_lock_entry(), most
> often when "cp -a" was trying to write to a smallish file.  Debug showed
> that the page in question was not locked, and page->mapping NULL by now,
> but page->index consistent with having been in a huge page before.
> 
> Reproduced in minutes on a 4.15 kernel, even with 4.17's 605ca5ede764
> ("mm/huge_memory.c: reorder operations in __split_huge_page_tail()")
> added in; but took hours to reproduce on a 4.17 kernel (no idea why).
> 
> The culprit proved to be the __ClearPageDirty() on tails beyond i_size
> in __split_huge_page(): the non-atomic __bitoperation may have been safe
> when 4.8's baa355fd3314 ("thp: file pages support for split_huge_page()")
> introduced it, but liable to erase PageWaiters after 4.10's 62906027091f
> ("mm: add PageWaiters indicating tasks are waiting for a page bit").
> 
> Fixes: 62906027091f ("mm: add PageWaiters indicating tasks are waiting for a page bit")
> Signed-off-by: Hugh Dickins <hughd@google.com>

Thanks for catching this.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7DAAA6B0024
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 09:11:12 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id j100so8945748wrj.4
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 06:11:12 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d16sor2743069edn.44.2018.02.12.06.11.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Feb 2018 06:11:11 -0800 (PST)
Date: Mon, 12 Feb 2018 17:11:09 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 2/2] mm/huge_memory.c: reorder operations in
 __split_huge_page_tail()
Message-ID: <20180212141109.2lowammpogi3wtvt@node.shutemov.name>
References: <4f64569f-b8ce-54f8-33d9-0e67216bb54c@yandex-team.ru>
 <151844393341.210639.13162088407980624477.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151844393341.210639.13162088407980624477.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>

On Mon, Feb 12, 2018 at 04:58:53PM +0300, Konstantin Khlebnikov wrote:
> THP split makes non-atomic change of tail page flags. This is almost ok
> because tail pages are locked and isolated but this breaks recent changes
> in page locking: non-atomic operation could clear bit PG_waiters.
> 
> As a result concurrent sequence get_page_unless_zero() -> lock_page()
> might block forever. Especially if this page was truncated later.
> 
> Fix is trivial: clone flags before unfreezing page reference counter.
> 
> This race exists since commit 62906027091f ("mm: add PageWaiters indicating
> tasks are waiting for a page bit") while unsave unfreeze itself was added
> in commit 8df651c7059e ("thp: cleanup split_huge_page()").
> 
> clear_compound_head() also must be called before unfreezing page reference
> because after successful get_page_unless_zero() might follow put_page()
> which needs correct compound_head().
> 
> And replace page_ref_inc()/page_ref_add() with page_ref_unfreeze() which
> is made especially for that and has semantic of smp_store_release().
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

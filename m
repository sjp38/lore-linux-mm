Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3296B0009
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 06:07:54 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id o20so7348886wro.3
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 03:07:54 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f55sor2956924ede.35.2018.02.11.03.07.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Feb 2018 03:07:53 -0800 (PST)
Date: Sun, 11 Feb 2018 14:07:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/huge_memory.c: split should clone page flags before
 unfreezing pageref
Message-ID: <20180211110751.tsseper2356aptbe@node.shutemov.name>
References: <151834531706.176342.14968581451762734122.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151834531706.176342.14968581451762734122.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>

On Sun, Feb 11, 2018 at 01:35:17PM +0300, Konstantin Khlebnikov wrote:
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

Hm. Don't we have to have barrier between setting flags and updating
the refcounter in this case? Atomics don't generally have this semantics,
so you can see new refcount before new flags even after the change.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

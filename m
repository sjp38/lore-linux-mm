Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0566B0253
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 08:05:56 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so11928256wmr.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 05:05:56 -0700 (PDT)
Received: from mail-lf0-x235.google.com (mail-lf0-x235.google.com. [2a00:1450:4010:c07::235])
        by mx.google.com with ESMTPS id e88si1871797lfi.291.2016.07.12.05.05.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 05:05:54 -0700 (PDT)
Received: by mail-lf0-x235.google.com with SMTP id f93so11293797lfi.2
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 05:05:54 -0700 (PDT)
Date: Tue, 12 Jul 2016 15:05:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: thp: refix false positive BUG in
 page_move_anon_rmap()
Message-ID: <20160712120551.GB18041@node>
References: <alpine.LSU.2.11.1607120444540.12528@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1607120444540.12528@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mika Westerberg <mika.westerberg@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>

On Tue, Jul 12, 2016 at 04:51:20AM -0700, Hugh Dickins wrote:
> The VM_BUG_ON_PAGE in page_move_anon_rmap() is more trouble than it's
> worth: the syzkaller fuzzer hit it again.  It's still wrong for some
> THP cases, because linear_page_index() was never intended to apply to
> addresses before the start of a vma.
> 
> That's easily fixed with a signed long cast inside linear_page_index();
> and Dmitry has tested such a patch, to verify the false positive.  But
> why extend linear_page_index() just for this case? when the avoidance
> in page_move_anon_rmap() has already grown ugly, and there's no reason
> for the check at all (nothing else there is using address or index).
> 
> Remove address arg from page_move_anon_rmap(), remove VM_BUG_ON_PAGE,
> remove CONFIG_DEBUG_VM PageTransHuge adjustment.
> 
> And one more thing: should the compound_head(page) be done inside or
> outside page_move_anon_rmap()?  It's usually pushed down to the lowest
> level nowadays (and mm/memory.c shows no other explicit use of it),
> so I think it's better done in page_move_anon_rmap() than by caller.

I agree, that's reasonable.

> Fixes: 0798d3c022dc ("mm: thp: avoid false positive VM_BUG_ON_PAGE in page_move_anon_rmap()")
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Mika Westerberg <mika.westerberg@linux.intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: stable@vger.kernel.org # 4.5+

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

> ---
> Of course, we could just do a patch that deletes the VM_BUG_ON_PAGE
> (and CONFIG_DEBUG_VM PageTransHuge adjustment) for now, and the cleanup
> afterwards - but this doesn't affect a widely used interface, or go back
> many stable releases, so personally I prefer to do it all in one go.

+1.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

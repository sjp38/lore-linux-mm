Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id CFD486B000C
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 11:30:56 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i81-v6so20611356pfj.1
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 08:30:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k33-v6sor1966101pld.54.2018.10.15.08.30.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Oct 2018 08:30:55 -0700 (PDT)
Date: Mon, 15 Oct 2018 18:30:49 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/3] mm: thp: fix MADV_DONTNEED vs
 migrate_misplaced_transhuge_page race condition
Message-ID: <20181015153048.lh7ehzrqkj4sjrmo@kshutemo-mobl1>
References: <20181013002430.698-1-aarcange@redhat.com>
 <20181013002430.698-2-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181013002430.698-2-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Aaron Tomlin <atomlin@redhat.com>, Mel Gorman <mgorman@suse.de>, Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Oct 12, 2018 at 08:24:28PM -0400, Andrea Arcangeli wrote:
> This is a corollary of ced108037c2aa542b3ed8b7afd1576064ad1362a,
> 58ceeb6bec86d9140f9d91d71a710e963523d063,
> 5b7abeae3af8c08c577e599dd0578b9e3ee6687b.
> 
> When the above three fixes where posted Dave asked
> https://lkml.kernel.org/r/929b3844-aec2-0111-fef7-8002f9d4e2b9@intel.com
> but apparently this was missed.
> 
> The pmdp_clear_flush* in migrate_misplaced_transhuge_page was
> introduced in commit a54a407fbf7735fd8f7841375574f5d9b0375f93.
> 
> The important part of such commit is only the part where the page lock
> is not released until the first do_huge_pmd_numa_page() finished
> disarming the pagenuma/protnone.
> 
> The addition of pmdp_clear_flush() wasn't beneficial to such commit
> and there's no commentary about such an addition either.
> 
> I guess the pmdp_clear_flush() in such commit was added just in case for
> safety, but it ended up introducing the MADV_DONTNEED race condition
> found by Aaron.
> 
> At that point in time nobody thought of such kind of MADV_DONTNEED
> race conditions yet (they were fixed later) so the code may have
> looked more robust by adding the pmdp_clear_flush().
> 
> This specific race condition won't destabilize the kernel, but it can
> confuse userland because after MADV_DONTNEED the memory won't be
> zeroed out.
> 
> This also optimizes the code and removes a superflous TLB flush.
> 
> Reported-by: Aaron Tomlin <atomlin@redhat.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

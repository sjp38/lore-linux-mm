Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 70C9C6B0008
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 07:33:18 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id b23-v6so15156095pls.8
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 04:33:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t22-v6si10219023pgj.207.2018.10.15.04.33.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 04:33:17 -0700 (PDT)
Date: Mon, 15 Oct 2018 12:33:10 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/3] mm: thp: fix MADV_DONTNEED vs
 migrate_misplaced_transhuge_page race condition
Message-ID: <20181015113310.GF6931@suse.de>
References: <20181013002430.698-1-aarcange@redhat.com>
 <20181013002430.698-2-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181013002430.698-2-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Aaron Tomlin <atomlin@redhat.com>, Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

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

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

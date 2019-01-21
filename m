Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 42DEB8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 10:55:47 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id z6so21195571qtj.21
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 07:55:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z54si93606qtb.1.2019.01.21.07.55.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 07:55:46 -0800 (PST)
Date: Mon, 21 Jan 2019 10:55:36 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH RFC 03/24] mm: allow VM_FAULT_RETRY for multiple times
Message-ID: <20190121155536.GB3711@redhat.com>
References: <20190121075722.7945-1-peterx@redhat.com>
 <20190121075722.7945-4-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190121075722.7945-4-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>

On Mon, Jan 21, 2019 at 03:57:01PM +0800, Peter Xu wrote:
> The idea comes from a discussion between Linus and Andrea [1].
> 
> Before this patch we only allow a page fault to retry once.  We achieved
> this by clearing the FAULT_FLAG_ALLOW_RETRY flag when doing
> handle_mm_fault() the second time.  This was majorly used to avoid
> unexpected starvation of the system by looping over forever to handle
> the page fault on a single page.  However that should hardly happen, and
> after all for each code path to return a VM_FAULT_RETRY we'll first wait
> for a condition (during which time we should possibly yield the cpu) to
> happen before VM_FAULT_RETRY is really returned.
> 
> This patch removes the restriction by keeping the FAULT_FLAG_ALLOW_RETRY
> flag when we receive VM_FAULT_RETRY.  It means that the page fault
> handler now can retry the page fault for multiple times if necessary
> without the need to generate another page fault event. Meanwhile we
> still keep the FAULT_FLAG_TRIED flag so page fault handler can still
> identify whether a page fault is the first attempt or not.

So there is nothing protecting starvation after this patch ? AFAICT.
Do we sufficient proof that we never have a scenario where one process
might starve fault another ?

For instance some page locking could starve one process.


> 
> GUP code is not touched yet and will be covered in follow up patch.
> 
> This will be a nice enhancement for current code at the same time a
> supporting material for the future userfaultfd-writeprotect work since
> in that work there will always be an explicit userfault writeprotect
> retry for protected pages, and if that cannot resolve the page
> fault (e.g., when userfaultfd-writeprotect is used in conjunction with
> shared memory) then we'll possibly need a 3rd retry of the page fault.
> It might also benefit other potential users who will have similar
> requirement like userfault write-protection.
> 
> Please read the thread below for more information.
> 
> [1] https://lkml.org/lkml/2017/11/2/833
> 
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Peter Xu <peterx@redhat.com>
> ---

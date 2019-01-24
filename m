Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4C2EB8E0047
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 00:16:28 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id w18so5265227qts.8
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 21:16:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b42si5536653qvh.197.2019.01.23.21.16.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 21:16:27 -0800 (PST)
Date: Thu, 24 Jan 2019 13:16:16 +0800
From: Peter Xu <peterx@redhat.com>
Subject: Re: [PATCH RFC 10/24] userfaultfd: wp: add WP pagetable tracking to
 x86
Message-ID: <20190124051616.GE18231@xz-x1>
References: <20190121075722.7945-1-peterx@redhat.com>
 <20190121075722.7945-11-peterx@redhat.com>
 <20190121150937.GE3344@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190121150937.GE3344@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Mike Kravetz <mike.kravetz@oracle.com>, Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>

On Mon, Jan 21, 2019 at 10:09:38AM -0500, Jerome Glisse wrote:
> On Mon, Jan 21, 2019 at 03:57:08PM +0800, Peter Xu wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > Accurate userfaultfd WP tracking is possible by tracking exactly which
> > virtual memory ranges were writeprotected by userland. We can't relay
> > only on the RW bit of the mapped pagetable because that information is
> > destroyed by fork() or KSM or swap. If we were to relay on that, we'd
> > need to stay on the safe side and generate false positive wp faults
> > for every swapped out page.

(I'm trying to leave comments with my own understanding here; they
 might not be the original purposes when Andrea proposed the idea.
 Andrea, please feel free to chim in anytime especially if I am
 wrong... :-)

> 
> So you want to forward write fault (of a protected range) to user space
> only if page is not write protected because of fork(), KSM or swap.
> 
> This write protection feature is only for anonymous page right ? Other-
> wise how would you protect a share page (ie anyone can look it up and
> call page_mkwrite on it and start writting to it) ?

AFAIU we want to support shared memory too in the future.  One example
I can think of is current QEMU usage with DPDK: we have two processes
sharing the guest memory range.  So indeed this might not work if
there are unknown/malicious users of the shared memory, however in
many use cases the users are all known and AFAIU we should just write
protect all these users then we'll still get notified when any of them
write to a page.

> 
> So for anonymous page for fork() the mapcount will tell you if page is
> write protected for COW. For KSM it is easy check the page flag.

Yes I agree that KSM should be easy.  But for COW, please consider
when we write protect a page that was shared and RW removed due to
COW.  Then when we page fault on this page should we report to the
monitor?  IMHO we can't know if without a specific bit in the PTE.

> 
> For swap you can use the page lock to synchronize. A page that is
> write protected because of swap is write protected because it is being
> write to disk thus either under page lock, or with PageWriteback()
> returning true while write is on going.

For swap I think the major problem is when the page was swapped out of
main memory and then we write to the page (which was already a swap
entry now).  Then we'll first swap in the page into main memory again,
but then IMHO we will face the similar issue like COW above - we can't
judge whether this page was write protected by uffd-wp at all.  Of
course here we can detect the VMA flags and assuming it's write
protected if the UFFD_WP flag was set on the VMA flag, however we'll
also mark those pages which were not write protected at all hence
it'll generate false positives of write protection messages.  This
idea can apply too to above COW use case.  As a conclusion, in these
use cases we should not be able to identify explicitly on page
granularity write protection if without a specific _PAGE_UFFD_WP bit
in the PTE entries.

Thanks,

-- 
Peter Xu

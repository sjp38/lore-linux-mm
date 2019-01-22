Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 64E7D8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 11:53:18 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id z68so22717889qkb.14
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 08:53:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 99si1721626qta.389.2019.01.22.08.53.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 08:53:17 -0800 (PST)
Date: Tue, 22 Jan 2019 11:53:10 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH RFC 03/24] mm: allow VM_FAULT_RETRY for multiple times
Message-ID: <20190122165310.GB3188@redhat.com>
References: <20190121075722.7945-1-peterx@redhat.com>
 <20190121075722.7945-4-peterx@redhat.com>
 <20190121155536.GB3711@redhat.com>
 <20190122082238.GC14907@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190122082238.GC14907@xz-x1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>

On Tue, Jan 22, 2019 at 04:22:38PM +0800, Peter Xu wrote:
> On Mon, Jan 21, 2019 at 10:55:36AM -0500, Jerome Glisse wrote:
> > On Mon, Jan 21, 2019 at 03:57:01PM +0800, Peter Xu wrote:
> > > The idea comes from a discussion between Linus and Andrea [1].
> > > 
> > > Before this patch we only allow a page fault to retry once.  We achieved
> > > this by clearing the FAULT_FLAG_ALLOW_RETRY flag when doing
> > > handle_mm_fault() the second time.  This was majorly used to avoid
> > > unexpected starvation of the system by looping over forever to handle
> > > the page fault on a single page.  However that should hardly happen, and
> > > after all for each code path to return a VM_FAULT_RETRY we'll first wait
> > > for a condition (during which time we should possibly yield the cpu) to
> > > happen before VM_FAULT_RETRY is really returned.
> > > 
> > > This patch removes the restriction by keeping the FAULT_FLAG_ALLOW_RETRY
> > > flag when we receive VM_FAULT_RETRY.  It means that the page fault
> > > handler now can retry the page fault for multiple times if necessary
> > > without the need to generate another page fault event. Meanwhile we
> > > still keep the FAULT_FLAG_TRIED flag so page fault handler can still
> > > identify whether a page fault is the first attempt or not.
> > 
> > So there is nothing protecting starvation after this patch ? AFAICT.
> > Do we sufficient proof that we never have a scenario where one process
> > might starve fault another ?
> > 
> > For instance some page locking could starve one process.
> 
> Hi, Jerome,
> 
> Do you mean lock_page()?
> 
> AFAIU lock_page() will only yield the process itself until the lock is
> released, so IMHO it's not really starving the process but a natural
> behavior.  After all the process may not continue without handling the
> page fault correctly.
> 
> Or when you say "starvation" do you mean that we might return
> VM_FAULT_RETRY from handle_mm_fault() continuously so we'll looping
> over and over inside the page fault handler?

That one ie every time we retry someone else is holding the lock and
thus lock_page_or_retry() will continuously retry. Some process just
get unlucky ;)

With existing code because we remove the retry flag then on the second
try we end up waiting for the page lock while holding the mmap_sem so
we know that we are in line for the page lock and we will get it once
it is our turn.

Cheers,
Jérôme

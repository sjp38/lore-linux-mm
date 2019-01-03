Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C22A98E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 09:39:11 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id r13so28819175pgb.7
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 06:39:11 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t23si46574147pgi.181.2019.01.03.06.39.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 03 Jan 2019 06:39:10 -0800 (PST)
Date: Thu, 3 Jan 2019 06:39:08 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] Initialise mmu_notifier_range correctly
Message-ID: <20190103143908.GQ6310@bombadil.infradead.org>
References: <20190103002126.GM6310@bombadil.infradead.org>
 <20190103015654.GB15619@redhat.com>
 <785af237-eb67-c304-595d-9080a2f48102@nvidia.com>
 <20190103041833.GN6310@bombadil.infradead.org>
 <20190103142959.GA3395@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190103142959.GA3395@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: John Hubbard <jhubbard@nvidia.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, linux-kernel@vger.kernel.org, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Jan Kara <jack@suse.cz>

On Thu, Jan 03, 2019 at 09:29:59AM -0500, Jerome Glisse wrote:
> On Wed, Jan 02, 2019 at 08:18:33PM -0800, Matthew Wilcox wrote:
> > On Wed, Jan 02, 2019 at 07:32:08PM -0800, John Hubbard wrote:
> > > Having the range struct declared in separate places from the mmu_notifier_range_init()
> > > calls is not great. But I'm not sure I see a way to make it significantly cleaner, given
> > > that __follow_pte_pmd uses the range pointer as a way to decide to issue the mmn calls.
> > 
> > Yeah, I don't think there's anything we can do.  But I started reviewing
> > the comments, and they don't make sense together:
> > 
> >                 /*
> >                  * Note because we provide range to follow_pte_pmd it will
> >                  * call mmu_notifier_invalidate_range_start() on our behalf
> >                  * before taking any lock.
> >                  */
> >                 if (follow_pte_pmd(vma->vm_mm, address, &range,
> >                                    &ptep, &pmdp, &ptl))
> >                         continue;
> > 
> >                 /*
> >                  * No need to call mmu_notifier_invalidate_range() as we are
> >                  * downgrading page table protection not changing it to point
> >                  * to a new page.
> >                  *
> >                  * See Documentation/vm/mmu_notifier.rst
> >                  */
> > 
> > So if we don't call mmu_notifier_invalidate_range, why are we calling
> > mmu_notifier_invalidate_range_start and mmu_notifier_invalidate_range_end?
> > ie, why not this ...
> 
> Thus comments looks wrong to me ... we need to call
> mmu_notifier_invalidate_range() those are use by
> IOMMU. I might be to blame for those comments thought.

Yes, you're to blame for both of them.

a4d1a88525138 (J�r�me Glisse     2017-08-31 17:17:26 -0400  791)                 * Note because we provide start/end to follow_pte_pmd it will
a4d1a88525138 (J�r�me Glisse     2017-08-31 17:17:26 -0400  792)                 * call mmu_notifier_invalidate_range_start() on our behalf
a4d1a88525138 (J�r�me Glisse     2017-08-31 17:17:26 -0400  793)                 * before taking any lock.

0f10851ea475e (J�r�me Glisse     2017-11-15 17:34:07 -0800  794)                 * No need to call mmu_notifier_invalidate_range() as we are
0f10851ea475e (J�r�me Glisse     2017-11-15 17:34:07 -0800  795)                 * downgrading page table protection not changing it to point
0f10851ea475e (J�r�me Glisse     2017-11-15 17:34:07 -0800  796)                 * to a new page.

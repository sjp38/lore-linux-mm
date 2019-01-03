Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id B10068E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 09:59:56 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id n95so42014679qte.16
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 06:59:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y22si1106748qtc.39.2019.01.03.06.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 06:59:55 -0800 (PST)
Date: Thu, 3 Jan 2019 09:59:51 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] Initialise mmu_notifier_range correctly
Message-ID: <20190103145950.GE3395@redhat.com>
References: <20190103002126.GM6310@bombadil.infradead.org>
 <20190103015654.GB15619@redhat.com>
 <785af237-eb67-c304-595d-9080a2f48102@nvidia.com>
 <20190103041833.GN6310@bombadil.infradead.org>
 <20190103142959.GA3395@redhat.com>
 <20190103143908.GQ6310@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190103143908.GQ6310@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: John Hubbard <jhubbard@nvidia.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, linux-kernel@vger.kernel.org, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Jan Kara <jack@suse.cz>

On Thu, Jan 03, 2019 at 06:39:08AM -0800, Matthew Wilcox wrote:
> On Thu, Jan 03, 2019 at 09:29:59AM -0500, Jerome Glisse wrote:
> > On Wed, Jan 02, 2019 at 08:18:33PM -0800, Matthew Wilcox wrote:
> > > On Wed, Jan 02, 2019 at 07:32:08PM -0800, John Hubbard wrote:
> > > > Having the range struct declared in separate places from the mmu_notifier_range_init()
> > > > calls is not great. But I'm not sure I see a way to make it significantly cleaner, given
> > > > that __follow_pte_pmd uses the range pointer as a way to decide to issue the mmn calls.
> > > 
> > > Yeah, I don't think there's anything we can do.  But I started reviewing
> > > the comments, and they don't make sense together:
> > > 
> > >                 /*
> > >                  * Note because we provide range to follow_pte_pmd it will
> > >                  * call mmu_notifier_invalidate_range_start() on our behalf
> > >                  * before taking any lock.
> > >                  */
> > >                 if (follow_pte_pmd(vma->vm_mm, address, &range,
> > >                                    &ptep, &pmdp, &ptl))
> > >                         continue;
> > > 
> > >                 /*
> > >                  * No need to call mmu_notifier_invalidate_range() as we are
> > >                  * downgrading page table protection not changing it to point
> > >                  * to a new page.
> > >                  *
> > >                  * See Documentation/vm/mmu_notifier.rst
> > >                  */
> > > 
> > > So if we don't call mmu_notifier_invalidate_range, why are we calling
> > > mmu_notifier_invalidate_range_start and mmu_notifier_invalidate_range_end?
> > > ie, why not this ...
> > 
> > Thus comments looks wrong to me ... we need to call
> > mmu_notifier_invalidate_range() those are use by
> > IOMMU. I might be to blame for those comments thought.
> 
> Yes, you're to blame for both of them.
> 
> a4d1a88525138 (J�r�me Glisse     2017-08-31 17:17:26 -0400  791)                 * Note because we provide start/end to follow_pte_pmd it will
> a4d1a88525138 (J�r�me Glisse     2017-08-31 17:17:26 -0400  792)                 * call mmu_notifier_invalidate_range_start() on our behalf
> a4d1a88525138 (J�r�me Glisse     2017-08-31 17:17:26 -0400  793)                 * before taking any lock.
> 
> 0f10851ea475e (J�r�me Glisse     2017-11-15 17:34:07 -0800  794)                 * No need to call mmu_notifier_invalidate_range() as we are
> 0f10851ea475e (J�r�me Glisse     2017-11-15 17:34:07 -0800  795)                 * downgrading page table protection not changing it to point
> 0f10851ea475e (J�r�me Glisse     2017-11-15 17:34:07 -0800  796)                 * to a new page.
> 

I remember now we do not need to call invalidate range because
invalidate_range_end() does call invalidate_range so it is fine.
Comments should be better thought. So existing code is fine.

Cheers,
J�r�me

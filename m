Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id CB2666B00B1
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 11:18:34 -0400 (EDT)
Received: by mail-qc0-f173.google.com with SMTP id r5so358214qcx.4
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 08:18:34 -0700 (PDT)
Received: from mail-qa0-x22c.google.com (mail-qa0-x22c.google.com [2607:f8b0:400d:c00::22c])
        by mx.google.com with ESMTPS id 72si914312qga.168.2014.04.02.08.18.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 08:18:34 -0700 (PDT)
Received: by mail-qa0-f44.google.com with SMTP id dc16so319856qab.3
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 08:18:33 -0700 (PDT)
Date: Wed, 2 Apr 2014 11:18:27 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH] mm/mmu_notifier: restore set_pte_at_notify semantics
Message-ID: <20140402151825.GA3614@gmail.com>
References: <1389778834-21200-1-git-send-email-mike.rapoport@ravellosystems.com>
 <20140122131046.GF14193@redhat.com>
 <52DFCF2B.1010603@mellanox.com>
 <20140330203328.GA4859@gmail.com>
 <533C081D.9050202@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <533C081D.9050202@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haggai Eran <haggaie@mellanox.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mike Rapoport <mike.rapoport@ravellosystems.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Izik Eidus <izik.eidus@ravellosystems.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>

On Wed, Apr 02, 2014 at 03:52:45PM +0300, Haggai Eran wrote:
> On 03/30/2014 11:33 PM, Jerome Glisse wrote:
> >On Wed, Jan 22, 2014 at 04:01:15PM +0200, Haggai Eran wrote:
> >>I'm worried about the following scenario:
> >>
> >>Given a read-only page, suppose one host thread (thread 1) writes to
> >>that page, and performs COW, but before it calls the
> >>mmu_notifier_invalidate_page_if_missing_change_pte function another host
> >>thread (thread 2) writes to the same page (this time without a page
> >>fault). Then we have a valid entry in the secondary page table to a
> >>stale page, and someone (thread 3) may read stale data from there.
> >>
> >>Here's a diagram that shows this scenario:
> >>
> >>Thread 1                                | Thread 2        | Thread 3
> >>========================================================================
> >>do_wp_page(page 1)                      |                 |
> >>   ...                                   |                 |
> >>   set_pte_at_notify                     |                 |
> >>   ...                                   | write to page 1 |
> >>                                         |                 | stale access
> >>   pte_unmap_unlock                      |                 |
> >>   invalidate_page_if_missing_change_pte |                 |
> >>
> >>This is currently prevented by the use of the range start and range end
> >>notifiers.
> >>
> >>Do you agree that this scenario is possible with the new patch, or am I
> >>missing something?
> >>
> >I believe you are right, but of all the upstream user of the mmu_notifier
> >API only xen would suffer from this ie any user that do not have a proper
> >change_pte callback can see the bogus scenario you describe above.
> Yes. I sent our RDMA paging RFC patch-set on linux-rdma [1] last
> month, and it would also suffer from this scenario, but it's not
> upstream yet.
> >The issue i see is with user that want to/or might sleep when they are
> >invalidation the secondary page table. The issue being that change_pte is
> >call with the cpu page table locked (well at least for the affected pmd).
> >
> >I would rather keep the invalidate_range_start/end bracket around change_pte
> >and invalidate page. I think we can fix the kvm regression by other means.
> Perhaps another possibility would be to do the
> invalidate_range_start/end bracket only when the mmu_notifier is
> missing a change_pte implementation.

This would imply either to scan all mmu_notifier currently register or to
have a global flags for the mm to know if there is one mmu_notifier without
change_pte. Moreover this would means that kvm would remain "broken" if one
of the mmu notifier do not have the change_pte callback.

Solution i have in mind and is part of a patchset i am working on, just
involve passing along an enum value to mmu notifier callback. The enum
value would tell what are the exact event that actually triggered the
mmu notifier call (vmscan, migrate, ksm, ...). Knowing this kvm could then
simply ignore invalidate_range_start/end for event it knows it will get
a change_pte callback.

Cheers,
Jerome

> 
> Best regards,
> Haggai
> 
> [1] http://www.spinics.net/lists/linux-rdma/msg18906.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

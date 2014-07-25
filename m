Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 28E426B0035
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 16:16:42 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so6718651pab.29
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 13:16:41 -0700 (PDT)
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
        by mx.google.com with ESMTPS id uk2si3640177pbc.200.2014.07.25.13.16.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Jul 2014 13:16:41 -0700 (PDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so6666936pab.12
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 13:16:40 -0700 (PDT)
Date: Fri, 25 Jul 2014 13:16:39 -0700
From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH 1/3] mmu_notifier: Add mmu_notifier_invalidate_range()
Message-ID: <20140725131639.698f18ff@jbarnes-desktop>
In-Reply-To: <1406212541-25975-2-git-send-email-joro@8bytes.org>
References: <1406212541-25975-1-git-send-email-joro@8bytes.org>
	<1406212541-25975-2-git-send-email-joro@8bytes.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Jerome Glisse <jglisse@redhat.com>, jroedel@suse.de, Jay.Cornwall@amd.com, Oded.Gabbay@amd.com, John.Bridgman@amd.com, Suravee.Suthikulpanit@amd.com, ben.sander@amd.com, David Woodhouse <dwmw2@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org

On Thu, 24 Jul 2014 16:35:39 +0200
Joerg Roedel <joro@8bytes.org> wrote:

> From: Joerg Roedel <jroedel@suse.de>
> 
> This notifier closes an important gap with the current
> invalidate_range_start()/end() notifiers. The _start() part
> is called when all pages are still mapped while the _end()
> notifier is called when all pages are potentially unmapped
> and already freed.
> 
> This does not allow to manage external (non-CPU) hardware
> TLBs with MMU-notifiers because there is no way to prevent
> that hardware will establish new TLB entries between the
> calls of these two functions. But this is a requirement to
> the subsytem that implements these existing notifiers.
> 
> To allow managing external TLBs the MMU-notifiers need to
> catch the moment when pages are unmapped but not yet freed.
> This new notifier catches that moment and notifies the
> interested subsytem when pages that were unmapped are about
> to be freed. The new notifier will only be called between
> invalidate_range_start()/end().

So if we were actually sharing page tables, we should be able to make
start/end no-ops and just use this new callback, assuming we didn't
need to do any other serialization or debug stuff, right?

Seems like a good addition, and saves us a bunch of trouble...

Thanks,
-- 
Jesse Barnes, Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2BB6B0035
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 17:57:20 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so4767509wgh.15
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 14:57:20 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTP id c9si20429155wja.128.2014.07.25.14.57.19
        for <linux-mm@kvack.org>;
        Fri, 25 Jul 2014 14:57:19 -0700 (PDT)
Date: Fri, 25 Jul 2014 23:57:18 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 1/3] mmu_notifier: Add mmu_notifier_invalidate_range()
Message-ID: <20140725215718.GO14017@8bytes.org>
References: <1406212541-25975-1-git-send-email-joro@8bytes.org>
 <1406212541-25975-2-git-send-email-joro@8bytes.org>
 <20140725131639.698f18ff@jbarnes-desktop>
 <20140725213806.GN14017@8bytes.org>
 <20140725144213.773474e4@jbarnes-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140725144213.773474e4@jbarnes-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Jerome Glisse <jglisse@redhat.com>, jroedel@suse.de, Jay.Cornwall@amd.com, Oded.Gabbay@amd.com, John.Bridgman@amd.com, Suravee.Suthikulpanit@amd.com, ben.sander@amd.com, David Woodhouse <dwmw2@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org

On Fri, Jul 25, 2014 at 02:42:13PM -0700, Jesse Barnes wrote:
> On Fri, 25 Jul 2014 23:38:06 +0200
> Joerg Roedel <joro@8bytes.org> wrote:
> > I though about removing the need for invalidate_range_end too when
> > writing the patches, and possible solutions are
> > 
> > 	1) Add mmu_notifier_invalidate_range() to all places where
> > 	   start/end is called too. This might add some unnecessary
> > 	   overhead.
> > 
> > 	2) Call the invalidate_range() call-back from the
> > 	   mmu_notifier_invalidate_range_end too.
> > 
> > 	3) Just let the user register the same function for
> > 	   invalidate_range and invalidate_range_end
> > 
> > I though that option 1) adds overhead that is not needed (but it might
> > not be too bad, the overhead is an additional iteration over the
> > mmu_notifer list when there are no call-backs registered).
> > 
> > Option 2) might also be overhead if a user registers different functions
> > for invalidate_range() and invalidate_range_end(). In the end I came to
> > the conclusion that option 3) is the best one from an overhead POV.
> > 
> > But probably targeting better usability with one of the other options is
> > a better choice? I am open for thoughts and suggestions on that.
> 
> Making the _end callback just do another TLB flush is fine too, but it
> would be nice to have the consistency of (1).  I can live with either
> though, as long as the callbacks are well documented.

You are right, having this consistency would be good. The more I think
about it, the more it makes sense to go with option 2). Option 1) would
mean that invalidate_range is explicitly called right before
invalidate_range_end at some places. Doing this implicitly like in
option 2) is cleaner and less error-prone. And the list of mmu_notifiers
needs only be traversed once in invalidate_range_end(), so additional
overhead is minimal. I'll update patch 3 for this, unless there are
other opinions.


	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

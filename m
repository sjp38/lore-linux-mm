Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE1C6B003B
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 15:28:45 -0400 (EDT)
Received: by mail-qc0-f171.google.com with SMTP id x3so1459646qcv.16
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 12:28:45 -0700 (PDT)
Received: from mail-qc0-x22d.google.com (mail-qc0-x22d.google.com [2607:f8b0:400d:c01::22d])
        by mx.google.com with ESMTPS id g69si6936271qgg.113.2014.09.12.12.28.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 12:28:44 -0700 (PDT)
Received: by mail-qc0-f173.google.com with SMTP id i8so991471qcq.32
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 12:28:43 -0700 (PDT)
Date: Fri, 12 Sep 2014 15:28:37 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 0/3 v3] mmu_notifier: Allow to manage CPU external TLBs
Message-ID: <20140912192837.GC5196@gmail.com>
References: <1410277434-3087-1-git-send-email-joro@8bytes.org>
 <20140910150125.31a7495c7d0fe814b85fd514@linux-foundation.org>
 <20140912184739.GF2519@suse.de>
 <20140912121937.ebb3010d52abd4196e9341de@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140912121937.ebb3010d52abd4196e9341de@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joerg Roedel <jroedel@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Jay.Cornwall@amd.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, John.Bridgman@amd.com, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, ben.sander@amd.com, linux-mm@kvack.org, Jerome Glisse <jglisse@redhat.com>, iommu@lists.linux-foundation.org, Jesse Barnes <jbarnes@virtuousgeek.org>, Mel Gorman <mgorman@suse.de>, David Woodhouse <dwmw2@infradead.org>, Johannes Weiner <jweiner@redhat.com>

On Fri, Sep 12, 2014 at 12:19:37PM -0700, Andrew Morton wrote:
> On Fri, 12 Sep 2014 20:47:39 +0200 Joerg Roedel <jroedel@suse.de> wrote:
> 
> > thanks for your review, I tried to answer your questions below.
> 
> You'd be amazed how helpful that was ;)
> 
> > Fair enough, I hope I clarified a few things with my explanations
> > above. I will also update the description of the patch-set when I
> > re-send.
> 
> Sounds good, thanks.
> 
> 
> How does HMM play into all of this?  Would HMM make this patchset
> obsolete, or could HMM be evolved to do so?  

HMM should be consider as distinc from this. The hardware TLB we are talking
with this patchset can be flush by the CPU from inside an atomic context (ie
while holding cpu page table spinlock for instance).

HMM on the other hand deals with hardware that have there own page table
ie they do not necessarily walk the cpu page table. Flushing the TLB for this
kind of hardware means scheduling some job on the hardware and this can not
be done from kernel atomic context as this job might take a long time to
complete (imagine preempting thousand of threads on a gpu).

Still HMM can be use in a mixed environement where the IOMMUv2 is use for
memory that reside into system ram while HMM only handle memory that have
been migrated to the device memory.

So while HMM intend to provide more features than IOMMUv2 hardware allow,
it does not intend to replace it. On contrary hope is that both can work at
same time.

Cheers,
Jerome

> _______________________________________________
> iommu mailing list
> iommu@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/iommu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

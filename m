Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5C774280400
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 03:34:11 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k20so1975810wre.6
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 00:34:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t14si1800764wrg.91.2017.09.06.00.34.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Sep 2017 00:34:09 -0700 (PDT)
Date: Wed, 6 Sep 2017 08:34:07 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC] mm/tlbbatch: Introduce arch_tlbbatch_should_defer()
Message-ID: <20170906073407.a5bqmfx5xx553euj@suse.de>
References: <20170905144540.3365-1-khandual@linux.vnet.ibm.com>
 <20170905155000.gasnjvor4slvgkst@suse.de>
 <c5e4e0ad-131a-8002-859c-1251096687f7@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <c5e4e0ad-131a-8002-859c-1251096687f7@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Wed, Sep 06, 2017 at 09:23:49AM +0530, Anshuman Khandual wrote:
> On 09/05/2017 09:20 PM, Mel Gorman wrote:
> > On Tue, Sep 05, 2017 at 08:15:40PM +0530, Anshuman Khandual wrote:
> >> The entire scheme of deferred TLB flush in reclaim path rests on the
> >> fact that the cost to refill TLB entries is less than flushing out
> >> individual entries by sending IPI to remote CPUs. But architecture
> >> can have different ways to evaluate that. Hence apart from checking
> >> TTU_BATCH_FLUSH in the TTU flags, rest of the decision should be
> >> architecture specific.
> >>
> >> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> > 
> > There is only one arch implementation given and if an arch knows that
> > the flush should not be deferred then why would it implement support in
> > the first place? I'm struggling to see the point of the patch.
> 
> Even if the arch supports deferring of TLB flush like in the existing
> case, it still checks if mm_cpumask(mm) contains anything other than
> the current CPU (which indicates need for an IPI for a TLB flush) to
> decide whether the TLB batch flush should be deferred or not. The
> point is some architectures might do something different for a given
> struct mm other than checking for presence of remote CPU in the mask
> mm_cpumask(mm). It might be specific to the situation, struct mm etc.
> Hence arch callback should be used instead.
> 

If that turns out to be the case then the arch can create the hook at the
same time. RIght now, this is churn.


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

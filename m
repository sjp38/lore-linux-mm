Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id E91AE6B0069
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 08:29:31 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id l18so10748078wgh.17
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 05:29:31 -0700 (PDT)
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id m19si1998891wie.16.2014.10.14.05.29.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Oct 2014 05:29:30 -0700 (PDT)
Received: by mail-wg0-f50.google.com with SMTP id a1so10557095wgh.21
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 05:29:30 -0700 (PDT)
Date: Tue, 14 Oct 2014 13:29:23 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATCH 1/2] mm: Introduce a general RCU get_user_pages_fast.
Message-ID: <20141014122922.GA763@linaro.org>
References: <1413284274-13521-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20141014115854.GA32351@linaro.org>
 <8738aqonuc.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8738aqonuc.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Oct 14, 2014 at 05:38:43PM +0530, Aneesh Kumar K.V wrote:
> Steve Capper <steve.capper@linaro.org> writes:
> 
> > On Tue, Oct 14, 2014 at 04:27:53PM +0530, Aneesh Kumar K.V wrote:
> >> get_user_pages_fast attempts to pin user pages by walking the page
> >> tables directly and avoids taking locks. Thus the walker needs to be
> >> protected from page table pages being freed from under it, and needs
> >> to block any THP splits.
> >> 
> >> One way to achieve this is to have the walker disable interrupts, and
> >> rely on IPIs from the TLB flushing code blocking before the page table
> >> pages are freed.
> >> 
> >> On some platforms we have hardware broadcast of TLB invalidations, thus
> >> the TLB flushing code doesn't necessarily need to broadcast IPIs; and
> >> spuriously broadcasting IPIs can hurt system performance if done too
> >> often.
> >> 
> >> This problem has been solved on PowerPC and Sparc by batching up page
> >> table pages belonging to more than one mm_user, then scheduling an
> >> rcu_sched callback to free the pages. This RCU page table free logic
> >> has been promoted to core code and is activated when one enables
> >> HAVE_RCU_TABLE_FREE. Unfortunately, these architectures implement
> >> their own get_user_pages_fast routines.
> >> 
> >> The RCU page table free logic coupled with a an IPI broadcast on THP
> >> split (which is a rare event), allows one to protect a page table
> >> walker by merely disabling the interrupts during the walk.
> >> 
> >> This patch provides a general RCU implementation of get_user_pages_fast
> >> that can be used by architectures that perform hardware broadcast of
> >> TLB invalidations.
> >> 
> >> It is based heavily on the PowerPC implementation.
> >> 
> >> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> >> ---
> >> 
> >> NOTE: I kept the description of patch as it is and also retained the documentation.
> >> I also dropped the tested-by and other SOB, because i was not sure whether they want
> >> to be blamed for the bugs here. Please feel free to update.
> >
> > Hi Aneesh,
> > Thank you for coding this up.
> >
> > I've compiled and briefly tested this on arm (with and without LPAE),
> > and arm64. I ran a custom futex on THP tail test, and this passed.
> > I'll test this a little more aggressively with ltp.
> >
> > I think Linus has already pulled in the RCU gup I posted, could you
> > please instead write a patch against?
> 
> Will do that. 
> 
> > 2667f50 mm: introduce a general RCU get_user_pages_fast()
> 
> In that patch don't you need to check the _PAGE_PRESENT details in case
> of gup_huge_pmd ?
> 

Before calling gup_huge_pmd we check for pmd_none. On ARM we have:
#define pmd_none(pmd)		(!pmd_val(pmd))
#define pmd_present(pmd)	(pmd_val(pmd))

So we know when we enter gup_huge_pmd that "orig" represents a pmd that
is present.

On PowerPC I see the definitions are a little different for
pgtable-ppc32.h:
#define pmd_present(pmd)	(pmd_val(pmd) & _PMD_PRESENT_MASK)

A pmd_present() could be added to the beginning of gup_huge_pmd safely
if this is needed for PowerPC.

Cheers,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

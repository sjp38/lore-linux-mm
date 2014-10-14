Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id AE1F46B0069
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 07:59:03 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id l18so10783315wgh.5
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 04:59:03 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
        by mx.google.com with ESMTPS id bc1si15981474wib.32.2014.10.14.04.59.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Oct 2014 04:59:02 -0700 (PDT)
Received: by mail-wi0-f174.google.com with SMTP id h11so6472320wiw.7
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 04:59:01 -0700 (PDT)
Date: Tue, 14 Oct 2014 12:58:55 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATCH 1/2] mm: Introduce a general RCU get_user_pages_fast.
Message-ID: <20141014115854.GA32351@linaro.org>
References: <1413284274-13521-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413284274-13521-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Oct 14, 2014 at 04:27:53PM +0530, Aneesh Kumar K.V wrote:
> get_user_pages_fast attempts to pin user pages by walking the page
> tables directly and avoids taking locks. Thus the walker needs to be
> protected from page table pages being freed from under it, and needs
> to block any THP splits.
> 
> One way to achieve this is to have the walker disable interrupts, and
> rely on IPIs from the TLB flushing code blocking before the page table
> pages are freed.
> 
> On some platforms we have hardware broadcast of TLB invalidations, thus
> the TLB flushing code doesn't necessarily need to broadcast IPIs; and
> spuriously broadcasting IPIs can hurt system performance if done too
> often.
> 
> This problem has been solved on PowerPC and Sparc by batching up page
> table pages belonging to more than one mm_user, then scheduling an
> rcu_sched callback to free the pages. This RCU page table free logic
> has been promoted to core code and is activated when one enables
> HAVE_RCU_TABLE_FREE. Unfortunately, these architectures implement
> their own get_user_pages_fast routines.
> 
> The RCU page table free logic coupled with a an IPI broadcast on THP
> split (which is a rare event), allows one to protect a page table
> walker by merely disabling the interrupts during the walk.
> 
> This patch provides a general RCU implementation of get_user_pages_fast
> that can be used by architectures that perform hardware broadcast of
> TLB invalidations.
> 
> It is based heavily on the PowerPC implementation.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
> 
> NOTE: I kept the description of patch as it is and also retained the documentation.
> I also dropped the tested-by and other SOB, because i was not sure whether they want
> to be blamed for the bugs here. Please feel free to update.

Hi Aneesh,
Thank you for coding this up.

I've compiled and briefly tested this on arm (with and without LPAE),
and arm64. I ran a custom futex on THP tail test, and this passed.
I'll test this a little more aggressively with ltp.

I think Linus has already pulled in the RCU gup I posted, could you
please instead write a patch against?
2667f50 mm: introduce a general RCU get_user_pages_fast()

I had one issue compiling this, pgd_huge was undefined. I think this
is only defined for PowerPC? Could a stub definition of pgd_huge be
added?

Cheers,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

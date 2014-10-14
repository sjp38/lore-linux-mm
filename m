Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id B78226B0069
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 09:42:30 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id y10so7408217pdj.23
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 06:42:30 -0700 (PDT)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id mw6si12988392pdb.146.2014.10.14.06.42.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Oct 2014 06:42:29 -0700 (PDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 14 Oct 2014 23:42:24 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id DC66A2CE8040
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 00:42:20 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9EDNhjS26017828
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 00:23:44 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9EDgJnG025163
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 00:42:19 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] mm: Introduce a general RCU get_user_pages_fast.
In-Reply-To: <20141014122922.GA763@linaro.org>
References: <1413284274-13521-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20141014115854.GA32351@linaro.org> <8738aqonuc.fsf@linux.vnet.ibm.com> <20141014122922.GA763@linaro.org>
Date: Tue, 14 Oct 2014 19:12:15 +0530
Message-ID: <87zjcyn4y0.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Steve Capper <steve.capper@linaro.org> writes:

> On Tue, Oct 14, 2014 at 05:38:43PM +0530, Aneesh Kumar K.V wrote:
>> Steve Capper <steve.capper@linaro.org> writes:
>> 
>> > On Tue, Oct 14, 2014 at 04:27:53PM +0530, Aneesh Kumar K.V wrote:
>> >> get_user_pages_fast attempts to pin user pages by walking the page
>> >> tables directly and avoids taking locks. Thus the walker needs to be
>> >> protected from page table pages being freed from under it, and needs
>> >> to block any THP splits.
>> >> 
>> >> One way to achieve this is to have the walker disable interrupts, and
>> >> rely on IPIs from the TLB flushing code blocking before the page table
>> >> pages are freed.
>> >> 
>> >> On some platforms we have hardware broadcast of TLB invalidations, thus
>> >> the TLB flushing code doesn't necessarily need to broadcast IPIs; and
>> >> spuriously broadcasting IPIs can hurt system performance if done too
>> >> often.
>> >> 
>> >> This problem has been solved on PowerPC and Sparc by batching up page
>> >> table pages belonging to more than one mm_user, then scheduling an
>> >> rcu_sched callback to free the pages. This RCU page table free logic
>> >> has been promoted to core code and is activated when one enables
>> >> HAVE_RCU_TABLE_FREE. Unfortunately, these architectures implement
>> >> their own get_user_pages_fast routines.
>> >> 
>> >> The RCU page table free logic coupled with a an IPI broadcast on THP
>> >> split (which is a rare event), allows one to protect a page table
>> >> walker by merely disabling the interrupts during the walk.
>> >> 
>> >> This patch provides a general RCU implementation of get_user_pages_fast
>> >> that can be used by architectures that perform hardware broadcast of
>> >> TLB invalidations.
>> >> 
>> >> It is based heavily on the PowerPC implementation.
>> >> 
>> >> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> >> ---
>> >> 
>> >> NOTE: I kept the description of patch as it is and also retained the documentation.
>> >> I also dropped the tested-by and other SOB, because i was not sure whether they want
>> >> to be blamed for the bugs here. Please feel free to update.
>> >
>> > Hi Aneesh,
>> > Thank you for coding this up.
>> >
>> > I've compiled and briefly tested this on arm (with and without LPAE),
>> > and arm64. I ran a custom futex on THP tail test, and this passed.
>> > I'll test this a little more aggressively with ltp.
>> >
>> > I think Linus has already pulled in the RCU gup I posted, could you
>> > please instead write a patch against?
>> 
>> Will do that. 
>> 
>> > 2667f50 mm: introduce a general RCU get_user_pages_fast()
>> 
>> In that patch don't you need to check the _PAGE_PRESENT details in case
>> of gup_huge_pmd ?
>> 
>
> Before calling gup_huge_pmd we check for pmd_none. On ARM we have:
> #define pmd_none(pmd)		(!pmd_val(pmd))
> #define pmd_present(pmd)	(pmd_val(pmd))
>
> So we know when we enter gup_huge_pmd that "orig" represents a pmd that
> is present.
>
> On PowerPC I see the definitions are a little different for
> pgtable-ppc32.h:
> #define pmd_present(pmd)	(pmd_val(pmd) & _PMD_PRESENT_MASK)
>
> A pmd_present() could be added to the beginning of gup_huge_pmd safely
> if this is needed for PowerPC.
>

for the huge pmd case, that is pte in pmd we may really want to check
_PAGE_PRESENT bit right ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C142C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 16:38:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A28F21473
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 16:38:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A28F21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8B266B0005; Mon, 13 May 2019 12:38:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A39B16B0008; Mon, 13 May 2019 12:38:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9292E6B0010; Mon, 13 May 2019 12:38:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4420B6B0005
	for <linux-mm@kvack.org>; Mon, 13 May 2019 12:38:02 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i3so18794004edr.12
        for <linux-mm@kvack.org>; Mon, 13 May 2019 09:38:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=SMPgTik9tWqRCeyL6dNlO9ZQTxIwB41hxEOOmUM2dIA=;
        b=BXtzp6QeDtAbFbtTN/U6w/qkMOb14EkWhWX3I4aXBXGRe982IA3bQQP0PlK5iCmUJL
         SAFnIT85ojkEiJZB4J/CtxlizOFx9O2ct3llsHSOjMO9B4lQWVgmvCJiFfYLmyXjDrCT
         lTvXRZwaSyVk2EYWoHFu1cj97Im3ZL75NALEXoz5GHUt5AAvBr/SiDhz+NGgGvMTS6jy
         0iD1PUpNkj4h0Gso2Btc+/RAsDue7NSttrVTviI5cDHD6CtcKd/eILculYMSOfZEojut
         rUDLzbV5TnxzF6K27Olf0Gs/rwtQeRBBv37x58nzitv9msKb25+Xv4BujZKbZSd7JvVn
         j3Lg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: APjAAAWjvqYaPmwzzV6CeML/aSW3dZxXqolnCva86lk+NHVSk5YWjRYp
	+2dmiOFZwVOyNUwOsQXsXoIhQIvw6EwnqRf+FqYkupcxX0feSPSeiSXvx6Slsmw0NvTtvjoIov7
	SY2cGnypTLQlITLzH5nxdCmM1OHPcTybGgRcDXsds5Fs9PquvRbe2k0NDhTmJR7vH7w==
X-Received: by 2002:a17:906:2acf:: with SMTP id m15mr8343211eje.31.1557765481760;
        Mon, 13 May 2019 09:38:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyj4KF3WRfRGTXMJ24jTgYTPmXSjeSQZorcZJ4gZWXz6tK/vewzc43XQoqfwZlrbrk0Yytd
X-Received: by 2002:a17:906:2acf:: with SMTP id m15mr8343130eje.31.1557765480664;
        Mon, 13 May 2019 09:38:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557765480; cv=none;
        d=google.com; s=arc-20160816;
        b=hknniqnt/auywMUI0bDiURSADClXdK9AUso4tZuSI+qXgTrxUpPNfCIeBL+As4ELWe
         EpPeKPm1GjD0l7gXmatzuwTronUKln44NfBkS4cGv9f2/RMEM+OjuPNg2bdUvuDEWxHk
         W+90O7O5Im1E9vkx8tJJF1IveDdUr4MZuhIcvr/x+1NFj6qWyp8XH6QZBmdTiR5nx8xX
         hiLFxRWXtPXvLdBlV0L3f6u2vxMSYjJaCu5pZ7am/XP80LvOUqqvIEthSpNYaAEGuV8/
         1DAuVTOe7DPR36P9aWrEUsb81SBOAXUO/gskhEFyzcSmGPsesxI3D2hIjb052PWOw7KU
         5Vfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=SMPgTik9tWqRCeyL6dNlO9ZQTxIwB41hxEOOmUM2dIA=;
        b=vExAvPQmpd7yuUOSYmkzRnHW2seRnIWm23biGmvF5Qt3Vk67dPlj7J7/ONSqvysRjg
         sEy68kQbUjUQ2mHmWSBTvgsb3sBPl8YgFdB6i9J09OXPgSuTLRnj33gJ83QbGva92tKz
         eTqWvFIc2+1hffnVjRYdl99S9gNjoyg7Zf8sZfS+Cbywd9oJoPz/qdi+2/Bpguym17Mk
         rXdFaQMVjIxqwSVv6Z1Fo/OW5pkHSA3/534K2DCkqcsmBGYmLseosC9OnUqtxk0OKKa0
         mx610KQGrVbOd7eLBlUTqUK4JzOQm6V5bGvKoPMkkrO2rZlKQWqHrtsZW29UgW1khJdg
         1f+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q8si1756291eda.299.2019.05.13.09.38.00
        for <linux-mm@kvack.org>;
        Mon, 13 May 2019 09:38:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 65A81341;
	Mon, 13 May 2019 09:37:59 -0700 (PDT)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5067A3F71E;
	Mon, 13 May 2019 09:37:57 -0700 (PDT)
Date: Mon, 13 May 2019 17:37:52 +0100
From: Will Deacon <will.deacon@arm.com>
To: Nadav Amit <namit@vmware.com>
Cc: Peter Zijlstra <peterz@infradead.org>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	"jstancek@redhat.com" <jstancek@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
	Nick Piggin <npiggin@gmail.com>, Minchan Kim <minchan@kernel.org>,
	Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Message-ID: <20190513163752.GA10754@fuggles.cambridge.arm.com>
References: <1557264889-109594-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190509083726.GA2209@brain-police>
 <20190509103813.GP2589@hirez.programming.kicks-ass.net>
 <F22533A7-016F-4506-809A-7E86BAF24D5A@vmware.com>
 <20190509182435.GA2623@hirez.programming.kicks-ass.net>
 <04668E51-FD87-4D53-A066-5A35ABC3A0D6@vmware.com>
 <20190509191120.GD2623@hirez.programming.kicks-ass.net>
 <7DA60772-3EE3-4882-B26F-2A900690DA15@vmware.com>
 <20190513083606.GL2623@hirez.programming.kicks-ass.net>
 <75FD46B2-2E0C-41F2-9308-AB68C8780E33@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <75FD46B2-2E0C-41F2-9308-AB68C8780E33@vmware.com>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 09:11:38AM +0000, Nadav Amit wrote:
> > On May 13, 2019, at 1:36 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> > 
> > On Thu, May 09, 2019 at 09:21:35PM +0000, Nadav Amit wrote:
> > 
> >>>>> And we can fix that by having tlb_finish_mmu() sync up. Never let a
> >>>>> concurrent tlb_finish_mmu() complete until all concurrenct mmu_gathers
> >>>>> have completed.
> >>>>> 
> >>>>> This should not be too hard to make happen.
> >>>> 
> >>>> This synchronization sounds much more expensive than what I proposed. But I
> >>>> agree that cache-lines that move from one CPU to another might become an
> >>>> issue. But I think that the scheme I suggested would minimize this overhead.
> >>> 
> >>> Well, it would have a lot more unconditional atomic ops. My scheme only
> >>> waits when there is actual concurrency.
> >> 
> >> Well, something has to give. I didn’t think that if the same core does the
> >> atomic op it would be too expensive.
> > 
> > They're still at least 20 cycles a pop, uncontended.
> > 
> >>> I _think_ something like the below ought to work, but its not even been
> >>> near a compiler. The only problem is the unconditional wakeup; we can
> >>> play games to avoid that if we want to continue with this.
> >>> 
> >>> Ideally we'd only do this when there's been actual overlap, but I've not
> >>> found a sensible way to detect that.
> >>> 
> >>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> >>> index 4ef4bbe78a1d..b70e35792d29 100644
> >>> --- a/include/linux/mm_types.h
> >>> +++ b/include/linux/mm_types.h
> >>> @@ -590,7 +590,12 @@ static inline void dec_tlb_flush_pending(struct mm_struct *mm)
> >>> 	 *
> >>> 	 * Therefore we must rely on tlb_flush_*() to guarantee order.
> >>> 	 */
> >>> -	atomic_dec(&mm->tlb_flush_pending);
> >>> +	if (atomic_dec_and_test(&mm->tlb_flush_pending)) {
> >>> +		wake_up_var(&mm->tlb_flush_pending);
> >>> +	} else {
> >>> +		wait_event_var(&mm->tlb_flush_pending,
> >>> +			       !atomic_read_acquire(&mm->tlb_flush_pending));
> >>> +	}
> >>> }
> >> 
> >> It still seems very expensive to me, at least for certain workloads (e.g.,
> >> Apache with multithreaded MPM).
> > 
> > Is that Apache-MPM workload triggering this lots? Having a known
> > benchmark for this stuff is good for when someone has time to play with
> > things.
> 
> Setting Apache2 with mpm_worker causes every request to go through
> mmap-writev-munmap flow on every thread. I didn’t run this workload after
> the patches that downgrade the mmap_sem to read before the page-table
> zapping were introduced. I presume these patches would allow the page-table
> zapping to be done concurrently, and therefore would hit this flow.

Hmm, I don't think so: munmap() still has to take the semaphore for write
initially, so it will be serialised against other munmap() threads even
after they've downgraded afaict.

The initial bug report was about concurrent madvise() vs munmap().

Will


Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2BBCC04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 08:58:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A04B520862
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 08:58:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A04B520862
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1431E6B026D; Tue, 14 May 2019 04:58:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CDE16B026E; Tue, 14 May 2019 04:58:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED60B6B026F; Tue, 14 May 2019 04:58:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9D6166B026D
	for <linux-mm@kvack.org>; Tue, 14 May 2019 04:58:22 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l3so7945786edl.10
        for <linux-mm@kvack.org>; Tue, 14 May 2019 01:58:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3dzj8ryujYIVV80n1k8Gt8NgYZbMTLASDkaYohAI8uU=;
        b=m7MFRR5hVUh4jR96y2D9k1O5NWrj2GkcFWUB71ZIugMIigQNmRmevQPRckZPNE2tjr
         Hd1N+ozM6uDtHpdX8/ADNg6GtJwdG3Lhm9VAZnWEZ1bq6JQeqAjpXQm8SNwbYROQOUZO
         0DtiAIIiawrsCizm3dYxBoTuR6Tss9PHduQ5MovO3oogL62zm6XqMR4UGtFuvLsYZIBG
         p5AWdbI26pUGiqYgZdfr8l2uIFYWRtNIL1P/WNms6ZGEB9Dbxgp3/E+mT2oNs4wjfY2N
         8SOlPrNL9lfc6xvsEQFRlaITimNwXpUvyf5QRfXHac8CdWPlNc/uezE1lfyMg/gc+zRA
         7Kcg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAWd5222BQ1iTJYsWaNI519sE+TS9gqn+MkakVihpeJyiLJMAa2B
	Q/nheMMNRTq7WrYb7xNRfXyt02HpyAklO0BSUxYgOL/lQnctlcW5OZzRJRlNyLT0AheEb5kXW3V
	s/cEPvlQAoc8SQDuuBpTpyQk2stDfvAQXPZxNDgr4Qdzn2YalzFMGXr0yt+WXhLXLww==
X-Received: by 2002:aa7:ca4f:: with SMTP id j15mr34415453edt.276.1557824302101;
        Tue, 14 May 2019 01:58:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYSp2XmjqsQ+67Xin9qTnil5QHsbs/KesqdRoU/SNo4c7MZVcAInd/d3eU+OZ/VX/tCI09
X-Received: by 2002:aa7:ca4f:: with SMTP id j15mr34415377edt.276.1557824301122;
        Tue, 14 May 2019 01:58:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557824301; cv=none;
        d=google.com; s=arc-20160816;
        b=Xo7IQ0DryBQWWGGNMbq1GG5DMpgPPpVNyy+F6JXfZt8Tsd3nfnVVCt9tK52GhaYJwr
         eY7RUQPkEBm6Ki4H+Uuheakj4LR5g8Jbd+5oQT4yGD9NbJBik+i9fCsEwE2/wFw9fl6p
         pD19q0WoqD1ubAfWph4TQe0Y7raRvmpfmYDc8CC4y/YxxquP5EnmUFvu1vN2JNqgY7yG
         8FIjTAj8c5Z0DiBt7mLVZaKfBD/iyHiIzonO7zWyfe0r4WPg6AZAfeIgTGBfFFrq/c4j
         o8mW7BYf0gWaZb3usw/PhxCGFGROyMeas2ei02wqv7e88oF27To2wWI0UXqpjBjvdBj0
         7D4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3dzj8ryujYIVV80n1k8Gt8NgYZbMTLASDkaYohAI8uU=;
        b=JywTDSZI5V0vZSkUNb7Z65FTnsBReWAj+unSEb25OpYJvZeupMQ6MCNbhQ7zNc4qLM
         Uo2gBMNc+tyjjojbb370MyVw9Pco5/4wVNR8gPH1zM6adG0uUKXgIa07gRSfF0OSzqTJ
         d8KZ2/Oc8+K6AmTmMc14o8prgT54xcwZtlMV7j+1RPvwhiEC5dG2s21WnXhqgzQq3iU5
         5rR20yXXOYsZFwwUnZc3VNxAG3VOry1AasW8AMTcGS2nWZf/ghhL+SXQ0smZzfBSp9Y6
         HpXEy18k7qykUp1VBpNZwmAtTqnxBG0DcrGWosD3bGwEyAX+DJhNKaIHME+/UCr1RlK+
         rRCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q5si6647221edd.0.2019.05.14.01.58.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 01:58:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 68BF8AE1C;
	Tue, 14 May 2019 08:58:20 +0000 (UTC)
Date: Tue, 14 May 2019 09:58:16 +0100
From: Mel Gorman <mgorman@suse.de>
To: Nadav Amit <namit@vmware.com>
Cc: Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	"jstancek@redhat.com" <jstancek@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
	Nick Piggin <npiggin@gmail.com>, Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Message-ID: <20190514085816.GB23719@suse.de>
References: <20190509103813.GP2589@hirez.programming.kicks-ass.net>
 <F22533A7-016F-4506-809A-7E86BAF24D5A@vmware.com>
 <20190509182435.GA2623@hirez.programming.kicks-ass.net>
 <04668E51-FD87-4D53-A066-5A35ABC3A0D6@vmware.com>
 <20190509191120.GD2623@hirez.programming.kicks-ass.net>
 <7DA60772-3EE3-4882-B26F-2A900690DA15@vmware.com>
 <20190513083606.GL2623@hirez.programming.kicks-ass.net>
 <75FD46B2-2E0C-41F2-9308-AB68C8780E33@vmware.com>
 <20190513163752.GA10754@fuggles.cambridge.arm.com>
 <43638259-8EDB-4B8D-A93D-A2E86D8B2489@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <43638259-8EDB-4B8D-A93D-A2E86D8B2489@vmware.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 05:06:03PM +0000, Nadav Amit wrote:
> > On May 13, 2019, at 9:37 AM, Will Deacon <will.deacon@arm.com> wrote:
> > 
> > On Mon, May 13, 2019 at 09:11:38AM +0000, Nadav Amit wrote:
> >>> On May 13, 2019, at 1:36 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> >>> 
> >>> On Thu, May 09, 2019 at 09:21:35PM +0000, Nadav Amit wrote:
> >>> 
> >>>>>>> And we can fix that by having tlb_finish_mmu() sync up. Never let a
> >>>>>>> concurrent tlb_finish_mmu() complete until all concurrenct mmu_gathers
> >>>>>>> have completed.
> >>>>>>> 
> >>>>>>> This should not be too hard to make happen.
> >>>>>> 
> >>>>>> This synchronization sounds much more expensive than what I proposed. But I
> >>>>>> agree that cache-lines that move from one CPU to another might become an
> >>>>>> issue. But I think that the scheme I suggested would minimize this overhead.
> >>>>> 
> >>>>> Well, it would have a lot more unconditional atomic ops. My scheme only
> >>>>> waits when there is actual concurrency.
> >>>> 
> >>>> Well, something has to give. I didn???t think that if the same core does the
> >>>> atomic op it would be too expensive.
> >>> 
> >>> They're still at least 20 cycles a pop, uncontended.
> >>> 
> >>>>> I _think_ something like the below ought to work, but its not even been
> >>>>> near a compiler. The only problem is the unconditional wakeup; we can
> >>>>> play games to avoid that if we want to continue with this.
> >>>>> 
> >>>>> Ideally we'd only do this when there's been actual overlap, but I've not
> >>>>> found a sensible way to detect that.
> >>>>> 
> >>>>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> >>>>> index 4ef4bbe78a1d..b70e35792d29 100644
> >>>>> --- a/include/linux/mm_types.h
> >>>>> +++ b/include/linux/mm_types.h
> >>>>> @@ -590,7 +590,12 @@ static inline void dec_tlb_flush_pending(struct mm_struct *mm)
> >>>>> 	 *
> >>>>> 	 * Therefore we must rely on tlb_flush_*() to guarantee order.
> >>>>> 	 */
> >>>>> -	atomic_dec(&mm->tlb_flush_pending);
> >>>>> +	if (atomic_dec_and_test(&mm->tlb_flush_pending)) {
> >>>>> +		wake_up_var(&mm->tlb_flush_pending);
> >>>>> +	} else {
> >>>>> +		wait_event_var(&mm->tlb_flush_pending,
> >>>>> +			       !atomic_read_acquire(&mm->tlb_flush_pending));
> >>>>> +	}
> >>>>> }
> >>>> 
> >>>> It still seems very expensive to me, at least for certain workloads (e.g.,
> >>>> Apache with multithreaded MPM).
> >>> 
> >>> Is that Apache-MPM workload triggering this lots? Having a known
> >>> benchmark for this stuff is good for when someone has time to play with
> >>> things.
> >> 
> >> Setting Apache2 with mpm_worker causes every request to go through
> >> mmap-writev-munmap flow on every thread. I didn???t run this workload after
> >> the patches that downgrade the mmap_sem to read before the page-table
> >> zapping were introduced. I presume these patches would allow the page-table
> >> zapping to be done concurrently, and therefore would hit this flow.
> > 
> > Hmm, I don't think so: munmap() still has to take the semaphore for write
> > initially, so it will be serialised against other munmap() threads even
> > after they've downgraded afaict.
> > 
> > The initial bug report was about concurrent madvise() vs munmap().
> 
> I guess you are right (and I???m wrong).
> 
> Short search suggests that ebizzy might be affected (a thread by Mel
> Gorman): https://lkml.org/lkml/2015/2/2/493
> 

Glibc has since been fixed to be less munmap/mmap intensive and the
system CPU usage of ebizzy is generally negligible unless configured so
specifically use mmap/munmap instead of malloc/free which is unrealistic
for good application behaviour.

-- 
Mel Gorman
SUSE Labs


Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 926FEC04AB1
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 08:36:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44E2520989
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 08:36:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Z+A0uN9k"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44E2520989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2BC16B0010; Mon, 13 May 2019 04:36:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDB9F6B0266; Mon, 13 May 2019 04:36:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCA656B0269; Mon, 13 May 2019 04:36:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9CAEE6B0010
	for <linux-mm@kvack.org>; Mon, 13 May 2019 04:36:18 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id h189so9381615ioa.13
        for <linux-mm@kvack.org>; Mon, 13 May 2019 01:36:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=A/LTjUKq3u7qRwt9jLoPyIVtj9SXda11NSro60RTqLg=;
        b=n+YMafLVkyyZBqhsHmftMxZHkijReBkdQFmTR1wu7ODcj72m0kVYijPEScf2svu3Z9
         EMOtIXPYEgXw3QAbdvpBsUX6a6UyqSx+KJ3oAF/1FfH1GCEY+4yowt3hInzGnuBNNc4U
         G4Y6IjIY/c+tQTBTnxwdEtUQuezQ/n8mS4knvR7sGYtjECoQBtYkYoJpxqSvlL7jQLXd
         DUW2vhd1/0JOANoI/VkpD1R/acEGAfC5P6MNEz9NUsdy4HPZkYZvWAN+8OrMuBisXkJr
         fxaBex6FviDGOAaqgFgwtCO5fA1FdVCvExzNgBS1tD8mCrL5t3n61Y3BMkXEsr2jiuKA
         gBaQ==
X-Gm-Message-State: APjAAAWR5jPzjmLPRx4CEH9lbbrTJ1KPkRQlpnTx8h32OnRQh/SkX/Z4
	gAzBpwXGwKXZL3HjnzbL3Wf4ia6QfJ7rMEzDzkQAZBLShKaOH+k/oeVu/DV6qWotk/GGat+lsTO
	CHrq5Cghg/3tD+n7CcaBpvvw8+nV82FIsoxDU7gNtqVa7K52Sh0m50A0gGjwxLlfsrw==
X-Received: by 2002:a24:1a92:: with SMTP id 140mr16220365iti.26.1557736578278;
        Mon, 13 May 2019 01:36:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwIeSVf60aIPdBLn6LrGBV3aCEfcEeXJmwKi1L4yZH6OwpwhgilQGJNF+jNOdZrMi07mo+f
X-Received: by 2002:a24:1a92:: with SMTP id 140mr16220344iti.26.1557736577400;
        Mon, 13 May 2019 01:36:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557736577; cv=none;
        d=google.com; s=arc-20160816;
        b=XYQ2pigYbM+pmdT6Lb7ItWG9pXLJ0HI4QeK4MBwKiWoXWfexgLzakozyvuz2L2Adsk
         f+/t3HDYalaVXfEKgH18r9O3m+gLuELvYCn3pqZHLoELhG7mauOrrTXXBF6vHtwWyRdr
         scqmw1ycJSAbx3sc/QHOozSRgbYjl7PFj6Q+uOV+iKMNelLIwYciNF9whh2EV0B0Cg3G
         lcatq2Un8b1oVORTbovWFaQG2ogI/HH1yyuxALat7+iKPNEIg7NhsPSxplf+e6dWERC0
         G0g0SmsTudYY1i3joeI4PjP+lvJQKC2hKWbOCsBO61+7xilX5JYjM1Uh0sNI4OEA6Wvf
         m7sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=A/LTjUKq3u7qRwt9jLoPyIVtj9SXda11NSro60RTqLg=;
        b=O1VyRXPzz/RzCiiY+4XuCMxfmZ68+8hx7ZAKay7JpUAc5FBK09ei9Q+8w0tsPO/YxO
         ccyTaUSUVAnSFQwvtVKFZEXOkhPeyvAqd307OhvzJw8ntzx61U2aMT2WTRRHxIv2xVbl
         h59X/2UmpX8RjN/mbql/sgww2ugpbYD6dcyxlBy7JDzlYe+gjrBf7KiUlqJP4hbunarZ
         DvkReIRaPFP0rqKVfIsTOJnZlgnZwMx5IaIBWQ3WnL1i0BaTbih7BKzcRwtMhEuCY4Rl
         8JCW9bwmGvXCKTWBcqpa45RbbK0ihnw0LlKXcFfIG+a8vnrhQw4qW10IClNioXOfJSrT
         TQLg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Z+A0uN9k;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id f187si7616242itf.127.2019.05.13.01.36.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 13 May 2019 01:36:17 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Z+A0uN9k;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=A/LTjUKq3u7qRwt9jLoPyIVtj9SXda11NSro60RTqLg=; b=Z+A0uN9kY/5akyp9FoyRxb1Be5
	1Qigih1z3BK4FURzUf9KoYBXn/anfPh+e1A+sbbSS/HRRb8MLcbOyWKifHMJ6oOv0qad6VkOVfvEJ
	iGe88evRSwyM6FRC08g6CBx0tpkMhp48t8Kbm6mK8WCsLjexMnSkrXTh+sRt2arZOAjGkP39tYOS7
	T51OK83w1YaMZIPXUD9OPs7Wk3gDOWhiSrb6U2N47GR8LVKO99CX+8SHYzddKQgQtl0PQbA5ex2nJ
	U5nzALEj53adVcan72GkNuBvJFAZ1nEhaMYuuT/t+BmkH3e2itGHs14rd1JPKaoMkAA5I9LKvYDEb
	NeDXz1/A==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQ6RL-0005UE-KR; Mon, 13 May 2019 08:36:07 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 25DFF2029FD7A; Mon, 13 May 2019 10:36:06 +0200 (CEST)
Date: Mon, 13 May 2019 10:36:06 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Nadav Amit <namit@vmware.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>,
	"jstancek@redhat.com" <jstancek@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
	Nick Piggin <npiggin@gmail.com>, Minchan Kim <minchan@kernel.org>,
	Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Message-ID: <20190513083606.GL2623@hirez.programming.kicks-ass.net>
References: <1557264889-109594-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190509083726.GA2209@brain-police>
 <20190509103813.GP2589@hirez.programming.kicks-ass.net>
 <F22533A7-016F-4506-809A-7E86BAF24D5A@vmware.com>
 <20190509182435.GA2623@hirez.programming.kicks-ass.net>
 <04668E51-FD87-4D53-A066-5A35ABC3A0D6@vmware.com>
 <20190509191120.GD2623@hirez.programming.kicks-ass.net>
 <7DA60772-3EE3-4882-B26F-2A900690DA15@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7DA60772-3EE3-4882-B26F-2A900690DA15@vmware.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 09, 2019 at 09:21:35PM +0000, Nadav Amit wrote:

> >>> And we can fix that by having tlb_finish_mmu() sync up. Never let a
> >>> concurrent tlb_finish_mmu() complete until all concurrenct mmu_gathers
> >>> have completed.
> >>> 
> >>> This should not be too hard to make happen.
> >> 
> >> This synchronization sounds much more expensive than what I proposed. But I
> >> agree that cache-lines that move from one CPU to another might become an
> >> issue. But I think that the scheme I suggested would minimize this overhead.
> > 
> > Well, it would have a lot more unconditional atomic ops. My scheme only
> > waits when there is actual concurrency.
> 
> Well, something has to give. I didn’t think that if the same core does the
> atomic op it would be too expensive.

They're still at least 20 cycles a pop, uncontended.

> > I _think_ something like the below ought to work, but its not even been
> > near a compiler. The only problem is the unconditional wakeup; we can
> > play games to avoid that if we want to continue with this.
> > 
> > Ideally we'd only do this when there's been actual overlap, but I've not
> > found a sensible way to detect that.
> > 
> > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> > index 4ef4bbe78a1d..b70e35792d29 100644
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -590,7 +590,12 @@ static inline void dec_tlb_flush_pending(struct mm_struct *mm)
> > 	 *
> > 	 * Therefore we must rely on tlb_flush_*() to guarantee order.
> > 	 */
> > -	atomic_dec(&mm->tlb_flush_pending);
> > +	if (atomic_dec_and_test(&mm->tlb_flush_pending)) {
> > +		wake_up_var(&mm->tlb_flush_pending);
> > +	} else {
> > +		wait_event_var(&mm->tlb_flush_pending,
> > +			       !atomic_read_acquire(&mm->tlb_flush_pending));
> > +	}
> > }
> 
> It still seems very expensive to me, at least for certain workloads (e.g.,
> Apache with multithreaded MPM).

Is that Apache-MPM workload triggering this lots? Having a known
benchmark for this stuff is good for when someone has time to play with
things.

> It may be possible to avoid false-positive nesting indications (when the
> flushes do not overlap) by creating a new struct mmu_gather_pending, with
> something like:
> 
>   struct mmu_gather_pending {
>  	u64 start;
> 	u64 end;
> 	struct mmu_gather_pending *next;
>   }
> 
> tlb_finish_mmu() would then iterate over the mm->mmu_gather_pending
> (pointing to the linked list) and find whether there is any overlap. This
> would still require synchronization (acquiring a lock when allocating and
> deallocating or something fancier).

We have an interval_tree for this, and yes, that's how far I got :/

The other thing I was thinking of is trying to detect overlap through
the page-tables themselves, but we have a distinct lack of storage
there.

The things is, if this threaded monster runs on all CPUs (busy front end
server) and does a ton of invalidation due to all the short lived
request crud, then all the extra invalidations will add up too. Having
to do process (machine in this case) wide invalidations is expensive,
having to do more of them surely isn't cheap either.

So there might be something to win here.


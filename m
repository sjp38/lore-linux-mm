Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A649C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 18:40:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9A8F217D6
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 18:40:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="fj9dGlCv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9A8F217D6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B52C6B0003; Thu,  9 May 2019 14:40:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3656C6B0006; Thu,  9 May 2019 14:40:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 286D86B000A; Thu,  9 May 2019 14:40:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E64046B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 14:40:09 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d5so1469886pga.3
        for <linux-mm@kvack.org>; Thu, 09 May 2019 11:40:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=SztKd1ju+6SnNDo4BjWr81OOwqXWrYRbPTmT3bN77eU=;
        b=oARommzVXCHl3pGdqog8ydwNfbGEVNxQmHgj8q6CZAOQ+9NoJbE9s9//Vk32HtPfrJ
         vWdxQXdLl92+RV6GGkzI3A2qTeFgbtCx7to4z/zTn/QBU3yz48RI7UEzYnmgRBsqMgdo
         9aWZzNvJvE9FgVjbyLVxW/6HOMtDi62BiGXkIko3XPFUPTCXmhotdMWDNZ4WkdJ2zEIy
         GzNpV+3hL4lM8HOvLCh6oSXg3vziYPW9Z//Rc/RhA1mErzWUos+BkFDM0nrsYFbKA9Cb
         NcZeO9gvQOU+GGtAv97wWRnJtNgXkt7vMgMRxZLUf8m060xUcVZRek62RcocyAnB2z+l
         8MiA==
X-Gm-Message-State: APjAAAXva0B+MvRHq585QkLlgTSVi+cugqXD3tnLZw5aCqH5pHIgCCoS
	TNQ89PKcMFX30N4/6Z90O5L5N8LxHWzv7j84o2okUvQ1wCrur+DTu2KLbaxuhhSG0SLW6AOZAkC
	0sWWbvAm9r/g3s5RvFYLnKdlMyRUOELIpjvUZzxbAirJZSEcTfZxvP+PtJggGLXc5jQ==
X-Received: by 2002:a17:902:e086:: with SMTP id cb6mr7289711plb.237.1557427209527;
        Thu, 09 May 2019 11:40:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNAgmzrLNVQvxaDKVJB299BRKIrW4FBZlB5blQxraiYdtrp9wTSbVRJeaXDBg3OkIb/vRP
X-Received: by 2002:a17:902:e086:: with SMTP id cb6mr7289618plb.237.1557427208754;
        Thu, 09 May 2019 11:40:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557427208; cv=none;
        d=google.com; s=arc-20160816;
        b=PDYIssfbioBCJVHFlpFvqhnaKJ+UzX/SPs4QGO+rsSZx3y6lHrXZ1hd4eoTGRymTST
         bBHqIo+zDxNpAVYrT97MOUt+53XEUFD+hU2yemNXejlBLLsJFWOlHYmXR1MdlEDOuHXP
         n0rMfYwY2BY1y19SZNQXuOyxkChyooNLg4Nb5MCdfAEr5FiJ8RzrQIKFE/sVlA/EcRGW
         gVWzWfP/S9/58WqhUtv0/JhUVksrVeOxT0InKOEwswjI0h+VzC3geIP2Kurg3ovAl9kg
         Nih39FuCq/yzYBokVqWBSS7nCS1q0zCoH7wkINXM5voDMQ700Dt1klWMcGO4r6vfV/6i
         nr9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=SztKd1ju+6SnNDo4BjWr81OOwqXWrYRbPTmT3bN77eU=;
        b=z5Nl6BvOCrNuHzdm2EHbzYukjZWWh4lr8hfebCe2MUyAJZj0zE7D4kReZ9CZrUk2K5
         puqYo4KkMd8nlR4auJWfmc2YTRXEAoR6ZjOCE8sZfct1HiKjx95IjV6rGJAsV4bXf8WR
         zH7uR/CDOzY2GqEr+nDEBUDeCPzbjFkRK5xQo1OYwAXaKfBjvaH5d8zBK9IO/WlM2fBB
         oj8L4TIIKdo1dkkb2iWVfLXZvvygZ+JL2MvrQfw/hLPYylmHEnoZEBoBWIWlgC/lVouE
         r5CWGIAS7/kpE35y5Hk4FJi4FaeqTVr1jJz68v9YjLpVH9gz7hW9o3aCQHrK7dmKs+TK
         Xm4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fj9dGlCv;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c19si3964870pfn.222.2019.05.09.11.40.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 09 May 2019 11:40:08 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fj9dGlCv;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=SztKd1ju+6SnNDo4BjWr81OOwqXWrYRbPTmT3bN77eU=; b=fj9dGlCvNYfI6Br9Am2Zi3JLGB
	eAMtthKG4CZvd3zQDzNKXT47VW5vNDYnqnzVpfPL+mPkciQoNnHoPeb4e10aj63dKPGKTeC8Ix1zD
	2bvW9RB6wCVeJDVWJzMKgVK+wFIF1Xb8i3EkaVdJskUUcNGQmyo5Qj6JYHxQL0osI99womSn0y5F7
	Sn9WJXxyd5YbqW9+tl/y6U1zjVNw23lDg1gFSnib5mi8cq2chEwsFwenTT/hy52V97YvKJsO96OQN
	rAl0s26wpKhZ7M/E5mmwgYGOBlFzvv8pTPmrFol631L1al/p0/grM4Rx098aV4NZgvaJMtrpBQSPn
	ht++QOng==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hOnxd-0001KL-2w; Thu, 09 May 2019 18:40:05 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 013B520268735; Thu,  9 May 2019 20:40:02 +0200 (CEST)
Date: Thu, 9 May 2019 20:40:02 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Will Deacon <will.deacon@arm.com>, jstancek@redhat.com,
	akpm@linux-foundation.org, stable@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	aneesh.kumar@linux.vnet.ibm.com, npiggin@gmail.com,
	namit@vmware.com, minchan@kernel.org, Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Message-ID: <20190509184002.GC2623@hirez.programming.kicks-ass.net>
References: <1557264889-109594-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190509083726.GA2209@brain-police>
 <20190509103813.GP2589@hirez.programming.kicks-ass.net>
 <20190509105446.GL2650@hirez.programming.kicks-ass.net>
 <6a907073-67ec-04fe-aaae-c1adcb62e3df@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <6a907073-67ec-04fe-aaae-c1adcb62e3df@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 09, 2019 at 11:35:55AM -0700, Yang Shi wrote:
> 
> 
> On 5/9/19 3:54 AM, Peter Zijlstra wrote:
> > On Thu, May 09, 2019 at 12:38:13PM +0200, Peter Zijlstra wrote:
> > 
> > > That's tlb->cleared_p*, and yes agreed. That is, right until some
> > > architecture has level dependent TLBI instructions, at which point we'll
> > > need to have them all set instead of cleared.
> > > Anyway; am I correct in understanding that the actual problem is that
> > > we've cleared freed_tables and the ARM64 tlb_flush() will then not
> > > invalidate the cache and badness happens?
> > > 
> > > Because so far nobody has actually provided a coherent description of
> > > the actual problem we're trying to solve. But I'm thinking something
> > > like the below ought to do.
> > There's another 'fun' issue I think. For architectures like ARM that
> > have range invalidation and care about VM_EXEC for I$ invalidation, the
> > below doesn't quite work right either.
> > 
> > I suspect we also have to force: tlb->vma_exec = 1.
> 
> Isn't the below code in tlb_flush enough to guarantee this?
> 
> ...
> } else if (tlb->end) {
>                struct vm_area_struct vma = {
>                        .vm_mm = tlb->mm,
>                        .vm_flags = (tlb->vma_exec ? VM_EXEC    : 0) |
>                                    (tlb->vma_huge ? VM_HUGETLB : 0),
>                };

Only when vma_exec is actually set... and there is no guarantee of that
in the concurrent path (the last VMA we iterate might not be executable,
but the TLBI we've missed might have been).

More specific, the 'fun' case is if we have no present page in the whole
executable page, in that case tlb->end == 0 and we never call into the
arch code, never giving it chance to flush I$.


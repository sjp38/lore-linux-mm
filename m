Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94414C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 11:27:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 467B8206A3
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 11:27:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="IwWEzplk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 467B8206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6F716B0281; Mon, 13 May 2019 07:27:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF8E26B0282; Mon, 13 May 2019 07:27:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9A296B0283; Mon, 13 May 2019 07:27:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B5716B0281
	for <linux-mm@kvack.org>; Mon, 13 May 2019 07:27:25 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id g63so11837516ita.6
        for <linux-mm@kvack.org>; Mon, 13 May 2019 04:27:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QlLTDpUw3LQEBrJUE4pLazn/f1TqZvICJfFNqlHW/BQ=;
        b=DB7yfTL1lL56KrzXiFX61XyTlC47lgsBwQjK85O5LQ/j6q7Zp8FhshTBUWtrq7SitM
         DLBcqhhSwQEz3k9H0RgbSBFgyUQYOTgIvyxAL0M+8q4D4AvF1OqNGkZNIiq0M27Ahmew
         T1EnrerOXmSuqTr0cXS7tnH/QbAmTM5y090Ok8ULMRRpEPLOSl36/SuLY5Sm0kTMbTRL
         7BXvxqN2zPBK3xsGvyrieGddcfet5uaC/QAT7LGmgQE0pW6I72cJ6BTETJ6xwzWjfVcq
         tZNFPsPxaJ2mcTcsN4rVbb7jsJo5zzRhAo1BRV+GP+vBpyuLCJIpEoBXkqlBlGTVEckh
         +kog==
X-Gm-Message-State: APjAAAU2rzYdbsHgceOsUs/7Jt9yqEbqY8yGgdLfjM14XEMoW9PLfK28
	f/4uDep4lmfO6AXEEUGTQz9020uDjCKLXEDRrDdMncaBvnNDmYO2oAmWntpOGtJxFkGVGUpw6rN
	NHGQ4ABtQoimAn30it9lBW7OP3kGKZrVzzBNnYU7s3xh9U3DtPDEdWlAAGE2BRWZx+A==
X-Received: by 2002:a24:910b:: with SMTP id i11mr14800819ite.76.1557746845389;
        Mon, 13 May 2019 04:27:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw93NMeczaWXbBjmr+icPWAio6md3DJ8kqe0wWKo0DbuNHMfZZW6fCO+XIgpxnxWsX+/uES
X-Received: by 2002:a24:910b:: with SMTP id i11mr14800798ite.76.1557746844561;
        Mon, 13 May 2019 04:27:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557746844; cv=none;
        d=google.com; s=arc-20160816;
        b=oKl4D7zMMlQeBYVtX8z5L3gL5jA9xDxZi+RGBJRSeYA6K9laF/s+lD5khDPf3I92Yf
         wqtnWVB+3q517zczYwsDW8k0cJFYUssXI/Olr5YGWMQ427xpe67F+Azx6VoW6ghFqu9f
         XiVrcrKkroJClS6g0eZblkQ2OxuXQhgp1wBeAXOjqIYO3zbimAyjwkSoK0njYJjGnSqq
         SL1AieXKL0rGguJE5TFE+SHYB8mMdde3JAMx3mZZaGfRchUq52bMma47YdfCevFnoIui
         8suCFesCsxPxEgB11WvbCzdPG7KQQaI67SdYYpk2kLrIadn+NbCvIsasuVYr63CsSBsr
         D80Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QlLTDpUw3LQEBrJUE4pLazn/f1TqZvICJfFNqlHW/BQ=;
        b=XWfz+xG4XYIl5tZ7Z4r90qxpI1qrWRpnQHhidvd0GV1EABkIPiHaiq5IjgGb02uneh
         KUD2I2ab14A2fLquiY0tXtqMtay3l0zYPp8x7ucD2AsO6mK9PnsosLJaaCfdJc0FFqkb
         PpQU27hVp+BEIG9kaKUhjp2pFmDQ/OlpnqCU8J8T2daDibgHwc0qkLf3ijw9EFcvNL3+
         g87ZtSbPLmqEHvE903NzwDaS6y6zo11M+mYr4ylGSHwwVc2Q7D0WpAnKpj++sSHf9D2e
         xdM3BMqhgJglcfMo6S8nEjZ0SfgimDQvLybmpAkf1Ke2FnoU/BM8WXPeQ+4wrbL3W6fu
         9BjA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=IwWEzplk;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 194si7802075itw.57.2019.05.13.04.27.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 13 May 2019 04:27:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=IwWEzplk;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=QlLTDpUw3LQEBrJUE4pLazn/f1TqZvICJfFNqlHW/BQ=; b=IwWEzplkAkvkiV39U9/PKkoJb
	Mbh2qFemubE06kI3RAvtqVE74136gc9EF11rwqkOIOqh3/Zllt/rNxayUsNYx6Yj8YS0buszvdTIM
	Oq52Pqhn1KbDNJdTxbEQ422JPZew+5gXySaIlAa/rb9C1GdAjiksksYWL51W/r5Hso54fqJLiFOl4
	2M4jC9VETnBTqBXWBiKdZWNGoC6oDaUtY6skxz7RpfawLsiEltTDWKsYd8p7rf9LOdhi6mI5GoZBb
	mvTgrr+48M9/o80HvkCIe6Jk4fUIuU/z1rUoPxpqQo3zTyOR4J6/ryDq//uAqZ1NGHDLwtnhHKe+T
	dPYpqSBng==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQ96x-0006dy-89; Mon, 13 May 2019 11:27:16 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 7CB452029F87D; Mon, 13 May 2019 13:27:12 +0200 (CEST)
Date: Mon, 13 May 2019 13:27:12 +0200
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
Message-ID: <20190513112712.GO2623@hirez.programming.kicks-ass.net>
References: <20190509083726.GA2209@brain-police>
 <20190509103813.GP2589@hirez.programming.kicks-ass.net>
 <F22533A7-016F-4506-809A-7E86BAF24D5A@vmware.com>
 <20190509182435.GA2623@hirez.programming.kicks-ass.net>
 <04668E51-FD87-4D53-A066-5A35ABC3A0D6@vmware.com>
 <20190509191120.GD2623@hirez.programming.kicks-ass.net>
 <7DA60772-3EE3-4882-B26F-2A900690DA15@vmware.com>
 <20190513083606.GL2623@hirez.programming.kicks-ass.net>
 <20190513091205.GO2650@hirez.programming.kicks-ass.net>
 <847D4C2F-BD26-4BE0-A5BA-3C690D11BF77@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <847D4C2F-BD26-4BE0-A5BA-3C690D11BF77@vmware.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 09:21:01AM +0000, Nadav Amit wrote:
> > On May 13, 2019, at 2:12 AM, Peter Zijlstra <peterz@infradead.org> wrote:

> >> The other thing I was thinking of is trying to detect overlap through
> >> the page-tables themselves, but we have a distinct lack of storage
> >> there.
> > 
> > We might just use some state in the pmd, there's still 2 _pt_pad_[12] in
> > struct page to 'use'. So we could come up with some tlb generation
> > scheme that would detect conflict.
> 
> It is rather easy to come up with a scheme (and I did similar things) if you
> flush the table while you hold the page-tables lock. But if you batch across
> page-tables it becomes harder.

Yeah; finding that out now. I keep finding holes :/

> Thinking about it while typing, perhaps it is simpler than I think - if you
> need to flush range that runs across more than a single table, you are very
> likely to flush a range of more than 33 entries, so anyhow you are likely to
> do a full TLB flush.

We can't rely on the 33, that x86 specific. Other architectures can have
another (or no) limit on that.

> So perhaps just avoiding the batching if only entries from a single table
> are flushed would be enough.

That's near to what Will suggested initially, just flush the entire
thing when there's a conflict.


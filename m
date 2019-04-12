Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3F2BC282CE
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 18:19:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79390218A3
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 18:19:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="SyI3VINw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79390218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 142826B0010; Fri, 12 Apr 2019 14:19:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F1396B026A; Fri, 12 Apr 2019 14:19:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F21F16B026B; Fri, 12 Apr 2019 14:19:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id A653A6B0010
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 14:19:40 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id 7so7269283wmj.9
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 11:19:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KpJsBc8SapSFzeXew9+sq3mf1ByhcdS4G0yhgcMADv4=;
        b=Y9X8YhCRnl35C8Ug6LsAblaU+GdG3mHNLFzaaTMCTzLnHQwnrJtAJJ291rEhcowxbC
         YCADl4C1Xmh5ZLR7QmsAMmYBJ7xLxwT0KyRjKnEHpVgRsaV4mQHWjBjTw/yQBAigaskM
         vGl5n564BNYsI779694oDa0v5aFGWYv+eRNIoYVZuygMr4tRt54Q0DynfqvMxR/4rVLF
         G7Ak5px3tkpDH6iNdHUtmjdeieXpGC2bL5KGv14kbR9VJg1cd5dq5kSD7x4gnmf4b31I
         4NZt9EC0unQtjY1+RNyRu2iCcXy5Bjta+/D4TKbWTXQmTeuMIISgeNOd7/gVRf93eVDI
         aNkA==
X-Gm-Message-State: APjAAAWutOlIZ/BCLOkDnc5fbTHdyulHWGMZ7p0XOcxs5GYllMDGKAiL
	cu3Hk490Vdb9tNVSLWIm6mxN7DXSAXA2gzWM0rhr8mAc0Xwtjl7m6+Y/jk8+GsUVO0vWpI0gvOl
	5+KuyITV5653apg599oIfIIahKHxdPhlDu0TBbIcskYFdWMIrgMtVnmDSwQletQ1w9w==
X-Received: by 2002:a5d:414c:: with SMTP id c12mr38347783wrq.106.1555093180076;
        Fri, 12 Apr 2019 11:19:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyH/UKH2HhOFCHBIKZ6qZRFWIJ7hT1uNaH1E5vR5YrM+E7AqPPXxDTNZPJUniE8TH+FtI/s
X-Received: by 2002:a5d:414c:: with SMTP id c12mr38347698wrq.106.1555093178687;
        Fri, 12 Apr 2019 11:19:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555093178; cv=none;
        d=google.com; s=arc-20160816;
        b=l3dcofZ/HqXoJENB5aUsFFLzy6jpQbN+zrEHJiIvC3+Wn1pxPVu/2zbWIyv1Lh5GZM
         +qMwofg5GhmevsQoen8sa+bW0LJt80FumjuYhk/NQdpNRIjI0NtaUhvI5uPF20ez3v2Z
         9xZpfHtLgohYOchC85BlykcqogSe1tR+x9l0YqvWYge+jP0vFJKAKCuqc+yMKYf4q8ph
         K5P4KpxWA7u0wPb7k7I/3v3+lhYPcEL09Tk889Xln0r6bN9AuzZe0Ie2FMabOF6rQOUw
         lO+Axnm8D35czHXTP/i0G2IL+cKujlpWN9tLh+tTRYTqix/xY+j1jxG8GdhlRDlkCyYU
         Lzow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=KpJsBc8SapSFzeXew9+sq3mf1ByhcdS4G0yhgcMADv4=;
        b=f4L9/v56sI2VhRe+VClTKvQMwtNCVEj9TOqg69rYzD+7prQcjFtg49Ztl5VEINQGs+
         HMzKcvuEWiu+bJGXhF6cWSh97wc0xrg5sZzpqwvrzc443kPO0pwYREUOh0yuhpdpUZD0
         Y310c9QHGbt+gcCd8gm5+tkU+DK9f8lT5TIa97B4d2oQO5CXWqOdR9SI+A9LHtf9HodZ
         W4jNTh2k+uHLHweE23gKobGfA6ptomnmBtqboP7fimZYkpSF1KQXTLhbfFH1rET0cGlc
         WYa72DcC5cXq9w3vDDGqaU71ec7hCgs+RtOHM8i0Ngll50r1UrrlIjl5BUKhza5ylgK4
         fC4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=SyI3VINw;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id x6si5536853wmc.107.2019.04.12.11.19.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Apr 2019 11:19:38 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=SyI3VINw;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=KpJsBc8SapSFzeXew9+sq3mf1ByhcdS4G0yhgcMADv4=; b=SyI3VINwNFgLzvaWksaXcp57z
	OrBAd86qQeWRtn4Gdt9uziZE4aq7ToC5Tnfpu4N3NXuW6PMlNq3fWO4f03wLNaSMRjUwBvJEnCCfg
	CtUaHXVvyjRBs+NvtqLt1apQ51+dZYEAXA8xEAyizv4v9KVsHjaekuqY9U+spyCcS1UwGB8BbzMGR
	APuailpptjRAjn8LmBLLairGX37lhLp1cNkd7D/0MaWUqLYPRH1Keb9QJ/dr1aaC+nqgNrVrbWmfD
	+lWdvRcIjVM/Oten7rbKgGYRENjKF8J0TtOJ9enf+7e2vrpvkq8WrFIhCbPAZnHeHca+meF6XC9JO
	+uq7yLbsw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hF0lv-0003Q9-NP; Fri, 12 Apr 2019 18:19:31 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 73C1529B20C3F; Fri, 12 Apr 2019 20:19:30 +0200 (CEST)
Date: Fri, 12 Apr 2019 20:19:30 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Nadav Amit <namit@vmware.com>
Cc: kernel test robot <lkp@intel.com>, LKP <lkp@01.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>,
	linux-arch <linux-arch@vger.kernel.org>,
	Ingo Molnar <mingo@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Dave Hansen <dave.hansen@intel.com>
Subject: Re: 1808d65b55 ("asm-generic/tlb: Remove arch_tlb*_mmu()"):  BUG:
 KASAN: stack-out-of-bounds in __change_page_attr_set_clr
Message-ID: <20190412181930.GD12232@hirez.programming.kicks-ass.net>
References: <5cae03c4.iIPk2cWlfmzP0Zgy%lkp@intel.com>
 <20190411193906.GA12232@hirez.programming.kicks-ass.net>
 <20190411195424.GL14281@hirez.programming.kicks-ass.net>
 <20190411211348.GA8451@worktop.programming.kicks-ass.net>
 <20190412105633.GM14281@hirez.programming.kicks-ass.net>
 <20190412111756.GO14281@hirez.programming.kicks-ass.net>
 <F18AF0D5-D8B4-4F4B-8469-F9DEC49683C7@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F18AF0D5-D8B4-4F4B-8469-F9DEC49683C7@vmware.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 03:11:22PM +0000, Nadav Amit wrote:
> > On Apr 12, 2019, at 4:17 AM, Peter Zijlstra <peterz@infradead.org> wrote:

> > To clarify, 'that' is Nadav's patch:
> > 
> >  515ab7c41306 ("x86/mm: Align TLB invalidation info")
> > 
> > which turns out to be the real problem.
> 
> Sorry for that. I still think it should be aligned, especially with all the
> effort the Intel puts around to avoid bus-locking on unaligned atomic
> operations.

No atomics anywhere in sight, so that's not a concern.

> So the right solution seems to me as putting this data structure off stack.
> It would prevent flush_tlb_mm_range() from being reentrant, so we can keep a
> few entries for this matter and atomically increase the entry number every
> time we enter flush_tlb_mm_range().
> 
> But my question is - should flush_tlb_mm_range() be reentrant, or can we
> assume no TLB shootdowns are initiated in interrupt handlers and #MC
> handlers?

There _should_ not be, but then don't look at those XPFO patches that
were posted (they're broken anyway).


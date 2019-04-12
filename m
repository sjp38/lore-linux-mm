Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 227F9C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 18:16:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3BDE2083E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 18:16:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TXtxbDYu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3BDE2083E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 738F36B000D; Fri, 12 Apr 2019 14:16:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E7756B0010; Fri, 12 Apr 2019 14:16:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D7A96B026A; Fri, 12 Apr 2019 14:16:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 254016B000D
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 14:16:05 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id t17so6716638plj.18
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 11:16:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=vLgYVDT49iGyhQ7eAaa1ouryxRYhUiXDgOprm8yEPCE=;
        b=EtJQSiq+y9M7vZwvuXVJ34/32SwYsPA9yqeobv3NL8CC8xA06U6s99yyRrim9mwdqK
         c9a2n7m71aqZIsXbnpmshv+P7kjlor9VCAlwk+jlrr6o8VjDm54nFLiAiIkO7BL145sy
         3SLxlVkGj3iGYLgbl8WJ7Gf/+//srySgJ1htZ4EhaAmFuIcVAFtX7/SK9/RKyrUvPvng
         j025xLq8Q1uCg7dJxU1OL56sRKD6U16eCxlw8213ARdzsqKKbupHUgMhKimME6BJUIx7
         wHkCUGrHO7FWUcc84+IR4v605tTQchv/b18tSX3JZKqNSDCbB8GZbSHbUVGFC07LqF0V
         4BaA==
X-Gm-Message-State: APjAAAUEURU8jcQVBbkYDy8vVl8RJ1nnzCB8RxluvX+kaPy4PJ96owhr
	uRWzp0mjKvnhKJqN8Z5qme7FHXkV4NzirhTr7s2L0kBIZziUk6xhPtxfNvaDJA4lujTgNu0FsCM
	DAetqXBdmIjdiXx/vz1PK0FjsTMnWwFyP4rk1EtQgQTEQEiKgV5tKXvCyggMxPkhS5A==
X-Received: by 2002:a62:e213:: with SMTP id a19mr59218289pfi.85.1555092964544;
        Fri, 12 Apr 2019 11:16:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/eNsliJTTzNM9GNtVCWglN/jD6QlLlIi8cmG7P6whbNg5BvY1OVF+Bs5ZHJZx7d0c3Uor
X-Received: by 2002:a62:e213:: with SMTP id a19mr59218227pfi.85.1555092963904;
        Fri, 12 Apr 2019 11:16:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555092963; cv=none;
        d=google.com; s=arc-20160816;
        b=GgZJb0CcfYwkjxthU9PVKEpVRdmuhUaEuBSFPEjWLFTNjk+jV5bKPlzbiU+ESI0oen
         DYfQkJzwPrZS2aKJZzxElrQ9Ir97xwyvXrsrSJJINjn51gFqF3uhMWps2xV96//ypxLP
         c3uyfoQTwqMk311KC+kfxTSfxMNFeQyhx+3ZPVii5hTiX7T9V+2jlHLS3toXrhzJtYcv
         8VBmOVEZz5Ib9Euxci52aSQGTYpFQzZpcwczehtfqD7HxRhuBhOPMO5ikbeSFS5oAu0K
         L0yM5TQ+1xZUyvgu+cHAm4ywXYorznljgwcGfABw/mLI4anuz6B6UrHq1VYKvAuRk9/v
         US8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=vLgYVDT49iGyhQ7eAaa1ouryxRYhUiXDgOprm8yEPCE=;
        b=f7ZhVD3vszT6QGTv97G/QwfgZPbgjvVdQqtK8DpQuVvmX9Gxlj0ZQFTeLevzl13iYw
         ASLgqf45ro/Z8Lw4xFAFLeT7d6rq5JjLKP2TysNEA6hiem+pFLBSkhYLFdaGcrRN8Qy3
         SsiskEF1XCyl8zWkvEtVSvdxZuQHFuo6mNZ+qZizEcKny61lvBWVS5dh1yW6tAf7MsET
         KqN3PB1O42NCXS8T6hfhMUTu6iboTq6jZTI93zMkQz4aryB5QCgl006UUQqqrrOipHlt
         iSWNAcCZqMwaXEGCqUVWVktbpsu5SDLhQBdOpLgldPUpkY9uy+50/TpMukKLTzni1pTH
         ygTw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TXtxbDYu;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v131si38191551pgb.452.2019.04.12.11.16.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Apr 2019 11:16:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TXtxbDYu;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=vLgYVDT49iGyhQ7eAaa1ouryxRYhUiXDgOprm8yEPCE=; b=TXtxbDYuMujQhLK+HaFsZkwEi
	ExxaqmfppeQtbOkWZPOZ2cCRPEV+S8sfIQnDJF5mi941nvZ00/tSkwtBibSXyg8MOvY6p0k6RpNOX
	lwozqoFRxl01U59Jze3IxOcOWGtOmBYKsB2T8WdmwPgOlUEXrO9SgyyR0u7KlZ7q854B9M4hg4v6e
	dLsdE9woWI/1TvbMWk5ksNt2u2XKJK813fNAW3KlIf+VJXfIBQ4iXaVZR18TkYS59DCcSIs66/F12
	QFW2ldsE539CqlBznmHrmdT7CIG8YLL+WdItNlI19A1O5xBfyJUp7uq9AP/90+GBDJWL7uX3RHsb5
	FVkbrZiiQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hF0iV-0003m7-Hz; Fri, 12 Apr 2019 18:15:59 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 69C5029B20C3F; Fri, 12 Apr 2019 20:15:57 +0200 (CEST)
Date: Fri, 12 Apr 2019 20:15:57 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: David Howells <dhowells@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	kernel test robot <lkp@intel.com>, LKP <lkp@01.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>,
	linux-arch <linux-arch@vger.kernel.org>,
	Ingo Molnar <mingo@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>,
	Andy Lutomirski <luto@kernel.org>, Nadav Amit <namit@vmware.com>
Subject: Re: 1808d65b55 ("asm-generic/tlb: Remove arch_tlb*_mmu()"): BUG:
 KASAN: stack-out-of-bounds in __change_page_attr_set_clr
Message-ID: <20190412181557.GC12232@hirez.programming.kicks-ass.net>
References: <CAHk-=wieBr3G=_ZGoCndi8XnuG1wtkedaGqkWB+=AVq65=_8sQ@mail.gmail.com>
 <5cae03c4.iIPk2cWlfmzP0Zgy%lkp@intel.com>
 <20190411193906.GA12232@hirez.programming.kicks-ass.net>
 <20190411195424.GL14281@hirez.programming.kicks-ass.net>
 <20190411211348.GA8451@worktop.programming.kicks-ass.net>
 <20190412105633.GM14281@hirez.programming.kicks-ass.net>
 <5890.1555087830@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5890.1555087830@warthog.procyon.org.uk>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 05:50:30PM +0100, David Howells wrote:
> Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> > We should never have stack alignment bigger than 16 bytes.  And
> > preferably not even that.
> 
> At least one arch I know of (FRV) had instructions that could atomically
> load/store register pairs or register quads, but they had to be pair- or
> quad-aligned (ie. 8- or 16-byte), which made for more efficient code if you
> could use them.
> 
> I don't know whether any arch we currently support has features like this (I
> know some have multi-reg load/stores, but they seem to require only
> word-alignment).

ARC (iirc) has u64 atomics with natural alignment requirements but
alignof(u64)=4 due it being a 32bit arch. Which is awkward.

ARMv7 can also do u64 ops when aligned right, but I forgot if they have
proper alignment or not.


Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60758C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:17:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16E152229F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:17:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="EIdI5E8i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16E152229F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB2FB8E0140; Mon, 11 Feb 2019 14:17:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3CCD8E0134; Mon, 11 Feb 2019 14:17:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B6EF8E0140; Mon, 11 Feb 2019 14:17:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 460958E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:17:56 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id n24so1039211pgm.17
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:17:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PhovsTo4Xv8LTyBtuMEIczUQFNzmciYoafJCDAEYZ6I=;
        b=pxk+SHlPEI4Ku7NwXIIoGyVJH/i4j3FF0FzNZRvwIoI3Dznkjr0tJNuJAKXH94wzbp
         tkLJCa7B+5XNu2MMb/Pw6gJIijvXrHbVv9G7XaCV3loN+qrPzW6WardzE09SOnD4TnSZ
         NGQyNg43znH/SsaVDMcv4GKTZV+JVmvPReTD/GXSyDLbPD5/To22KLkoKUDB5igorCfo
         YiE7N92b80svPD+8EpLDwwOcSK6o6OJG7gbRdFjN+QdE3JFwCRCzkV7Cj5Bc6LQMGv2c
         XJo0TMrdGiXxeih5SJiXRyLuHjJggIVyHNyXLVpckTT8EXAfKs21PeNHhGjqMyZgNYrK
         oKxw==
X-Gm-Message-State: AHQUAuYASShiH+UYLKDyOWDMngIBZ9B3M2c4TTJ03XeZpqUv7GmLfqLU
	XT98o/k3JBlVkd2pWo/qr+oq6O2rIAGjtyq/P8Xmb07nnDLilLf7nieFlB8YoOYvaa921z20mXg
	RNCaiG+3/+Sk6TbRu2aWijwdvMByGh0LYmDehI2IyTU7I6SCPzMgKKDqSgI5ZxMQLgA==
X-Received: by 2002:a65:5cc4:: with SMTP id b4mr15894504pgt.365.1549912675946;
        Mon, 11 Feb 2019 11:17:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZbe8rwwDbXjGFyACnI9tOQxPW8jpcfZwi6srgQ/JOJA/ip/JGk/BYrBa7B91/qC9TOp87c
X-Received: by 2002:a65:5cc4:: with SMTP id b4mr15894452pgt.365.1549912675225;
        Mon, 11 Feb 2019 11:17:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549912675; cv=none;
        d=google.com; s=arc-20160816;
        b=XPXLyJMa93m6TiQ+sBI6C0vIapX4h2gTVtFW7yS9SnRJqXaNoJfaXOJervFhFdRCoM
         Gb4lTPxCwTX6RlltQWhGeT35FfJn1nOojSrGTtUPvZK0ZM6Y5PsSiGCZMcUdyNbOAagV
         lpVFHAh5H0M2sw2S5u+lE4gL1Bc5Y7QXecdknmX3OTd6PVFlKDJ8qmQxNbRKLzYL6O0L
         mqbQhNYCW3Jp6K/ujZOY8pWB53iyDdTzIM5tH8WqmzI3cZVVeimrf9RP5SYmu4qpuO7d
         YiOl1xzp39ZyWHIJysySaxxES6UUmYXyxOwI5ofkJvrwGAe80uFzvZR6wp4aGS22qMy0
         67hA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=PhovsTo4Xv8LTyBtuMEIczUQFNzmciYoafJCDAEYZ6I=;
        b=cqtcnVi980RwvD/E4XtVGEm+hT9pEPk6XAefe1m+e1qHKuLvQG1xxU/oV1O9ghu8Vn
         9aIm62pQ5/cU5pBpMnDsR1rjgZvOfQjPl+AvSXindIF4f3v58Wwnk1pp8v+XBgj1MKav
         gY8Wof70rYKTqfAuoNvVHiU5hQIjQXi+/1SDG+R3gevTbAwly03a1jh86l/hKeeKSf6O
         wzF7TQB91wz5dR5UoziZnIbvauFl5J2jyKi5RdhxvGBgKHEdhwUtsyMuGfdmrvfE9h2Y
         dUoX8pFQCxTpFVPlGxO3fIVgvETG3ZIUqc4QgFDoJSrPDXJROmuxhIohS2s3BeHF4pzH
         94ig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=EIdI5E8i;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d22si7567480pgv.40.2019.02.11.11.17.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 11:17:55 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=EIdI5E8i;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=PhovsTo4Xv8LTyBtuMEIczUQFNzmciYoafJCDAEYZ6I=; b=EIdI5E8iaO4aWl9BXM0N3/znQ
	ShzUD9u4zTit5UCMJt0e9MXC8KLillpZOBKf3g6klckwN8OGpYDTF0t4vVK0TXDmWwQu3Fcaz6Jpu
	rvhe8csgstPHJhRPjSqpE55G6AdLrWRWFcaDaBEXZmEwrCwnsKPUiaEeiEBF2y7h7wvM+LQU7VLVZ
	ydxp+a3nAmD7mVuLbZ6Mb1JPWRhFr/7MLlFngP013/vtdoLd8qNg9uZfeklja82SYPs4CEqNKMNLd
	hsrsAv3jq1CUv2ZOk8ZnEW5utsuyNkcMc4PxvZYbZZ/7fk3KyUT5992Dm7AU6DZU0D8gknj1SFMPZ
	Xt397UBmQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtH5O-0000yj-3z; Mon, 11 Feb 2019 19:17:46 +0000
Date: Mon, 11 Feb 2019 11:17:45 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org,
	Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2] mm: workingset: replace IRQ-off check with a lockdep
 assert.
Message-ID: <20190211191745.GH12668@bombadil.infradead.org>
References: <20190211095724.nmflaigqlcipbxtk@linutronix.de>
 <20190211113829.sqf6bdi4c4cdd3rp@linutronix.de>
 <20190211185318.GA13953@cmpxchg.org>
 <20190211191345.lmh4kupxyta5fpja@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211191345.lmh4kupxyta5fpja@linutronix.de>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 08:13:45PM +0100, Sebastian Andrzej Siewior wrote:
> On 2019-02-11 13:53:18 [-0500], Johannes Weiner wrote:
> > I'm not against checking for the lock, but if IRQs aren't disabled,
> > what ensures __mod_lruvec_state() is safe?
> 
> how do you define safe? I've been looking for dependencies of
> __mod_lruvec_state() but found only that the lock is held during the RMW
> operation with WORKINGSET_NODES idx.
> 
> >                                            I'm guessing it's because
> > preemption is disabled and irq handlers are punted to process context.
> preemption is enabled and IRQ are processed in forced-threaded mode.
> 
> > That said, it seems weird to me that
> > 
> > 	spin_lock_irqsave();
> > 	BUG_ON(!irqs_disabled());
> > 	spin_unlock_irqrestore();
> > 
> > would trigger. Wouldn't it make sense to have a raw_irqs_disabled() or
> > something and keep the irqs_disabled() abstraction layer intact?
> 
> maybe if I know why interrupts should be disabled in the first place.
> The ->i_pages lock is never acquired with disabled interrupts so it
> should be safe to proceed as-is. Should there be a spot in -RT where the
> lock is acquired with disabled interrupts then lockdep would scream. And
> then we would have to decide to either move everything raw_ locks (and
> live with the consequences) or avoid acquiring the lock with disabled
> interrupts.

I think you mean 'the i_pages lock is never acquired with interrupts
enabled".  Lockdep would scream if it were -- you'd be in a situation
where an interrupt handler which acquired the i_pages lock could deadlock
against you.


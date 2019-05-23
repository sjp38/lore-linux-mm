Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 039D2C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 01:55:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C31F21019
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 01:55:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ksfHx4cj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C31F21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E93866B0007; Wed, 22 May 2019 21:55:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E43FD6B0008; Wed, 22 May 2019 21:55:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D58CE6B000A; Wed, 22 May 2019 21:55:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9EB2B6B0007
	for <linux-mm@kvack.org>; Wed, 22 May 2019 21:55:14 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id g5so2988590pfb.20
        for <linux-mm@kvack.org>; Wed, 22 May 2019 18:55:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=FB0rgwSUFK0gjNHtzWzGVkOJssH8RLWkI1QfMPGyhSA=;
        b=qErjrxFSUTD9J0cQwvRXDExM67EuqX79cgFUQdKC6qTHm2pOw6u6PrbA+quLjon5IA
         GoYIaghNF9D82lsV4mUjKzyj/muEEVhBAraVleDVqUlwPclew7uwmUXSxxo3ZuCR1Tg6
         UdI/QqYq/svMKqpSIz5t8RuW2Y6gISUvRGqzde87Gffb1k7MH2k9JB0+re7QtSPSBfve
         o2sJjJHSh8kboifxJ+DnelUJ8vm4EnaV5/AOOGjc7NLzCrCpgLLmV5ov6uIDj81HYbTk
         aV0Xazz+LoTT+pl3i4Gdq+uKyWipL3pOoGfGeP0CHONXQ1Gz+WbS6biF3xcAHEgijXFO
         0dZw==
X-Gm-Message-State: APjAAAUn0zfgYW9BaEuB3rRaBvkq5ril13Ju3ThGBFsPHtHy6Qdu52zN
	SmW2OS+Vc4UNf2cqOhCNvZzE1q18FBug6Fi+FUzeseVQvCPERZCNgKH80Hq4Wkk8NNXu5X1zj1r
	FfKAlqCBDE8961e0494StOFMaEpxRUpmlOvUnC/4n6lIVZ5/ARz25eoDpe13YcEieZg==
X-Received: by 2002:a63:5607:: with SMTP id k7mr39111666pgb.118.1558576514166;
        Wed, 22 May 2019 18:55:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHZIRz4k2T+7E/am6RX4e+zlYL9mx5CuBYWnY77oKZiDVM3Mgd98cEMDqk0YfOFSoSDEjz
X-Received: by 2002:a63:5607:: with SMTP id k7mr39111615pgb.118.1558576513413;
        Wed, 22 May 2019 18:55:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558576513; cv=none;
        d=google.com; s=arc-20160816;
        b=mQ9IyoVIsystVM1C78XTVRUXbVHZLCIvbYcDtmNxTrzFTmIFfh2U+obVIOyl8N1MCq
         xNpARjBE7nO1dMkwDg2lJjI5KETQpgGqGjJjiWIIRpQXnzOfZx9pgmEGaSv/JP7ylLnB
         +0I4TTS7oEMY1A4luYEhW8sVIhvaGS0cF39rwgAieAYj9ii1VvlWFG5qogMWvA7EQVNI
         YSpOyqRGrfZxFmnYrBVbs5GyKJRXG/QyDEeDxE5gxrDkD2JGQnCErk8SSnPVN++Kt2iB
         hT2taLjHDId0oeBt7fhMAHC2u7a+41o6fQeULiwS4NSUiZqOqsQCcNVWiHR3cD31JSsb
         YHUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=FB0rgwSUFK0gjNHtzWzGVkOJssH8RLWkI1QfMPGyhSA=;
        b=a1UTzAqQDbKfNKMLCZhdJU9ZMKDjLWj8QboZJcGBD4zTyJlrjkB2jkMFGCgxELwRQh
         cqvBmTUweaGC2C+7qA0VxsHHT2ywtEDvBDgoVVIchEQYghkqxn9GcjZ3z8BybjH2G6Wj
         LwLqxxAMeGhm/BriAJg6jhyu0CjDes9ivz3BHVNu3REGTg3VWiJrPn80FC6vPYEYj6+Y
         vBwAuqoLnAkzeHaTArTnY+yVvIQErOrp7c7QPyNjm77MI6EoSS1gE3fysHSS9fl0dYgs
         g2EKks5PlxKCFQuUQrdOJqArNT3tD2FyZ6Ag3SkFpuiPYZ4yIwNToM8lKj/UUi+J0xdh
         OEZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ksfHx4cj;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g21si27495124pgb.313.2019.05.22.18.55.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 22 May 2019 18:55:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ksfHx4cj;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=FB0rgwSUFK0gjNHtzWzGVkOJssH8RLWkI1QfMPGyhSA=; b=ksfHx4cjdGSeL6SQ1VLWi2UrB
	RInXwVnw9F3Gfpew5glTJPTWLuJEannzGhvzROaGaxy26DQBhNniId3QLSSEg0Isr5A5cELRH93IX
	S013B/0b0ipETHk50o8bS4HYP4IuM/cripwTYGqKtTxP7L6JLQ1JUIiXSgGXviTAgZeOWomVnnyG3
	0f5rBASA5VeOvxJ0wxgQWXm4KiehptYF3LkvX/sb7RdEyENAVmt33GQ0IM7ma73a33KFiil3v8o5G
	C+6qSxGRLwYzZIWktBGI37qDLKXaLsbS2B3XYAxyFnF1a+teb7v2d6WtdisMQ//fYVZloeFTXIfP3
	j0uNLWj5Q==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hTcwp-00026Q-Fz; Thu, 23 May 2019 01:55:11 +0000
Date: Wed, 22 May 2019 18:55:11 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, linux-mm@kvack.org
Subject: Re: [PATCH] mm: Introduce page_size()
Message-ID: <20190523015511.GD6738@bombadil.infradead.org>
References: <20190510181242.24580-1-willy@infradead.org>
 <eb4db346-fe5f-5b3e-1a7b-d92aee03332c@virtuozzo.com>
 <20190522130318.4ad4dda1169e652528ecd7af@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190522130318.4ad4dda1169e652528ecd7af@linux-foundation.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 01:03:18PM -0700, Andrew Morton wrote:
> On Mon, 13 May 2019 15:43:08 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> > > +/*
> > > + * Returns the number of bytes in this potentially compound page.
> > > + * Must be called with the head page, not a tail page.
> > > + */
> > > +static inline unsigned long page_size(struct page *page)
> > > +{
> > 
> > Maybe we should underline commented head page limitation with VM_BUG_ON()?
> 
> VM_WARN_ONCE() if poss, please.
> 
> The code bloatage from that is likely to be distressing.  Perhaps
> adding an out-of-line compound_order_head_only() for this reason would
> help.  In which case, just uninline the whole thing...

I think this is unnecessary.  Nobody's currently calling the code it
replaces on a tail page, and the plan is to reduce or eliminate the
amount of places that parts of the system see tail pages.  I strongly
oppose adding any kind of check here.

> > +	return (unsigned long)PAGE_SIZE << compound_order(page);
> > + }
> 
> Also, I suspect the cast here is unneeded.  Architectures used to
> differe in the type of PAGE_SIZE but please tell me that's been fixed
> for a lomng time...

It's an unsigned int for most, if not all architectures.  For, eg,
PowerPC, a PUD page is larger than 4GB.  So let's just include the cast
and not have to worry about undefined semantics screwing us over.


Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D6DAC10F01
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 15:15:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E051F217D9
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 15:15:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="R+M7Hbt1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E051F217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F45F8E0004; Mon, 18 Feb 2019 10:15:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A4248E0002; Mon, 18 Feb 2019 10:15:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6933B8E0004; Mon, 18 Feb 2019 10:15:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 25A818E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 10:15:52 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id b15so13979366pfi.6
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 07:15:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Yd673/bZsI/lWohx4acadJrVu7fDWTLz4coEY1Do5u8=;
        b=nvvjd5op5rE3BraTAmBlhnp5wzQ0RzVTHODnHHytwlu4+5GSuRbaKK+Fy81oyvhbGU
         vpxLCiOwZT5L39qLM3VA/u7s/wcEsoE/CKcRMbQ/3KwuRyz/LSUBp3+zqURA3QdQ7M32
         nql7+yBJgpJujdtfGMFjHA/rZeoHbDV4gQvOXOU2JLUVUC89J4lqfgBONuzIAKw3GTWy
         2i5OMj9k5eNmsZlyBVU237gxiS29wO9vNLvX6jMNn7BtkHo7BXDUwcEsXD4wcIDXXftp
         Iy6fYhp/j7RflFeTRDXzRWLydM2X2vcCFOnLoHw8PF2LapdYjJhzqLObIrP+0VGCDOtF
         e5UA==
X-Gm-Message-State: AHQUAuaBuVrhAWQJGo+gTayEZI7kQLhQKlF+5nIoVBzIN63qMZKblRfe
	yU64RHEfUWm7f/0/txMZrPS+4owZNyBkSyql07siMCtrxu46Yy9qT6SW7LqqEW3baqHKy8lIfe8
	wfjzUynFbSH5uzKCaFF1fycwCfJAVlvzwrJci9B4jBpWtdMwpVb5alaWi8ff8dIoskA==
X-Received: by 2002:a17:902:7d89:: with SMTP id a9mr9724693plm.33.1550502951756;
        Mon, 18 Feb 2019 07:15:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZby3nTHhFDDDGvIBxoAMM1+YICAAIO6GBYnysD2NJ+TuIibS+UCDdsI1Boo29xfRe9q2lU
X-Received: by 2002:a17:902:7d89:: with SMTP id a9mr9724650plm.33.1550502951045;
        Mon, 18 Feb 2019 07:15:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550502951; cv=none;
        d=google.com; s=arc-20160816;
        b=SMH8OH8EPVd8n84N8DoK414wiT3h1rAAy4b7oXYiAnpt2xsSxEJ41fhCGYzbwJjVkS
         pBlJNfyV892l5YKbgqnT9FssNxW0RNFzLp0U7sHCE+mODGSvAijnvnnK1FNg1u53XqqN
         QtoWou5J1TaOu5oe8vAR8jAb0q0BRuwmPTezJAkuVFU7Y8VZdPcZ8aMRrMI4Gxk+crME
         rrIQ4n1C/1+PdAO0yMcF8YQUpnsQWK/uD1DiYLnwD6J9s9HD1ZZR1hsw/YGcpPAm3kbO
         AT7k5/W7pICkq0OLqXsoTr/mJjPHrxKhSfleIZO3wchePUDrykvnKhy/sPkMx0FsYNNa
         FFNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Yd673/bZsI/lWohx4acadJrVu7fDWTLz4coEY1Do5u8=;
        b=zpOs3PTUhh7FjFLrSUc79DYUXngfiDnwQjo2SsgaDK4zivLgaIatGtEXc3wX5bhaxT
         PnbncQRCSTs3b0eg5nxhQp3gu8vBRB1vb1FCvCPt1Fv1bwDJXVPNFeyIS1xUCy5UJ0KW
         ZSw29yjV3B2Kbtm8FUBS8ynopV+I5yC9wVPn1QOC9h4Ogjum1a//9HCbMRWG3kJcgjjE
         g5urX+2sxHrgLQSid6ddOsFW6UZ3tS+7JUG0KpLmayXGS3INBM6zbKEpy/fNKPji3uub
         v82huKoMTmOs41ZhHvAVUhutiG98NlCIrAxXmGtFs/5njUssNj8HyKVyt8myTLX7JeSs
         k9Kg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=R+M7Hbt1;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r138si7362645pgr.370.2019.02.18.07.15.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 07:15:50 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=R+M7Hbt1;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Yd673/bZsI/lWohx4acadJrVu7fDWTLz4coEY1Do5u8=; b=R+M7Hbt1DbHpvsa13LNkodA1J
	+hR4HdHvnY1WV9XWZZdcFeiAARP88JlrqFGzw7nzqksn83w0Ac/q3PyT232lGxzXgbhzCDTRLpUln
	JCvruj/kizM0Lj96FHsMFF9IIshY7lHrECjoSkhEuxbI6akL3CRaSqTrUGfWtMWGCuck2JZQ34vxS
	onhxDsgIHn6KalBJKXZzzqislo6sy4y13wnRJ63c7EuvoEsoI+qYHsLYuom4XC+U7hKI9TDkrRlfo
	qj1lxsctR4QU7CJwReGTIGjzynKIzRgU2zxnNya1ZfgTv8RHR3t8IWTtxWlwIsDqkCJix7/MKlZyw
	tGpDOOzgg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gvke5-0002GP-J2; Mon, 18 Feb 2019 15:15:49 +0000
Date: Mon, 18 Feb 2019 07:15:49 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Adam Borowski <kilobyte@angband.pl>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	Marcin =?utf-8?Q?=C5=9Alusarz?= <marcin.slusarz@intel.com>
Subject: Re: tmpfs fails fallocate(more than DRAM)
Message-ID: <20190218151549.GS12668@bombadil.infradead.org>
References: <20190218133423.tdzawczn4yjdzjqf@angband.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218133423.tdzawczn4yjdzjqf@angband.pl>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.004745, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 02:34:23PM +0100, Adam Borowski wrote:
> The returned error is ENOMEM rather than POSIX mandated ENOSPC (for
> posix_allocate(), but our documentation doesn't mention ENOMEM for
> Linux-specific fallocate() either).

Returning -ENOMEM rather than -ENOSPC in this situation is clearly
wrong, but just about every system call can return -ENOMEM.  It might
not even be due to memory allocation failure ... these days it's just
"I am unusually short on resources, you've done nothing wrong, but I
can't handle it right now".


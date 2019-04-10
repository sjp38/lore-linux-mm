Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF327C10F14
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 06:54:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE7352083E
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 06:54:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="RZyKzm4u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE7352083E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 489886B0003; Wed, 10 Apr 2019 02:54:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4111C6B0005; Wed, 10 Apr 2019 02:54:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D9446B0006; Wed, 10 Apr 2019 02:54:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id EA1526B0003
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 02:54:45 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g1so1061530pfo.2
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 23:54:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=H1C4I3vWd98RJJ8Eta+m72y8iEckfQFBk/w0gj9aw0nWsYQZ7j7tLW3CHH48Gd6lb1
         1Q7QuoigwSMJPLQeQe9VgB1CZfXAN3Ea8oL2543kgZZLtfm5ZREnIpccwnJeOtE7u0u7
         JNcOf2HkcAdgbE2vhdFv+nkP6aPEkPyhvQ5ETDdklwZdK0p6Lm3vTPhngKjPaJlZgRKX
         FM/Kw5AlDr8fgeRFBHdVUM3vmUZBqeZCe7ViIG8yS84402zRZXaWEy1lQAU4CDUJAUdW
         0bM7ExSz3XAGePVb88WiHQV8uIBWYUqFGUUnZcAJ3lJV/MapKAgvRwxFuTeJlg8BREZD
         sf3Q==
X-Gm-Message-State: APjAAAUyp/61lJ0lmcH3TkreRGjUiowATooNPDoaXbCIZM3g3yuRTpMJ
	D7gTSPKs2NLVHgemVI7jV1zrJG8KWz+EgFtlFB6Flkd+uzMUuuac5GinGmz0saaRgRc/42KnoBV
	chALcX/5TONC7p4zobufoHfntzdElxsj4WCDPsC7sL4OZuCNqtUsuFkoJpYRYnCM9Qw==
X-Received: by 2002:a17:902:4501:: with SMTP id m1mr13362562pld.290.1554879285496;
        Tue, 09 Apr 2019 23:54:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0M7OY/am8WadGlu8tpLEpWNIQ9lCigAJf76Q5NfHFf99CRk0juTE0xM9/1DuXjv4ei6GQ
X-Received: by 2002:a17:902:4501:: with SMTP id m1mr13362517pld.290.1554879284819;
        Tue, 09 Apr 2019 23:54:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554879284; cv=none;
        d=google.com; s=arc-20160816;
        b=UfJKdIMgE/AlYwXyJh50I3Q/WAIBVvwRkl5ZLlN/k+UKbo2Z8G9AX36tiGoTvWPrps
         4FZbRGbEvU+Q063uF1nxETx9fN8kZqaZrv7vDncAXYR/k3+wjR1kx3KbNJOwPbsHdyHZ
         J2qwhxh+B8BWFY47gUCg3kKCW2LRhd/FfUDZ6S5qhopEbNH0/q5U7rV7P3UKVMTS+sv6
         UqLRZOqotv7CfIZE/Cz8h5oeGtfGg3R7/iEq28+X0WcD52nR7POyeG+V3Xh8kXSlYk3T
         DQLrfOubOBcfqF8GymaucNODMNnrK4keSIHiy4F1MmqZLQgxVtAEyMxmQ2VTnLRIV7Yi
         TsIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=nTHT9HUiUQBI397tPJXfk8melQB7VHRjjfjX06cFd4/BDceiuJx4LVRDLU1rwlAXH1
         AqOTmT1BLDxRC9v3fpvDzU7wruVMg4rqrGE5c4udKCPUf0NOUOWh7h9D0MQeYxzhvdPn
         oYTyNSQ1QT5W2+DpXptQyshFnnwCtF70uNs6CSWj9yGv4iRyiQs5dPo9TwZGe2qe51HE
         /OGFNUjXa5Ymr7pV08l1cady1sEb8FaLwE+0gnMvir6ZFueP3TyMJIHP5wT8Rm8ayBNt
         +J4idOwlLxfk78KQr1bj0mAMf7Y2KwweBQwbqmAQfghfJZdh9jUQj42G4exFR7+8FfFB
         nR9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RZyKzm4u;
       spf=pass (google.com: best guess record for domain of batv+a16ff09a3038f8df3613+5708+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a16ff09a3038f8df3613+5708+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i37si30689356pgb.436.2019.04.09.23.54.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Apr 2019 23:54:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a16ff09a3038f8df3613+5708+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RZyKzm4u;
       spf=pass (google.com: best guess record for domain of batv+a16ff09a3038f8df3613+5708+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a16ff09a3038f8df3613+5708+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=; b=RZyKzm4u2hUpCKwebzI9rBT0V
	byzRMZTGU0wgRy/lta/IQ19i/ckswBwNHrr6CU+KJYzOzbVzrho7ndTkMN/HPOq9dQ7vDLXInFOHt
	mJX1BQ+7Ohgws7S1+JkKp0YgGfpb6zyPAEiWUukc8uZS9Tehszwf9N+2JCACMK1JOVHcCfQivq8Yf
	OZq2LYHbZMrt9+ZHOMk/AZmcwvECPoO+0kGqbylgtPsPFMyp+jjaMbDHynui5BOKWAndOs4vdKxFp
	3cvEWOBb4gThZA0XlBRs/6wxx9YpfZWxYw3T8MogZisEhC3ZR2QScAjwTzpw2nWeu7hM4VHmjuiSt
	Q/mBi9S7g==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hE781-0000uJ-83; Wed, 10 Apr 2019 06:54:37 +0000
Date: Tue, 9 Apr 2019 23:54:37 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Kees Cook <keescook@chromium.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Palmer Dabbelt <palmer@sifive.com>,
	Will Deacon <will.deacon@arm.com>,
	Russell King <linux@armlinux.org.uk>,
	Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org,
	Paul Burton <paul.burton@mips.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	James Hogan <jhogan@kernel.org>, linux-fsdevel@vger.kernel.org,
	linux-riscv@lists.infradead.org, linux-mips@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Luis Chamberlain <mcgrof@kernel.org>
Subject: Re: [PATCH v2 1/5] mm, fs: Move randomize_stack_top from fs to mm
Message-ID: <20190410065437.GB2942@infradead.org>
References: <20190404055128.24330-1-alex@ghiti.fr>
 <20190404055128.24330-2-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190404055128.24330-2-alex@ghiti.fr>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>


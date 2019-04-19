Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EC22C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 14:05:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EDEB222C8
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 14:05:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="jTOIGU81"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EDEB222C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82D4D6B0003; Fri, 19 Apr 2019 10:05:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DC566B0006; Fri, 19 Apr 2019 10:05:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CBC86B0007; Fri, 19 Apr 2019 10:05:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 368206B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 10:05:31 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h14so3457382pgn.23
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 07:05:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=8GHfViN1qI7tP5bjrRTuauCJlfPJIop88X8YcwvDN6s=;
        b=jfifnZsf2031mpjxsqvfjA1Dfhl39ZYgFMGkxDoLApujwTkbSr/e5PVzM8HKPERXXW
         11yP3j+BHXLMY5b6Krkj/dmwbh8M5F7F49O5jIb0ljSmFmwLKG5YaBSQNRSzW+KVJfh8
         siy+hq6ZmNRuJ23iTVIDew34w7P1HctEvVuGMIhvHkpxvgQTZR370ejsjS/JzapS/uSI
         oekr2j784lZuD89QShwon+3qFx4LYHhoJIUT+0HzQnaJY436QySAIBM4o7YcsJIUiwfY
         ZH3G0jMvtVZYssqI8KeSt+dWYTvtarlqPqfT4WgMLq8+f10G5zbfHUdhT87nEgN9dGH0
         pivw==
X-Gm-Message-State: APjAAAWlbZJk2rB4r3yMqA/J5M2VYEPDrRH9A923MIRC1frwWsyOldMO
	gacpMbAzxx72xB/ls/fHW2FAb8nFpy/wKLyzT7Haz1TBPEp9N8g3K3UASbIt5cxwmJf9sMVAKTl
	e0yrPsH/d/eh/xWszTQJ/TqZ0LWuu+HakzibUUeXjqfhbZzQG4sz+FFgaPAIoocnpsw==
X-Received: by 2002:a63:5947:: with SMTP id j7mr4096521pgm.62.1555682730718;
        Fri, 19 Apr 2019 07:05:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkcKL/3B84Y8AVSFPj1UDPg4D+XQNUdx20vQhXOqWYh5MrmUETdVij27k2YzQ8k6iqTaBC
X-Received: by 2002:a63:5947:: with SMTP id j7mr4096463pgm.62.1555682729947;
        Fri, 19 Apr 2019 07:05:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555682729; cv=none;
        d=google.com; s=arc-20160816;
        b=xJ58xeK9zt/4ue9jtX4dBwd6somYUkLrW9GnOnqLD2egcyG+4MxMXcUqgqS7aTA+uO
         nqvrtS2ltR9RduCY1/nZQAQ4mEkX3DCoYpozcB9snZmyH/bQAmjfpNiNbYRN8ejmcgR3
         tuclpBqF7L+NkTL6zoX+qLkXHezRM+tUJfLIlAaqvyFu5mDlhrQvFKgmAIpBw2FwoKp+
         ik8gwy+msQNmqbaCS/Rf+SwjVhkI0ZnsiC8+HTyp+Q1ESYh1KmZtIFWpJ8locVKjqrYd
         swKTrQlGnJYSCE9RpVcltOgnQDf9ONqMhrcL3NJsNiK/iWVzfI8lBqo4TmcvosK166iz
         jqlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=8GHfViN1qI7tP5bjrRTuauCJlfPJIop88X8YcwvDN6s=;
        b=giGBubPKjXG303lyA9BbyfKEO+9wN04bYphlY0QcGpUcdeJatYTD/gWNBTKrTTRLm0
         8sCU0tmoTYqrUhyiHWW3fo7qdjJXYF02OWrQAIHj8Ai/5JKLckGbKEBVWzvJAhRYfBU6
         nSzzCTdaRWvY4SXCdRX9vt3oTtXHreMtWsghVNWBipvrvHKqCB8J8qYPEtQR7qkXehOM
         58YnwiJ3BmpWAYtWrmrHtFqn3AtZEm62+7U9FmwmpgPOWGhBWeEczKyRbQknNxbD+eka
         cx79b9BEJIzvbtOo85tLcJ1vWXVN9z/1FWBFIh/9xJfrKHlyPzB7CaSw0KoElo7783LE
         YMJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jTOIGU81;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e22si4947338pgi.66.2019.04.19.07.05.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 19 Apr 2019 07:05:29 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jTOIGU81;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=8GHfViN1qI7tP5bjrRTuauCJlfPJIop88X8YcwvDN6s=; b=jTOIGU81UGM+SZeugfFRNRueG
	l6N+dMe5L8tE+LsbrB8ff0RI23zdhq6sMGzaJL9CqIcSoEsKeE+4mKtV6w04nWSC7qRYvmWsX4qVv
	Em6ez34lCyAWPmoo4haiEBl4pAP0PH4JLNkC+J77nltznW7JRNaHYaUvM5IoJDhTTIt9fWrjgAVWX
	Is1aHcSYYpXbYDLQcz5qHAlAfHu6Ej/IcDznFo6/qIoVShfVOmTYM2vgrmAG/mFYR9pCVl8JRV8eu
	HeKPmAjiFhTEbg9PgKdqcVA72Lz8X+M7ZlBEd2a/rQHpy56woJi6su9wdmYLTprp8Drt48ag2WAIl
	/o7GbTcpA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hHU8n-0006OX-Cm; Fri, 19 Apr 2019 14:05:21 +0000
Date: Fri, 19 Apr 2019 07:05:21 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Mikulas Patocka <mpatocka@redhat.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	linux-parisc@vger.kernel.org, linux-mm@kvack.org,
	Vlastimil Babka <vbabka@suse.cz>,
	LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org
Subject: DISCONTIGMEM is deprecated
Message-ID: <20190419140521.GI7751@bombadil.infradead.org>
References: <20190419094335.GJ18914@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190419094335.GJ18914@techsingularity.net>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 19, 2019 at 10:43:35AM +0100, Mel Gorman wrote:
> DISCONTIG is essentially deprecated and even parisc plans to move to
> SPARSEMEM so there is no need to be fancy, this patch simply disables
> watermark boosting by default on DISCONTIGMEM.

I don't think parisc is the only arch which uses DISCONTIGMEM for !NUMA
scenarios.  Grepping the arch/ directories shows:

alpha (does support NUMA, but also non-NUMA DISCONTIGMEM)
arc (for supporting more than 1GB of memory)
ia64 (looks complicated ...)
m68k (for multiple chunks of memory)
mips (does support NUMA but also non-NUMA)
parisc (both NUMA and non-NUMA)

I'm not sure that these architecture maintainers even know that DISCONTIGMEM
is deprecated.  Adding linux-arch to the cc.


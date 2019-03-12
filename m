Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32BEEC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 02:38:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3911214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 02:38:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="W3Al45pt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3911214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73E678E0003; Mon, 11 Mar 2019 22:38:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C66E8E0002; Mon, 11 Mar 2019 22:38:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 567FB8E0003; Mon, 11 Mar 2019 22:38:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 152CB8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 22:38:39 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id z1so1356011pfz.8
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 19:38:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Ok7Jka9kdFefhwhAvAaPL3/12Bc5D9En5EUc/BRhy+g=;
        b=ZrW+pA2QEnG84zo4+7FRXz9TaPMtY7dnJ/jY8q0i0Yt++HtRlWHqp0oDzdnsItP+bs
         iwwazdAu+C33Tktrg7bz0ZhXGpBLdoC2P0lqZivif2hJepIiHFXzOWgauziNHncfjhBn
         WPQw3nnNGSYbSUlFZzM+6v72ZY6cObYUNn74/44WVpb0BcTWsbX5e8LQEhwUxUkLcCg6
         i7nFMYmoY7+AU3ICxNp3GNJf+RaE4qGjvJWPOXcP8wMQDpv4Pqal4cvwT3jkdRVoSSxI
         TXYZVk8jE7YsucE085LCojK3vmknjt8AfI+uGO+QGnAB57I79Sc05i2ylKvK8NUNgx7f
         1vUQ==
X-Gm-Message-State: APjAAAX7EGGM+W3uf19swKdk3eAI2B3vLVpXEEJN3eZ7zyv9XuTcVYGk
	YqJKJwNL2ZZ+5L2jojgErAcAXLlcHJ7oTK0oXehbo46/AdKiywEnA63B8RI3lnlSrtCgWS1YTr1
	Li3HfBj/jCu4Zgkj1kjFppqpLKbcOgEteaHhkrT0y4FxEA4tlAkB0zMFfNh6vvt0XnQ==
X-Received: by 2002:a63:5318:: with SMTP id h24mr32916543pgb.76.1552358318765;
        Mon, 11 Mar 2019 19:38:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLWDMRw2Z824j5NFtvV+3NtxzqGJWv+G4BhtHzLy6J2sEoCqq4HMG5P/cq0+r/AtR2Tt6+
X-Received: by 2002:a63:5318:: with SMTP id h24mr32916476pgb.76.1552358317697;
        Mon, 11 Mar 2019 19:38:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552358317; cv=none;
        d=google.com; s=arc-20160816;
        b=dZNuJfGtVo0BNqkiJ0BNZ3cJHwplZzALU2UwqTMPpFwLGmQ8VahkCHNiQx1XHj9fxJ
         eOQakAsWxAg9GUL9UKC1ke+evxs4TcF2ePZGghN4VUVOs+CQZvi8D9JFJcubC3q8+z9x
         3vwlWFxYwyRy3JFvPXAm1DejkJeFAokTp3UMzb6fs2w+lZtQjCU9M+vuTsTMNo71j2ba
         k8nGFOYrLhQdIWe2YW8C07MkVTXJGEuk9v6ZGr6wSfRH/8Npi5lCssnysPlLEmucZqzp
         31UmxgTQ8z6TS8Gb4LreX/e65Z0pI21xqzDYQixMRzAhqgJDUJxWTUcpAfU3ADn4P25t
         lxrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Ok7Jka9kdFefhwhAvAaPL3/12Bc5D9En5EUc/BRhy+g=;
        b=cSaOE5IBhCchiW0ndMBZRgT9oJ0VMQ1O+1JFHzUxy/uEPieafTm8mOQnxqHSgpqY+L
         ZaWRiZLWaPgMqU7/+2YcEvS5FjCviOu3dkeHlSezSo2BJ/6XoaIYo+rd5joJj/uEzN0U
         HuIWqNqMBf/0JO+jeuNigek2K/TPeGFSE070MTPsFherHbwSzR7DBsvc5BI7vMJFiXPl
         5ISzyAoDkoEBwHPrbccORa6Y8yXL6MGQmh8bKP7zdsNPrxJdkyFwDMtExgJ401h9UmUt
         piX4xHyLaelo3wSmZ5JjkBufwowRUQmUjmF1H7lKmwg+IU9gS/hn4p+u9njJsovm0YKv
         vk+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=W3Al45pt;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 71si6453300pgc.87.2019.03.11.19.38.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 19:38:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=W3Al45pt;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Ok7Jka9kdFefhwhAvAaPL3/12Bc5D9En5EUc/BRhy+g=; b=W3Al45ptYcop7XvpXCgnlleG7
	TIKOrvpx+7LOVG250M7sMevNxQZoQ627xff+ixZVyFr0LG/dt5bqM7C+A73yF0Asx/TzkJYe8YFkZ
	rpWZ9Js6X0PpFSegVFkfJ5pBRJmSsn10l8TdOxPuuHQ8dD4E+nvlvA+OVTD39oNZb6/HMgL0f4+i7
	8fwJTyt2vvpWbYpjDIqr6NJOtH7Ks6Ng61NTZoPZ1LYTT9VDWoDXMAmfmD7lLFVdf9gN9YPFlhnPy
	E79U6+f5j1u1JpDEDey46Fdjb4fWyKUVP+OmB0SEsez0rit5VpJIV2ib4F+rFxmQzOcTRAy9awN/b
	DMY+a1QUA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h3XJE-0005kn-RB; Tue, 12 Mar 2019 02:38:28 +0000
Date: Mon, 11 Mar 2019 19:38:28 -0700
From: Matthew Wilcox <willy@infradead.org>
To: "Tobin C. Harding" <me@tobin.cc>
Cc: Roman Gushchin <guro@fb.com>, "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 0/4] mm: Use slab_list list_head instead of lru
Message-ID: <20190312023828.GH19508@bombadil.infradead.org>
References: <20190311010744.5862-1-tobin@kernel.org>
 <20190311204919.GA20002@tower.DHCP.thefacebook.com>
 <20190311231633.GF19508@bombadil.infradead.org>
 <20190312010554.GA9362@eros.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312010554.GA9362@eros.localdomain>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 12:05:54PM +1100, Tobin C. Harding wrote:
> > slab_list and lru are in the same bits.  Once this patch set is in,
> > we can remove the enigmatic 'uses lru' comment that I added.
> 
> Funny you should say this, I came to me today while daydreaming that I
> should have removed that comment :)
> 
> I'll remove it in v2.

That's great.  BTW, something else you could do to verify this patch
set is check that the object file is unchanged before/after the patch.
I tend to use 'objdump -dr' to before.s and after.s and use 'diff'
to compare the two.


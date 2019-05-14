Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8A87C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 14:51:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C11D2084E
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 14:51:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gb7x3Pu7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C11D2084E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2CA56B000C; Tue, 14 May 2019 10:51:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDC706B000D; Tue, 14 May 2019 10:51:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCD006B000E; Tue, 14 May 2019 10:51:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A711B6B000C
	for <linux-mm@kvack.org>; Tue, 14 May 2019 10:51:32 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h7so634298pfq.22
        for <linux-mm@kvack.org>; Tue, 14 May 2019 07:51:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+TUPqPPPr12XyeZ6xdxOXi+1ZKOSa1ZmLZ8Ram4qMHI=;
        b=NoUkcFPYWt76sy40FKSMDhUIR7Kq2mDYNlve6KBBqCGjBtXbeaDonq6OcBFDsdUPud
         bYj9MC8zYyY3BkFHzz7SPsAQThThNq9P6K7JF2tg88vdF5nG8JwF+V2vsCOGFs8MA8RM
         xpumN68avhY/Q8/R2R3nsrzncgp9lOijJMX5Vtj+ZbvR7evTWUsMTMniAnOXaFHLeGxB
         +AiZM2fVVrNeBgDxtxAU1+SeznyfjCwTqP5/iaYD4OFtfaQyo/hIaIqK1SZp9oQw/8+F
         YNUPMJjSGPzA3Rn/B05fZCPTn/8sX3SG1xY23JA1kStwhjyZpvo+CDvfjK45/0mVcXko
         NpgQ==
X-Gm-Message-State: APjAAAU5xgowvUjpEeR8VH/G/T0e2mRLdgKH1pjZA23KS5x07NWO+Ygf
	Ujqj38IubpGATwSvcWI3kWcaMOJ1BXl8jDWX3zAlU7cdLRIsO81UugL77vc6tH1/J6DNQa1bxck
	pcMMfkPHlGLeYseWLzNVa4WJ54iRdmUCPDaUAyVfaJ0TlZsNjW8AxfLTmqUpO/sVH9w==
X-Received: by 2002:a17:902:a585:: with SMTP id az5mr37734207plb.261.1557845492110;
        Tue, 14 May 2019 07:51:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXjJZMfaPu2AiXXxo1kNU1qqLiw6N1QHnSnCArZXnJQAKfDn9gArANpETTB254pWBUCV+k
X-Received: by 2002:a17:902:a585:: with SMTP id az5mr37734159plb.261.1557845491457;
        Tue, 14 May 2019 07:51:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557845491; cv=none;
        d=google.com; s=arc-20160816;
        b=Mn0DNjqeHIhaGOhU70+1yyjIu/B1PbCfh8b8geJFFRCx7w7EBZapQVHurmebnv/KdH
         BzlIgY35zz0MyR7y1XBFIXa9c3aNV+A7PdvAkbxCkDcFxsuJXj43a3QA7bMjHNA3rw+f
         RCYGReMMkA8EVUFienxT+OW+hgOLcwqF+ThythGr+LJKWZGSGwkI3nRIkMtgCUj9Urn5
         7vfeAW72S0PnzZ0SaIXuR3gO+jQqC88uOBCP36/QbB6aKLwPBccSVD/AXKbCXFtaU2rP
         LozG/sSj1gwu0/SD9gdFZadwY65o9cowIbOwwgCQogMjUVl93cOQKvnr1qbv1vKkj43Q
         WZKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+TUPqPPPr12XyeZ6xdxOXi+1ZKOSa1ZmLZ8Ram4qMHI=;
        b=nYxAedbCfBQXEtAbNmhIEIltlheKc9DgetYt6oLo/fi/lcDIC9+iUKEEDwY7+SGi2+
         I4qjFF0DkC517o8Djm0Qy4grVlfyRwpER+UVHtBsfL2GBf9G80qiYiACrPFAA4qgIocC
         F1H7aSBQDwfGImXNe/s5C8E5jbj8q8XavtVo/aJt7wUHwUUAgnHPzTITv6vo38OpK32i
         a7UrVYziRm1zIEVuqda4nWFRlns9zAF72uUR0uP5CwM7by99i43gh0T7Nxybgt6YCbAZ
         FSN3eq2B259F971RHkMaj836fvNYec4Gd2xNjE1PG6klerfJ5U5w9Aa94nJscyCBcbvA
         1Q8A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gb7x3Pu7;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h3si20409597pls.408.2019.05.14.07.51.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 07:51:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gb7x3Pu7;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=+TUPqPPPr12XyeZ6xdxOXi+1ZKOSa1ZmLZ8Ram4qMHI=; b=gb7x3Pu7vRAJZmvSl3U4z4CT+
	qUcMk1Dz44VcyBYbzNE1WJpG1UfEHBwMAYQPY1chtp7OpZ7gsLEbOVZn9b2etz3KjKkR/MJCj9V/x
	ENBe/Jbx0AFLkOuJw3Trm198m6eHcw9bGvFTF43dnTuwOYpi40aFPher2K5QrBoF2SeYAgzN6kw6z
	6j3LKZQ4Blqy+ikTMV6ihyS9/VdNuDWFgqEaXHDcyOSDffPuLrxrc9Tkqd+wmnZ/IoHnNsggQ6UHm
	UYR2Xe+5O98yFNOduoIaE33KYzocYhGkEBvUCTt5AdgUZFj6hJb3Lv95fIZkZ5NArL4CFc7Lfwc1J
	95D6E2gKw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQYmA-0006Vl-UC; Tue, 14 May 2019 14:51:30 +0000
Date: Tue, 14 May 2019 07:51:30 -0700
From: Matthew Wilcox <willy@infradead.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org
Subject: Re: [RFC 00/11] Remove 'order' argument from many mm functions
Message-ID: <20190514145130.GD3721@bombadil.infradead.org>
References: <20190507040609.21746-1-willy@infradead.org>
 <20190509110755.v4dzyophpaoinqhr@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190509110755.v4dzyophpaoinqhr@box>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 09, 2019 at 02:07:55PM +0300, Kirill A. Shutemov wrote:
> On Mon, May 06, 2019 at 09:05:58PM -0700, Matthew Wilcox wrote:
> > Anyway, this is just a quick POC due to me being on an aeroplane for
> > most of today.  Maybe we don't want to spend five GFP bits on this.
> > Some bits of this could be pulled out and applied even if we don't want
> > to go for the main objective.  eg rmqueue_pcplist() doesn't use its
> > gfp_flags argument.
> 
> I like the idea. But I'm somewhat worried about running out of bits in
> gfp_t. Is there anything preventing us to bump gfp_t to u64 in the future?

It's stored in a few structs that might not appreciate it growing,
like struct address_space.  I've been vaguely wondering about how to
combine order, gfp_t and nodeid into one parameter in a way that doesn't
grow those structs, but I don't have a solid idea yet.


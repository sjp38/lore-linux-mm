Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36F53C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 10:20:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD87320873
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 10:20:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="NgebHSNw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD87320873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BB056B0005; Thu,  2 May 2019 06:20:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36BDB6B0006; Thu,  2 May 2019 06:20:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 234276B0007; Thu,  2 May 2019 06:20:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE2C66B0005
	for <linux-mm@kvack.org>; Thu,  2 May 2019 06:20:25 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id j1so985259pll.13
        for <linux-mm@kvack.org>; Thu, 02 May 2019 03:20:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=BZ3UM29LlTMvKG0ZuhdqBuLexLkqyCTHtEkADaQBuXY=;
        b=LCzQZwsx/kR/VSS8wzQoV9u3SFYJdCecnIjhhCwAHUd3oklg80elxppbXFcFtQXNda
         Z39h/azaAXYowHb0t/vDg1lqvwBO/KsgEll5YWJ1wza+LEPN8TKBC+vn81irUrcOZszX
         AuDhrMeyxiE/PW/mF4y96/TR+orSIZ+5Ls7MfgLD5oyXRHmTXBOjs0KjTNgvZu0c+ms3
         CXyHbWBt3A08SSpQ/DQcJsDrfMpHQaAaWb6dvYhNcmR26nwMulbZrNGyKfihDsmP7mlp
         EGKynAQ7Z3itdMtTGQXU5nJqrgacokek9o+/5DuG62WlBOzOTFwcEFInSkpoMVZv8b1i
         jQVA==
X-Gm-Message-State: APjAAAUI7krStxPgYrPKX1XE6tjnDGkmP2LsmZTT51hHrxhMPfcsVxsu
	BhZ6rtApBbwczptwbnskQkH+uJusq9U0ABPLYqQ0zQJFURHNw7uG2fG3RvN7X/0CzOfhfB4FeTE
	onwujVq1OezlwXagO0uZu7XANIo7JaK+kdHdbIhwzpKj5iYR9j28rfMMOFAyaweYdWQ==
X-Received: by 2002:a17:902:567:: with SMTP id 94mr2841163plf.120.1556792425560;
        Thu, 02 May 2019 03:20:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwqqmSXZZiKHeLxV1mzgGrt7sMPh3Wy2N1cc9pFM3TeUefhPIRJxPAn/w6o/KwsitqIayX
X-Received: by 2002:a17:902:567:: with SMTP id 94mr2841100plf.120.1556792424806;
        Thu, 02 May 2019 03:20:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556792424; cv=none;
        d=google.com; s=arc-20160816;
        b=eyVXQ94t+i/Rj4BUAxMTjwTGIAsUsvGMdq3/tIrCkGA1efilF1HQFBr/+MuzAB6exn
         nuzfBBWKL/oN4MRjFJqkAMAinu6MsQsvC+BorI3zjcoWFdV/sObQQ4qAM1IKkEDtDLLq
         5FVbPPV5QGDtbzfoAwnqyNWEtu1FQHAuUxbgkIA6p8COpFJ95K9v508zpfAycdctYEh/
         kCtghZELaBxjaZJdtK1M+NPNdQutXF/JtpDUfgdSK2pwzgEdblqBk2uRrlJpEh44olsE
         Aq+/GVTPATxVsDDGzrDcadcgRlciHe3iZlGCYPMpwbw94XRw7ePVso55dqjGoIXPvz4w
         h/Ug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=BZ3UM29LlTMvKG0ZuhdqBuLexLkqyCTHtEkADaQBuXY=;
        b=UbwGaC1co0TN97iYPXx36UOdhUPUw+P6k57kqIVfkQG8mW2pUi58CuGYXXc3oVjR53
         ErWyV19v6KNCRWzU1LRp2LqJU1JqqxHSUvTtr5zKk9ui2u/vbYusoFPzm9oSKxbNO5fS
         bOjKBiZQ2e4q36qFNpC++M25Wd8G8/dv6BXeLzelJr/insLbx26a3IpWYgdIxMx/I+2E
         muk0YuPoaupngeDCTQ8Bu6P6oafRGqMDyAp+AFYcX/+463SciX8ApyHzlpn60fllGwnA
         QAdyP4tVLMOLmoa1awQY++eCn9Rw6x00EY1pq5fu2CwaFseEpFtTSvXwbX1DZwwJRoGD
         rbuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NgebHSNw;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o64si43965933pfa.274.2019.05.02.03.20.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 02 May 2019 03:20:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NgebHSNw;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=BZ3UM29LlTMvKG0ZuhdqBuLexLkqyCTHtEkADaQBuXY=; b=NgebHSNwQgTcd2GkI6djqj9ph
	KvuJh3eTipixESblBd7Dedi7npgGxAXtWGg1jtIv0ND9AX1BNT5S/E/gaGelpZan04UJGJTOPYxMY
	Vm87HfW7NwRqmK67bzlth2PpbH4rNf4n3iY74cE0RSohIwQXbLYJkZTm1O7nia96VdK4Xz9ogiVBB
	TBYbYTGvgtrri4kVLQfd/HxU5K1PBpkzKMfrlleKxCN2/yFBffRgua2vE3O2BYkxcG3gmDU7FKjev
	tjBfLaDLbPtYludmF9v0L4P3r4H7SUY0YWLaiaoLTjj49x9Eq35Lh0OK8KXH5OTsgGBNrcUH6rhNm
	hAeVlE67w==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hM8p6-0000QX-6a; Thu, 02 May 2019 10:20:16 +0000
Date: Thu, 2 May 2019 03:20:16 -0700
From: Matthew Wilcox <willy@infradead.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Sami Tolvanen <samitolvanen@google.com>,
	Kees Cook <keescook@chromium.org>,
	Nick Desaulniers <ndesaulniers@google.com>,
	linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 5/4] 9p: pass the correct prototype to read_cache_page
Message-ID: <20190502102015.GC8099@bombadil.infradead.org>
References: <20190501160636.30841-1-hch@lst.de>
 <20190501173443.GA19969@lst.de>
 <AEBFD2FC-F94A-4E5B-8E1C-76380DDEB46E@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AEBFD2FC-F94A-4E5B-8E1C-76380DDEB46E@oracle.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 02, 2019 at 12:08:29AM -0600, William Kucharski wrote:
> 3) Patch 5/4?

That's a relatively common notation when an extra patch is needed to fix
something after a series has been sent ;-)


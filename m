Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEA9DC10F14
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 06:59:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EE7020850
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 06:59:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="HBYgeKPO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EE7020850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1ECF76B000A; Wed, 10 Apr 2019 02:59:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19B006B000C; Wed, 10 Apr 2019 02:59:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08D816B000D; Wed, 10 Apr 2019 02:59:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C28F16B000A
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 02:59:35 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id v9so1250418pgg.8
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 23:59:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=fFE+9/kOp4OUWfRO+WWISESZEfgsfvM0ppkCR07sd+82gqT9vcoEhLOxd8Qdx9TS5S
         tt3TBVB48JAnMKiCTO0rJTJMiTs1sgECucUvkBXA4+OgBqM9TCeu2pWyQvmWEJQUSc5W
         KR29HGZKEMo7D2S7aa4h/KFY/CZQnE8C5VMXUlDlSZhhnmkoXgCE2/ai0Y/LvX4AvqfS
         P7nQjRAPvRMN1czKb1aUxU2IZ9+CkH+QhjRKJ4HaaTVVUQ5Sqi13NhwPRPJXX9nUow9M
         6Z7uoZ3RdkzxZOSm+NM1IaDa+FMXHxoocAwsNQOxB1m70MMw11FTB8+q5nZ61hnTeHYr
         SL3A==
X-Gm-Message-State: APjAAAX4ci2aZDV0HsoFII79FtIyIwmaiOKunQs+8D8mLzZxF2B+yUjb
	/3/p69P3Lor1aCRQlKmTZg6VEufsUXep1WVAxGrAPDsJ8FCGA0xtzJOSiClIHK5NX2CawVB43WL
	v4P6i91IbigDKsjU0FfqVguqO1n+BwTK0Kv1ZEbvI24dN/j/NazFvK7g8tfevq4ASxg==
X-Received: by 2002:a17:902:4381:: with SMTP id j1mr40246931pld.75.1554879575452;
        Tue, 09 Apr 2019 23:59:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzO4ccCv2Pus0z71WBrHNdLwcYZWwmuoSKbZiZzeKCVoCHAKhbOBUMQSqaHkAXxdbYY9EWC
X-Received: by 2002:a17:902:4381:: with SMTP id j1mr40246902pld.75.1554879574941;
        Tue, 09 Apr 2019 23:59:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554879574; cv=none;
        d=google.com; s=arc-20160816;
        b=rLhMl0a2p22IgTExdMvm9xiQ4EGJg/fRw8XA2XYb+rmktm8Z2ZJxR7NzAxJt1UcwA9
         6uoWKwYCT6Dj6bEQKwfeUa881GHWQY3BRMdntw1l6iUGUBIKTWTHH14PyTUgrxTa9+3g
         Pw9oYsQGbmL2s79MNFIz+njzqQy3FSUdHcGg2JRPsg3rvBlvPdsoGcducyRGgjqqE6f/
         DNN7Xt5ODqRUz9ptPHRZrfCql99hl0mz/dQao+NftvgV2dj9Zd22agJ5ix26RsdO5VNY
         sog4gbIXdSAt5LMQlnDt5TnXws3VTC9Fo+8gClMcYJtYepT8Lax5A2poRmrf310dejxH
         8wOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=KixP0NVbsZytNe1gh1NGS/95F+Mh24RONWGhsWqfv02OJ04dsDIsyZLrpwDBtWAmyB
         O2a5dy6Au/lgfOLiMTTEjIQj0sTdMz7RfKWSsfnVL1H+qvrF+0lfU0jnAmGT2Dc7tfrZ
         ph7i9cD8zJI9QCJam/O6MOxaKw7lNoxTJWGsRVfO3xvyuy4urUBpQpFQUO/WRzpZyc9B
         wEvTlazJymBm1U2zWxUH+8EuFCireCs6j0HTN3WJdAI+o1xwIqV65rlNW4C1aAK9rLFR
         pTb3KIB2K9WvkGxotE7CQI2PGBePrADCLiIekYBMBpAnI4r3oI4Ze4xba90Zk+SmBYMj
         oDEw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HBYgeKPO;
       spf=pass (google.com: best guess record for domain of batv+a16ff09a3038f8df3613+5708+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a16ff09a3038f8df3613+5708+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 2si4447970plf.294.2019.04.09.23.59.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Apr 2019 23:59:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a16ff09a3038f8df3613+5708+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HBYgeKPO;
       spf=pass (google.com: best guess record for domain of batv+a16ff09a3038f8df3613+5708+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a16ff09a3038f8df3613+5708+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=; b=HBYgeKPOdkpup2ZwGf/wNMi1k
	YE2XTsEtQr9oixczaj6gWzM4waxp/O0RAUD/tZWZvCpkUFvmXar3GGQkJxTkO1aUeOnZETWBh3ctH
	42HTlzYqzu+DIZt4C5OLcLd4zMrZ60Y5U48K2pinODd7NZRWSUaTCpaM4cc85rblDE+ppjNqsZ1iq
	5qj1sv3ZwJ4wSkOowWxUo7z9+BEbni/LpTY8G1irI8smfCCOWkEUVyvbFrjHyjB06pKs7oIA7VzCH
	U5TYOKzECkTD1T+rRUTgIJusV9Vs4rYhDw7JLZJw1SgciPZcy48BJfawhuFNttB73vwIOz//Q72OP
	yJw/rU+hA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hE7Ci-0003pQ-UV; Wed, 10 Apr 2019 06:59:28 +0000
Date: Tue, 9 Apr 2019 23:59:28 -0700
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
Subject: Re: [PATCH v2 5/5] riscv: Make mmap allocation top-down by default
Message-ID: <20190410065928.GD2942@infradead.org>
References: <20190404055128.24330-1-alex@ghiti.fr>
 <20190404055128.24330-6-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190404055128.24330-6-alex@ghiti.fr>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>


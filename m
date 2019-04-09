Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53ED8C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 12:13:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2E1020857
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 12:13:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="uYWG8C9f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2E1020857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 401C56B000C; Tue,  9 Apr 2019 08:13:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B0B46B000D; Tue,  9 Apr 2019 08:13:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29F2A6B000E; Tue,  9 Apr 2019 08:13:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA1816B000C
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 08:13:23 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d1so12463420pgk.21
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 05:13:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=VRvsXTQ3GjdpdN5n2kYCn2enLOEYsHiI8Nby7QD3k1k=;
        b=sAuz8X+DW6uotV2lkb8oUOrm2b7K2S8TpUMQllf0S06FJYR/2S03f4PtW1St31ZocW
         lt21e2m/gh9BM9x9DjHFQIR0Hyd4+9sdAw9DsSacdqRrnpDE19GKDAK5oMhYRL6kQhxh
         ETa6ThN40zU+RxTCCxBNHx9wOA5wHZjrhuyrq81kr2BgUFdnYxV5PSeqaprmDV938xhB
         xUuaI2/SDOIYoaqoh/rptGgJmYO0UXemcRoFkeyk5g4qCeFS2zDTx1acPPiE8l/Y9e/g
         rpsTyV8SmO2SWi/o27sYo5tdGOJJBvH2jCATulKKtTLhbTXar2fUkNA78neI4GAEulsA
         p6AA==
X-Gm-Message-State: APjAAAXdv7Ksuyvp6jYUy9iQoveW+5qyhlNIXb1LlUHzqKrALx891FOj
	c7ubf6suUKdAXCqBIBq3/lAzHdU/7wRFAod5cg0kGcnd5NbcP8TKDnr2NKPSlAK0EwsEo2g0iyP
	zZzIZtT9kCPk6H7TPEicpBygsneWppi7G9ZDu4uOvTm0el0na0LSNmB6t7LWFFJXAFg==
X-Received: by 2002:a17:902:2ac3:: with SMTP id j61mr37121145plb.112.1554812003268;
        Tue, 09 Apr 2019 05:13:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTQaCfDs0KYqadBvc8lFwNG+z2vUjFHrGt8mf7h12r9Ku9lKk9hUShMnZBHxbFt1J+3xcr
X-Received: by 2002:a17:902:2ac3:: with SMTP id j61mr37121064plb.112.1554812002454;
        Tue, 09 Apr 2019 05:13:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554812002; cv=none;
        d=google.com; s=arc-20160816;
        b=Cl5lKODz+gFGxPZyfSHPStb9cNkvuvHuwPnD/r6lQYoPLYDLJ70xS9Wt8mjxIIQUT/
         YBvsCcB2SPqHD9p2jAek3EEormBqRlJKpbb7ZnHDvPJptsM+A4gDIMK4BZazo/rO0aSD
         85BVNyP1bxYl66/ZaEsakNs2sal79hbUTUmLt2GcldqfOyDpnQZCsd2b3YhXmHTzbUL3
         RGuLiPbAwK4FMvc53u0usrVU9Y4l44w1UFi6tr/uph4iXtBhm3bNvkeiW1ig2cb3XJhy
         UforjtXY0KqzASWoci+kBCUvTAxKw6O1nvhx/bM1sqeyTvm3L5XYhx87lH/rNiFAQwoC
         Vf4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=VRvsXTQ3GjdpdN5n2kYCn2enLOEYsHiI8Nby7QD3k1k=;
        b=LEarxJIrbCS35dApvPIjSX5KFqpyd+aTLSqQJLFybnUIbwUcufiyywbOFUWuI8x5YW
         8Mc7k4PlBCopF9sFRLS5mSXAQWCeRgbDLabYuBBJveGYzDOPq9uCEkLpnxnT94y0Yg9r
         6i1OZvFCOMgZAYNWWOkPPn1ip/PY7Dyg3pFHET4ZfyRPinsvZwJVJOh6jrW8uNJ2daev
         rX+XVSuJoJHP2aURV0XhDXrbFcNm/Lw3fO6sDeutKO2/tWRfzKi9dHWI+fTYxKr5m5Ov
         eiN+S0sLsT5BMg1k0F6ex9WmW4ulZUWkkgxlJqHjknL9asfsp7Ug2k2G8GRRSruYGmI5
         oUoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uYWG8C9f;
       spf=pass (google.com: best guess record for domain of batv+31c75a5d3837fdba6a7a+5707+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+31c75a5d3837fdba6a7a+5707+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z189si13025311pfz.126.2019.04.09.05.13.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Apr 2019 05:13:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+31c75a5d3837fdba6a7a+5707+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uYWG8C9f;
       spf=pass (google.com: best guess record for domain of batv+31c75a5d3837fdba6a7a+5707+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+31c75a5d3837fdba6a7a+5707+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=VRvsXTQ3GjdpdN5n2kYCn2enLOEYsHiI8Nby7QD3k1k=; b=uYWG8C9fa2W/1ofQ/6IyFNpSO
	iu0V82Kq9jQiAgCdfjkjKw22uXQPkJMHiYDnFmiTPazLx6S1iUbd6O2uU8UWQKigb3LKxiuwwUlgJ
	es8/g9LVDGAPfERmZO5jE5hTxgoi6XD/ZKl4vUm6HU9Vgn7BVC8C9//Jky9Rgcs6wTYggR6JnbTeq
	MWCyz+g4viZ43BaZzTYSyJxJllb79/Tb/Qe67urnB/U0sXvBsdb/B9KDgv50dFC/hm4lv0N0KOBtn
	Jnyy1hwkXfhvsJ+jySxvJjcVAg8i8swVl0wtetpC1Sf3TQPK9jPuJvRD0I0ZclNbO36pE9UmYfddb
	BR/4NS4NQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hDpcs-0000al-IJ; Tue, 09 Apr 2019 12:13:18 +0000
Date: Tue, 9 Apr 2019 05:13:18 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Len Brown <lenb@kernel.org>, Keith Busch <keith.busch@intel.com>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>,
	vishal.l.verma@intel.com, x86@kernel.org, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org
Subject: Re: [RFC PATCH 4/5] acpi/hmat: Register special purpose memory as a
 device
Message-ID: <20190409121318.GA16955@infradead.org>
References: <155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155440492988.3190322.4475460421334178449.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155440492988.3190322.4475460421334178449.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 12:08:49PM -0700, Dan Williams wrote:
> Memory that has been tagged EFI_SPECIAL_PURPOSE, and has performance
> properties described by the ACPI HMAT is expected to have an application
> specific consumer.
> 
> Those consumers may want 100% of the memory capacity to be reserved from
> any usage by the kernel. By default, with this enabling, a platform
> device is created to represent this differentiated resource.

This sounds more than weird.  Since when did we let the firmware decide
who can use the memory?


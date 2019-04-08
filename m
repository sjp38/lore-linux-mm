Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 718DFC10F14
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 14:13:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FBCC21841
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 14:13:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="LxXKg4kW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FBCC21841
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD2896B0005; Mon,  8 Apr 2019 10:13:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B839B6B0006; Mon,  8 Apr 2019 10:13:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4C5E6B0007; Mon,  8 Apr 2019 10:13:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6833F6B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 10:13:25 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id b12so10564251pfj.5
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 07:13:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+reI6IWjQov4mB0Up+1lm8sZxqlFGW/kzlH+giQh14c=;
        b=ol84ySbXdlklPXaqvy8adDmsuAK9g3zHmIE1LzC7sgv+djkYKKEnMEOm8J2ks2MN4K
         ol2+7HW4j70MsH0pSMLGD42vPnLfJGZ3r0ugK1X1tWRZ30YmPvCVMtqprDghgjZy1LdC
         JPrfOxO3gmRFUSNeE7yVK7Wefez6c31nZPfUkh75hN3pr691W9PeckW4NT6RiOp+fdZd
         mdOPk+kQ3MCuB7mIT6IHkCT4SCt/c7r+evxJiLBWhZiPILc3QEGrppPrNBwHW4NtaplF
         jHco4WIk1xDOB+MYt0WUY736JHB60kyWtufikqyWnNc/IxyH6QvbpFgGmQob4BGr2TiX
         lD1g==
X-Gm-Message-State: APjAAAWJEscSi9HzoDZC9ZIiUCaQRO98cF3JRXsIDMleYty3wH54PvuV
	s3SD3SsdeNPA0Yw3PjAOCZtbKAW6eiyR27bSqO+siHrm9Ieffj8lgq5GTiXe4r8vXnwZuP0Y8jP
	oAnj1n4A6CSAHqaVtE3HD9AQ8Kl6KvKXDvkxImh/cwT74ygsBiNOzuSGLHRB6Z+WQ0g==
X-Received: by 2002:a65:65c5:: with SMTP id y5mr27917206pgv.192.1554732804950;
        Mon, 08 Apr 2019 07:13:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjbN7p3z4Y/kYjG6PhZ1iXzy3urvS+rgbdNt/PADH7GvcKqoezaNhHLlEmmOLGZsaRX7PU
X-Received: by 2002:a65:65c5:: with SMTP id y5mr27917138pgv.192.1554732804214;
        Mon, 08 Apr 2019 07:13:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554732804; cv=none;
        d=google.com; s=arc-20160816;
        b=bnLc7/SfMKZInkB1ctOuq92w40KA65i3QYEUYuh6xgnZtsDArAq6wQtd2ox1aEygRB
         +nyS8w4o77J4AOQXP84O/LkTDywBE2pV8VTBBD7IZ4wDa+pbG10xZzME8XkmJGD9bkwl
         nBUh168t1KZYt26zJSFHJrKJHhXjdNygVET600f2fC5GkrPqLhWJlq5sJZ6JhTsLai83
         sUnYxHLDfl0MrMaG00EIS9Uh95lf5P51k9TmtJXHj/hNkpOwt1Nk2ODLgF6IdtKuJlWl
         H9guoIAoR94w9d6SjvanFOG4dZQY1RhuuBEV0AKeGVYOXGsZRIsTTrtkAcIE/ZWV17N8
         7VGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+reI6IWjQov4mB0Up+1lm8sZxqlFGW/kzlH+giQh14c=;
        b=C8KQbS8qmkiU+0+K78fys+jNyuTt2GpIUoIZI5E/9l3RfurdqkHyV+XnJlDwtH9SOg
         BBD3h6RZBP1+esY0YUkcs4NwkNE4XfUsyIwlz9oEnRygg73p2xs2h0jS4tT9H43sidXf
         j4+SD0iIedewjmkQEoLb6AKcADcAz9OaIhzuNAoT8bM3xt023XxsbT5sk++vAnXKN0GJ
         4KK3ZDy2FEa2ReTOSElm8gygfY0i2fey8S1JVM5EBl/pmd4dKm6CO9hiS6w5ACPn2bMM
         +ZrpB7+cFFGWQOQVX/HYX3TDsmeBzdfRxD7S4sahZVaqk1j299jqYjVsVP6vUVKCp6tb
         ERAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LxXKg4kW;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 1si16117258plo.217.2019.04.08.07.13.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 08 Apr 2019 07:13:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LxXKg4kW;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=+reI6IWjQov4mB0Up+1lm8sZxqlFGW/kzlH+giQh14c=; b=LxXKg4kWXS+faNbwg9ehOyy7I
	ykui4EQtxXgWSPztHpHwAaSTZmBp8YI+nN5EgmMkzTz45HBo/N8Y0lbq1ugpo9vnAPKJeADDq0Hq/
	7uGezLBTg8bBVTjyZVPP2nePjTScdPOx9qapOgq+slTxvf1gFc/aHpKUUh/Z9OPYVZKWVFeKZxzTD
	cqqfKJmy+t0CQRofvcimWJ7tpLnxQQPpiiHf9ikR6k1fQx7/waVKLRgB9x1L1Nek0qtOwYq1mTqeg
	BOKtO2kTqCEEjJ0fLVxOGjFtHEATp7bjbthy0i4SnELwcCC8NN4V185M+CBfpND7xDRDxbd4QnkuG
	aDvpTksyQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hDV1N-0003P9-Lc; Mon, 08 Apr 2019 14:13:13 +0000
Date: Mon, 8 Apr 2019 07:13:13 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Huang Shijie <sjhuang@iluvatar.ai>
Cc: akpm@linux-foundation.org, william.kucharski@oracle.com,
	ira.weiny@intel.com, palmer@sifive.com, axboe@kernel.dk,
	keescook@chromium.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/2] mm/gup.c: fix the wrong comments
Message-ID: <20190408141313.GU22763@bombadil.infradead.org>
References: <20190408023746.16916-1-sjhuang@iluvatar.ai>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190408023746.16916-1-sjhuang@iluvatar.ai>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 08, 2019 at 10:37:45AM +0800, Huang Shijie wrote:
> When CONFIG_HAVE_GENERIC_GUP is defined, the kernel will use its own
> get_user_pages_fast().
> 
> In the following scenario, we will may meet the bug in the DMA case:
> 	    .....................
> 	    get_user_pages_fast(start,,, pages);
> 	        ......
> 	    sg_alloc_table_from_pages(, pages, ...);
> 	    .....................
> 
> The root cause is that sg_alloc_table_from_pages() requires the
> page order to keep the same as it used in the user space, but
> get_user_pages_fast() will mess it up.

I don't understand how get_user_pages_fast() can return the pages in a
different order in the array from the order they appear in userspace.
Can you explain?


Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C96BC41514
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 21:03:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 032222253D
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 21:03:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="kJ8lRTX8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 032222253D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FFD96B0008; Tue, 23 Jul 2019 17:03:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B0A56B000A; Tue, 23 Jul 2019 17:03:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79F356B000C; Tue, 23 Jul 2019 17:03:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 43FCE6B0008
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 17:03:39 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id q10so3561037pgi.9
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 14:03:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=MAiAHdI8iqd+O1xZOBVxWbAPjMbgMmfQoqtQMb7/9dY=;
        b=oqij3gm8rYlHssqPde/Q62x+yw3e5GkbL8ETQC6G6JWLcHhkESCYH3+y0DcnirbK0B
         eXvHgAhLPzoxVkql8Un3RVUX9aOQHV/c8ttkioyno5TszSwmYFdSzMqZAz1ymRlvGon7
         6YBRTvT3p7bdfS5l1bIxogVnvjdr34OeYKHs+TeHEfsQq000+oloawZkKS6Gs76itJTt
         XU3N0WoKtbjr3c74XCp2zwVqJF/gPyEP/M2GeV+qH2updds7YF9pysHol+f6H4l5+/y2
         tF1v6BJlANDV6TV2rh+EJqEmR8tMbLoRM1r75dvMgXUSRRLzjZPF9Ji4yuguFrZWhCJ7
         feFg==
X-Gm-Message-State: APjAAAX28J49VkYyuz0A/tmUkj1OLOtEH+nHdgRAJKAyF6BmpQIf6KZo
	MtcqdFvFpts0xow0tf59KqXRzY+qY+9RggV57kpDcjx45MWUBWMHSHtTOGHY7U1KaGFBBjnUAS9
	CYiQKcvUjtd4NEJiEtS4KNIBqzmX5tH6ma/taH6j32sVcV3D2GD9c7taqUEGuyhCBgQ==
X-Received: by 2002:a63:b747:: with SMTP id w7mr25206254pgt.205.1563915818829;
        Tue, 23 Jul 2019 14:03:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgz4CZTTrWNQrooJlJ65DROnJlUcJiJMn2hPZQQXpLSmT7ZO15LW0dUTuhKrln5omr4Bb6
X-Received: by 2002:a63:b747:: with SMTP id w7mr25206211pgt.205.1563915818148;
        Tue, 23 Jul 2019 14:03:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563915818; cv=none;
        d=google.com; s=arc-20160816;
        b=ezsYq9t4gBoObYBXrCMAKztIMPIkbprv5i97Og664O7RZ/PP50aho2zWsx7MnlMGTd
         8f9u6aDx0d0WbBz4dToQWJ8M9ZzA6XGAYQBGI+xh5uw+8cVIpPDfoDzzwkE7k57LO1hy
         hn8U6lqI3BnXzOURLtLnpLcjLyVXqhproqQUPhkwkbBZm1Fl7P+YcZ5O3zcfsyVL7mfC
         6Ex2P4f8eaRRw7O+XWigYybQXOlnTEZiDZ/U5IPGwrWDIwuP/0WA1ae47oT+dCmHgUJy
         3BBb/BigW/8ZshDGP3b33M944/y/Cy6MB8TPDPu5vEUoADz1GqC98WCtWNmYwImsahCi
         CoNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=MAiAHdI8iqd+O1xZOBVxWbAPjMbgMmfQoqtQMb7/9dY=;
        b=AJgP9lbEtLF8Eb5O4oL4B9J/pm9RuS8Tp8kU2+W2Q4gi7zPpkNMZHg0+7ctauuCYIF
         0YiDNXhe4/S+4ATxRFx7WrSLUpWe5bcQlwIIh7vY1MaZJViWsTUE2umT0UctbJs9UrpM
         7NU4Dysycq2zJj+URsy2EfkdyQzNLdTeW/8oeo0WdFfwsR21bS/DjtDPvPrcyZNv31a1
         EwygEZpOYLMymudPi0PJ+iflUNeGgis0DdGQo9YjmGYNNTyR1LSOUY4ryQMhHtL2XtpQ
         pZznq69uwn35IoMilQT6mwVVDfImE3ZPt8Zw2Yz+YqJXg+FhOXdjIgfC1hoc2rBkYCgS
         q4YA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kJ8lRTX8;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 67si15218678pfv.74.2019.07.23.14.03.38
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 14:03:38 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kJ8lRTX8;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=MAiAHdI8iqd+O1xZOBVxWbAPjMbgMmfQoqtQMb7/9dY=; b=kJ8lRTX8AB9F+NMYgfnZETBZt
	+IMESiEAf2nmfF16xStjt7BfjJjungHR+CGu2CRXauwgHY1YwJx62B3pTjd+aBI7/7KsqWyeFV2Z+
	hTNct4d4QvyrO9XU/R/iNtmytjQaSgaT3uInXl1nLcBTF3/lheb+JLgzU5ePyKm1J4SkESXYAkROo
	33zzrI5H6VLQNmzdHCz0tIjYkMPbBsiOEde86mSCV9XIC0dJetkK4NgfXCQQJS8Lg37a2MkOBERi6
	xzJ18gGWKf2gy8MruIaf54lT5JNJMPkkdz5UKDYSEu5YKpHjMgm4lPTK1LP+WBzi7x0wiFMVx+jsT
	f3o3uomJw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hq1wf-0008BU-3W; Tue, 23 Jul 2019 21:03:37 +0000
Date: Tue, 23 Jul 2019 14:03:37 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Atul Gupta <atul.gupta@chelsio.com>, linux-crypto@vger.kernel.org
Subject: Re: [PATCH v2 1/3] mm: Introduce page_size()
Message-ID: <20190723210336.GP363@bombadil.infradead.org>
References: <20190721104612.19120-1-willy@infradead.org>
 <20190721104612.19120-2-willy@infradead.org>
 <20190723004307.GB10284@iweiny-DESK2.sc.intel.com>
 <20190723160248.GK363@bombadil.infradead.org>
 <20190723175838.GA29729@iweiny-DESK2.sc.intel.com>
 <20190723181413.GN363@bombadil.infradead.org>
 <20190723204416.GA27491@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190723204416.GA27491@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 01:44:16PM -0700, Ira Weiny wrote:
> > > Side note: why 2 checks for !page?
> > 
> > Because page is assigned to after the first check ...
> 
> Ah yea duh!  Sorry it is a bit hard to follow.

This is one of those users who really wants the VM to fall back
automatically to any page order block it has on hand.  We talked about
it a bit in the MM track this year; not sure whether you were in the
room for it.


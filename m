Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4035C282E5
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 22:52:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46E4F20815
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 22:52:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="uYhUPzjx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46E4F20815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3C1B6B0003; Sat, 25 May 2019 18:52:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9ED136B0005; Sat, 25 May 2019 18:52:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DA916B0007; Sat, 25 May 2019 18:52:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 57B3F6B0003
	for <linux-mm@kvack.org>; Sat, 25 May 2019 18:52:13 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id x14so8458088pln.6
        for <linux-mm@kvack.org>; Sat, 25 May 2019 15:52:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=675ql6GcRQpTVtR1wVuEHWrfLLsg/psl9syrVdg5i1g=;
        b=eIA9GCG1xpYm6AdNW5z4DiVOaTLcSvgqmSwuByI/jNDQuAEGg+mm0bOfAQJnKxG4Xg
         rI7CzqBjeomOultJdyf5kd1G82XO58dIu4F/3x5ZaY+Ie3X9QdWi1II917/9ljRJC+LR
         k/NvHEPz6L8eqRa77YdepkK7PnvbY6X5cjBKX3WjcXI3xG+l2OZ3bbTeYBYusC5aP64T
         05cdhvI0kkrX9/e6r5aBPcUDiT0vaOETajiziKKT05uW7DgItfEaD0AduwC7x8xlTs/p
         L6qFK9mjx1H16Fj1t02ATlndzz0jaUYJNV0i0fe7xjwmRCODGLfX8t1jxyhzKA+cIeUV
         es3A==
X-Gm-Message-State: APjAAAWDe5jEZGymKIruSED6QfyTvR/E6fxyFjRHUxEdMzaSu+AEnbdq
	d0VMAliO/f5ZqDe2zSsYN+XXFoiNPTfizRs2BsFrqmKc/vbUDUduKvDg7ZBL6iecYEV79IIBYvr
	tSPS9NEXnKSzC7vG2/b1iierkS+sdtJinE1gdP4pluRe6OUbdkVyYV1k2CIxl3+4yuw==
X-Received: by 2002:a17:902:8d96:: with SMTP id v22mr41524534plo.282.1558824733018;
        Sat, 25 May 2019 15:52:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+09zRtHNAooeb4VPGrAsX47G9NxjHoMMqBRA0aGwb3sKIBP72zBdeW/PHyyzS1e9tOL7d
X-Received: by 2002:a17:902:8d96:: with SMTP id v22mr41524452plo.282.1558824732215;
        Sat, 25 May 2019 15:52:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558824732; cv=none;
        d=google.com; s=arc-20160816;
        b=IVfOmizF6TFk0KXUZPIEXSqSUydaWXBNlQWkKJau0/UBlxd/ovnsbRuV5XLQutu0eS
         Fkc2dpnbPqFGGtVPr2iXcAiKHwB5lragjSwzqy1vu+WsCcVzkrx0ydmukeePgixcdiGU
         BWZqaET+/+PaH8HthpkiQZoVhKKbf/ZAV6Z/9dMjhxHCNj4r+tsoyo79w2X52TW+TG4E
         GQSiS7VggoME89kWc3ucQ+SGSkkiqku6cnqEq4fZMoBqEDuc3l1PY17uLRVVXYMGO7Qw
         N2lVrc4hs/v1Sp5JpfyDRKbQZN5t6rGQ2lkJkilHWejm3h8NLyGL3e4ZDdAM4b2hPQT7
         gz7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=675ql6GcRQpTVtR1wVuEHWrfLLsg/psl9syrVdg5i1g=;
        b=wfNlJIblqgk6dh4xti+gdXXGuVkC6zEIEeOEG5RiekGNNIl9YuyNPb4abwDSTfmALW
         k1DlgXdjauo3YbvKKBh0wQBAqxA/galbNeb3fzhAv/8JJYlPwGAaMJmGAYUaiCrAb7+e
         sXmc/Tqa7I7+cx7HCQLtr+xaMwjYS3n+FN6blUt2t/kIypgeYoV4nFh/lzhhTSb353ll
         Np9Unrd4dGo4zyXjdWDh8rgI3h7xPOrl4H/FWHUzg647a8ThI2g0Gp/vMWM/4EsAp96A
         CEi72sHGX2RfoNmvTvHBGF3jTxGhbSu36VETmP5yjbbAS950nYTcaod2jelUo4xnzVyd
         aqeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=uYhUPzjx;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e127si10354864pgc.214.2019.05.25.15.52.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 May 2019 15:52:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=uYhUPzjx;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E8FC42081C;
	Sat, 25 May 2019 22:52:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558824731;
	bh=MJPUSD67w1vDzE1s8ukB7WvKrTYgamW84goFYYVDSPI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=uYhUPzjxc/GeB+FzHFhyxZ7vo3ablcJVW7xTFZBQ663X5B5pDMj9l2/WBJbSP5sIr
	 PmGFV5rSX7sooE3xDLZ0ZP95v/yHZ+2wABSbIW1lqY2R4xZBk6KSwpM+VoS3oiefLg
	 XSQ9v+swjbOvZCStCoNjXDVcLBs5kNEKQR+06saQ=
Date: Sat, 25 May 2019 15:52:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Airlie <airlied@redhat.com>,
 Linus Torvalds <torvalds@linux-foundation.org>, Daniel Vetter
 <daniel.vetter@ffwll.ch>, Jerome Glisse <jglisse@redhat.com>,
 linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org, Leon Romanovsky
 <leonro@mellanox.com>, Doug Ledford <dledford@redhat.com>, Artemy Kovalyov
 <artemyko@mellanox.com>, Moni Shoua <monis@mellanox.com>, Mike Marciniszyn
 <mike.marciniszyn@intel.com>, Kaike Wan <kaike.wan@intel.com>, Dennis
 Dalessandro <dennis.dalessandro@intel.com>, linux-mm@kvack.org, dri-devel
 <dri-devel@lists.freedesktop.org>
Subject: Re: RFC: Run a dedicated hmm.git for 5.3
Message-Id: <20190525155210.8a9a66385ac8169d0e144225@linux-foundation.org>
In-Reply-To: <20190524124455.GB16845@ziepe.ca>
References: <20190522235737.GD15389@ziepe.ca>
	<20190523150432.GA5104@redhat.com>
	<20190523154149.GB12159@ziepe.ca>
	<20190523155207.GC5104@redhat.com>
	<20190523163429.GC12159@ziepe.ca>
	<20190523173302.GD5104@redhat.com>
	<20190523175546.GE12159@ziepe.ca>
	<20190523182458.GA3571@redhat.com>
	<20190523191038.GG12159@ziepe.ca>
	<20190524064051.GA28855@infradead.org>
	<20190524124455.GB16845@ziepe.ca>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 May 2019 09:44:55 -0300 Jason Gunthorpe <jgg@ziepe.ca> wrote:

> Now that -mm merged the basic hmm API skeleton I think running like
> this would get us quickly to the place we all want: comprehensive in tree
> users of hmm.
> 
> Andrew, would this be acceptable to you?

Sure.  Please take care not to permit this to reduce the amount of
exposure and review which the core HMM pieces get.


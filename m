Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 737A7C31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:18:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 363DF2184B
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:18:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="b90xGJ+x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 363DF2184B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB7CA6B0007; Sat, 15 Jun 2019 10:18:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C68248E0002; Sat, 15 Jun 2019 10:18:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B56668E0001; Sat, 15 Jun 2019 10:18:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 81F9B6B0007
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 10:18:30 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x18so3772980pfj.4
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 07:18:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QAtCly+PQtUNfQV4P5g2hw3GFHENxhTcIuvEPxpIuGg=;
        b=cSLz9fgCxkDo3gD9N2ULWgmZZn0nCrOl8e/xDWFW79sXcTS5Nit5vF5ZF3RHmF/b3T
         WtSDqQ3GEednAVcU1EU3JBX0tRc88HE1Fdfg9oyNAqZ5lZPOvoAEwgHCUVvNZhxeVDnW
         VfWRtt/TOGNbLlASCZz+ELr90dOsJmzH/FiCWXQyuTz3vz/XN/hohfuAes/9u9RoG8X/
         wuAQ/srpIINmH84trAouOpuh73xZYAGH3cdWwUFnRHFHRMNUjsa4r3DaS0rf5iMJmIUl
         p0ndtWklZQWlCfNy2unJkwgbkCa6k989aOCNMaBwOea+O3gGIA/WCYjbNBFiEnkA5KDR
         FwNg==
X-Gm-Message-State: APjAAAUK6wKoZ5ikxplTeu0+CGAvr6+jlSLFyEJXRIWyF61PTubjd4zC
	G68oIauUWjzUlSEHZiUl4QlkQBme9Ial2CeqQqOQMQpGddxWJ8cpsoRDUtzeQHSLAPdXUuv7g/d
	p8Lg/TafYlgSBAJRaPrukS9CfYev4Tw6jN/r+hJjcObfhZyFttyQswW7m2l1lH7inpQ==
X-Received: by 2002:a63:834a:: with SMTP id h71mr6436428pge.68.1560608310123;
        Sat, 15 Jun 2019 07:18:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyY1N30UpAl9VseH7ofj7IO560IYz08nYGwka3ROUeoDqzJ/aNduACa7iitc/02CmzqtFMC
X-Received: by 2002:a63:834a:: with SMTP id h71mr6436387pge.68.1560608309427;
        Sat, 15 Jun 2019 07:18:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560608309; cv=none;
        d=google.com; s=arc-20160816;
        b=qE1xFaG+kT9tgCp/NSdZVA8Q5i1m7d3XeK2mYKgQTNNOXqnuOj+0SAlhTDvEAIS5EQ
         xxXDxDGz47B6pT1/vxwZv8AfHHNgc6w20P/jTJmNKEZhC2Z0wtiRkmlAiN622qKZ72ek
         qC1Zr0+M5PRN5o5KmT2Q0ywz2sB0a6E8ePrZRSaG9ydZZfQJ4Yeqb6JK1MVFU5D3B2Kx
         +WqDp6sE9vDshBcMJfXPWwvQTS2e1NlXkvm5GFPp5YyV2zS6evtau6fwPPg0RJyXbX7J
         LskIsuYRZpcTNi729AswCfdi1YF6XIp4bxniS2lWJtbZ1t9aj8wIMe0e5qfVKH7/eIhH
         SHGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QAtCly+PQtUNfQV4P5g2hw3GFHENxhTcIuvEPxpIuGg=;
        b=GLezX8+dshZKsSNFvxfO1ZfjOuX7agUBEtpn3owPNCClw9EFRBwafy9dQ4cPY3Smwx
         zYmptkPpYJbG/R17xOtrR4+snSZJyKa4SuWF/XJbx1SZwbD69WjmPBjljYDWg0n5kk+V
         pt1SwylgKjl10MoHKGqWUW/JkvkJN/bexe4Pwa2NEK9wfNazLzZkIo/fWqJgCeX0x2oV
         TrI3n+f+zS8QXPVTjs33YaLBKHd66lrnUm/H5sOJZltX1xPhKjl+K7/y4QbUScSJPYzF
         fVgdmYzUijjJCqkX0fmvRgI2WfAKBMmC2vd2awHCaGvtaZbq8sqS6X+bA1AmJby7WHaG
         KgMg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=b90xGJ+x;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k26si5323951pgl.70.2019.06.15.07.18.29
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 15 Jun 2019 07:18:29 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=b90xGJ+x;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=QAtCly+PQtUNfQV4P5g2hw3GFHENxhTcIuvEPxpIuGg=; b=b90xGJ+x0UwJqU/7Ldqu6D0lo
	DiD/e1TSteHI3mAWCw5RLZyrsLKkdqBExF4Dp2UL7jBDQEkfwhDrxDWPunc3tsNcMuz3t2n1SMwxU
	3zYlg/2iooeD18X5DJ6lLLDByKgg7asLYVufuU51WkA0bxF2v9XGQoL0fIsjRr3BlUGV3QKYhWrUS
	P9CLWe2hrue2MN57fLznBpUgYMfPyO/sPbAnH1Sp5vHhbSbOJ5IZivel1MoZYuDK4CUV4dSQDiOMv
	olCW2JBxsKPM+GNzvfpcXs1yx7oZnKU4hPYZ47nMD6Xjay+rv16teG9PUH51Rcm2NUZf91Av+R2mR
	XT0/l+wOA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hc9Vi-0004Vn-La; Sat, 15 Jun 2019 14:18:26 +0000
Date: Sat, 15 Jun 2019 07:18:26 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Ira Weiny <iweiny@intel.com>, Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 10/12] mm/hmm: Do not use list*_rcu() for
 hmm->ranges
Message-ID: <20190615141826.GJ17724@infradead.org>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-11-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614004450.20252-11-jgg@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 09:44:48PM -0300, Jason Gunthorpe wrote:
>  	range->hmm = hmm;
>  	kref_get(&hmm->kref);
> -	list_add_rcu(&range->list, &hmm->ranges);
> +	list_add(&range->list, &hmm->ranges);
>  
>  	/*
>  	 * If there are any concurrent notifiers we have to wait for them for
> @@ -934,7 +934,7 @@ void hmm_range_unregister(struct hmm_range *range)
>  	struct hmm *hmm = range->hmm;
>  
>  	mutex_lock(&hmm->lock);
> -	list_del_rcu(&range->list);
> +	list_del(&range->list);
>  	mutex_unlock(&hmm->lock);

Looks fine:

Signed-off-by: Christoph Hellwig <hch@lst.de>

Btw, is there any reason new ranges are added to the front and not the
tail of the list?


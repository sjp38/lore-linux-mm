Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 071E4C28CC5
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 08:54:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDC34214AE
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 08:54:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gTClu4LE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDC34214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 534F96B0275; Sat,  8 Jun 2019 04:54:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E6366B0276; Sat,  8 Jun 2019 04:54:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 387846B0278; Sat,  8 Jun 2019 04:54:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F23E46B0275
	for <linux-mm@kvack.org>; Sat,  8 Jun 2019 04:54:31 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d125so3159638pfd.3
        for <linux-mm@kvack.org>; Sat, 08 Jun 2019 01:54:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=f1hJhow60v+LJiQ/UMCdIN+9Bx8ZXj0xQ+YgDg2iVzc=;
        b=b7QRryUGm4jl/IwGXWqe+rW3uXFJhGZXB4nT+lKOaW3xJxtfsKXDYfLxAgb/WmSpTQ
         AXorJXYEwKHbqQXEJTR+9IDyemC6iR46Vqe1CSxQ3NhxB5o2YslbmrKiVqmDlWUqJNYi
         aJhLWgAKOH3OcWUbAEtO9uo7IRbct7Rv4T4QzQREIGD1YA+IWDph9PT0A79KK9eS3eXv
         jK+1SytIklyTRXfmlqzpgAuBFzHSyLKUVMekOGxiHUy+ppAB0ctDtcoBq3okWcTA3mjA
         ntW9ff48m70d0LE8h0KUX/r+V7KJHUXk2p7cxDEiWHBT+0K3QxO3wA47ofqVGtRpL69L
         4ERA==
X-Gm-Message-State: APjAAAXqT303ReJ6h/FLzpPM8fyYVJPzpi5YvL/33R0++BFcp+G8sYvs
	/ADI2NQcDGHJ81wIBRsGN8S40eFey/BpO7QqbCghOGend2wqjsKJg/CRuY4f8VkpZBu0o86E5eW
	xx/35LdKj+/2MrRUtwiQbEoykA2oXa5ZcfijOnstIqDoA7jb5wj6VoXSkOgwUjk/8EA==
X-Received: by 2002:a17:902:ba8c:: with SMTP id k12mr57441891pls.229.1559984071611;
        Sat, 08 Jun 2019 01:54:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1JfyMUI0x4rqtpDhERUflRmQLPdNtaavXvMTw4fdMXOx3LciA+kJttPOvXJvGIEyThDmJ
X-Received: by 2002:a17:902:ba8c:: with SMTP id k12mr57441863pls.229.1559984070998;
        Sat, 08 Jun 2019 01:54:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559984070; cv=none;
        d=google.com; s=arc-20160816;
        b=mZDLagKtpCcQ8UJRnMzJZvsyZVFbzR2T3C68DoqQO2MSd06qv98f3XyYGbcqjEbYrA
         Rc0CyduuEh+CRYIWcii1n84yRTOFr23MaQV+JRoY4qJ1z2KrRg+iYTZX/EGp0NdJlW6H
         yKRbIJbK6CoRu5FuQmxKTtQDeYQq/gCHaH/eQ0KKO5jg54wuOno5sEo7xydje3sohF8l
         tO68zPNBtK5miC0PNxsCmzICkQHIF5UCLeZbF9ULNDp+w02OTxsiwJUX1/xgk8+w63HF
         09d3OzFIz9zcStkvuEl8anYkS9NZyMqs7S4nSGNzsfB7lhKAuJDtEZ7pOaWTVcICcJpB
         L2hA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=f1hJhow60v+LJiQ/UMCdIN+9Bx8ZXj0xQ+YgDg2iVzc=;
        b=xiTP3VRRfJDiLvFyU1KZopjnPJUnZ2F21KnRyu9bbwPpNq2cm8fFhyzUwMt633kfec
         gTZN/Ifx1zdpG9s91SH1g2HNrf8V09i33n2UH+n7woCHfzmPui1JEb2C9Zo6nQlgffpc
         z3Y0VsiC0Wc2Z266Ze7hdL8t/d2eUDjDh2UuCcrM48EdBmLeni1SBzOLQCS8cHMpaLup
         sNncZBHyc8pkfa/dKTFvMSfs8p4Bwps229Bc5sHB6loqjeq9pL8T7RB+4QDOjyGPchDX
         rUUbaXAC7fSerlVHRCaogkXKL5K2YJaIfnUhBfTZrPR/USE5LXuGYjKyo8tYuAVCvzJ/
         Ps/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gTClu4LE;
       spf=pass (google.com: best guess record for domain of batv+ea1dbe8c224dc30aa319+5767+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ea1dbe8c224dc30aa319+5767+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l2si4142606pju.5.2019.06.08.01.54.30
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 08 Jun 2019 01:54:30 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ea1dbe8c224dc30aa319+5767+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gTClu4LE;
       spf=pass (google.com: best guess record for domain of batv+ea1dbe8c224dc30aa319+5767+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ea1dbe8c224dc30aa319+5767+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=f1hJhow60v+LJiQ/UMCdIN+9Bx8ZXj0xQ+YgDg2iVzc=; b=gTClu4LEf03iqlVKsw61uPJ0B
	pS9Ck86baVc6Sm95eVVSUUBhBhNbUwnwFz+jQttEnVDd4gBod0YA7TIWl1eHagLumRzZpfFM0dOa1
	5YBQQ0X7x8gVGzHHWCIyyr4G7qROkOfLdQRDhC1QQF19EULewSw3heaYsnb1gnBDib6CvUBig7tBV
	zz/Vshh8/4EKjmDFCJxFS6vzexhFNVtxzTTzT2xdxue69XMKFDaWjnyOGWD1m+w/kdXjsgjxB8BDl
	ONOuSdIYi82tzxuRKOqBnqQfOWCtkGuNzVDEk7uzCpwoBT9zpbo71D0cotxdv7X9eZVj/OcRfy+4I
	cUXwYfNqA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hZX7J-0003Ez-Ag; Sat, 08 Jun 2019 08:54:25 +0000
Date: Sat, 8 Jun 2019 01:54:25 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH v2 hmm 02/11] mm/hmm: Use hmm_mirror not mm as an
 argument for hmm_range_register
Message-ID: <20190608085425.GB32185@infradead.org>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-3-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606184438.31646-3-jgg@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

FYI, I very much disagree with the direction this is moving.

struct hmm_mirror literally is a trivial duplication of the
mmu_notifiers.  All these drivers should just use the mmu_notifiers
directly for the mirroring part instead of building a thing wrapper
that adds nothing but helping to manage the lifetime of struct hmm,
which shouldn't exist to start with.


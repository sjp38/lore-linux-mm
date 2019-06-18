Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 051DCC31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 13:27:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA65920679
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 13:27:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="n3ZDxpzb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA65920679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B4746B0005; Tue, 18 Jun 2019 09:27:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 564AE8E0002; Tue, 18 Jun 2019 09:27:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47A5D8E0001; Tue, 18 Jun 2019 09:27:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 100FE6B0005
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 09:27:32 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g11so7781578plt.23
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 06:27:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=R8Y3KUjrFsX7X/g2S4dMsmTowqPuT9Y71h6/+llmgw0=;
        b=WgcAsUupZMpxXlg5dVyE4AYK7Y9yIN+NtpL+0tLDt4QE8V4eOAIVZy+ylZD71NDGk/
         lz8WDnk8cSSAqgyiOzkPGjWUXvhwXg/xzNQJ+dSIlNvuQgYSlyGluOMOyBCiG4zjiKmR
         mnKaz86eBI4Y8fSHKYcH6O0rN+EKaD4sIu9KpBMX9fETT9GY2ZHtx10aRe0WorHo1wrL
         jJzULFGebXdFCxf1POgJ5//BpfNGy97cuwVj04Hnz8uu3NnupziYvzAVRmwB+LN/5+W1
         3SP9i3fMqyVTEGcY962S+J7q3pDiLmFA+Utnp3/x6PV4UDPIPsB5wo32moZNr+irJZH5
         uzwQ==
X-Gm-Message-State: APjAAAXFteRaEcxAYSM1FDEbunWMYJeD32zjf+aMis6Y/APRl5ms+KDZ
	NlDeigWDRCu2h/YQ0x+kfdR54ic/Jtw+rHaPEPBtnmpeJG9IsYDh212Kz+PYr5oG/v+Im5hwXjI
	MQrOHYzbzIzfBCGM/g1Nsz3rVUAfaEP8NnuhwVcKgpXkBEr6Eu4QMkI2aHjAEgEa2xg==
X-Received: by 2002:a62:6344:: with SMTP id x65mr15239344pfb.111.1560864451536;
        Tue, 18 Jun 2019 06:27:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvZmRUzHTDuSTcm+HELhAgWWODbWi97Cm/Q5dLzh4kNUjcmvRXCwgeV/unF8uGhrm+0Fxj
X-Received: by 2002:a62:6344:: with SMTP id x65mr15239288pfb.111.1560864450973;
        Tue, 18 Jun 2019 06:27:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560864450; cv=none;
        d=google.com; s=arc-20160816;
        b=f2IHoUz++vEJtPUU8xhylwLgdhONOsnAA7phunEg8abMJTzDzLxBfCRPxMaZuE+t4+
         ixyNM7M98Xu9W4x+9x8GrcoBLTSmcIsffImXaKnWMXBnYdigb8c0pjDx/g9ZpA91MZMr
         VeXVK0eIEhZf2XKtYudJniYByoDK0mzV0iBKmCclK9JjCWAxIPP1NqCnCpOAvqm1EEEi
         lZ1+3GtS+9Z6VUygs4kHhP2vRB76FdvukeACWYcsyiMPflQdzbRMUy0sTcN+Fyh4D3Lp
         LSz/S5SvU/8F78fcUoICRkTHy7XbTpSX8+kdTop44KejVH8xrz6Vq2w6/kJd2gK+Vc4s
         22UQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=R8Y3KUjrFsX7X/g2S4dMsmTowqPuT9Y71h6/+llmgw0=;
        b=Q4zxbzu+AokhI/KpjBmyD4GC12aI0OCpt+CZcM/DkArXiyt1PmkZQMGIlWVRIYsFVO
         bqOa0yZ8bwUnRUoG0k8pSdgC4oKiUjp2ku3Y06eEEw7N7gy9M8js6SIh2GiUy/uXJAJv
         +CqlpKUwqoxpBWX5HtNyVpCZGPtoxY25womEhvS7Y8s18W7nNqTANhM/2rEPTj9GpTFu
         8uSUie1PsfR2ENvm7ucNOiOMXfz38GCkSO2wO+w4Fs+qOymD5Q7Rmu5ioFn1eAP+SASO
         iJceP5e5txH31R7+s3uuA7i70ISULTQzFrKEr/PwiRQsEPV/7XJZtdQD11rHdXr1/YiO
         ScWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=n3ZDxpzb;
       spf=pass (google.com: best guess record for domain of batv+aaa270176d60fe65a2bf+5777+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aaa270176d60fe65a2bf+5777+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d21si3700052pll.369.2019.06.18.06.27.30
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 18 Jun 2019 06:27:30 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aaa270176d60fe65a2bf+5777+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=n3ZDxpzb;
       spf=pass (google.com: best guess record for domain of batv+aaa270176d60fe65a2bf+5777+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aaa270176d60fe65a2bf+5777+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=R8Y3KUjrFsX7X/g2S4dMsmTowqPuT9Y71h6/+llmgw0=; b=n3ZDxpzbEjb8R1YKJLBpAmwI5
	fg4UHLI0YBDL1Xe27VYvdUCGF95z2vAUdWoaWGPThlJIFk6rgNQuGjNp5TDE1LLU9ECS4LxQw96ML
	+RCnUJDGNPupO5iWQgPgY71z5jdI6LT9v+5khZpolVw0InzMNQKiIn4/PHhnOF17eUM1E32oFnzqC
	iWauMQoWTacJNZ46XZqRsJeWRwGpaq1/Dv10jtsfzimXcwJGM/5zSO47R/FPNsz/wwBuKwfpsz2uG
	yZpfrSudQW9FDkAJR2C2gjZlV/jsEeePTa3LPRYnyVcRAYJnFrHd7UlJ5Qr1Dwk10+mVVNEVELOb+
	AJSeWlhpA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hdE8w-0000uS-GG; Tue, 18 Jun 2019 13:27:22 +0000
Date: Tue, 18 Jun 2019 06:27:22 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@infradead.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 08/12] mm/hmm: Remove racy protection against
 double-unregistration
Message-ID: <20190618132722.GA1633@infradead.org>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-9-jgg@ziepe.ca>
 <20190615141612.GH17724@infradead.org>
 <20190618131324.GF6961@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190618131324.GF6961@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 10:13:24AM -0300, Jason Gunthorpe wrote:
> > I don't even think we even need to bother with the POISON, normal list
> > debugging will already catch a double unregistration anyway.
> 
> mirror->hmm isn't a list so list debugging won't help.
> 
> My concern when I wrote this was that one of the in flight patches I
> can't see might be depending on this double-unregister-is-safe
> behavior, so I wanted them to crash reliably.
> 
> It is a really overly conservative thing to do..

mirror->list is a list, and if we do a list_del on it during the
second unregistration it will trip up on the list poisoning.


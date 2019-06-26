Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FA7DC48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 07:35:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE5F7208E3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 07:35:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="FEIrxw0f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE5F7208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 35AD96B0003; Wed, 26 Jun 2019 03:35:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30BB48E0003; Wed, 26 Jun 2019 03:35:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F9F08E0002; Wed, 26 Jun 2019 03:35:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id DB8E36B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 03:35:36 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id i35so1074882pgi.18
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 00:35:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=lDmlG4QlTTriJzFXWbGaRSBBFeeq9DSPhk5L2uu/dys=;
        b=fsCcY5bfETFyy7259eNaGDIUcIzwdEP6GLyZ5BdL/XJd8BhE1DaDX+hK5LA/GdXP5E
         o3BZgdjYufT+jhgD/XUU8JJ9zoIZgqbUnjud8/e1fHbXeuzaStM9QvmcQA6PccsUiNxz
         Az5jrZMWh65c5SUhUyT/u+Kl/6c0ujtIrpVWVTHJEOYXm+lwrQPT1xq/g8pXBnqIuEMq
         LiC27qiQbbFMl7swX3UB60ql9eV4T4NdSv5JkrWU8reC/pUV7YAPAKaZZnYQ/NMq7Bi8
         slk5gIMrm/+WWWP/liysH+sBcAwr+rr8n8b1tgd1BXBT45v39y8n9xgo7U0ZaKc8D3pU
         zWnA==
X-Gm-Message-State: APjAAAX5vj3b7htY0FH+vADhfHCdspzT8uEofd1jPAyE5pWXBe9Ov8OM
	Bwx9940G6m2J0DsQXeRXdHUjEEHfvtyEphvXTkOaM79GgjjeJITvOtgXm3SKI3+fHxVdC6RvpCT
	xIAifbJ4am8DsgYZSNzHicCk9Ppa+ci64vyuHFXW+JX9alLY80IYFlhCnlY/xiUAqRg==
X-Received: by 2002:a63:fa4e:: with SMTP id g14mr1540432pgk.237.1561534536310;
        Wed, 26 Jun 2019 00:35:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0UW93admr1RGCSgZGUHDVdNX7G3nkjJFbDEs0m6lIawuXSiaPZDCvJ47/OZUjJY0MjOm/
X-Received: by 2002:a63:fa4e:: with SMTP id g14mr1540370pgk.237.1561534535421;
        Wed, 26 Jun 2019 00:35:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561534535; cv=none;
        d=google.com; s=arc-20160816;
        b=lgRyIJfh/TwgmhZJ7w003wzmsVDgMFSFXlsxPF5NdbN8iEpuViOjbIXS4MAc6loYc4
         jfXOaUTx9KYezKwdDaNDeL/07Hh7Lf0bCVtfE3mMtDNI+jc+A5aYr3tCly4AiS+YLeUR
         orpTu2I9Ifcam8YR7W8X/rrzlums52fqFY7Vj8pijy8z359B9VBS7KJ+wQUNhuAk60Mg
         xrlxTgukXNJ2gu7JppNtIviQzB9Y9z5TA7UhiesX3B/I3Dkq6yD+CI7cpP0/wx0ARZxE
         8dqYSz7CD192ZQcOGzCsBB/xxLSBx3dNat2Y48uS/+8/z7ULiTmLWMy2H3J7nS72ki9J
         Uj9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=lDmlG4QlTTriJzFXWbGaRSBBFeeq9DSPhk5L2uu/dys=;
        b=dnlznGchnC1BkWwarq7QqfgNVxusZ4AeRFULRqdFtVFze5ljQ1t+nUqkItSLljqiTY
         GcRaOWY181Ysu3+rWm52Hq1lZg+iSU+6wnYV4X9ffANppdIiIeWzBYarpI3shrodtItq
         J73ws72eBD8i9Ug6QGR4bouZPDoVcqHFYsYIzqfGTCblXhpyxqsxx7CGmnQwnkVDe/QM
         2/2HUP9wTKoaD8AGjsBj/8OxPiNXMc2Na1RQSrH1BZkAinaBz01AHmUBQyieG9IF+DRk
         KXrqWGR8NnpRLEe3NzX/f7mheszTLC9xST+XXMtChIsJIe+5w2/c3nBxVGTujp12HN1T
         Kmyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=FEIrxw0f;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id cl14si2704972plb.341.2019.06.26.00.35.34
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 00:35:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=FEIrxw0f;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=lDmlG4QlTTriJzFXWbGaRSBBFeeq9DSPhk5L2uu/dys=; b=FEIrxw0fA7wZ2Dgvq5SBxdVmN
	yhPyT0gCj6Bxbl/m8JShCPjIBGhfUFMREoijyGu6CGikjCKKCpf0b2qqwRam7jR/hlWuYyDPM14ds
	bqUfT5iAeCLEabNpYahNp1jcOmxfA6iSmh2JpyOpAGQyjm/PM5Ydk9rf9HcVKqWWmuf4OJHVZc+6D
	rl69Hx7yZb+nynPThSA+wG+PtBSuSdLyPqJw9ARsh/w+6FRPip840hneIcWRmm0HUdymEGBFaMQnZ
	LldmT8tVf34HugoPD5imjld6/n5Hh1p8tAsqrTrCSR7iV3Rjlzy3Ea9+xB76jwxTfsxNP6/h0qr0F
	y1s4FQJ5Q==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hg2Sr-0007dW-2T; Wed, 26 Jun 2019 07:35:33 +0000
Date: Wed, 26 Jun 2019 00:35:33 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
	catalin.marinas@arm.com, anshuman.khandual@arm.com,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Jason Gunthorpe <jgg@mellanox.com>, Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v3 0/4] Devmap cleanups + arm64 support
Message-ID: <20190626073533.GA24199@infradead.org>
References: <cover.1558547956.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1558547956.git.robin.murphy@arm.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Robin, Andrew:

I have a series for the hmm tree, which touches the section size
bits, and remove device public memory support.

It might be best if we include this series in the hmm tree as well
to avoid conflicts.  Is it ok to include the rebase version of at least
the cleanup part (which looks like it is not required for the actual
arm64 support) in the hmm tree to avoid conflicts?


Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FAKE_REPLY_C,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27653C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 16:09:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E34AD2173B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 16:09:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="d3D/6SvI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E34AD2173B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 666276B0006; Wed, 24 Jul 2019 12:09:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F00A8E0005; Wed, 24 Jul 2019 12:09:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B88B8E0002; Wed, 24 Jul 2019 12:09:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1283A6B0006
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:09:38 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d190so28809778pfa.0
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 09:09:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=HXDgC3r+QZndYF+JhGOtU3oBVmxVpcd58tRMaOLYpnI=;
        b=SHJHHoPLWGqUNSXtGsNW0cd5yph0TWJp7PBZVgBp++Wkb2LbMFKWb/BRdrXQ8EcjVY
         zM1Gbp5UGp3Z4AXSt6awz48jkB0LSP79g2dEquIHiDxXzGGsqYXj391pxhZd3miphLfX
         xPOXCl+dCYm0L1duOnVLVZl3CRM8K59aOKnrV3vLrWejBxOJzLe1G4EMVyVCPAkR21H6
         gQqoM8/zjRnrbFutKEUCeWSiB0dOlATNLZ/YqXLZoex+glOF2IQXZ7HRHXc9BKfWFsdb
         i+/TsfMrYGoyn6Vag6WCu6fWgal75iyvONNwzmh051VE72UkM9VPrwtZBgpaSEZacoOL
         L+Tg==
X-Gm-Message-State: APjAAAVY9EdLsG+2pyaseGO9+xFyh/MQgL34+mO/dNGaTBWkPe0Ow2gB
	iEn9oWbQKLn4RRXC2ZfarQlSF7YoHLqFyE+80EQWRrger2+N9JDPsQ0fz8g6AMumFmQfbHVf9QD
	RWhxhKpX2lbKGG1S8s361e3pKThkb//u2i9ihb5HxZxa84nwCBV/5xd0+uF/QjCz8ag==
X-Received: by 2002:aa7:9a92:: with SMTP id w18mr12071337pfi.167.1563984577610;
        Wed, 24 Jul 2019 09:09:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQkfGxVIWOIyWWhO5rS+FGW6GoI2qHovCevgsqSflK2IMbPqWusfxEs/2Ux/87IpQLa37i
X-Received: by 2002:aa7:9a92:: with SMTP id w18mr12071283pfi.167.1563984576872;
        Wed, 24 Jul 2019 09:09:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563984576; cv=none;
        d=google.com; s=arc-20160816;
        b=KnYFX8sWz7V2YWkthcrejZEc/tW4iNgV2CEZ5zT2HjlCMNoycrrgkJcRU3hs4CiAQ3
         u71FYWvlxhd2/D0G3qfTpecugbJabeHA4cYjjZsAtaQG1NhR4wA1x4lQML6l57jszYMa
         FP9K2+twaoqSFC5NIGLx9WDHeXY7G+HZWibUqX2b1XkSWEune8J5rQfxYpdR21/d6xBC
         /AR7cTP24SCglU4jZ0mZcE8AYMljCNPKSoOtLNphdgRQ+wSM/ULcC83/R+JPWzegMvzi
         9aPoT7x78CWmDzezb961sXMF0IgHo2SuvG5NN/1Wo7DAtUNPxJVJOwthaFCkf46FdP74
         YfXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=HXDgC3r+QZndYF+JhGOtU3oBVmxVpcd58tRMaOLYpnI=;
        b=tU4SO0exQgGweVG6kPRdez6VilTm1NoSoS0+c2osLdbuIQB9apTJegUb3zCQhw13gf
         M6DKqI6+R5gocYppuf15Ij6RLUAsnfTYpagjydgmbfwIzC089AE6vnU/rmkNE88QIe50
         Bpg9TASSOPG6tsc5EEpnuuYjDcXvgmvUbA9FXdqKnrm+MszXKP+s+upss4f67aFLllnZ
         Xu9/8tgXSt2PD5+L4js2pOunuZ/DpcY7v43wQ6h+hq/3eWDV7qrqklPub45v8/DHjwZj
         /9d4eyRlM3wMC4vOlNmbo1MR3q7CAlId3fK/dHeMdua2MSn4/RR/oHJsiXx/8QcKEwGp
         O46w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="d3D/6SvI";
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w19si5977209pga.462.2019.07.24.09.09.36
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 09:09:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="d3D/6SvI";
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Type:MIME-Version:Message-ID:
	Subject:Cc:To:From:Date:Sender:Reply-To:Content-Transfer-Encoding:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=HXDgC3r+QZndYF+JhGOtU3oBVmxVpcd58tRMaOLYpnI=; b=d3D/6SvIZRlTvJ4R8TcVqF4SL7
	PnO32n2UOdRKzi4R406Kmnuht+z1TH4GbopOWqBzcNBF9gF8gOB0Z2HeZdfLqE9uDgdzC46V1Aa6g
	S+5KtgJ+4KPjAEDUGO6DKj2FkIqx1roD3g56z56/APJMkoBJU8T/8lQLTrwpeahrDBzP55c1khSuo
	WE5aUK5ELeoDcQPo9qOh+s3vok/HYoxbT9gUrYk6FyVb5baCCQjTii446Tz57dE91gw+FWqr3B0YY
	7DzwclfUBhNY88751AsXNCMbRP+hl//FBMqE+dkRJ1DRC2wWKq994Pb0vCVLdnisJralEi2i8YPnG
	lSMeoenQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hqJpZ-0000Rp-EL; Wed, 24 Jul 2019 16:09:29 +0000
Date: Wed, 24 Jul 2019 09:09:29 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Bharath Vedartham <linux.bhar@gmail.com>
Cc: sivanich@sgi.com, arnd@arndb.de, jhubbard@nvidia.com,
	ira.weiny@intel.com, jglisse@redhat.com, gregkh@linuxfoundation.org,
	william.kucharski@oracle.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v2 3/3] sgi-gru: Use __get_user_pages_fast in
 atomic_pte_lookup
Message-ID: <20190724160929.GA14052@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I think the atomic_pte_lookup / non_atomic_pte_lookup helpers
should simply go away.  Most of the setup code is common now and should
be in the caller where it can be shared.  Then just do a:

	if (atomic) {
		__get_user_pages_fast()
	} else {
		get_user_pages_fast();
	}

and we actually have an easy to understand piece of code.


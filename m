Return-Path: <SRS0=7ROk=S6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F64DC43218
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 08:11:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32B142075D
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 08:11:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TFCG+qkP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32B142075D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB5DC6B0003; Sun, 28 Apr 2019 04:11:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B63436B0006; Sun, 28 Apr 2019 04:11:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A037E6B0007; Sun, 28 Apr 2019 04:11:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 663DD6B0003
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 04:11:19 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a141so3562005pfa.13
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 01:11:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=9cfzCZHsC8Z1URVhGFCxQrxINgq5TQBCpge+7Hexgeo=;
        b=OknsrVBIbYQ+0GK2mZI1PI+Urnn8nvEJNScx/1cRXFd3JZs8lBBHhbyzwm0WcZb2yS
         lD+JMXNNorveRyTQFxOhd0uhwe4XmrXo12qzMCt0YLgBusM0l3t1o/ROfW4iqsPGtAgG
         63HV0/wISDN7Cn668x/hpZ3gAd49bk+dw8mMf+DmZKtT56rrZekQtolwVx/vJ5zGEgHb
         uvI+m0sJzlTQ6Ym4u8uEk7tquV2O0YLm0lZ6OmiX+A0Kv0fqsftrWSLTJmKuf2ln1aGT
         WaK3UgEyqQ57Z8qT5EWISve88PPDJfOwY15YCGreLsUNPgdaZW1f6ss9HEUFS3YY8s0O
         21dQ==
X-Gm-Message-State: APjAAAWHeJ0YzrIuWMnVka3bJhymqtPuvs+rICoA2iHw9hLBWJXiQWT4
	ikrUp3nb02aXu2J6Ghn2qq4UYpqyNs9n8QRJuZvVJlGn2eZyS414DuPKKgsHqREQS5LJpqiFSI/
	W6vi6/c4NCGdob0dGAzsP1rdqAUR+fpY4fEidT/FhPcotPw/m7HBfYoMYP9vSXxpo9w==
X-Received: by 2002:a62:be1a:: with SMTP id l26mr2271386pff.201.1556439078921;
        Sun, 28 Apr 2019 01:11:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGUriT9okm3CnnPZDV/TTyF7VdIYTJkyKAT98comhQWx2B/4A5d8Se424iLi5SxpKt0eZm
X-Received: by 2002:a62:be1a:: with SMTP id l26mr2271352pff.201.1556439078171;
        Sun, 28 Apr 2019 01:11:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556439078; cv=none;
        d=google.com; s=arc-20160816;
        b=bilowKyYjuhGw+DLSOzu8lsAP1whi+hdIwpZ7Y9JS+Z/5Su2cUneqmRSmjHtbQZ639
         qazJhW/XLQpHweNXfX3ukHtXkWjHJeqMhWgM8fcHVAH3q/JMZWujtuDTfC69DU9DZntU
         BIu6uzuPOdXwR2KAESIoGMdR7ZAVJHef5RfmMl9oQgr+QVZX0oSTuJ+vSXbTWdocw1md
         O3TLmzMDU9acpUoRs192uDFiOAnXOky0L/qgjd2ur/7cTEj+sHplR8p0klyLsfHErkWp
         enVxajC7eeiLtOQKyq/sv/PHBZ2P31YPVCqw1PPXHxBuHyo4lL6nB0+9XCPAw0JBAdjV
         cYvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=9cfzCZHsC8Z1URVhGFCxQrxINgq5TQBCpge+7Hexgeo=;
        b=ZfSyG2QBHL58WTIYqKrmZKlGKnjkKQNHRbr95Q9C/dq/hMYshIXMPuZ8CI/Pf9kQpi
         bSd4h6qDD1Z6R0uJdJOJd1JPLzbIhwESX3K7xM/3OctyYnYJl7vVRFgyB2W/1jUmMURM
         AK3IcPGLLSgYulnajkXyUeQ3SsZbjoOZi6SwySjCOUJ9UHknk46Hso+BuVCrTArmkj0r
         7l9m2vrv6HEdAMZs7D1EZinBuaS0c1RjBGPNq0My5GTNLpQoMx4kP+0uoReqr5GpkLP2
         qAzrEElAijBdOsIdL1Dds1rqv745cDJohopWOdSsfl1EObcblyS68f5iNnk3GpOpA4TZ
         T1mw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TFCG+qkP;
       spf=pass (google.com: best guess record for domain of batv+6e876697d14fde6a77e3+5726+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+6e876697d14fde6a77e3+5726+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j15si29948438pfi.8.2019.04.28.01.11.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 28 Apr 2019 01:11:17 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+6e876697d14fde6a77e3+5726+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TFCG+qkP;
       spf=pass (google.com: best guess record for domain of batv+6e876697d14fde6a77e3+5726+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+6e876697d14fde6a77e3+5726+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=9cfzCZHsC8Z1URVhGFCxQrxINgq5TQBCpge+7Hexgeo=; b=TFCG+qkPsR1tZhgIZ7nDdAu0U
	41Nj91cp2ngQL//A/7D/Qd/9wiELv5/cmOFeNyPyksBVKb+qMzDrmLMV4ybT5jMS9H+MF5ZsLts1l
	lfKLPgcZ0ZX3lBjNfifZXvn/oylF71G4vYc2rkGFLX8tAm9OrHVcOVcOGG0fnOkbaFDAL4OM0KDPp
	T8SYAMoCCLFGrrD8yxjawK2PBNYA0Xix+L43FIhjbTddeH2nGIBjguRfnkqeOg3LL21Kp+PkuxAh/
	4bERD+PCrlUYLJtsUSZQ5FXKeu2DsZb8IsCRYAqtv3geoy0wDTwEDGjksVmGvGbPjksJtmYTcqLcr
	1c0xSPqAg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hKetv-00011K-CV; Sun, 28 Apr 2019 08:11:07 +0000
Date: Sun, 28 Apr 2019 01:11:07 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Christoph Hellwig <hch@infradead.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Matthew Wilcox <willy@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mikulas Patocka <mpatocka@redhat.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	linux-parisc@vger.kernel.org, linux-mm@kvack.org,
	Vlastimil Babka <vbabka@suse.cz>,
	LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org
Subject: Re: DISCONTIGMEM is deprecated
Message-ID: <20190428081107.GA30901@infradead.org>
References: <20190419094335.GJ18914@techsingularity.net>
 <20190419140521.GI7751@bombadil.infradead.org>
 <20190421063859.GA19926@rapoport-lnx>
 <20190421132606.GJ7751@bombadil.infradead.org>
 <20190421211604.GN18914@techsingularity.net>
 <20190423071354.GB12114@infradead.org>
 <20190424113352.GA6278@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190424113352.GA6278@rapoport-lnx>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 02:33:53PM +0300, Mike Rapoport wrote:
> On Tue, Apr 23, 2019 at 12:13:54AM -0700, Christoph Hellwig wrote:
> > On Sun, Apr 21, 2019 at 10:16:04PM +0100, Mel Gorman wrote:
> > > 32-bit NUMA systems should be non-existent in practice. The last NUMA
> > > system I'm aware of that was both NUMA and 32-bit only died somewhere
> > > between 2004 and 2007. If someone is running a 64-bit capable system in
> > > 32-bit mode with NUMA, they really are just punishing themselves for fun.
> > 
> > Can we mark it as BROKEN to see if someone shouts and then remove it
> > a year or two down the road?  Or just kill it off now..
> 
> How about making SPARSEMEM default for x86-32?

Sounds good.

Another question:  I always found the option to even select the memory
models like a bad tradeoff.  Can we really expect a user to make a sane
choice?  I'd rather stick to a relativelty optimal choice based on arch
and maybe a few other parameters (NUMA or not for example) and stick to
it, reducing the testing matrix.


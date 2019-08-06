Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FB1AC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 07:31:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21151218D8
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 07:31:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WIwjlkRb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21151218D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A98EF6B0003; Tue,  6 Aug 2019 03:31:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4AAB6B0005; Tue,  6 Aug 2019 03:31:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EA4F6B0006; Tue,  6 Aug 2019 03:31:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 58BAD6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 03:31:11 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 6so55316167pfi.6
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 00:31:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=crhuruONrHFEz4gXAFuP/D7saXD4jPoaf+inORpxRGM=;
        b=iGg+YSpSJUIKF26CgkIXuKpdxBWS85m4dWO1AIgwXpxOOcFtp0zPkkNMy7SNR3l84I
         BzZ4h728WfTCopb33xk3W+/rioQND4J3USL5/OYBJ/Bb03+dnOwoaT2JLDjhPMljIt7z
         BbrrGYbX2ROktvLOkBMDiisGwGTeB4+En+aYFtXWe07XF904osvrSBGuRmYdtIuF+Y+t
         xUNQ16t3nXb4I43hGlNfwTGgcSO6fal6jCfXibueIm1bbRAt9mRSB0LkmPboM6L8147x
         84hNHvLef7msiqDe2wyDzX1IAvxGAMc2Xaf31Yda6aTMDNomVHlRq3/aKAYr5BVggJJm
         C40A==
X-Gm-Message-State: APjAAAVYHoo7+hkSho2ApRK1ruuD8K4EboR4nkjXq8h6tCbaoqYBf4Kw
	aQYUK+XpQhTQQof3+6OT9e06LRaMVfnl6OzqJsT2NWqs9Hhl+xn/BRDur9h4XtOZ8UBFA2hqaWP
	qP057bnezi70wm6fJxrOGjx7AI8/xLtTqFHnbcm7ZoeVaFcgmxuBNs3wYA4wfthNwWw==
X-Received: by 2002:a63:b64:: with SMTP id a36mr1810350pgl.215.1565076670788;
        Tue, 06 Aug 2019 00:31:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwADi95ipDI2lQ+MZh7KJ9Kf16BVjf1lZjyCJ1BsN5hZjNBhkT50MJou40I0KY+Z+HXWdWo
X-Received: by 2002:a63:b64:: with SMTP id a36mr1810299pgl.215.1565076670001;
        Tue, 06 Aug 2019 00:31:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565076669; cv=none;
        d=google.com; s=arc-20160816;
        b=nIu0cNCLFExgKaaucyJyDYyascR3b897+907tLGloYZvudMKVKsXZgBMkyVxzlp3+v
         ZLeCyCeGgsE6MLW7EXVd+2pjuwxGWXb9v40/0Vx4cxxdQge53MF7xBVOYZHZu0KQHmH8
         NkE7ChWCkp/YCftyFcMzt7ciy45rg31EHFIyr6ww96KOCj+jeYnrLrBE/DoiIHRX+Zmm
         2cor81czwGJ1PurGaNYtAeoK6c1wA9ArJuIfOa+zCn7Tr9BRH1MdS3xq4isclLr6CJ/P
         teENp0Hy/e4S3yJl8ZKMjksknc4tJlpWoyGjjQ7q2SXc4HZDSQkdGcx4jJe9Cxfxdkzq
         rh1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=crhuruONrHFEz4gXAFuP/D7saXD4jPoaf+inORpxRGM=;
        b=Onb315de5/Cua6lySZcH6jlfPnKIO1SuJrAHZ2UFsEOIXPly6vIeyIXqiN0z1Zk74G
         bigVcFjWuO7dK5PQlkLf3/97e36bP40aO9vFDWVIqu2vBbGNb87FD7HS7YYOoyNNu/jm
         I6tva5e5irqik2RlWg6nwyphTJK5mM56Qf/oVx6OBGHcAKiUX6UDhHWyZ51ppQ1gzjKj
         EjluGHxKj/pkOJrkoEISigI4UdGOAsM4YfVEl4484UT6H0NIVUV+V5MgqALcpSnJTHA5
         Kv5eTygpIpufGNOxd9txlBoT2rWjxpKTthbthi/JhcqPqU/ko1cEz4Vs5TMi/OQ0BbuT
         8zyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WIwjlkRb;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d1si42553273pld.318.2019.08.06.00.31.08
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 00:31:08 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WIwjlkRb;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=crhuruONrHFEz4gXAFuP/D7saXD4jPoaf+inORpxRGM=; b=WIwjlkRbC2r7feW/pdrPAmV4+
	bFlx8zSxpRn0QCdNac1h1NTijp5r8nyNHWs1uEkEOsbtNw+WXAISm5GXQgvlArXduBJizVY40Yttp
	OS+EGO70Zb9K4IBi1htqP0T7zBToyH6cbgPHFl9E4EW6NAs/nUmdQtP9IhenbXk8ceCpUI4qEaLP3
	FVKhM3Km5f0oB/JpID9rkroeSV0yQFPlxDgTQ6A5OiKxE6kdHVzB4IxwQUvl3+ZCl7yYY8bsTW+fU
	G7jmcPuJHn8tf/SIOeR1DNeK/OlrI2uguLuK3ZSMPUzUOLXSRj+SxGKyaFAD5Eu35j8o0lY83Bw3X
	AQvUq/KiA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hutw1-0006tX-GD; Tue, 06 Aug 2019 07:31:05 +0000
Date: Tue, 6 Aug 2019 00:31:05 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Ben Goz <ben.goz@amd.com>, Oded Gabbay <oded.gabbay@gmail.com>,
	Christoph Hellwig <hch@infradead.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [PATCH hmm] drm/amdkfd: fix a use after free race with
 mmu_notififer unregister
Message-ID: <20190806073105.GA20575@infradead.org>
References: <20190802200705.GA10110@ziepe.ca>
 <c59ebe8b-9b18-24b8-b02c-8ccaa7df4dc9@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c59ebe8b-9b18-24b8-b02c-8ccaa7df4dc9@amd.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Btw, who maintains amkfd these days?  MAINTAINERS still lists
Oded, but he seems to have moved on to Habanalabs and maintains that
drivers now while not having any action on amdkfd for over a year.


Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1D68C31E4E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:47:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E36A21773
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:47:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Cj3+LM9v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E36A21773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F1C16B000A; Fri, 14 Jun 2019 09:47:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C7AA6B000D; Fri, 14 Jun 2019 09:47:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DD586B000E; Fri, 14 Jun 2019 09:47:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 48BC56B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:47:46 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id n1so1628430plk.11
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:47:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=2klM0787YOypidTxFFKkFXrGCXrbMhQ5qreI3X9Vu1k=;
        b=uLyhUD+9sWTR3aLSmlOgiQx/27YrDBJG1G6uO7f5UUlLTtdFvzaM7B4ZZU/hCPAePB
         GADbczeqdgFMRcajhE6hcpSDxgyXxQh+jet1Td9JwtOwFBGe0P3/ILixhroCZeiXNQZR
         N4zNrHEtV0DpcGrBm5eG/PeonZszsnxcG81iDcK49h1nDks9bi6K6/TbjOkvGDeByArp
         HO53fuSmC4PNO8dfIbVJrWwbtaE+eLgY7Ksmq1wjNF/xXm4vugHENeyyiBBdjrx5HJeb
         47n4GD1Ecr/zSEMUhUXN95mXGiPqu1ltjyf77Wo6ZfPTuzCzKynW0sowvQfo4bQ75nwa
         Lhsg==
X-Gm-Message-State: APjAAAUqiW9R7i9HBgjXs6mO20RBQInSW10D1CyrRPfB0e68ID1z4oFN
	9xbb8mDE2hOWslt1+tYqVmcGei2JlNBtPg2ZYRb6v0JlVp7WH7UloYSTqclUbGnSembwCV3FYbb
	OJFcheGNuyesdJM2USVPniwBLgZAQ/pxRukZudxciXM4YyP3L3xrjd94hHWKk3yg=
X-Received: by 2002:a17:902:6902:: with SMTP id j2mr21129590plk.321.1560520065950;
        Fri, 14 Jun 2019 06:47:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTKuULp/lep9iSKXg8D3b2wGuXNRZ9oJSqS+rlzBy2P2CYLfaeDc6RUsdQXmMzpzy9YOOP
X-Received: by 2002:a17:902:6902:: with SMTP id j2mr21129537plk.321.1560520065228;
        Fri, 14 Jun 2019 06:47:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560520065; cv=none;
        d=google.com; s=arc-20160816;
        b=mVyMMHlcqWuuLl44PJeuhsajoILDENfQIprcir6L6m0ItuvlVMbcZJxGmC8MBWxptL
         RlnPz/UpbiVJJMYPK+bvYykuXxu9XSq19x2BwDq9SdE90ibGyl9KZr/VDOoLYh+t2PFj
         bA9UN+vNpzlrBTnHg3b2IXFiLAygCx+YpEuLxsQeg5T13Wyxexf4rjGYausHnDSgTw2r
         jDMgcX6u/i3RZIiLVVIgx5u3MtFc9qYxlyjFhLJ0iIr6TkTFs+41c/ZZi4IA0K8PDjN+
         ogJtFjfGqnf4xKfSNQRZowO6aPXNDPCStFhI4iOhXgt74KaAZYuWhCeGZVmfceWtqk6O
         4XRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=2klM0787YOypidTxFFKkFXrGCXrbMhQ5qreI3X9Vu1k=;
        b=09h58yGy4QP3Tp/Rm8nfgrGF9Z0UjyZ27qHe9RK25BUQs0GmZQ02wQ78In/ZS1Fdqg
         Cg6dHGitJjmbTTldrrWYo/R8GBJZ4ucC9r0hW0Fr9LCpCdKi8oGwbbvT6v3PFbEPukiQ
         jvbJla8OZMHuKIWXoDYeSRB40IXvUPRzwgJ77LysLxKurdbmdJzMSA9GrX4eC271g/mz
         ytoSB9mUruj0clZV7pHUuMk3ouyMx3gxXnObUIMfgbUCNhGsefEgU1c8HZeI7UCUB/gU
         EEiQIdJQERaLNk8b8olxpsHKB49kCIJGSVZJo6Cv83tQETjFG2tOp/7A2biArroB/789
         Nl3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Cj3+LM9v;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s18si2354833plp.128.2019.06.14.06.47.45
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 06:47:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Cj3+LM9v;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=2klM0787YOypidTxFFKkFXrGCXrbMhQ5qreI3X9Vu1k=; b=Cj3+LM9vIrA6nltYCay8yBPba
	y6IkbYwpLx9JZh8kK5t2kLy0T8EhKYFLd4ni8FEoVyGRGa1u1i3grWUes4UAS9IJ9k3PGBxh0Ddkp
	+eH6rF5lBzxCwQMwke6G/c2TJda2p6rGBomPUsGZBfRc0dQxUxHgwIel6XPax0+lxmSXe9hnoqneL
	tM4WnvDTXZk0YQhKyEzCwXVDmrezpr/WzX/aQS4stZilw7GkSoqCXo2Zka98OqbC6gFV5/7OKNZNF
	BKEvRnmiaTr9rp4o4Y6qOWysCXUmGZc3uHBgRcuKZdrN51a9q9TVTZ/wz3VsIWst8b5uTNKZ6nDin
	VS2+DYitQ==;
Received: from 213-225-9-13.nat.highway.a1.net ([213.225.9.13] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbmYG-0004Xc-Jk; Fri, 14 Jun 2019 13:47:33 +0000
From: Christoph Hellwig <hch@lst.de>
To: Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>,
	David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Ian Abbott <abbotti@mev.co.uk>,
	H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Intel Linux Wireless <linuxwifi@intel.com>,
	linux-arm-kernel@lists.infradead.org (moderated list:ARM PORT),
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	linux-s390@vger.kernel.org,
	devel@driverdev.osuosl.org,
	linux-mm@kvack.org,
	iommu@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
Subject: use exact allocation for dma coherent memory
Date: Fri, 14 Jun 2019 15:47:10 +0200
Message-Id: <20190614134726.3827-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

various architectures have used exact memory allocations for dma
allocations for a long time, but x86 and thus the common code based
on it kept using our normal power of two allocator, which tends to
waste a lot of memory for certain allocations.

Switching to a slightly cleaned up alloc_pages_exact is pretty easy,
but it turns out that because we didn't filter valid gfp_t flags
on the DMA allocator, a bunch of drivers were passing __GFP_COMP
to it, which is rather bogus in too many ways to explain.  Arm has
been filtering it for a while, but this series instead tries to fix
the drivers and warn when __GFP_COMP is passed, which makes it much
larger than just adding the functionality.


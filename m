Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26384C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 19:07:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF43221955
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 19:07:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TDn8HmOO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF43221955
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74D876B0007; Mon, 22 Jul 2019 15:07:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FED48E0003; Mon, 22 Jul 2019 15:07:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EB5F8E0001; Mon, 22 Jul 2019 15:07:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4CC6B0007
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 15:07:32 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id p12so44428310iog.19
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 12:07:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=IHo0jd60OP5WBABQOSv1YQjEJDC3NFfuLVsurLyCzEY=;
        b=MrehJPMxaDbKW3Bf6A2aMHp0MHdA/417HL8ljbG4nEmMYuQtQcdRT6L8KHXsSZ5zfW
         b7sFh+fbQZESq2CAgUpcldyFEZorsfs53xX8frRT6fHXholr2iSfcqboTXF1J1vjVc4T
         uG9gKIjDiu1f4utvexKiQpMNd6yjIn1KQWdoZlH5P2xOoML3FLQzJ3HPJaxeW2+i35vh
         3CyqE1JIJVCUQlVWv1meW0clch6bCQqOGuuIG3a8lczdBwJ33JVJlHs6mNvO9ur1K0IN
         Wy3nsAnBg3lcIIMYcnkMROi5i9KJn3SM690k3y9DeZo9BbyNkHPjKuOIcKDwxujIv/LY
         s22Q==
X-Gm-Message-State: APjAAAU8NlaQS2oz8Qb5ZRZWXzDiSCd7iYp8W9drk1Kpj0XJsOQF6J/S
	Sk0jv145j1rVky3T1+tNHqU2clAuIujARVOL0W7yI0J6F4qneY6wh0ycoGH0gquKddwOd0xM7kT
	cT+3fgG7Y9E1DatvaN32iOy48Cg6CjkyqqGbQcbmJDfm8y4kBQRELjsf10NW7htkTSA==
X-Received: by 2002:a05:6638:281:: with SMTP id c1mr73736662jaq.43.1563822452015;
        Mon, 22 Jul 2019 12:07:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5TyZEnT9zbYIQRbg+lhJcH8ob6uJQIwwR1ji4e97MuYT2jp/QK8RlfjZfQb7PuyuIdD/S
X-Received: by 2002:a05:6638:281:: with SMTP id c1mr73736574jaq.43.1563822451388;
        Mon, 22 Jul 2019 12:07:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563822451; cv=none;
        d=google.com; s=arc-20160816;
        b=c+fqeYber6KPdMNwb1PUaxrFvjZNJcpKSulLG80/iJUZAY6SOk/QcPibfCq1QUBa/Z
         eVx22UQVPEjnEp9Z398urXvlTRB7XFOEvf7xtxDv+Y62oODyUPHitfcptu1yXIrTgHEL
         m+GhoBjl/lLG2TYjJpvmj8ry2SlLPEHvFwL5+SZJggxM0SZ1dIshROjWDuXmjsuElt4m
         Q6vMsByCswigoFhhcF3gKIxAIBwDZyQdh6JIqB7T8fJ0WN9m9m47i5JyhikkS23xHzuw
         FsBWjCc9TYkv486QuXv7ae5vy6NnezBjkIczSoYRZdJmD0FPlxsw3zCDyjrQfOYU702H
         MscQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=IHo0jd60OP5WBABQOSv1YQjEJDC3NFfuLVsurLyCzEY=;
        b=MCWy002E5k3AofJFhM3DAcYaXIfXxsqF8Tjg05tsQTE9dGZkqgUWUZHw3disKCrdCd
         1J5U/pdhph3p5tZT2uGwaBlilVKcWlBJ1RP6UT+rqq3d7ka6ZeYNWRJx5cbRlWcBGId1
         1QrAFwnN7qgTAKek0fEj0kum/ShIpOFJ41wNQIXzsrQJnvPr2Yb3H2jpnhPgboY2cbp0
         51p3Jm8oYC5zC98W4qUU/W67cCulsJgSypkekyBEs8zGyJ2GJEGqZ2nxRix+lncPFLKO
         u1K4VSLWRNxzbilxU2S5k4xkpJI//Q2R0tpsuBB8Lr00QwVy97hkfn2sgYBlycrkvlOR
         /n8A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TDn8HmOO;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d14si64079109jaq.25.2019.07.22.12.07.31
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 12:07:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TDn8HmOO;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=IHo0jd60OP5WBABQOSv1YQjEJDC3NFfuLVsurLyCzEY=; b=TDn8HmOOJ96erQpia/yNOR+Am
	YGQqQ9dQArre0h0KZDDqf99IHdkb/l0SKklOSbgpgKBBxoLsCLryfEj6RWfmx4DzDPt+rxYgB9uoK
	HlzC/qR3epIN5Zp+2mm2Eh0h566b5uvbDMvD60Z2twrJFWDp7fp+Y0MF9aRcqi0ggM2m4pI6GTB0F
	6GBuIKdZlIWXZn2ybmmbcZjqZg/bV1BEe0awYSuqo9n0vP+IZcIp86Izotrk4G6zHjQTWmvczaFIT
	hUgoONnHg9OZ1x5tDD7cxZKUiNLBZmS2Qv10sjaF766RSkLhz9Cy0Hzyo1vHTA41Aojb86W2/vC4z
	idOs2SARg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hpdec-0003Jj-Kf; Mon, 22 Jul 2019 19:07:22 +0000
Date: Mon, 22 Jul 2019 12:07:22 -0700
From: Matthew Wilcox <willy@infradead.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Christoph Hellwig <hch@lst.de>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	=?iso-8859-1?Q?Bj=F6rn_T=F6pel?= <bjorn.topel@intel.com>,
	Boaz Harrosh <boaz@plexistor.com>, Daniel Vetter <daniel@ffwll.ch>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>, David Airlie <airlied@linux.ie>,
	"David S . Miller" <davem@davemloft.net>,
	Ilya Dryomov <idryomov@gmail.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jens Axboe <axboe@kernel.dk>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Magnus Karlsson <magnus.karlsson@intel.com>,
	Miklos Szeredi <miklos@szeredi.hu>, Ming Lei <ming.lei@redhat.com>,
	Sage Weil <sage@redhat.com>,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>,
	Yan Zheng <zyan@redhat.com>, netdev@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-mm@kvack.org,
	linux-rdma@vger.kernel.org, bpf@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 1/3] drivers/gpu/drm/via: convert put_page() to
 put_user_page*()
Message-ID: <20190722190722.GF363@bombadil.infradead.org>
References: <20190722043012.22945-1-jhubbard@nvidia.com>
 <20190722043012.22945-2-jhubbard@nvidia.com>
 <20190722093355.GB29538@lst.de>
 <397ff3e4-e857-037a-1aee-ff6242e024b2@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <397ff3e4-e857-037a-1aee-ff6242e024b2@nvidia.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 11:53:54AM -0700, John Hubbard wrote:
> On 7/22/19 2:33 AM, Christoph Hellwig wrote:
> > On Sun, Jul 21, 2019 at 09:30:10PM -0700, john.hubbard@gmail.com wrote:
> >>  		for (i = 0; i < vsg->num_pages; ++i) {
> >>  			if (NULL != (page = vsg->pages[i])) {
> >>  				if (!PageReserved(page) && (DMA_FROM_DEVICE == vsg->direction))
> >> -					SetPageDirty(page);
> >> -				put_page(page);
> >> +					put_user_pages_dirty(&page, 1);
> >> +				else
> >> +					put_user_page(page);
> >>  			}
> > 
> > Can't just pass a dirty argument to put_user_pages?  Also do we really
> 
> Yes, and in fact that would help a lot more than the single page case,
> which is really just cosmetic after all.
> 
> > need a separate put_user_page for the single page case?
> > put_user_pages_dirty?
> 
> Not really. I'm still zeroing in on the ideal API for all these call sites,
> and I agree that the approach below is cleaner.

so enum { CLEAN = 0, DIRTY = 1, LOCK = 2, DIRTY_LOCK = 3 };
?


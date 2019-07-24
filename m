Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEA01C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 05:31:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61A762084D
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 05:31:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="oW2+1uEt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61A762084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3624C6B0003; Wed, 24 Jul 2019 01:31:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 312DE6B0008; Wed, 24 Jul 2019 01:31:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 203088E0002; Wed, 24 Jul 2019 01:31:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E0B4A6B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:31:18 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id n4so22926103plp.4
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 22:31:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QMaeodYE6xPawroosfuLAM7Isuyd6msaiuu7WIzXJNg=;
        b=aHXhrRd97FRaf8oJYEAR0e9o6K6ePOQL1v6bC0jkf1dVvVD505DTK6AdtSl+HegLjS
         Z9aIAF2A/iaA0SRxeVuY2qWfJZpS4QRVqEii9quEcXZ5oxvHgDDLLWBEelPn2B45sxXw
         sipN+VqC9Vq0AZoGDaMN6niuFRgSIhFqNcH+D0tNjtREq5PKqBaL9KK5AqudKWgYCKaH
         /A4YJFDtZPnkwZaSRIsVM3rTgDTyQnW7AP3dQD0wrhB4NWupJO8yWESePVgOiVlqtoxQ
         oNqjhkPI7Z7KiwBJMq7oRhhO9Hbjwg7goP7+wq4Mb2Kq2XRn3Fm136KZWK6+nn30PAjM
         Zo6Q==
X-Gm-Message-State: APjAAAUw+PMBEBHE6xtE3MUKvXQMvYfg1pnMH+TnDDVUXjXlKTlBNM5X
	oQ7MqKXa0rr/svMmbE4wQrue34fLvc/2dvDmjj0W74w0hbKdPRn7EXOcN5aBFoIlraQuKCljCA4
	o/my8aXVVOARL/VifVQ0DsPuRpvVJ0yMpMMIXo+UHFLlOH63xwdxFF2chcU1fJREDbQ==
X-Received: by 2002:a62:2d3:: with SMTP id 202mr9603292pfc.131.1563946278478;
        Tue, 23 Jul 2019 22:31:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysptlSuND85WyrDCEpsjhZDW3QBhPEwV6gUoJQo3gWSZBSBpyVd3Y5BgLXn4FF3QjjZGJ6
X-Received: by 2002:a62:2d3:: with SMTP id 202mr9603246pfc.131.1563946277779;
        Tue, 23 Jul 2019 22:31:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563946277; cv=none;
        d=google.com; s=arc-20160816;
        b=XBUls2VqpTdS6Z+5BeH7s1SvaAQPzhyGSzyA/xJB0ighRjK0mmCeZH53N9ER4zX7Q6
         Jr4z4A7XUaxDum6PmHSxNlNpNL27NWmexrMO/TGzSOhL99vkVhap8/ciSgQbpKvTG/Jf
         CmJ4wgBDUzjUOj1yqk0UsQJqq01i5sHILvcMKsB/TVukQfn8sugXqVzovIaYIuL6l7gS
         kd9AkozQIn7P88NbotKxAjnK6fK0exXFwnXJ+IScCRvaP2MOnpY3yR545ds6czBgaad7
         /4+Ni0AE7nLvLvgM9efd58KhwG2EhNeawaJFnk9wsvK6xjCL49uqd5xGfMvLylZBW+bf
         q7Tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QMaeodYE6xPawroosfuLAM7Isuyd6msaiuu7WIzXJNg=;
        b=QjYtKJ337ks3rdpu7eGGuzxweiKW78WCWXwZg6WTbFyxiCOTrttW98q6mgTt+rdITV
         YNLCV0fMNmOMl0wi9oRKCzqRF7KdeXWl22hwFjUsaGpIQ0GtjT/DrS1Ji08/+fCJA3rB
         O/8IFKKD5jPcGJJsUUv6hiTtZjsQv1X06mpl6tV/Gl8zMP2xJidGkSnDeq/A+ruJejrB
         ri1HdjptBFfu22Q+XLUgn2i8BlOGioXU94/mNbby9Y+kQsWaxmrqSR7VasUHIEqbqIQA
         sBkR9e17vULjNE8BVl96041+VcsuwPUEiZIZCAXtESvz+ei9U6dEBGJn8t6lGL9s74XF
         s0iA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oW2+1uEt;
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 33si16576344plj.90.2019.07.23.22.31.17
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 22:31:17 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oW2+1uEt;
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=QMaeodYE6xPawroosfuLAM7Isuyd6msaiuu7WIzXJNg=; b=oW2+1uEt0qJRsZ3rIR+o/XGwJ
	IpJYdIAzmbpSGeQXXd0w7hFDdorld2bWWW2oiCVa9bfBdmqzQ8VzYAS+3VpPpYND1enTUT3LXM1SV
	CwbH89SUpW2WcPCY1lNCr1Q9WWq6hrUjLEGXr0uuup16IdlyJWTjkk54FwGggAAJ6/K2n0CpTScov
	6bsInH3E0/xFvQn6gl70zra+lZBETmvjV0nc1ECTcsc2eePjN7LRDKmPqETKEgRYUFXsRBdhR/R8v
	o2dvpNjC4kqeW2Xy7IKsHBsPaIMTNnKrfPXCCv6MAnnK2HeXtxBGaSw/R+BXARy62cABx/L38sQl7
	Pi0QmIdOw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hq9rZ-0006FA-JW; Wed, 24 Jul 2019 05:30:53 +0000
Date: Tue, 23 Jul 2019 22:30:53 -0700
From: Christoph Hellwig <hch@infradead.org>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	"David S . Miller" <davem@davemloft.net>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jason Wang <jasowang@redhat.com>,
	Jens Axboe <axboe@kernel.dk>, Latchesar Ionkov <lucho@ionkov.net>,
	"Michael S . Tsirkin" <mst@redhat.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Christoph Hellwig <hch@lst.de>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>, ceph-devel@vger.kernel.org,
	kvm@vger.kernel.org, linux-block@vger.kernel.org,
	linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, samba-technical@lists.samba.org,
	v9fs-developer@lists.sourceforge.net,
	virtualization@lists.linux-foundation.org,
	John Hubbard <jhubbard@nvidia.com>,
	Christoph Hellwig <hch@infradead.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Minwoo Im <minwoo.im.dev@gmail.com>
Subject: Re: [PATCH 03/12] block: bio_release_pages: use flags arg instead of
 bool
Message-ID: <20190724053053.GA18330@infradead.org>
References: <20190724042518.14363-1-jhubbard@nvidia.com>
 <20190724042518.14363-4-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724042518.14363-4-jhubbard@nvidia.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 09:25:09PM -0700, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> In commit d241a95f3514 ("block: optionally mark pages dirty in
> bio_release_pages"), new "bool mark_dirty" argument was added to
> bio_release_pages.
> 
> In upcoming work, another bool argument (to indicate that the pages came
> from get_user_pages) is going to be added. That's one bool too many,
> because it's not desirable have calls of the form:

All pages releases by bio_release_pages should come from
get_get_user_pages, so I don't really see the point here.


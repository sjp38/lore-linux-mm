Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DC4DC76186
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 20:57:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 494442070B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 20:57:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 494442070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 053498E0003; Mon, 29 Jul 2019 16:57:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F1F888E0002; Mon, 29 Jul 2019 16:57:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBF8B8E0003; Mon, 29 Jul 2019 16:57:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id B75588E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 16:57:39 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id g189so16339482vsc.19
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 13:57:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Ej87fJCgfgG5YmUqt7FsxEwGENhvNmHWA4s4Vq1TU6w=;
        b=s1R3J5Uy7BYu4ScOLGqiQjjSW8vOe6gZrD3XKl+hWSiDMoPBIpCXs36OGCZzD4BaJY
         CVq2P8k+MpzixagSuEKAnwkqjaFWQYP2jIUv4dFJVq14IkpJCfM6bHKwTT0SbUiWDdZf
         MhmLJUEuYgbLY4rqqil7h+XgSJ4+1MkNBQejbkswadVxFDBa0sT6yRSZIL11J3QykfCZ
         trGSpT6ChY1lIQc1yxRJCGU/7jKxLAS2Nc1IUGgKSgP8jpSDftRUE1A54QiE4M+g9pKN
         m76TZfFhE1CBI15db5E2xvL+UJ2tTkLbjsXbtAbGY79FD2XP+voMgfqYRYfLpFZy1D5n
         Y9mw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXkZF2U2X2mFwiLahzfTaoAQZQ9C9X7yNMCrErhL0wsI55l9Xrd
	iHAUCJtIoR8A3d/gZNyTyHSRurf9UOLwwSJrsgO50MbVlJ4oSSwjSo6+tzHKCV2iFWHdUAi8LeS
	4xqNjR46SPFzZ61HLI2uHWngmLoGYhlT+2GK03rPeFPOCjdhMZBAa9cDFUYeqSjFF1g==
X-Received: by 2002:a67:c914:: with SMTP id w20mr43243061vsk.110.1564433859550;
        Mon, 29 Jul 2019 13:57:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+JZ2GAoQ6FebGpPFPMBPREfwG41BBRWJUkc29vxLKxVdgxUDs5W1UpR2ZMNWTD/7POSyi
X-Received: by 2002:a67:c914:: with SMTP id w20mr43243002vsk.110.1564433859020;
        Mon, 29 Jul 2019 13:57:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564433859; cv=none;
        d=google.com; s=arc-20160816;
        b=y19blDOYTjw6FIWMxbcIVXBkqycTuKTr7BCfDE0ElSC9JeVIBP5xaiqdKo594WQ2d+
         QkKHT4D86ZVL12UB88EB6RC2hTxM3tXpwOQEXHDZvv6wRYSYMel7Evp2URF1N+8Chsro
         qCz4f/AxNc9D3ZuoByC4EOKqwGgFo0LU3RHJRg6idsNkVMeGRitqHl4bSwgLsjQVBdOB
         AaoZwfT86vnfPfBFsWpR7KNMQYqF+KZvWZ4LiDyC86owlgkDGu1a5+C+QFV82bjkZ3w1
         FpT21ZPbrFFVMlOZ5ceBkjx89rgNq5iUDOv3/klRVZEGm/vRfj8bLbngUa4teq25V8IR
         MYAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Ej87fJCgfgG5YmUqt7FsxEwGENhvNmHWA4s4Vq1TU6w=;
        b=O/ZrWuItQrjr5Za/jC3vhQlJfvKZ3EJN1oVU5118S7x2PJd87RF+jBC+dYukOkEEWO
         /CZuZD4AyfJpolpzFG4VlZLbKhO2Wd5Lk0ucCjET98DGPQE8nFbc7I1EOUCVKNfndzog
         HRsUVJtCqqJsVWZPz5We7swzgGO3JgUHTyieCSZzbuDxBFQ89C6kv/aLqDLDyxNhJf3E
         OUbqTMBgmhuWQkNvr3kLKjYu/1vJ9dhIXxlTnIfO4XzExCqjbrrXjfw/s4jUVl0H8Kik
         z626IxA3A0vNUK5WxWtBPTE1iQsZeMFx2KUotfO1XRCNTTVyc5p4MH4BfRoWVBTonjcV
         ubOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t11si6455415vsm.360.2019.07.29.13.57.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 13:57:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 40047C060204;
	Mon, 29 Jul 2019 20:57:37 +0000 (UTC)
Received: from redhat.com (ovpn-112-31.rdu2.redhat.com [10.10.112.31])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1D8C65C219;
	Mon, 29 Jul 2019 20:57:24 +0000 (UTC)
Date: Mon, 29 Jul 2019 16:57:21 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
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
	Minwoo Im <minwoo.im.dev@gmail.com>
Subject: Re: [PATCH 03/12] block: bio_release_pages: use flags arg instead of
 bool
Message-ID: <20190729205721.GB3760@redhat.com>
References: <20190724042518.14363-1-jhubbard@nvidia.com>
 <20190724042518.14363-4-jhubbard@nvidia.com>
 <20190724053053.GA18330@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190724053053.GA18330@infradead.org>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Mon, 29 Jul 2019 20:57:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 10:30:53PM -0700, Christoph Hellwig wrote:
> On Tue, Jul 23, 2019 at 09:25:09PM -0700, john.hubbard@gmail.com wrote:
> > From: John Hubbard <jhubbard@nvidia.com>
> > 
> > In commit d241a95f3514 ("block: optionally mark pages dirty in
> > bio_release_pages"), new "bool mark_dirty" argument was added to
> > bio_release_pages.
> > 
> > In upcoming work, another bool argument (to indicate that the pages came
> > from get_user_pages) is going to be added. That's one bool too many,
> > because it's not desirable have calls of the form:
> 
> All pages releases by bio_release_pages should come from
> get_get_user_pages, so I don't really see the point here.

No they do not all comes from GUP for see various callers
of bio_check_pages_dirty() for instance iomap_dio_zero()

I have carefully tracked down all this and i did not do
anyconvertion just for the fun of it :)

Cheers,
Jérôme


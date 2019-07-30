Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4831C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 10:26:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6CE2D20651
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 10:26:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CE2D20651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 214558E0003; Tue, 30 Jul 2019 06:26:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C51C8E0001; Tue, 30 Jul 2019 06:26:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B40F8E0003; Tue, 30 Jul 2019 06:26:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id B1AEA8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 06:26:01 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id i2so31568110wrp.12
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 03:26:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OLnhwp1Ir7o0Cp8Oes6ebmKFiIiIxO6WwaM5tBmCVZg=;
        b=kAdliAvocQGjONVHeVbdtCqeMpF5uD9oAKEcb2MKJGif26rEsEECqZFGgFUfLv/iSg
         zxEzdxEwUdcZWfCvgLdNl9iuVBHUhOjBm6QXEFaV66TKegKWlhTDuChrv+OjUefH1nKb
         Q00eaD5px0fk0nqs8zWQqutluY08ZCvkB3QtnB0KCfCddb8Pz6YLcVBzUvgjFYw81uoV
         bhribvkqXRWdQWw9nyiiGjapnnYza/QDyN1MHQuMiFUXnh9mJ9N3JWdMIfph/dCv/3M5
         Vy0xlLJEXYSq5odebQ3ZW+y3zB3Fp7zJO3xFgmyf8jCc1pnNnil3zSBoxctloglV3wIS
         6OBg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVP4+K2wCBN3FRxEowZeslN1/pmFpfmLSB+DYNGG2pmZXnYjlHT
	FcF4HBjnjeSwdFfkXQqhupuAdgF8d4XlkJHIpQrEvRV4tBwvo2i7QZkpgpRVQU/cN78/Hh+aQt/
	GPwC0+hMYkd+xpXs57ix0iGiXod/0c2qWTfa6UTLfED27JP5iyPVrKvKTcLwoItuJLw==
X-Received: by 2002:adf:9d8b:: with SMTP id p11mr91428808wre.226.1564482361330;
        Tue, 30 Jul 2019 03:26:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBlOD0l4jr030sbcSwmop01uwvi+aLsfrEFYovAPtyQemNytn2f2OwEJlQDt9FSqQPL1Q+
X-Received: by 2002:adf:9d8b:: with SMTP id p11mr91428713wre.226.1564482360493;
        Tue, 30 Jul 2019 03:26:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564482360; cv=none;
        d=google.com; s=arc-20160816;
        b=aD0rLoR/wBjAcRpXoIf4Jn7kDwV4nJu2ZNshtKiZkKTUbxTCz5E3lIfqZrXVCksr+l
         9f5sEnp3UtGjbdSJRRAPxSxkrfzwMcoS6EDKh22Pz8MIl6yWwJjUuvbuxVVNRP6Ouyqo
         DLY2PxZORHD+/Hrt1+MqxGaanvqUY4aMIYCkAb1f23PuVFvawAvXXZKR1g4unUIgSdzs
         LtEgI4L+mWOG8zioo9SMIpIjHM0sVVWeaH0bVPYZ3SPEa71zF6hT5xp32g4rMMI/SvhM
         jOD5ySv0mGJWmX/dZrrbjmyhfBWeSXXv7Dvh4bHmmkQCgYGlEP4hr8stucZ/7alzBOg7
         AM5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OLnhwp1Ir7o0Cp8Oes6ebmKFiIiIxO6WwaM5tBmCVZg=;
        b=T8I9fWo7G5AeUZFXSIy9Ll/hLf9W3GLErZJxYPaAcVj58GeparB9klAoOplFsmp+lM
         dJJPcoEiMwJ3+bni63QzODxElbr8FImuLKQ1JNNFaHuhWz3XTVn9q+aelNDrjtgmnjcU
         hm9xSI+Z8vyQN5Y8EjyYwz/lQtvQyaRGQ03gqzIwbBnoUBXT+WztpWyRHzZzaLyXXCAQ
         nMQhL6EhhSNPmiYxuH0KMu4841ib09a8GZrTcy2jnKjMuhVmknaadBHUgg7XLraNr9B7
         s/7wgCiqYIW1ia+es1JqF0p2eclprdq2ssMh5LxY/A5dFNd4W36zdYPUy5GNVt4H4S+T
         DCGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 17si47358733wmf.19.2019.07.30.03.26.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 03:26:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 4C21468B02; Tue, 30 Jul 2019 12:25:57 +0200 (CEST)
Date: Tue, 30 Jul 2019 12:25:57 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>,
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
Subject: Re: [PATCH 03/12] block: bio_release_pages: use flags arg instead
 of bool
Message-ID: <20190730102557.GA1700@lst.de>
References: <20190724042518.14363-1-jhubbard@nvidia.com> <20190724042518.14363-4-jhubbard@nvidia.com> <20190724053053.GA18330@infradead.org> <20190729205721.GB3760@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190729205721.GB3760@redhat.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 04:57:21PM -0400, Jerome Glisse wrote:
> > All pages releases by bio_release_pages should come from
> > get_get_user_pages, so I don't really see the point here.
> 
> No they do not all comes from GUP for see various callers
> of bio_check_pages_dirty() for instance iomap_dio_zero()
> 
> I have carefully tracked down all this and i did not do
> anyconvertion just for the fun of it :)

Well, the point is _should_ not necessarily do.  iomap_dio_zero adds the
ZERO_PAGE, which we by definition don't need to refcount.  So we can
mark this bio BIO_NO_PAGE_REF safely after removing the get_page there.

Note that the equivalent in the old direct I/O code, dio_refill_pages,
will be a little more complicated as it can match user pages and the
ZERO_PAGE in a single bio, so a per-bio flag won't handle it easily.
Maybe we just need to use a separate bio there as well.

In general with series like this we should not encode the status quo an
pile new hacks upon the old one, but thing where we should be and fix
up the old warts while having to wade through all that code.


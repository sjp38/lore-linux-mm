Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7679CC0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 15:57:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B0AE20693
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 15:57:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B0AE20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB5408E0008; Tue, 30 Jul 2019 11:57:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C65C28E0001; Tue, 30 Jul 2019 11:57:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2D2C8E0008; Tue, 30 Jul 2019 11:57:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 931158E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 11:57:21 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id l7so8624155vkm.21
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 08:57:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=4c3jR0CaYiCMyIFZvXMgV0XG+tZgPmzd0opuCtAzKQ0=;
        b=CYBOOkxOLzHofuB1mLSXIVt0E+GcMfeRJJ3d2P1rff1ECc/IttLeadw/Lr6yLNCBRM
         3Xjga0z9jRRIQyeA5Hl9TwPeFvX2n4+axBYHggZoIjqf1zoueLajh77zR9IFVsU+bQ7V
         hSDUPsO/tME+HWANbVuI2vetNP+eZnyu+BcBACy8ZGY61tdUHNJcaRdhdf2AkqWkwwwA
         FCF5uuwr12e20p8KJVOBLsGkigqGnwr7t8/TuAWiQijiYQkeQwuMHLJ6rFhKfzQbdLsW
         f7hgpc1oAUZurwwp3d2S1vDsG5U8j+nCfEiLaR6iiXxhU9NFmpLZrlWy6bFB+2jXG/bv
         AFdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVj+ehlSPeuTsZDW9NEhPxv3MP4XCCe4sJx+pm0KISd+/7oS+zc
	xghaCk6QPdXoK/yhAwmf3iXPCxEhRKAyQxiohblAayTwLSpwViJuuk3SCdboLo3GcHMJ+/9ufYA
	Y1c/Ia5riTV+XBqaX7YMo3gwb8yenn3/LkwTY4/Gk2+caaR+S+8z7NeOEEq1wpXShLw==
X-Received: by 2002:a9f:2027:: with SMTP id 36mr23682207uam.52.1564502241340;
        Tue, 30 Jul 2019 08:57:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzemmYHPSRxBCY4jYH0zq7js7TNf8jQhUQqu4JlTJvlBluubXluGYlwX3XPcGyjf6MUKnz8
X-Received: by 2002:a9f:2027:: with SMTP id 36mr23682142uam.52.1564502240648;
        Tue, 30 Jul 2019 08:57:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564502240; cv=none;
        d=google.com; s=arc-20160816;
        b=gHDpiHOFhdZ2EwLtLtmmTZYa1fcmiOs1qNKiPL9v/D25DsCMKpyrco5EwKnNuF5+s8
         usELi+LPbTXjre/4WVFWE5x888n/ilKBEAk7wXnMz6/bENVGOM34X15qEIKhzRfVPPjQ
         hxOI8F+zCJ8exNhSolp4KDYVqyDXtzyPQyc8ZTNE88V8PUKeK4De2SfVqPIj1PNMIMW+
         rfiYLKKHbttBNHh36WgqHTnnqIgKvArkeFolxEqasNnw+877xhmYLMeMWcn+CekvWvGx
         Uwub781u8WVJdVI3PvItFgK+Zr8uJwgQDaZkhNaV1FE/re1CyK4kiLmOH1ju2lp4pn7e
         SUUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=4c3jR0CaYiCMyIFZvXMgV0XG+tZgPmzd0opuCtAzKQ0=;
        b=dROFpVr5VwXd8SCMWV/mjP4NccZocIZuCqgTK/Hs9sQP+mVjbHWLcslkXrdXa0GIQn
         XhEuGfJPPRpQ8dUAIvAErs8T+sZP+NjgGUdHBX074vAKH6la0DSigWWO+TuLM1XRytuZ
         PocJoerrwFIY17p0nxgWI+C++57UluOCfmhkM2WucbfRG9xW9bjjO66YPmY2EntZrexz
         VC5QEe/CXSqQKWrLlKCwNBrhn3gxvm5nK/G9u02pJILWszke3zcSvauBMiCfrElPW6vb
         394qQ+TwtO0BEu4uaZhm/pput0aAqdUejIHiTUAiuPrg/eyYWPPR0NMcEzsURJFYbZEd
         QlFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q7si14984332vsm.71.2019.07.30.08.57.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 08:57:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AD19A300CB0C;
	Tue, 30 Jul 2019 15:57:17 +0000 (UTC)
Received: from redhat.com (ovpn-112-36.rdu2.redhat.com [10.10.112.36])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A63655D6A7;
	Tue, 30 Jul 2019 15:57:05 +0000 (UTC)
Date: Tue, 30 Jul 2019 11:57:02 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Christoph Hellwig <hch@lst.de>
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
Message-ID: <20190730155702.GB10366@redhat.com>
References: <20190724042518.14363-1-jhubbard@nvidia.com>
 <20190724042518.14363-4-jhubbard@nvidia.com>
 <20190724053053.GA18330@infradead.org>
 <20190729205721.GB3760@redhat.com>
 <20190730102557.GA1700@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190730102557.GA1700@lst.de>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Tue, 30 Jul 2019 15:57:19 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 12:25:57PM +0200, Christoph Hellwig wrote:
> On Mon, Jul 29, 2019 at 04:57:21PM -0400, Jerome Glisse wrote:
> > > All pages releases by bio_release_pages should come from
> > > get_get_user_pages, so I don't really see the point here.
> > 
> > No they do not all comes from GUP for see various callers
> > of bio_check_pages_dirty() for instance iomap_dio_zero()
> > 
> > I have carefully tracked down all this and i did not do
> > anyconvertion just for the fun of it :)
> 
> Well, the point is _should_ not necessarily do.  iomap_dio_zero adds the
> ZERO_PAGE, which we by definition don't need to refcount.  So we can
> mark this bio BIO_NO_PAGE_REF safely after removing the get_page there.
> 
> Note that the equivalent in the old direct I/O code, dio_refill_pages,
> will be a little more complicated as it can match user pages and the
> ZERO_PAGE in a single bio, so a per-bio flag won't handle it easily.
> Maybe we just need to use a separate bio there as well.
> 
> In general with series like this we should not encode the status quo an
> pile new hacks upon the old one, but thing where we should be and fix
> up the old warts while having to wade through all that code.

Other user can also add page that are not coming from GUP but need to
have a reference see __blkdev_direct_IO() saddly bio get fill from many
different places and not always with GUP. So we can not say that all
pages here are coming from bio. I had a different version of the patchset
i think that was adding a new release dirty function for GUP versus non
GUP bio. I posted it a while ago, i will try to dig it up once i am
back.

Cheers,
Jérôme


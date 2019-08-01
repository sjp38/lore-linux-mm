Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9D80C32756
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 08:20:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 785B120665
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 08:20:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 785B120665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06C468E0006; Thu,  1 Aug 2019 04:20:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01D128E0001; Thu,  1 Aug 2019 04:20:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4E558E0006; Thu,  1 Aug 2019 04:20:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A97D8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 04:20:10 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id t62so2095404wmt.1
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 01:20:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JnTFS0WWM+rsnRNr8nnkFhMjGGpMGsthUwfEfSdwuJ8=;
        b=J+4219vn0kL+iPPZa9JZ9ZmFuf+I6eDkPMbOjqbxw5KoSYmnc1mPLH1CEIUCjJUPDO
         FxnfaWDJ1Pl3tC5ISIbI3IMZv5t7Y3HdlV5wzFvTqTWJIZ7KcHnlAgfKDrI3L++lzgpd
         fVPNhhoUfcKYLGXLWnLnya8ZaxzJZf35frEouP71qADh/L2JWTz6y9CaTXfWJM4K1N/k
         wZcuDMI3/ffYZ86rGV4AXg8JofbYJ/KbrrPwcy6+6XeGKgWn5+PHnxunaGzSSZ71QH4C
         sHH4YnEK4VBc/XLoT4UTjDPVkxLGuQfLCmaq4IWb0V+Syt2QKHUl/M9wEyWKp4/i9n0C
         NBDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWKuW6cLZdm6BiTJtBiWaYJ93ioy3eU8gmMucRF3BdDMd4QbZPA
	xdlMPfoSTj0eLzjlHJaT+TT8pLjoDBVxkG+TSzoHjI6rniZ1c+jvE/HKBQGQqy7dHzZaX3hhGEi
	8NGrZnAUHYMtUxE7eAgE9uPfl+pXMmUGGQcaaJTQjglpBa9ByrRK0EyhTjpLAcNeRhg==
X-Received: by 2002:a5d:6583:: with SMTP id q3mr1144811wru.184.1564647610234;
        Thu, 01 Aug 2019 01:20:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhCAcLilndK8uqO3nEyFsbszXhjeioRpMR87wwFu5/iitrSQa/L8FSyPMoql8noQmpjuFk
X-Received: by 2002:a5d:6583:: with SMTP id q3mr1144691wru.184.1564647609290;
        Thu, 01 Aug 2019 01:20:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564647609; cv=none;
        d=google.com; s=arc-20160816;
        b=d5LyetBKH8wZHVsGBqNQQnoq8nXIRNsMkBEncz1G6rcnJWhqhDPP76KySeIWmVdTWZ
         Wb10HzGvmlrSK9fW8cO/zYcYTgXErjo+N4LSJhJMFFTg3S+MdUBuabnht2/wtM/0aW41
         tN6WSPZyXQaO+7zODko+JCwnmQS1FNABy03e0qa0/FlGFk1EXXjHLNozDJuVXptpglI4
         rObot83FVPNEcQ1mDlN7IuR5M7TlptoDETTliRL+ZKvo7oFltC+YMh6OpOjskyhnI9+g
         dCaJYzkzcyU83flGR99PoMV6xO9p2yZt7QuDv8ZLraUnSqLfZZ/jEM0TxMvwwWOtdH6c
         JCqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JnTFS0WWM+rsnRNr8nnkFhMjGGpMGsthUwfEfSdwuJ8=;
        b=uJcbZ8EaGC66bwvSSE96XIGNfsEvJ0Avo5obys9F5brB0KnikWI4ijBbqNQ83hbe5t
         BC3OvSsXEbnDysNjGa68Y3HVk4P9vX041JVwi21IaFPzkWfzQqkfQ8GfzpOiAS+2msLU
         odFvK8gZtmAkiOd3sLfMGjn1PUk+ND1653TIB861dk8vpjY+5J+pSB9/Q554hSTHJrmf
         KsqHPF1qEovpImp62grdq2TIkxFWgDloTeL55nU5yM4hLwhe6W1+AjF/0aDlInTHB+UB
         18H4uJ+SssKsjFb6dvk51FnAPuvRamV1JtRbNnAPwsdPEruoVlvPhlt4c/tcVKezU2SP
         V/sw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id r11si64004278wrn.103.2019.08.01.01.20.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 01:20:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 21DE768AFE; Thu,  1 Aug 2019 10:20:05 +0200 (CEST)
Date: Thu, 1 Aug 2019 10:20:04 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Christoph Hellwig <hch@infradead.org>,
	john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
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
Subject: Re: [PATCH 03/12] block: bio_release_pages: use flags arg instead
 of bool
Message-ID: <20190801082004.GA17348@lst.de>
References: <20190724042518.14363-1-jhubbard@nvidia.com> <20190724042518.14363-4-jhubbard@nvidia.com> <20190724053053.GA18330@infradead.org> <20190729205721.GB3760@redhat.com> <20190730102557.GA1700@lst.de> <20190730155702.GB10366@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730155702.GB10366@redhat.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 11:57:02AM -0400, Jerome Glisse wrote:
> Other user can also add page that are not coming from GUP but need to
> have a reference see __blkdev_direct_IO()

Except for the zero page case I mentioned in my last mail explicitly,
and the KVEC/PIPE type iov vecs from the original mail what other
pages do you see to get added?


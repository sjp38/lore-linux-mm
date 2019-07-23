Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 368CBC7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 12:47:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED71D2239D
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 12:47:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="AIBWSs3L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED71D2239D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8020C6B0003; Tue, 23 Jul 2019 08:47:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B1FB6B0005; Tue, 23 Jul 2019 08:47:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A23A8E0002; Tue, 23 Jul 2019 08:47:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4BC086B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 08:47:10 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id t124so36402533qkh.3
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 05:47:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=piZ8i8TowZ2SsXDzt8tX5OF8nKyYqoULcyfh5zRNZ38=;
        b=qilStfCWDjF//rsjuYiQpmn+OtyZM/MtlDuu85LpHx9sQYZhoZ/CmAuOBU7HWuHanK
         RYLiaCqIoFeeBiX3g2fohq22Ey6wLUZ3nyCDam2+FjpCBtJNGZTSnkFG+DbF8FPBPhbh
         7Cvi3Jl1bluWUIhXgQ4G7v8EHszqMQqNUI/aerwfIM1m6liHQDVr5ODe22Abw2EAiwWV
         ewUOt2KMgNHbZw1A0Lc5j1xB78UUY4ar/1jBDgAFLpSe33lGQpnnMfly2mka7Vyl9Gya
         D57hMxTzhZ9w9JcMp7ogY2lCziXjgmAVPbKo8w7lspLXflOsP3rSU6elcf96a9KHiX21
         C9uA==
X-Gm-Message-State: APjAAAUNrfwS60m92mmpFWtRZ1zsOF2zeepVrHDTAkKgYITOMgBNUYni
	Kp94TbasUOXq1nG2GMz+Mpp/pMG+t1uctonQyCq9Ay/i1k89XrZYZEo2+Oq8A20ngc0/2cPXQqq
	ZUIrgfSEhqBbOOSeS6rN7ZJs2SVHSVc3iEMDeoHMXltMpxxK/1r0lW3G71Zeq5Pyo3Q==
X-Received: by 2002:a05:620a:1228:: with SMTP id v8mr5564971qkj.357.1563886030072;
        Tue, 23 Jul 2019 05:47:10 -0700 (PDT)
X-Received: by 2002:a05:620a:1228:: with SMTP id v8mr5564926qkj.357.1563886029465;
        Tue, 23 Jul 2019 05:47:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563886029; cv=none;
        d=google.com; s=arc-20160816;
        b=JmpBf0sx2fuvCqXY0vqYeAKhM3BPZ7UPrkwrzBxScjOahKTZWQbPk8GgfSkGWfLa7y
         TICLO1xhaouwHjEl2W3Tx9MreXM5DtUywxX4ObNlFcHxZRlYBxVEGaSPjIppP/wQitK8
         dr9pU5zCOeJxZFq3NFzD9qo5zXTxlMR+ccv5wr+bFQ6dhrhUZcRGKZTUSjcUB9GdTmel
         PKKQiop49Ku031FmTGWF7k5LDHOJUOhN9nB6xDikNdyfQQsRrrUyiOQpsYSqemlKf+5e
         bXZELPKuYMp6EpJndCWBW5nTzyPYMiz8sgHKsvA0wi4iKvK4aPhLUmfQWzwcpni/WssC
         0+Ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=piZ8i8TowZ2SsXDzt8tX5OF8nKyYqoULcyfh5zRNZ38=;
        b=gH5oEBq+3zztOD6ILfAtycu8YnPJrbs25ByWf7zYpDiAAaNUr5yolafjqNINY6l8pN
         hWioMvwEWQoU+6ZFSWalckcrsLaC1ysJjTW4sbYFzh0V+YirbkB8pCHNCvL1+FIxAmxl
         X4RSFGTeu58xbgflEy+ctsiX6jHRqlYMfanc3NBvOYuPm5dhP6GMwflyuLt55W2zyWIp
         9Jt7nufknGDDPel7BXxMGkc1bwo9E8Ygcp0+CbsZt4s5A+84ENp+28JfjRbfMbKuV446
         0JsYBHgk/GYbUJ2orMhox8tX1zt1M3qcNtsDBPpT6x2ihnyeUgsi4CvBj4bVTzSg1xJ2
         Vq/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=AIBWSs3L;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v5sor56344787qtk.73.2019.07.23.05.47.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 05:47:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=AIBWSs3L;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=piZ8i8TowZ2SsXDzt8tX5OF8nKyYqoULcyfh5zRNZ38=;
        b=AIBWSs3L6TMrqR1kjSjiMOoco1Jvz8sMlyjAm/koUlgASb3F1pge4pF62yhgDzaLyN
         8W6kJiJVRv2Ltl10P0KJ3h4Rxv4Sqan/wDHsLcdXsjf9MrtAiVLfb6MvuqzOUpw1Pvo5
         nfDvSBFzcy4NTtXExC58RlVhp7zb6QbnLZPrvQwNNigrLSQSCT0Y7gE3jAYG9SExooUW
         JtXIQ7nuInz2UXqhOw5OA3nFxJXlzY3ERVxPfPBlTt9/UEojN9Wnpkk9roKmmsv/AIWs
         aeioIMb0c14NQnQgfwpCWB/P0nQs5B9LzMw6NDgi8cvJhVre3EHc/K68PAB7f3zGy6Lb
         WGNw==
X-Google-Smtp-Source: APXvYqyDweYbQsaT3Kt4MRrQs5/v1m87TpQW/FZm/84f2JQiv3oW3vaHuL2MCkVEVWkDHF7BwFh/Mg==
X-Received: by 2002:ac8:877:: with SMTP id x52mr53156167qth.328.1563886029140;
        Tue, 23 Jul 2019 05:47:09 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id q3sm19357570qkq.133.2019.07.23.05.47.08
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jul 2019 05:47:08 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hpuCB-0004tl-I7; Tue, 23 Jul 2019 09:47:07 -0300
Date: Tue, 23 Jul 2019 09:47:07 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Ira Weiny <ira.weiny@intel.com>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	=?utf-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>,
	Boaz Harrosh <boaz@plexistor.com>, Christoph Hellwig <hch@lst.de>,
	Daniel Vetter <daniel@ffwll.ch>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>, David Airlie <airlied@linux.ie>,
	"David S . Miller" <davem@davemloft.net>,
	Ilya Dryomov <idryomov@gmail.com>, Jan Kara <jack@suse.cz>,
	Jens Axboe <axboe@kernel.dk>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Magnus Karlsson <magnus.karlsson@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <miklos@szeredi.hu>, Ming Lei <ming.lei@redhat.com>,
	Sage Weil <sage@redhat.com>,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>,
	Yan Zheng <zyan@redhat.com>, netdev@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-mm@kvack.org,
	linux-rdma@vger.kernel.org, bpf@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 3/3] net/xdp: convert put_page() to put_user_page*()
Message-ID: <20190723124707.GB15357@ziepe.ca>
References: <20190722223415.13269-1-jhubbard@nvidia.com>
 <20190722223415.13269-4-jhubbard@nvidia.com>
 <20190723002534.GA10284@iweiny-DESK2.sc.intel.com>
 <a4e9b293-11f8-6b3c-cf4d-308e3b32df34@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a4e9b293-11f8-6b3c-cf4d-308e3b32df34@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 09:41:34PM -0700, John Hubbard wrote:

> * The leading underscores are often used for the more elaborate form of the
> call (as oppposed to decorating the core function name with "_flags", for
> example).

IMHO usually the __ version of a public symbol means something like
'why are you using this? you probably should not'

Often because the __ version has no locking or some other dangerous
configuration like that.

Jason


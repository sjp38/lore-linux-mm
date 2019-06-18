Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8449C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 18:57:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70B84206BA
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 18:57:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="PXeS3vrp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70B84206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0779B6B0006; Tue, 18 Jun 2019 14:57:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 027C08E0002; Tue, 18 Jun 2019 14:57:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E58778E0001; Tue, 18 Jun 2019 14:57:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id C65286B0006
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 14:57:58 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id o16so13335781qtj.6
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 11:57:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PttUnfJR2Mh5w8ZNX8UBClI5Uo9DGdQHvLC9b9+U4Hc=;
        b=G1+XkY2bCh50fIuMoaApIZ662t0wlWdCpdR3p5t7+KLQjjVwusltZflWNeci7lZAm4
         MzxQRTmygSAp5GKFrP7OGwj2E9y4oFHswquQFI8HS6z9v4hZMGcps8KgNwjihhzZaQxW
         LtkjKVos0kpliVzAco7jhFlsDxpbsTNQTlQVv9xWf3JQ+lnQRSv4j61kv0neiNdNlZD3
         eqKvnynmislTGsKJKUP3UUeH+Wky2YoM/O18IcChZGaDz4DXPtTsL9oKUST41hZCRIjn
         UaRttwT+hLMu4N2+B7vfpi0wU0l/He6T+PKvcMtdz7OiPLVJt4H0Jc1bMS+uXTeoNPvD
         V3eA==
X-Gm-Message-State: APjAAAWnjBJyPgYpUZbGFWkqtKUYy06IpV/0B1uapW13YK9iXhyQ7cqz
	w3BYJl/ljc8C2tqq6DuR4MM9T6XYnIkG2UQN5P18gkR690cRJ0rKN/BVxlrnYp+xs2XZI6OLCLs
	dwg+qxDYocliO+Yxh9w/wLR7+f2toze2qGMVblgB/AdH9I6fS5C4BmRURaXof5h+lCA==
X-Received: by 2002:a0c:b036:: with SMTP id k51mr29991988qvc.103.1560884278610;
        Tue, 18 Jun 2019 11:57:58 -0700 (PDT)
X-Received: by 2002:a0c:b036:: with SMTP id k51mr29991949qvc.103.1560884278126;
        Tue, 18 Jun 2019 11:57:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560884278; cv=none;
        d=google.com; s=arc-20160816;
        b=DMV6Jc5oHAn6gpYDY9U/Vj7NCUPNt7TIeg6xe9uFiE4kMqHyrGej47ujfZOnD8/2L9
         8viio/D6/wdTZalAkaSE49PwO0r6DKVlpFykE/qeEKierbrwAVWu4XNjKOeKayivft3H
         7JyOvQaWxF9zq9rLL5PwMPYuZn6bus+XO1WTqzuG8dnjPgKscHS43rAqiE8w/CE2ZxT+
         OP51xn/+5muPmw6lKEkLpOkA4Vf/G350MaYshOsnzzlG6D7vQjJF+TTb1gT5D/MOp+/a
         7IFC7c/WeobnX8MmUeF9z+WspGcjlXkz2mTjuHdHW+9v+qqKTPoivTZM9jth2Gt2p3nS
         NnZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=PttUnfJR2Mh5w8ZNX8UBClI5Uo9DGdQHvLC9b9+U4Hc=;
        b=EUgQzhvz5VE44D/0wKzwhmNyzdB7+wRWpvFgDZJwGl4RfB+Vz+2J+8syi/wYHvJj42
         YvdJf1BWKRug7o1jEHoxVdi+/YlGZ+HmuLew3Kyg8ovFrg9+RB9QKFrMOIwkh5R390z3
         SFzkNC2ofLIgtC5J1WawLNJHtZQzqGoW5auEcUBfCbuLzcBXymljOaI1Ed/3XbDraJ3W
         NLqPqi+4Qz57aghAResKBLYyjDRGlUInnfWif1gh5rSJF2nlViPKvRxBqSQLTgjRIofZ
         CnFG0mOJ55GsNeDBiABP2TJ+Yd/+hUKK6Rn5lnrhKhpUeJ3aizj9Krakw7H6zDPrAuIm
         quew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=PXeS3vrp;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r8sor22160312qtp.58.2019.06.18.11.57.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 11:57:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=PXeS3vrp;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=PttUnfJR2Mh5w8ZNX8UBClI5Uo9DGdQHvLC9b9+U4Hc=;
        b=PXeS3vrprzJCfOdHHqzsyJuksx6Jm56D2ltYr60kDgSXAubt62volsRxeiJYH3eQEA
         qkIDep9gBltu/VFi4HJjTckykz/IF/uFm7scvosf85B+lHsbj0dpRu3aDtM8neaO1TM8
         jn75MRkzxtq6VT6WxVud/XCv4fiC/Hs/QuY23+nW+QuinJo8UTrJFA4I2rX38F3Pxeiw
         eP9rL5iIlAFSNbpVdB19/9eqmpnvMNQsySfc/gSbru2YJ1r1laZ6myv5v4YTCDELSwVm
         yt0NAobLw0i6IyHq1SKxS6BjkonU3m5GhldixnjUWA6n0jM3Ie3wseLt5i4fZPceHLH1
         /ZTQ==
X-Google-Smtp-Source: APXvYqwnCmKjPrstr3X9a/omza5K8iCghkX9+cWplH9fTwptdxDxjvrYmzpam1j8Twpi6fT6wctRWw==
X-Received: by 2002:aed:21f0:: with SMTP id m45mr87408989qtc.391.1560884277919;
        Tue, 18 Jun 2019 11:57:57 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id m44sm11840255qtm.54.2019.06.18.11.57.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Jun 2019 11:57:57 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hdJIr-0000A8-2v; Tue, 18 Jun 2019 15:57:57 -0300
Date: Tue, 18 Jun 2019 15:57:57 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 08/12] mm/hmm: Remove racy protection against
 double-unregistration
Message-ID: <20190618185757.GP6961@ziepe.ca>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-9-jgg@ziepe.ca>
 <20190615141612.GH17724@infradead.org>
 <20190618131324.GF6961@ziepe.ca>
 <20190618132722.GA1633@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190618132722.GA1633@infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 06:27:22AM -0700, Christoph Hellwig wrote:
> On Tue, Jun 18, 2019 at 10:13:24AM -0300, Jason Gunthorpe wrote:
> > > I don't even think we even need to bother with the POISON, normal list
> > > debugging will already catch a double unregistration anyway.
> > 
> > mirror->hmm isn't a list so list debugging won't help.
> > 
> > My concern when I wrote this was that one of the in flight patches I
> > can't see might be depending on this double-unregister-is-safe
> > behavior, so I wanted them to crash reliably.
> > 
> > It is a really overly conservative thing to do..
> 
> mirror->list is a list, and if we do a list_del on it during the
> second unregistration it will trip up on the list poisoning.

With the previous loose coupling of the mirror and the range some code
might rance to try to create a range without a mirror, which will now
reliably crash with the poison.

It isn't so much the double unregister that worries me, but racing
unregister with range functions.

Jason


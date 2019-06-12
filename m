Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DA00C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 07:42:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E10E2080A
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 07:42:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E10E2080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=chris-wilson.co.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FCAE6B0003; Wed, 12 Jun 2019 03:42:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 886D76B0005; Wed, 12 Jun 2019 03:42:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74E266B0006; Wed, 12 Jun 2019 03:42:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 271D96B0003
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 03:42:16 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id o18so725342wrm.0
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 00:42:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:to:from:in-reply-to:cc:references
         :message-id:user-agent:subject:date;
        bh=/o7LN2RdVGqZlWkSmkf25tQ3liwQ77qKYDs32NKvoOg=;
        b=NHPm3qW0PuvpWhWhCC0cy+vzN9QhkGSVYs2567iqAkzw3nl2LZInOtQeEq53NVdLJC
         /rUfPVkzFwR802xgSG8RxxYJq+LVIp4/xn2UUMMymCqXbQ01BQiIp8fkmB6wQaGBfzFL
         EG1P+fi9PcYtBvWKjtaFnFoQSZ6noRjTa82SCBBziJHycQjWHpXjFV4XyCxIJihDEPRp
         ABxYsVSy3XRHmZHcDBoI0K6gaSzi10519UUmr5SG88vjJoft/LVNLUfol39B1K5efu+T
         VeDO1O6Wh71Nzd7duUtUnCVfRtoGYEglZBjFiReqvZ0Hzlz7sxZXAduxib05jir4VqXD
         xJow==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
X-Gm-Message-State: APjAAAWVQp/nu0ngsSxJ3vbZiT330HVwJ9SRont234zaOT02QdOf1GfS
	ZDm2nFzcxE613rNDU67oDnDw7gNlDOafIzxxOoaumL3dqAxjxtXT8mJvfkyY6dkHe2bbe862jas
	V+K61nme2IAfZfORlGm3WMu5dDoCMk1Iz+6Yg2y+za1R2IlEFr2CA+5FKzeJzxGs=
X-Received: by 2002:a5d:6949:: with SMTP id r9mr37695242wrw.73.1560325335746;
        Wed, 12 Jun 2019 00:42:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzeRxAUdKxq291cFe/MNbEsN53CAFSYC+EbL9P+7AEaGliAF4sOKvAfc5XOR5PDTjxuBbUt
X-Received: by 2002:a5d:6949:: with SMTP id r9mr37695172wrw.73.1560325334805;
        Wed, 12 Jun 2019 00:42:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560325334; cv=none;
        d=google.com; s=arc-20160816;
        b=VQ5qCKs1Z+LDtGhKCHEGzRg+CtTiwZcFMJuGs3h1+NmaRdIjuiVuVm8xm7n5xZX0xX
         j8au74BI9KVx+n2DnEdnbAlNOLye8OF8Ivh4yyRRprPy6XIy2YSLD8iG5KuZiWayGJye
         yAkdcpsqel+72RrmuNTwTjwN91u1UvIKPIRDdlF+a9s8gwGwyOsxNUcLLMinM0d+H8dT
         DlEpBR9LD4kSxzyDOfnYc01zdXufEsTYWACw/qlSAHI8yDNSEyTZ4BwKiVAhn+uK7sV5
         HEs8b9H8rq/rnpIdgIRozlJVu6UHoM/Gc7FIIGu+yrZFtpQ82vYr2l6483WNrtN+rtGr
         lfTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:subject:user-agent:message-id:references:cc:in-reply-to:from
         :to:content-transfer-encoding:mime-version;
        bh=/o7LN2RdVGqZlWkSmkf25tQ3liwQ77qKYDs32NKvoOg=;
        b=GzhyrSGl6YYAYl46GsoNDJ4Xnbw/zx6cieQpqW+9lwe3TBqf+Mu/RqQUPRuvsXGJ86
         +OhhFwJ2G8xO7ms7MaBYiXJoVcyOIOSiiqye282/PXmZLq2rlwqwm/PBll3JciQl5f64
         jQhrwEGz3KjuIvYQl6/zlvZg7O7nJXuSQAXo54h5gQygTwc5E51h5Fww1vvZyXGFDhx5
         dmPB0e0Z0hyApf4eshpMOTR0RNqCehV4vDiQWNuD469PFTimsiFqDj2uavwQEksXhN2y
         jlDhfHfO0QktBCW/WvZmDNU50luCq9VFdOn/MajVMAsUw1qbTcSt6nVSLoL9UehKtPfy
         hbSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id q14si4369159wrm.285.2019.06.12.00.42.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 00:42:14 -0700 (PDT)
Received-SPF: neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) client-ip=109.228.58.192;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
X-Default-Received-SPF: pass (skip=forwardok (res=PASS)) x-ip-name=78.156.65.138;
Received: from localhost (unverified [78.156.65.138]) 
	by fireflyinternet.com (Firefly Internet (M1)) with ESMTP (TLS) id 16872251-1500050 
	for multiple; Wed, 12 Jun 2019 08:42:06 +0100
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
To: "Kirill A. Shutemov" <kirill@shutemov.name>
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20190612014634.f23fjumw666jj52s@box>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Matthew Wilcox <willy@infradead.org>, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>,
 Song Liu <liu.song.a23@gmail.com>
References: <20190307153051.18815-1-willy@infradead.org>
 <155951205528.18214.706102020945306720@skylake-alporthouse-com>
 <20190612014634.f23fjumw666jj52s@box>
Message-ID: <156032532526.2193.13029744217391066047@skylake-alporthouse-com>
User-Agent: alot/0.6
Subject: Re: [PATCH v4] page cache: Store only head pages in i_pages
Date: Wed, 12 Jun 2019 08:42:05 +0100
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Quoting Kirill A. Shutemov (2019-06-12 02:46:34)
> On Sun, Jun 02, 2019 at 10:47:35PM +0100, Chris Wilson wrote:
> > Quoting Matthew Wilcox (2019-03-07 15:30:51)
> > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > index 404acdcd0455..aaf88f85d492 100644
> > > --- a/mm/huge_memory.c
> > > +++ b/mm/huge_memory.c
> > > @@ -2456,6 +2456,9 @@ static void __split_huge_page(struct page *page=
, struct list_head *list,
> > >                         if (IS_ENABLED(CONFIG_SHMEM) && PageSwapBacke=
d(head))
> > >                                 shmem_uncharge(head->mapping->host, 1=
);
> > >                         put_page(head + i);
> > > +               } else if (!PageAnon(page)) {
> > > +                       __xa_store(&head->mapping->i_pages, head[i].i=
ndex,
> > > +                                       head + i, 0);
> > =

> > Forgiving the ignorant copy'n'paste, this is required:
> > =

> > +               } else if (PageSwapCache(page)) {
> > +                       swp_entry_t entry =3D { .val =3D page_private(h=
ead + i) };
> > +                       __xa_store(&swap_address_space(entry)->i_pages,
> > +                                  swp_offset(entry),
> > +                                  head + i, 0);
> >                 }
> >         }
> >  =

> > The locking is definitely wrong.
> =

> Does it help with the problem, or it's just a possible lead?

It definitely solves the problem we encountered of the bad VM_PAGE
leading to RCU stalls in khugepaged. The locking is definitely wrong
though :)
-Chris


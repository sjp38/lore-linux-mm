Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63B51C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 14:00:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F256920657
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 14:00:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="FKW7sXZU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F256920657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 818A88E0004; Mon, 11 Mar 2019 10:00:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C63D8E0002; Mon, 11 Mar 2019 10:00:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68F0D8E0004; Mon, 11 Mar 2019 10:00:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4699E8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 10:00:26 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id g17so1416152qte.17
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 07:00:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:date
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=7e/sIv9a3FB59iaDh6xa82eP/WupGN03SOOLFKiW9uQ=;
        b=d+fBPK2faiLi25UYD82+wdgCnWBAo+FF2Evf2YB1k1qmFYfmHNZHreYfCpdyN2+uSu
         qt+kbvK2KUedw4irEuZAYXWGA0ikgqzosOpYYBMgmZ4kFYqZWy28R5mCixYochRcN5N7
         b/9qLg9kazWpZlALrBOU+sW6DvPyG/38Fb50BhFSOPtpSS/qfaCTRtR1fCW9SD1eJzJA
         Bhb8FH2odCGu8WTdC4juGhwyPdXN9hLM55TWKR1ozBbJMQoHQh8y3F6wCKsBOveW6xHd
         9obs9bHmPSxjIxdL+JdPCIo0eJr6Y8Nd4QwNlCDbYl8suvU+eDgzSdtx4knmNtKpHKlE
         oTFQ==
X-Gm-Message-State: APjAAAXvgvL3UBNZY7BtDtahTMOR30tMlSKZYHwCQz4ResfC/UAugnmF
	1Uwep6RZF8w4mLd7aT3JKHcXitEaH3DHAP4vWQhqNFWZjyc/04YRRg0AXZPCYA+xqucb7F4F6WE
	Lsvfz3zD4bpWvG12YLhun8OoMB911MzZfdVcW4uQLYs6VluN+q8UiUiusgn/C4CuiOSGNRxQsQq
	iB3KAf5LDAFm2fEs24pYhWMwI0YRf+PqVRvjKglUqZX3mv97ybx2jbKFQ0gCgnQoK6/UJHJ4FeA
	qp03p32k+wtY0rKcjdbTYshMKf04qKoGQKJ6s85VSlh4fs4wFRAjoNea1ib/nY7NM8ocJBuZiqn
	u1Vr6BDPtAsdVbT7mVwcCHXj1IEzFN+ny0o2xmfOAsRuM68PZiqIr7KfbCVsacy6h2bFCrM9WPr
	3
X-Received: by 2002:a0c:b5ed:: with SMTP id o45mr26103907qvf.242.1552312826064;
        Mon, 11 Mar 2019 07:00:26 -0700 (PDT)
X-Received: by 2002:a0c:b5ed:: with SMTP id o45mr26103852qvf.242.1552312825330;
        Mon, 11 Mar 2019 07:00:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552312825; cv=none;
        d=google.com; s=arc-20160816;
        b=e9mmvaM7NUBNXPQbLZO5KfxGstO/ec+w6VqNpDPIhZKGChCBbfDN2E7anxzjLSVz8J
         wsG5ZWE22q4kvMVxuLdDI0F42yx4aG/vj5wl58pp7WMjdHnB2/Pf80vOLLkMd49/F8fJ
         HcT8aXMljwSX7NgZJbv9mwF3iye9dJ/VWPXqNZ7gMuCcgIa41+RtCIsHgnTFhwq8iMCR
         HUOTIB+D3q8Qmz2+JBpt1y6V6MYulG7KJSGbatPiDCzayp9kjzLBHHyaO7a+3k1p/XZm
         qWneLSO0GgtNVO5R0JdqmbHZ+KjjuajAjO7FpuzgePQ0YciCqnCKw30igt9nnEo6WmKB
         ieLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :to:from:subject:message-id:dkim-signature;
        bh=7e/sIv9a3FB59iaDh6xa82eP/WupGN03SOOLFKiW9uQ=;
        b=K4bJmtAWR9fs1ZnDO4RAaY+KlrDvtr6/du6yiTfY70vt4vQyI+K1oJwcHLVrbmSyk5
         t+gT9H21mLBNef8qN3wN6rnmQ2uzd4CRvxSZPv8S+77NKD5Ihz7q3Bg5nTV3yBiX7liO
         BNSFsLXwGbJoYgCFqb/txylRR3Pyr5GxErnRkptk0QYKa2KBBb0ekbNwd1UtNa3nvNr+
         VXQsTipDQrW6QJY6N4jTu106Bun3WEN9I+2O0i3si9QBNHSq4HExCbFEbrM3VX12F6k7
         UnPZThGG7i4ClphnLXr6W9wR/nkCk+NRrtbVxIiLuyjTo6SDcosoPobVhEVvW/0TmP4a
         ceTw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=FKW7sXZU;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h19sor6155381qve.33.2019.03.11.07.00.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 07:00:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=FKW7sXZU;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7e/sIv9a3FB59iaDh6xa82eP/WupGN03SOOLFKiW9uQ=;
        b=FKW7sXZULHfKT2P3soD8Z3Buc4yB+G5oFrPwXEGz3MTOcCGcLfcv3vA8A2xW+T7S42
         izCoAN5FhrH633LNdM2D66G2vru16qJMCdMC0SjBSYBbH3RjNasqSg5B5SfLOMmh4S+i
         GILZNC5HwZRTWZAQ1pA1tZnIWKo09omSlPyF958K+fq7zFbgkfKY7mkEBbSHnRG5bqid
         Pe81R7jn2FIASRyBNSzADzMwgY8jI8eGG1iar5MfUlE6Zqq3jYHacGXXOwEqCX64Drzg
         fy0SVDDf9EpbQa/cdaG09gH7RcT8WbDl2agK1t0cIUBAqarLyO50y1Ei5/jFyEPTdXNE
         C3cw==
X-Google-Smtp-Source: APXvYqyrzbHp30AOtaNKWbhPUW4Yv76xWC0kK28w3JfGZFJnRhi8OQzdW/LL3jtw2cjzksSuvs/wgg==
X-Received: by 2002:a0c:9508:: with SMTP id l8mr25723897qvl.88.1552312824439;
        Mon, 11 Mar 2019 07:00:24 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id u31sm3957532qth.15.2019.03.11.07.00.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 07:00:23 -0700 (PDT)
Message-ID: <1552312822.7087.11.camel@lca.pw>
Subject: Re: [PATCH] mm/debug: add a cast to u64 for atomic64_read()
From: Qian Cai <cai@lca.pw>
To: Jason Gunthorpe <jgg@mellanox.com>, "akpm@linux-foundation.org"
	 <akpm@linux-foundation.org>, "arnd@arndb.de" <arnd@arndb.de>, 
	"linux-mm@kvack.org"
	 <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	 <linux-kernel@vger.kernel.org>
Date: Mon, 11 Mar 2019 10:00:22 -0400
In-Reply-To: <20190311122100.GF22862@mellanox.com>
References: <20190310183051.87303-1-cai@lca.pw>
	 <20190311035815.kq7ftc6vphy6vwen@linux-r8p5>
	 <20190311122100.GF22862@mellanox.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-03-11 at 12:21 +0000, Jason Gunthorpe wrote:
> On Sun, Mar 10, 2019 at 08:58:15PM -0700, Davidlohr Bueso wrote:
> > On Sun, 10 Mar 2019, Qian Cai wrote:
> > 
> > > atomic64_read() on ppc64le returns "long int", so fix the same way as
> > > the commit d549f545e690 ("drm/virtio: use %llu format string form
> > > atomic64_t") by adding a cast to u64, which makes it work on all arches.
> > > 
> > > In file included from ./include/linux/printk.h:7,
> > >                 from ./include/linux/kernel.h:15,
> > >                 from mm/debug.c:9:
> > > mm/debug.c: In function 'dump_mm':
> > > ./include/linux/kern_levels.h:5:18: warning: format '%llx' expects
> > > argument of type 'long long unsigned int', but argument 19 has type
> > > 'long int' [-Wformat=]
> > > #define KERN_SOH "\001"  /* ASCII Start Of Header */
> > >                  ^~~~~~
> > > ./include/linux/kern_levels.h:8:20: note: in expansion of macro
> > > 'KERN_SOH'
> > > #define KERN_EMERG KERN_SOH "0" /* system is unusable */
> > >                    ^~~~~~~~
> > > ./include/linux/printk.h:297:9: note: in expansion of macro 'KERN_EMERG'
> > >  printk(KERN_EMERG pr_fmt(fmt), ##__VA_ARGS__)
> > >         ^~~~~~~~~~
> > > mm/debug.c:133:2: note: in expansion of macro 'pr_emerg'
> > >  pr_emerg("mm %px mmap %px seqnum %llu task_size %lu\n"
> > >  ^~~~~~~~
> > > mm/debug.c:140:17: note: format string is defined here
> > >   "pinned_vm %llx data_vm %lx exec_vm %lx stack_vm %lx\n"
> > >              ~~~^
> > >              %lx
> > > 
> > > Fixes: 70f8a3ca68d3 ("mm: make mm->pinned_vm an atomic64 counter")
> > > Signed-off-by: Qian Cai <cai@lca.pw>
> > 
> > Acked-by: Davidlohr Bueso <dbueso@suse.de>
> 
> Not saying this patch shouldn't go ahead..
> 
> But is there a special reason the atomic64*'s on ppc don't use the u64
> type like other archs? Seems like a better thing to fix than adding
> casts all over the place.
> 

A bit of history here,

https://patchwork.kernel.org/patch/7344011/#15495901


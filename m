Return-Path: <SRS0=dvGr=TS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88837C04E87
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 01:53:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 342F4206BF
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 01:53:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l4ipXGRA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 342F4206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB68B6B0006; Fri, 17 May 2019 21:53:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B683A6B0008; Fri, 17 May 2019 21:53:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A7DC16B000A; Fri, 17 May 2019 21:53:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3D56B0006
	for <linux-mm@kvack.org>; Fri, 17 May 2019 21:53:37 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id q12so4267476oth.15
        for <linux-mm@kvack.org>; Fri, 17 May 2019 18:53:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=nQoQJoHpzJQYSi8VTTlyTdi+eKb5pb19O1ImUVZ7ifQ=;
        b=I7RB02upr4ZzY1YX0VJmsQt1mPb+wtJqe+7sU/7byZK2Gq4zc0O2ZUOXPajg+csKNm
         rZH8g8uuZ3+pwQ9LTJ6nO6FDC1AWdd6MgAsGXeEKJ3e5hs+plJsyZlhIFSZlRK2hQPh6
         RjOakROthK0UG5CAMIMzQmdKecBN1xtf74/0+3wpxnVg2KkPI4tc03X0e8syLR2Qr14w
         9hA0sGx97rH6zdnmJIE5v8S/OL8F2AzarNjqKb0MZRNncsp9DYLcxwDcL69Y0Tj1HSKV
         ERdex9PcS80lzJ7bv0O+xFliMNT2cw0nJxRsl2Dg23LH3ts7iSiWM6o/IvL8sELZBLQe
         ZoTQ==
X-Gm-Message-State: APjAAAUsG82TDnaINPK+2+B5Ju4P/W2guXQnCi0hTBvhY77jpwyIg/ik
	hAvPoZ+uV37oUS4Rt6nWyHpNvjOy3FmmaWrzaO0eTdJBCYxbd93irjBYaxRH0y4QSc85TxLndX9
	AnpTF1ncAVipncawu3i6lzZ/jVW8+6FDqUVgPLCnMBvIk1ZV+0h8Mla6jt7LFFstesQ==
X-Received: by 2002:a9d:7acd:: with SMTP id m13mr26098760otn.336.1558144417065;
        Fri, 17 May 2019 18:53:37 -0700 (PDT)
X-Received: by 2002:a9d:7acd:: with SMTP id m13mr26098742otn.336.1558144416409;
        Fri, 17 May 2019 18:53:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558144416; cv=none;
        d=google.com; s=arc-20160816;
        b=kabcyXQea/QszKuaXuetl7KiqDi0SE8tDIwFqaraceJOAclvcbqoPpWDYxuebWZkJ8
         hl50kdY8K1V4Zj1wcqv/iqpjclhssFTRIB9CrBgGlBpHBRcHglWOW9Qe+mr3ZsDFOarP
         U2woUGyWWpp/iF2W+orv9CuCyeY6R/Dt0rJoYoyJ4KikcQEiumJoqo536esu/6Zguy+e
         /Kecvc+AXDg6yFArUiu4aus8haVzJLfPe1iAWe1ll5UM+sSveONBz6tu7prDgTE7iRks
         0gF14+OEdZulYUbRFM5ABUn1nqQc7/f2GBaZPLQ6p5c+pU3CIfITn82dt8Rjfs5V6XGX
         JIww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=nQoQJoHpzJQYSi8VTTlyTdi+eKb5pb19O1ImUVZ7ifQ=;
        b=V75Kyry/XvodGCmjkOuo8aQZjZpnkoMxY72pCNKGmb/zuyhxtb7qnHR2JNVJ9cncIQ
         VDrY9DC+DqrzB9hflrjLg4qnDaXYcC92fi/hsKaiU26aTpvFcASGnsBas4bL+ApRntw/
         2snFA8KBvKkv2JOWaQBQL+KJnvz5xSIiGJG/TsOhB5blaP+T7eeSiHb90qhBjCo0L2p5
         nVf27cEVtmv0/J8YLdTK1/je++/m0blxL/ksGhcuuREwIa6L0TnUttHouwQqxcZowteJ
         +fhxRe1P1X9Wc8B257C2TqNnh69kNNJZFs13TQUSf0CZiHR/yNEy5kQQbaT9dlCpxsCU
         aNyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=l4ipXGRA;
       spf=pass (google.com: domain of jaewon31.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jaewon31.kim@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c2sor5155766otl.156.2019.05.17.18.53.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 18:53:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of jaewon31.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=l4ipXGRA;
       spf=pass (google.com: domain of jaewon31.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jaewon31.kim@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=nQoQJoHpzJQYSi8VTTlyTdi+eKb5pb19O1ImUVZ7ifQ=;
        b=l4ipXGRAjIUzrlrkNvaTG2k7I+bCkITMEedVuFdJU25ONJvkJw5RSmJ17hfa8hOlTj
         mNz+//ZqwGZCy+TvYGRK0bDw0eTbWJ5r+kSSmDLPhgun28oX3ZxMC7XPRpjVdYpkMDni
         omHVPXuYpg8wrhglnXxlow1lzLh96xxBmyWiMeoD+1gwQZWGntUKXA5decjWwKiBG/lx
         axYgdvPwoEQZka/tB8jXG2WFzWSkSZWogp1PycM1fBN5M8h783W4P4NzgFB5oWuHQYP5
         lBWYYo1w+qK5lL3mmcj3Y+cilEa1QO9YPKCKkewslqpnFc3OzC0DSNTcs5DiBqIFGYFw
         0goQ==
X-Google-Smtp-Source: APXvYqzakSouikJDjGU/ZZDMXGyP5yHiZqGJqzz077iJsfIXTiPOTHYX631z9th9Ri2xS+j3CwbDVfry70noOTIRAQs=
X-Received: by 2002:a9d:4808:: with SMTP id c8mr3385903otf.316.1558144416123;
 Fri, 17 May 2019 18:53:36 -0700 (PDT)
MIME-Version: 1.0
References: <CAJrd-UuMRdWHky4gkmiR0QYozfXW0O35Ohv6mJPFx2TLa8hRKg@mail.gmail.com>
 <20190517163420.GG31704@bombadil.infradead.org>
In-Reply-To: <20190517163420.GG31704@bombadil.infradead.org>
From: Jaewon Kim <jaewon31.kim@gmail.com>
Date: Sat, 18 May 2019 10:53:03 +0900
Message-ID: <CAJrd-UuCMpuSDh6Sx24=aesK38XSB5ys2pHCT4K-O0VSj4ewkA@mail.gmail.com>
Subject: Re: [RFC PATCH] usb: host: xhci: allow __GFP_FS in dma allocation
To: Matthew Wilcox <willy@infradead.org>
Cc: gregkh@linuxfoundation.org, m.szyprowski@samsung.com, linux-mm@kvack.org, 
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Jaewon Kim <jaewon31.kim@samsung.com>, ytk.lee@samsung.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Thank you for your comment.

In ARM64 architecture, default CMA region is commonly activated and it
could be used
if no specific memory region is defined. The USB driver in my platform
also uses the
default CMA region as DMA allocation. If using the CMA to do DMA
allocation is improper,
then do you think that the USB driver for my platform should be
changed not to use CMA?

According to my understanding, in CONFIG_DMA_CMA on both v4.14 and v5.0,
__GFP_DIRECT_RECLAIM will try CMA allocation first instead of normal
buddy allocation.
Then it will get default CMA region through dev_get_cma_area API.
Please refer to
dev_get_cma_area code below though I am using v4.14 for my platform.

git show v5.0:include/linux/dma-contiguous.h
 61 #ifdef CONFIG_DMA_CMA
 62
 63 extern struct cma *dma_contiguous_default_area;
 64
 65 static inline struct cma *dev_get_cma_area(struct device *dev)
 66 {
 67         if (dev && dev->cma_area)
 68                 return dev->cma_area;
 69         return dma_contiguous_default_area;
 70 }

Thank you

2019=EB=85=84 5=EC=9B=94 18=EC=9D=BC (=ED=86=A0) =EC=98=A4=EC=A0=84 1:34, M=
atthew Wilcox <willy@infradead.org>=EB=8B=98=EC=9D=B4 =EC=9E=91=EC=84=B1:
>
> On Sat, May 18, 2019 at 01:02:28AM +0900, Jaewon Kim wrote:
> > Hello I don't have enough knowledge on USB core but I've wondered
> > why GFP_NOIO has been used in xhci_alloc_dev for
> > xhci_alloc_virt_device. I found commit ("a6d940dd759b xhci: Use
> > GFP_NOIO during device reset"). But can we just change GFP_NOIO
> > to __GFP_RECLAIM | __GFP_FS ?
>
> No.  __GFP_FS implies __GFP_IO; you can't set __GFP_FS and clear __GFP_IO=
.
>
> It seems like the problem you have is using the CMA to do DMA allocation.
> Why would you do such a thing?
>
> > Please refer to below case.
> >
> > I got a report from Lee YongTaek <ytk.lee@samsung.com> that the
> > xhci_alloc_virt_device was too slow over 2 seconds only for one page
> > allocation.
> >
> > 1) It was because kernel version was v4.14 and DMA allocation was
> > done from CMA(Contiguous Memory Allocator) where CMA region was
> > almost filled with file page and  CMA passes GFP down to page
> > isolation. And the page isolation only allows file page isolation only =
to
> > requests having __GFP_FS.
> >
> > 2) Historically CMA was changed at v4.19 to use GFP_KERNEL
> > regardless of GFP passed to  DMA allocation through the
> > commit 6518202970c1 "(mm/cma: remove unsupported gfp_mask
> > parameter from cma_alloc()".
> >
> > I think pre v4.19 the xhci_alloc_virt_device could be very slow
> > depending on CMA situation but free to USB deadlock issue. But as of
> > v4.19, I think, it will be fast but can face the deadlock issue.
> > Consequently I think to meet the both cases, I think USB can pass
> > __GFP_FS without __GFP_IO.
> >
> > If __GFP_FS is passed from USB core, of course, the CMA patch also
> > need to be changed to pass GFP.
>
>


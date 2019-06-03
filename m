Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01849C28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:29:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3F8825FF8
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:29:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="rBmKAzm6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3F8825FF8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 604B66B026D; Mon,  3 Jun 2019 13:29:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58EC06B026E; Mon,  3 Jun 2019 13:29:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 456006B0271; Mon,  3 Jun 2019 13:29:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B6526B026D
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 13:29:22 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id k23so8126806pgh.10
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 10:29:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=E3YMznrQvI4XYCbxYdGQLQYRxZ6se0IICAJQI35QmUc=;
        b=LB/PSz27bkDmfFSFg9GaK5Rxo0Hlm//UhMpjHsYB0Zw13/0xkNXEfih9gsdERprgac
         whcLb10OCYH8wuc505xxSj3Tjv2romXimmpYFufPxM51RkIlPOPdx3bQ8ACHAF7dW79n
         llFZ+T1n55RyfcYgVZtFEZ3B8LhsY/qilfBzt8pX0dGHk03vq8aMqrda4yHi9xbI13MM
         O1xtulQtH4B8CFs01zKqJVBxtlO/90AjWgn7RndyK31ZRw/K/uVC7LSgGXD0oqHIzjwh
         xNBmxh54Adrv/RzRpDxPjXXVVC4qCEvYlUK/pg1PFuPcyEGA+mAnWB2OL3NFf2CuLHog
         YPTA==
X-Gm-Message-State: APjAAAVxoxYfT6CxNpY2P5zqwwB1gk9/BHKkizMZI0MrszEQx6q1PymT
	+A9/bJz+h6We486n3ruYeMpMKozte+SFf1fzVmlFi+6OseQ44ICxYpiO42ybpHOEPh3vSlS4Kyb
	k+gp5BnnJhBntf4Iox7sKfncNLxuSjKocyVYRWIY2S5GPuIivfbDY6eouIfbhBslfmw==
X-Received: by 2002:a17:90a:778c:: with SMTP id v12mr30102401pjk.141.1559582961722;
        Mon, 03 Jun 2019 10:29:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwqHAKSjahg2qoHUUq3bMwOxUxwveF5yptlBjJZmdPVssiJOZEvbkED7Ljs/ChyHu0fh5vc
X-Received: by 2002:a17:90a:778c:: with SMTP id v12mr30102350pjk.141.1559582961096;
        Mon, 03 Jun 2019 10:29:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559582961; cv=none;
        d=google.com; s=arc-20160816;
        b=aIxx6knaE5aOcKhPmcW9nX18PJBQpvo4BmRdV+buxxYsjO0Rs8B2R8ohYvi664F3+v
         9sXZGiiItRRgJrRpNi/hDJaYchTXwLhACA2SbsMf2lk2x+yCxBBh7qdTUkRYo5u/bzOl
         j0ozDkX0McGqHy0Vfm8TNl4yedse4RKydxxQhFWhcobpoArHG5cdA9TN4lFsUXLcc182
         Y2gKKE4yWx7iYAgZqCJXC/76nhAuzWIcSUuX8mytUQwD/pCnFsofCoReLqPZLtOTGBvB
         vnAeIqys93zVgjauHo70cDcb1Jq5+DqVGOHqg66AssTR4C7rrA6zD2HBOfNbpRgKgLf5
         LZtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=E3YMznrQvI4XYCbxYdGQLQYRxZ6se0IICAJQI35QmUc=;
        b=CqpxyFdsqYk2c90SNHAcjFlMppYkRMLs2wiBZH3Vb2ih1jDqw4kSy6hitRvV8HsvRJ
         9jJ42ue5HxlgeqGcwVAscINMGN/qzBy7oFrD/bvamyHX7GlMC9eBnlENLlfTtAnZk0HN
         +SBGyaowaQtBJXCq8FDKX082R4ZXEjC2ceT+lhxxeMv1Z0LEssu5SRFippVI80B/FzFg
         hxozxybnRTChFczA3ASYhxMN4WRWOY25Mc220t5yhzdBexU03PVf9RJ4Y6WvYaR+1kLv
         vX7FLVWa/kux2bt0XXxT5H6/bZjytcEep/U/97QLEoVSVW+nkjChp0m5jIldPWVP1lKI
         XnCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=rBmKAzm6;
       spf=pass (google.com: best guess record for domain of batv+507fb5ef556a40660e26+5762+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+507fb5ef556a40660e26+5762+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z33si19244647pgk.516.2019.06.03.10.29.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 10:29:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+507fb5ef556a40660e26+5762+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=rBmKAzm6;
       spf=pass (google.com: best guess record for domain of batv+507fb5ef556a40660e26+5762+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+507fb5ef556a40660e26+5762+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=E3YMznrQvI4XYCbxYdGQLQYRxZ6se0IICAJQI35QmUc=; b=rBmKAzm6VMFiVqBuypdPrNnHG
	9qR/xC1YUSUo4q1ihLjn3I1k3Z3Zt6ifT4BOE9d8JuD+KANIIdW4jN8PXiVc/rtwsBx2jUqqiusN9
	XZiJCQFveWwYCiDODxQrw3kCKKimNiQpVcsgEcblb0zsMWY+TexrkRomHsn0JqXwETKx9ELJfGj9q
	jOQlw3G/UlUJUPhW/UmsBMxDxE09/TlTcCGWjEEy2oiu1YHyvKMt+HBSMRmxLaLtbJMUdKbvkie5m
	R6xIoJDLFjnWEVIxBVl5q2n4wLYhS96OJs3nOLbuM/ziN5On8QOyJ8ynpVakg7HFTHIHdWMjvK7eX
	tMuk6CEhg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hXqlo-00025Q-9C; Mon, 03 Jun 2019 17:29:16 +0000
Date: Mon, 3 Jun 2019 10:29:16 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v16 01/16] uaccess: add untagged_addr definition for
 other arches
Message-ID: <20190603172916.GA5390@infradead.org>
References: <cover.1559580831.git.andreyknvl@google.com>
 <097bc300a5c6554ca6fd1886421bb2e0adb03420.1559580831.git.andreyknvl@google.com>
 <8ff5b0ff-849a-1e0b-18da-ccb5be85dd2b@oracle.com>
 <CAAeHK+xX2538e674Pz25unkdFPCO_SH0pFwFu=8+DS7RzfYnLQ@mail.gmail.com>
 <f6711d31-e52c-473a-d7ad-b2d63131d7a5@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f6711d31-e52c-473a-d7ad-b2d63131d7a5@oracle.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 11:24:35AM -0600, Khalid Aziz wrote:
> On 6/3/19 11:06 AM, Andrey Konovalov wrote:
> > On Mon, Jun 3, 2019 at 7:04 PM Khalid Aziz <khalid.aziz@oracle.com> wrote:
> >> Andrey,
> >>
> >> This patch has now become part of the other patch series Chris Hellwig
> >> has sent out -
> >> <https://lore.kernel.org/lkml/20190601074959.14036-1-hch@lst.de/>. Can
> >> you coordinate with that patch series?
> > 
> > Hi!
> > 
> > Yes, I've seen it. How should I coordinate? Rebase this series on top
> > of that one?
> 
> That would be one way to do it. Better yet, separate this patch from
> both patch series, make it standalone and then rebase the two patch
> series on top of it.

I think easiest would be to just ask Linus if he could make an exception
and include this trivial prep patch in 5.2-rc.


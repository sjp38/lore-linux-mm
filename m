Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBD55C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 19:35:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91788208E4
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 19:35:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="MerkcBq6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91788208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2365B8E0003; Wed, 31 Jul 2019 15:35:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E8148E0001; Wed, 31 Jul 2019 15:35:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D7748E0003; Wed, 31 Jul 2019 15:35:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD98B8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 15:35:22 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id p29so35273711pgm.10
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 12:35:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dnU6IvA3KdW0SFxdpQmn9A16T5orF4xfoYuarMx2Vu0=;
        b=pAgiYP6arzcVmg8+1byioezpqZhCA1nFUWRZ9q3UlGhUzzgZo7AqqOeoQJZYI97akl
         ZH4MNfw3fk23DmOTPXIqiOhhs/51HsHZemBNrBER8okJJgU1rWdSHF3tJpFDESwg93dT
         S09r5Q5LtyW6d5w0MdsudOBwGCAG0fZwtngcWDrHRTMfuyDeqXvC0PIFAVX6Mn3xkA34
         w4zPM65tvgTWi/WSVrnm0O3cZlsPqUUb7AUvBuJwayPSRCovtESsbofxZlukWi9+2EVO
         V4zS/nLSuIFBHfUuw3183t67aa514IKPngbV+5T2yfYMtvsU80bYBJ4/agj/F/ZBBCpx
         rUiQ==
X-Gm-Message-State: APjAAAVcf9EeJZl8IDWv0pIa8ItUSe6INPz1Y4SLgYhovx8xKXy9woOh
	EjIE0zgrntvp/TgVWY7NdDKV0cl3xMODOMGm3RStqB3QxG0d66R1zH8UNvzoRvlgjEfawow6KHc
	ieGZ7mIA5p+Dsvrd1MPjNzcZMzaglmOlH9zdOIOv/BAp8ZAA53K6x4Fv2eFJwUMnr0A==
X-Received: by 2002:a63:d852:: with SMTP id k18mr44279252pgj.313.1564601722323;
        Wed, 31 Jul 2019 12:35:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw59XknTZ508DnEmFArDQ6EnwKjZcPHqzZvc6QujDYheUKiDPPBr2NidArq2VpzqK+tWqjL
X-Received: by 2002:a63:d852:: with SMTP id k18mr44279224pgj.313.1564601721717;
        Wed, 31 Jul 2019 12:35:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564601721; cv=none;
        d=google.com; s=arc-20160816;
        b=PfwyofgfIG0p+DCAw2kFxWMMrSDC2j1oYsUdlUNHQtQjIzbQzZmEg04uKrwaxqrSFc
         m2Eeh03W8EPi3xjl7hi0uhM6+uh1oXBTs/O/AwyUxR29Mbzb/brSyjCx2hK900Za5MeB
         62aqNZ11tKAaKImDgAOT1zWKwjgQit9WGHVGfK64HgF0wplqPtw6ozG3FZD4SbgrqnQe
         sONKbczWjQ7PDjDUjWJQPVDRbBVzIOjTy3x/0XqrFjpXsYDNIxzLDI9eKCjC7FhNUPMx
         tKaZF+spVB7qyx1jj/p6Y3C1NPfZb1wwcsbs+hr2er5bRI5+OCAqfUoW8TA8CA7D/zSk
         i05A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=dnU6IvA3KdW0SFxdpQmn9A16T5orF4xfoYuarMx2Vu0=;
        b=D7owznnxbnnBJBT9+bZvYusfcBpeJ1kBJ9e/Ru0swpNBbQ1IMCBWlanFAIxlAFL6bX
         o2OC/5oYnkQ6o08nsxyqlNQ9z0Il/f/sAGQxWPK+jIGD94Bs2sNR7/QFzNzW/rpshXY6
         qaQ0ua5AFRUk/9P3NCRi2QKbcQzf70cfuwHVjT9AQ0S1Yh6MSm/ZSPZdJLYyW6MgNVtb
         iNTwqwEkPnKJlnJzywixGgpO1rAapYFf3jaV+sVcWHQdbGZTEbxlSiQ8/um6XZfdMlb+
         z2Ks9ObWIe6NY4JPyDplRnrEJ9rltJXngrvzh99dAKmHjZa7WJZQg3PKsNbobM+4xW97
         Iq8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MerkcBq6;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s3si31223819pgn.467.2019.07.31.12.35.21
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 31 Jul 2019 12:35:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MerkcBq6;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=dnU6IvA3KdW0SFxdpQmn9A16T5orF4xfoYuarMx2Vu0=; b=MerkcBq6fNC8YU006LyRsNhey
	fOfZ20Clanrtet/ujAe1kIB29nLezFepLkb65Jd8OMlhcrJhgKQ4iCoSvVD+3loE3p5mkRmPgHpoQ
	Ri/uUWJBs2ng24IYY5xG/JHwnmvjXmgqMrwQ/OOJ9L3DscnD1TiqxjWxeVOIy4LQcWzEzsBDGeU8j
	BupwY0n3dTIRwtrbfUxsEKu3nDO9nSbC4xRxstKYzb5HX/a7yIw7HzB0i7zi2Mt7xxam3iRYOm7Mf
	9n97kWf/xV3wd/HnN4hzk7R92oZfTQOoH+bsKo87PoxIF/p+hrfhAUZz15pHpmO3gkhVhTgTbuL3M
	2WW1LhTSg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hsuNR-0000M0-9O; Wed, 31 Jul 2019 19:35:09 +0000
Date: Wed, 31 Jul 2019 12:35:09 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Alexander Potapenko <glider@google.com>,
	kernel test robot <rong.a.chen@intel.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, Christoph Lameter <cl@linux.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
	linux-mm@kvack.org
Subject: Re: [PATCH] mm: slub: Fix slab walking for init_on_free
Message-ID: <20190731193509.GG4700@bombadil.infradead.org>
References: <CAG_fn=VBGE=YvkZX0C45qu29zqfvLMP10w_owj4vfFxPcK5iow@mail.gmail.com>
 <20190731193240.29477-1-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731193240.29477-1-labbott@redhat.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 03:32:40PM -0400, Laura Abbott wrote:
> Fix this by ensuring the value we set with set_freepointer is either NULL
> or another value in the chain.
> 
> Reported-by: kernel test robot <rong.a.chen@intel.com>
> Signed-off-by: Laura Abbott <labbott@redhat.com>

Fixes: 6471384af2a6 ("mm: security: introduce init_on_alloc=1 and init_on_free=1 boot options")


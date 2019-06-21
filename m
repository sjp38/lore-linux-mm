Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90715C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:39:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 233D7206B7
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:39:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="LOaqH/Dl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 233D7206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9073E6B0006; Fri, 21 Jun 2019 09:39:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8924B8E0003; Fri, 21 Jun 2019 09:39:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 731C98E0001; Fri, 21 Jun 2019 09:39:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4E0066B0006
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 09:39:13 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id e39so7863395qte.8
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 06:39:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=W1v9REbUjdM2ZPgzn5WvSncnmCktMY/9EZgX6QI0HOA=;
        b=q9VHMHK7p37gMdDHpQOy4peqB3NDlNhKk09E0fwcKErNFxz+PgUHdPOcLJ25cPlf68
         QXpRKBbvOrNPDjqQCQ4RPTjM8JnZnBmULMF7cdTW8KjgSpnCUQamkwdHfo7NjJIgOOco
         7jayMdXedvOvyalvk/5U03jv7Lm6hfJ04gGDgYm4/HJHTv1eMEK/1eSWAlP49FLUDu8C
         KMcs7eO/d6dJFgs8sHp98T9R4WXRqsJSicIgndXkSPEbnF6KssrYICbCkTPOULNarN9b
         ACWFdMbX2bFe786O05noRnbrv9qDpl7zREDMexb37NktsLNGldii7k064Qigw3pChtP8
         l9CA==
X-Gm-Message-State: APjAAAUY0Rocq+7vyMREOks2qbiUW3S17LJ3GOlAnHqHTTURrhKWFaO9
	31hUFbbSPSSuNdd4BCPX5bMBWe2i2siY15BjP6dyk09OCU+KIXi5X10+GFFl+Xrp2P7kludw5ZB
	JtSFiPTTpl2Seqs1udlimfwlJyXCYJrjw3pqof28Dqipuhatcx3A+N9vX/QPMa9iYrA==
X-Received: by 2002:a37:64cb:: with SMTP id y194mr102207749qkb.197.1561124353119;
        Fri, 21 Jun 2019 06:39:13 -0700 (PDT)
X-Received: by 2002:a37:64cb:: with SMTP id y194mr102207709qkb.197.1561124352595;
        Fri, 21 Jun 2019 06:39:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561124352; cv=none;
        d=google.com; s=arc-20160816;
        b=ZEpyuKQ2eojQJUwzv1X1P1gq4OjyMi5e/mYsEqnnNAnOUO3ZWjr8o3+sL2YlA5XcX6
         j1Q88atT3POVeEQi1Isxa51z2bGUYWgOHxMuPgkhrv3PQ/w+KmzOucOwJXc+B6D+qYkL
         ORWHcoRWSmIrxNKURYEs/C/m2RBo6vit5nxtwtDP5+hax8DSHA6vhZyAQg8JsoRbfwvT
         1NXBvtoAY/glUl8uqaGKCm3/9SpPsDTC1MeerX0hwxgVTYQR5bf9mOgqgsOwz2WnRrxq
         j1wKgkoG5ODV2PeDUhyuMQBDsjInsB8ekz52nUXNFh+tnr9Rz2zAy38nxQyHEIBR8Lid
         0YFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=W1v9REbUjdM2ZPgzn5WvSncnmCktMY/9EZgX6QI0HOA=;
        b=kQ4hXnG6dOJglgVADVljI8UQhA93atphaOdvYV5lwnAQn/IAB9mdniGfItHPNA3TI5
         7wyKenrKhXZYmC5eqf+DFMtIJR0zqnc8snzQzbkr8Ixz47pf6nd6qd00RwsYJQ4yi/bN
         2/MdUCvxX2YKYsfFb0B3Y5POcsr2dbiU1wmiWiuTScgBX/80BuKk8MkZNsKMcEomyong
         RUkCckd67T9uar+ICOCjST5qLVuRIIm5C+xf8jBdZhRoYMZmImviQNXoNIRZBlJvfeTA
         8LiBfT19shI6tmC/0ZoNEszOfdzLCrZAR14Gajf1twABGW5Ewr/gLu/s/Oki4g1RHrPO
         iIOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="LOaqH/Dl";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d15sor1595116qkk.175.2019.06.21.06.39.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 06:39:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="LOaqH/Dl";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=W1v9REbUjdM2ZPgzn5WvSncnmCktMY/9EZgX6QI0HOA=;
        b=LOaqH/DlAyTiaVsb+/cJ5fNqCKK9dcYheZzqBkbU8/dJCNcbdbTdvycRRW6WsdWNrq
         s1KlIlJ8pqtzQuZr4K+pscDPf+VAoNvvbLh7zGps691WEcEWVHVgG/y+SfGLilLH8xno
         0bDlX2xF7lyCGAB4ZXKagYnPnFu5m/m8VbNEpdAbBtffvGdOG5+2xjfKlD1S7GX/sCJ8
         Tki+kAZuPALbN16uIeo3/RJOzrwHbwCpqBWSiMTS52KfM4E4JV89wOogvhl4vLh60o2b
         9hG2keijKi4DWyDadCzOTDOZpyKgf7ZyhWBT1TsI17RSZcSyUl57cSd5RfTlT2NIe0b0
         X9Vw==
X-Google-Smtp-Source: APXvYqwDjXm2EEI8RDeCs7A5M5DgZpv1lwL8EVk5ylfRpHYYLvhclwPmRsPezAJyTvAyxaG7iZQC7A==
X-Received: by 2002:a37:ef01:: with SMTP id j1mr40587433qkk.163.1561124352349;
        Fri, 21 Jun 2019 06:39:12 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id a6sm1525606qth.76.2019.06.21.06.39.11
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Jun 2019 06:39:11 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1heJl1-00005R-4p; Fri, 21 Jun 2019 10:39:11 -0300
Date: Fri, 21 Jun 2019 10:39:11 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 01/16] mm: use untagged_addr() for get_user_pages_fast
 addresses
Message-ID: <20190621133911.GL19891@ziepe.ca>
References: <20190611144102.8848-1-hch@lst.de>
 <20190611144102.8848-2-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190611144102.8848-2-hch@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 04:40:47PM +0200, Christoph Hellwig wrote:
> This will allow sparc64 to override its ADI tags for
> get_user_pages and get_user_pages_fast.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
>  mm/gup.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index ddde097cf9e4..6bb521db67ec 100644
> +++ b/mm/gup.c
> @@ -2146,7 +2146,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  	unsigned long flags;
>  	int nr = 0;
>  
> -	start &= PAGE_MASK;
> +	start = untagged_addr(start) & PAGE_MASK;
>  	len = (unsigned long) nr_pages << PAGE_SHIFT;
>  	end = start + len;

Hmm, this function, and the other, goes on to do:

        if (unlikely(!access_ok((void __user *)start, len)))
                return 0;

and I thought that access_ok takes in the tagged pointer?

How about re-order it a bit?

diff --git a/mm/gup.c b/mm/gup.c
index ddde097cf9e410..f48747ced4723b 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2148,11 +2148,12 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 
 	start &= PAGE_MASK;
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
-	end = start + len;
-
 	if (unlikely(!access_ok((void __user *)start, len)))
 		return 0;
 
+	start = untagged_ptr(start);
+	end = start + len;
+
 	/*
 	 * Disable interrupts.  We use the nested form as we can already have
 	 * interrupts disabled by get_futex_key.


Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E9EAC4646B
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 15:54:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45C3920665
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 15:54:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="bLoA8Vtp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45C3920665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AED2C6B0006; Fri, 21 Jun 2019 11:54:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9DAA8E0005; Fri, 21 Jun 2019 11:54:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 964F68E0002; Fri, 21 Jun 2019 11:54:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 76D5B6B0006
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 11:54:17 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x10so8315321qti.11
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 08:54:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=mLgah8hWTBbEh5+bUoBbV4cO6mlCq84wOyEco/eLAZk=;
        b=kbB+bTyVpuTLTy2jE1IEmPmI1NK/dpQmI7SABd3CtIOHaJ+XgaU+hbIgcO+qTBKqfg
         A7oyYBcksETSt3QZA+mZU9WfKqY9ATrP1+dlJ2pV57arXsjQ/zZW2ujDh/ATmVAZ9HD2
         ipZcxdOVz63fJbf/CCHGLV4wQFVUXD/3vVDMjhtgaRDeRnE6I6ihWwZyFDX0gjEzqaxX
         iJXcL7n9m6KArzqhyxhDYLBjkwLd69E708A1G56tndBaWMWhc4a1JVT7eWwE8PLztXPB
         JyQgp0YBkZpyA2GbELKH91NpgOe+J9K9sgHlhoBs+K4f7k7viXZCfcrJ+96f8kUAYg1m
         fBKA==
X-Gm-Message-State: APjAAAXQO1nIKCvfsEbm+T/Dp0zcHZ88Ha6KE91tf7V3QB70vQmRyLIJ
	9OHwnSv3obz0Lzdinhv1uyx980jTJ2W98Bb2BaBjsKZOzmKnJPfF7RuqKEje5Dj1YuDdHTR4Iaa
	kLL1CXCjK075Vy8KO857+GOG5b+QC6AFFXbe30SFiEkwK8YOZWqfbe5XSisBTW2/FZQ==
X-Received: by 2002:ac8:3fb3:: with SMTP id d48mr118413195qtk.290.1561132457247;
        Fri, 21 Jun 2019 08:54:17 -0700 (PDT)
X-Received: by 2002:ac8:3fb3:: with SMTP id d48mr118413143qtk.290.1561132456471;
        Fri, 21 Jun 2019 08:54:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561132456; cv=none;
        d=google.com; s=arc-20160816;
        b=pdC2gH6ihlff1O/LTeANxhAZMSQ7XvO5r/eSJB6yW9jHdVO3/SaNVY9dTJf3aKqOt8
         0+F1ZZoM6y9J0bn9McUSNYhhQ2+J11aD5BuI0TWN+7DhxoawtWZ5/HkbNpTe6mxb9USk
         SUydxawMFmTqhC2CdtpUsPbXiPa2ywuYV/Lw+/WqaymGLbwUaIxI58h7DrCsAOJkxEYZ
         1xBPkfoUw/TUkH80OnUhuPyZ0+lAqGpMgLMV4OdNBE7UY6vNzmLp2LuEeMhP66LY3dnu
         p/NdWCfWdkERTc/lShlwSDKfa098/y3q9oh2yAYARhGY4b3sQADBBunamQZGIkz42PhM
         FoyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=mLgah8hWTBbEh5+bUoBbV4cO6mlCq84wOyEco/eLAZk=;
        b=xzAnuiwr0WoGjKtZ5H9zqogX8gFZJsHE1iZMTCRrINkb15G5ZDelk3EePaBn3ZTWH3
         mkqUP+T8xscXqJcC6232WSACU4CifkOTBBO8qFRVWJ0pQKx1LD+FPwGsneuGast+rOUQ
         SuPBUR0vsQFyvB1l9jcqAov/K9RVkgZY06hFr+UkgFMD35ILB2Q7uXfRNKsfYnQ5qcsb
         HXdp2FmePh5TLPsdJsx20sf26/mACiZ3f8TbW/eRT/iofhE9/wLxuSHGP38Cz9UcW1q4
         fJf5ek39z1mvuhNINkIBjg/1ARxVQJipaIEuBvUinvME1q22eY1O2pb3LXMpOtUuBGHG
         d8Ow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=bLoA8Vtp;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 36sor2719503qvd.11.2019.06.21.08.54.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 08:54:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=bLoA8Vtp;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=mLgah8hWTBbEh5+bUoBbV4cO6mlCq84wOyEco/eLAZk=;
        b=bLoA8VtprCwV9w7tPcg86jZ1rpAS3H8PKijh78PfsPQTzI+nU5oul0zgXMeLaRiXRt
         0wFPKH9U615gCpHD+L5Yv8W5lvde3UkjewCNuhwBu5S0CsDeI4/UcCMqeCIrj/KG+8Zb
         l3QD277Vy5HfhTuZfxzL2AOHsfaHAVgllOoulaRVcrlIq1FSXlq3gNYiB0wHGCzm7t/H
         qWTA1oANgEuyafWGY7DXvPIkRaLh51XuTMrMh/wGGhVgrxJRSu7jTVC4lvw3CGowryz4
         kFxWUuoYC16OKmvczWftpSNQDTxxycyKDXLzpSxXkmqILfG31DDx+kT4wcJhilA/snBo
         PXUw==
X-Google-Smtp-Source: APXvYqzhkQgyWFPdC17pHjyc6apgZlhrLfru3XQYo7Lqsq6E89yDvd3j/NnDUqHTzZE/tzkJFdAVuQ==
X-Received: by 2002:a0c:8885:: with SMTP id 5mr46203792qvn.137.1561132456162;
        Fri, 21 Jun 2019 08:54:16 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id 15sm1699745qtf.2.2019.06.21.08.54.15
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Jun 2019 08:54:15 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1heLrj-0001oa-5A; Fri, 21 Jun 2019 12:54:15 -0300
Date: Fri, 21 Jun 2019 12:54:15 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 01/16] mm: use untagged_addr() for get_user_pages_fast
 addresses
Message-ID: <20190621155415.GU19891@ziepe.ca>
References: <20190611144102.8848-1-hch@lst.de>
 <20190611144102.8848-2-hch@lst.de>
 <20190621133911.GL19891@ziepe.ca>
 <9a4e1485-4683-92b0-3d26-73f26896d646@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9a4e1485-4683-92b0-3d26-73f26896d646@oracle.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 09:35:11AM -0600, Khalid Aziz wrote:
> On 6/21/19 7:39 AM, Jason Gunthorpe wrote:
> > On Tue, Jun 11, 2019 at 04:40:47PM +0200, Christoph Hellwig wrote:
> >> This will allow sparc64 to override its ADI tags for
> >> get_user_pages and get_user_pages_fast.
> >>
> >> Signed-off-by: Christoph Hellwig <hch@lst.de>
> >>  mm/gup.c | 4 ++--
> >>  1 file changed, 2 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/mm/gup.c b/mm/gup.c
> >> index ddde097cf9e4..6bb521db67ec 100644
> >> +++ b/mm/gup.c
> >> @@ -2146,7 +2146,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
> >>  	unsigned long flags;
> >>  	int nr = 0;
> >>  
> >> -	start &= PAGE_MASK;
> >> +	start = untagged_addr(start) & PAGE_MASK;
> >>  	len = (unsigned long) nr_pages << PAGE_SHIFT;
> >>  	end = start + len;
> > 
> > Hmm, this function, and the other, goes on to do:
> > 
> >         if (unlikely(!access_ok((void __user *)start, len)))
> >                 return 0;
> > 
> > and I thought that access_ok takes in the tagged pointer?
> > 
> > How about re-order it a bit?
> 
> access_ok() can handle tagged or untagged pointers. It just strips the
> tag bits from the top bits. Current order doesn't really matter from
> functionality point of view. There might be minor gain in delaying
> untagging in __get_user_pages_fast() but I could go either way.

I understand the current ARM and SPARC implementations don't do much
with the tags, but it feels like a really big assumption for the core
code that all future uses of tags will be fine to have them stripped
out of 'void __user *' pointers. IMHO that is something we should not
be doing in the core kernel..

Jason


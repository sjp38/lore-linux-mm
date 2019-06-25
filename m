Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65CC0C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 11:56:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EE15215EA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 11:56:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="EJRqkA+W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EE15215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 917798E0003; Tue, 25 Jun 2019 07:56:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C88C8E0002; Tue, 25 Jun 2019 07:56:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 790098E0003; Tue, 25 Jun 2019 07:56:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 56F058E0002
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 07:56:16 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 97so20548202qtb.16
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 04:56:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fvKANBJdXNXYIeZ/L8y6ph5Ezo3tgbjUcpe/Mc2NV2o=;
        b=denvLZmAxU2efZfYntQXb+IpGFPiPEw54oOwoHOyoX6lsHA22qcO7qCfg4RvbI5scc
         ACbpbFvpZrj8Owuua5flI4OJxnzBDvWwHL7x+7L1O44LP4evE5znbFey9HqKxcaxObHB
         x+EX2jytMKwtSQLNYil9E4lY7+u/HXvD9oJKn7odGX0qDIUSQyyySuaMr66r9koHv1ne
         A98+6QeSZbqC267Zr+RjkK+q5ffkvBpEJKaD35rIRdKVrndWlYgFMOsHkzr9M7/b43VT
         Dsi14C8neZOD43cZadBR2YP4JJ/SB3KbMyJSCGcWgHMhG/pBBdiSbWI9EBjBlNkGHOaD
         Mi9w==
X-Gm-Message-State: APjAAAVanp6CRTEpKVjPqdsnwak3YQInlA35y0j6mqiNiFMARrGQglbU
	Uwhu1Viu1jp1RmoSvIVxyVxHbcCbpv+4vnI0E8QIi3PxD33qYllbqnD3Eo6X7l1iNIJtlOKiaOX
	c8myYjX11seM+BYDDJTCqdsM3cEMpCqmsYvjnXGjcL9/HrW8yrJJf2MeiAwqhumOJow==
X-Received: by 2002:a37:2750:: with SMTP id n77mr22079558qkn.370.1561463776124;
        Tue, 25 Jun 2019 04:56:16 -0700 (PDT)
X-Received: by 2002:a37:2750:: with SMTP id n77mr22079529qkn.370.1561463775608;
        Tue, 25 Jun 2019 04:56:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561463775; cv=none;
        d=google.com; s=arc-20160816;
        b=qXXRCLa5qflo/e+EymbTSh8C6QU1Taa6rdzpX+jOdjEwftZo9hdytzDbNWJ1SQ00gD
         rfL8v3Z/8TijTTba4KFaVJM0qA6ZLUmDxc4TT9vOaWjdM/Thut0rV1bo3uLRyGJbMoSF
         8eTaJNreXQUUF19YWINGqMqa9te+nokNY/RFd5bkMpDEXJj76icqK4mo/aJltqAy2e+e
         pwxNYYS0/63bZsVJd+Xdog18CBCZfp7btRSTVBXkcWSqSmhtKtCW7Iu6hQKfpp3hSlj4
         4qH7PNpO+P1whtal70Sn4P2iG77JRcvbmuE3D3LMNc+0MIivVCh7tLwEwHQ6CRucvbLd
         /1VQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fvKANBJdXNXYIeZ/L8y6ph5Ezo3tgbjUcpe/Mc2NV2o=;
        b=i+d87JqYFldsHNLwX1KHbgliy+f0RBhR1zEt8ZK96badll0YBiiaJBYfh4Ig3SI+qa
         8ewMvGKNJxYUG4tyc1H1thHe7wABj72RHq0w60JX30JqlyZZ7foXXwHUwy/oqZ/nJK5G
         m1hhhmAYaig5fmju9ZT8bJQFOE7emvv7HZN3hxSIRFjjNBZrKsU/pqAeBDcqNRd2Ft+0
         nX9qeEzFJ9BURu8wR4B3HKIEZWtfQvdAYa2nfR7DYcKXFDzkOgwc0aPknqcZpUfGY62u
         Lm6lK3OU283KIUAWiEkmtXSOpVD6Vmg7Z9OnwSUHAThoxnpFqYixU6DaYGoBky+lQ5Oj
         SUFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=EJRqkA+W;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q41sor18958655qta.24.2019.06.25.04.56.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 04:56:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=EJRqkA+W;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fvKANBJdXNXYIeZ/L8y6ph5Ezo3tgbjUcpe/Mc2NV2o=;
        b=EJRqkA+Wa+2yuhExyLU8Eail2cNMSKRlyq+nyaUncHcGsgxKcs1Sr27rWWPyQ3UTrB
         cMuPzb9Z50gDAZFEwVZrXYSwVpLDqhyoJKVcX3zqSCKfqGnqquaMARKFxeOFyW8rB9v8
         jr8CU8j5ySeuXjYBbGTSI57V744cpPQESxf93yY5iy18Va9ZEqkNrNrZ0wCGg02RJ3JA
         r5NbagwGrwXFZDv3ukSXLA1uRvHbeXlvc3o0PAo+oEEBwferAW9/XgegyzdhnpEkAbuO
         8J0rVpLZNN7V7DMRLZuQKxHv2O074zq201ScyzNZLnpy9zB3grhcnmsth2ZOqQC4k+TL
         yUXg==
X-Google-Smtp-Source: APXvYqyDewrQnE99HjPqs/AAVHvyzq2HO2LnRgTekknR3UF/nZYhm98dWnU6mW2wKUuKLbin6gnbcg==
X-Received: by 2002:ac8:1a1c:: with SMTP id v28mr129005789qtj.270.1561463774976;
        Tue, 25 Jun 2019 04:56:14 -0700 (PDT)
Received: from ziepe.ca (209-213-91-242.bos.ma.meganet.net. [209.213.91.242])
        by smtp.gmail.com with ESMTPSA id g2sm6682374qkm.31.2019.06.25.04.56.13
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 25 Jun 2019 04:56:13 -0700 (PDT)
Received: from jgg by jggl.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hfk3Z-0000yk-Gl; Tue, 25 Jun 2019 08:56:13 -0300
Date: Tue, 25 Jun 2019 08:56:13 -0300
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
Subject: Re: [PATCH 11/16] mm: consolidate the get_user_pages* implementations
Message-ID: <20190625115613.GB3711@ziepe.ca>
References: <20190611144102.8848-1-hch@lst.de>
 <20190611144102.8848-12-hch@lst.de>
 <20190621144131.GQ19891@ziepe.ca>
 <20190625075650.GF30815@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190625075650.GF30815@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 09:56:50AM +0200, Christoph Hellwig wrote:
> On Fri, Jun 21, 2019 at 11:41:31AM -0300, Jason Gunthorpe wrote:
> > >  static bool gup_fast_permitted(unsigned long start, unsigned long end)
> > >  {
> > > -	return true;
> > > +	return IS_ENABLED(CONFIG_HAVE_FAST_GUP) ? true : false;
> > 
> > The ?: is needed with IS_ENABLED?
> 
> It shouldn't, I'll fix it up.
> 
> > I'd suggest to revise this block a tiny bit:
> > 
> > -#ifndef gup_fast_permitted
> > +#if !IS_ENABLED(CONFIG_HAVE_FAST_GUP) || !defined(gup_fast_permitted)
> >  /*
> >   * Check if it's allowed to use __get_user_pages_fast() for the range, or
> >   * we need to fall back to the slow version:
> >   */
> > -bool gup_fast_permitted(unsigned long start, int nr_pages)
> > +static bool gup_fast_permitted(unsigned long start, int nr_pages)
> >  {
> > 
> > Just in case some future arch code mismatches the header and kconfig..
> 
> IS_ENABLED outside a function doesn't really make sense.  But I'll
> just life the IS_ENABLED(CONFIG_HAVE_FAST_GUP) checks into the two
> callers.

I often see '#if IS_ENABLED(CONFIG_X)', IIRC last I looked at that, it
was needed because the usual #ifdef CONFIG_X didn't work if the value
was =m?

Would be interested to know if that is not the right way to use
kconfig

Jason


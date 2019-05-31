Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2704EC28CC2
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 23:19:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4CD426FE7
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 23:19:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="f1LmKeIl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4CD426FE7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80A816B0269; Fri, 31 May 2019 19:19:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BB7B6B026A; Fri, 31 May 2019 19:19:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60C3D6B026B; Fri, 31 May 2019 19:19:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2AEB36B0269
	for <linux-mm@kvack.org>; Fri, 31 May 2019 19:19:11 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id v17so4418302plo.20
        for <linux-mm@kvack.org>; Fri, 31 May 2019 16:19:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=OBkn41KBzlGPK7jEmV7BtD0vX9tIAAepdrwcEGsA5+w=;
        b=CkAdi1mo8H1TRvPNln9isRpps18TSKtgPPnh0jZibEVxDHUW8Esu86dUQV721xim96
         yZS4IBp+VTLyc78UoUg0IKEt9/TYEC7RSZzIPOG6+OxYh075vrGKZNKCL9p4LLIYxxBs
         d3pnblGuuwWnREZ9FzIj+0Q9FVwWJ639ay77OtVSFpkm8rP+x5Uli2hLITMI5Pr5FMYW
         YgEjx4EB4h7ZqH76zVZyPP9SdwPYl4FBmLcBB7l82x88cua5YnMxXl+0aY02OOqElza/
         HFudxkXzrUxMttqEN5M168qNEVzBbgFavCRUFYCNZpYf8XQfZiv3VgMincZZ20/tHQb/
         wSAw==
X-Gm-Message-State: APjAAAWnmbox7rRAuqS0+ZrHqKfkDX6nV3nFYFfskOpklBs08vmqK/7J
	nBZK5o7pxrCyJTm+NgFg73zp1mYcHK00wQJltsabcRoXckFwnLmpUOSd2nBMjfIjZ9a0lBx16WY
	JuRGGafCe6YzKwz+OiLrhYhiNGX/ab3Lq3ZfGYM+5bnsYdUEpGUlZw5o9Q18dJGA=
X-Received: by 2002:a63:2b8a:: with SMTP id r132mr11964707pgr.196.1559344750814;
        Fri, 31 May 2019 16:19:10 -0700 (PDT)
X-Received: by 2002:a63:2b8a:: with SMTP id r132mr11964672pgr.196.1559344750099;
        Fri, 31 May 2019 16:19:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559344750; cv=none;
        d=google.com; s=arc-20160816;
        b=eV9KlheV4Fgqtzfk1Q97ghSGSHZuI2E9tRXR7o3jTN+jkvqzRVUyC0fSKDq90P/Qk0
         vkL/uqOOitMPoPmaDBAZ8IxnBhmeOHzd99nxJFKerfCYPy3Lv09YAHVVRaDFtknTPNX3
         82SANpkrijAbj/1Ey6wAEIaOBNjXCETmDPEn+GsOUv4csN7hYAuIbGspzNDCpn+i9n5v
         5GD5iOQ+iyKP3PuXN8ZctfUsnZDLdUHIOAKSpG8qk0AHS/kpMHMLLRwfcRJLoS764G4L
         WxNOMIcYtYhlY+cGEL5etGpXnC9xy6XMalEc+RIbqu0SoNxbVbEQwnnZomTS4sHnT1mO
         xy6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:sender:dkim-signature;
        bh=OBkn41KBzlGPK7jEmV7BtD0vX9tIAAepdrwcEGsA5+w=;
        b=CBYnQr87cntrF+WkZVE7gLHgATQ9INi2lJPgyC5BxGKyahghQ1hMt54qqS+P+e3eKJ
         kEuXLmJ2AjxynHcDVrqYKaioKH3CGGfpTETsdQUX/xjMTrtYx73BAH//FIxs8Mye9M6E
         XpWumfB8eFBVIULu6mpEpy/4mPqkuG7zV47DYQxTjx+Fi7eV8yz8v/66GIDtli2r1Ejw
         q9zDsqMVUSKvF/zJU9tfTyqI6EqYXWHsogoabiLmWNGk1BKHg8YNAUDw33Wo6D0P7d49
         eY7X8sDcuiBpY5IemJ+rLIdGikBBLjzm03lfEVqATW0+Bj+91ZzpGwTvm7x9+tbsx9kq
         l1jg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=f1LmKeIl;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m129sor3364916pfb.2.2019.05.31.16.19.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 16:19:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=f1LmKeIl;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=OBkn41KBzlGPK7jEmV7BtD0vX9tIAAepdrwcEGsA5+w=;
        b=f1LmKeIlF+EXuCgaz3EuG6LlWSltz+X7bsxaknz34pKaycrAKRLn9vvqYZA3JBev6r
         OCN7Lc8r39/kTKAkOVwhotscdF3y27IeIpCXRJMJlcROgjsRwTToq1AolFiU8zyNPhcf
         FxTtBcZDcfOXCRBdbkf8hZwQz1mQltjnKlLPgycKGiuVqdmJwJboVcu9ddUBjxphxa+X
         OpsxbOOaRwVFHE5//eefmSF+QfyXcjVQjxSZ7MIW94sOO1eJXVrGHkCD1BQQHe3cMOZM
         uyk0h2h6DN6zBJupx3x4ZQFWIPwkX193GsQiAN/71nWAfVzcMpbkbHJO6se95mSl/kXa
         GcDA==
X-Google-Smtp-Source: APXvYqwlaLnvjar6sK0YrFR/Mv80Eb/Txa+lx67buxss1QoweTkwqrSTUHaA0EACzyTCmeYVmOIJtA==
X-Received: by 2002:a62:1990:: with SMTP id 138mr13345803pfz.133.1559344749725;
        Fri, 31 May 2019 16:19:09 -0700 (PDT)
Received: from google.com ([122.38.223.241])
        by smtp.gmail.com with ESMTPSA id x18sm12173516pfj.17.2019.05.31.16.19.02
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 31 May 2019 16:19:08 -0700 (PDT)
Date: Sat, 1 Jun 2019 08:18:59 +0900
From: Minchan Kim <minchan@kernel.org>
To: Yann Droneaud <ydroneaud@opteya.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com
Subject: Re: [RFCv2 6/6] mm: extend process_madvise syscall to support vector
 arrary
Message-ID: <20190531231859.GB248371@google.com>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-7-minchan@kernel.org>
 <2fd5d462449f24b04adad2bbdf0e272647e62247.camel@opteya.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2fd5d462449f24b04adad2bbdf0e272647e62247.camel@opteya.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Yann,

On Fri, May 31, 2019 at 12:06:52PM +0200, Yann Droneaud wrote:
> Hi,
> 
> Le vendredi 31 mai 2019 à 15:43 +0900, Minchan Kim a écrit :
> > 
> > diff --git a/include/uapi/asm-generic/mman-common.h
> > b/include/uapi/asm-generic/mman-common.h
> > index 92e347a89ddc..220c2b5eb961 100644
> > --- a/include/uapi/asm-generic/mman-common.h
> > +++ b/include/uapi/asm-generic/mman-common.h
> > @@ -75,4 +75,15 @@
> >  #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
> >  				 PKEY_DISABLE_WRITE)
> >  
> > +struct pr_madvise_param {
> > +	int size;		/* the size of this structure */
> > +	int cookie;		/* reserved to support atomicity */
> > +	int nr_elem;		/* count of below arrary fields */
> 
> Those should be unsigned.
> 
> There's an implicit hole here on ABI with 64bits aligned pointers
> 
> > +	int __user *hints;	/* hints for each range */
> > +	/* to store result of each operation */
> > +	const struct iovec __user *results;
> > +	/* input address ranges */
> > +	const struct iovec __user *ranges;
> 
> Using pointer type in uAPI structure require a 'compat' version of the
> syscall need to be provided.
> 
> If using iovec too.

I will fix them when I submit next revision.
Thanks for the review.


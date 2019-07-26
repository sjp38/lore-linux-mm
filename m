Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3CC5C7618F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 21:25:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6528622BF5
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 21:25:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="SgoM4QTy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6528622BF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE42D6B0003; Fri, 26 Jul 2019 17:25:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E93BC8E0003; Fri, 26 Jul 2019 17:25:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D5AF68E0002; Fri, 26 Jul 2019 17:25:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9DE606B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 17:25:07 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r142so33962570pfc.2
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 14:25:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=rCSNynzsJ2BaJs7UdF7xUQfSzXN+dEXEzajH9yZrdVU=;
        b=Th+nHMmcXH+5sMmxVp25BNZHPBryxkojWmY1I4bjnO+X/u3kja0hN5xFV1u54kdndp
         oxMdc2OUTtC2nkGUmRzQhxwKa2KvTrIo5ZUojL3DlWHXNXG2EWqlzQRjPgzilsgCIjkr
         O4iTpZDAXN6ephy0V3tF1fDQU3vEpQwvRR2jHzEyl54nwI3EN++7I5+Rj3G/oUNM4jP3
         tLbPixAhHj48rWFTf6cqoi9m0RuecLsg0WY6iVaNcXyXhlIFDzpDigTnYJ75zhXRnFer
         5uoCIBylEMvkMePQJ8FC/qYmlo/vwBF42Ksb00rQSkpWg1Ikozy8JOV9rwunt55+BQwG
         N30Q==
X-Gm-Message-State: APjAAAVPIpAGrftg8cfVo4NRIir0SwWSNbXx/Qf5p+h7AZKUubYXcB3Z
	8i6IYecXoYVb9E5+CEDGMSK3SuaOx6RtShDQeq6AgeAnPyYyrHrqIeF6E1sC60lG7Esvgg1hLjE
	RwaCcIFxPe+jFwFfAp3TLCaKkBmLKlyS4YfW2QNDJ9ONHm3qMCFJ/CyE5RDBPrp2ZAw==
X-Received: by 2002:a62:3103:: with SMTP id x3mr23839992pfx.107.1564176307094;
        Fri, 26 Jul 2019 14:25:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzeicETekoH0TBMbKvAKCtFrI8yDD3enemCWpq8N77vQl1uc7By+rm+EOjD22zmEM8gDb4L
X-Received: by 2002:a62:3103:: with SMTP id x3mr23839951pfx.107.1564176306445;
        Fri, 26 Jul 2019 14:25:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564176306; cv=none;
        d=google.com; s=arc-20160816;
        b=cza5iLY/ljBx6lXUsBGRBwEOv3aPqlkE1l4mQxoZWfNmvertCz6JcEHDAn8dd//ImS
         dE61ft6Z1J3DYk3XyhfEhnPlywGEznRfAU8XbFZCDJ5c/DZ4Nobs/kfid7tozlcym1Gk
         1FR8cko+By5HnU41UFsP8XgqVixuw2Dqc2FzRR8mCCENXIa4PJn6XNOuWRGWSp7nHkig
         Ncbuz2ePwhBOyHdZFU5qRI0jOa9tN454Ve78pHYSgLCg8jnmgX+Uo/KQ+cw+q/JIB0vW
         ca1zKZBhUvZj2TPOXhMLgFy41/k8k+cK6+qWkoiG9SGtR9GJfANCUdXaTGpBm+8GZ8j1
         XUEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=rCSNynzsJ2BaJs7UdF7xUQfSzXN+dEXEzajH9yZrdVU=;
        b=eHplkxTuSAPvckoIgHE0gCT5curKDq73kwhd1Zttb9x4+S5v3zsywUjV//yuw0k7hG
         rpETfXc/Qh5EnwaCS3CGQHPRghWLXjkub+B76DGpSNVpuUMjA521N7qXtg5K1YSpzY0c
         WTAs0JHKP0RyxkzNe627DjY/0CUXhAwxZyBBT2vdG551uXoYI07LpdLzRMvHAd2YTqUR
         5CZn5aX87BVbXcvQVdVa677cVMC9MxBmYQU+jaTap0HVon1xODTnEtbfaiZIOH01W7Im
         Kn00VD1fIUJ4vYPJ4CRnP0Y9ibEatILCc5AVpaQJpBhf1JOCAW29v4l8rfaRJnK5KiHe
         ZuUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=SgoM4QTy;
       spf=pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jlayton@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d67si21793709pgc.62.2019.07.26.14.25.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 14:25:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=SgoM4QTy;
       spf=pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jlayton@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1D8DA2083B;
	Fri, 26 Jul 2019 21:25:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564176306;
	bh=ZMdUsOA413NREipWgNGiUNHEV337/SQnp+du76ZZxss=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=SgoM4QTyfOezHqndzroxeVQLXZc50SrbGADq3WK34Po2ZYwAgUgtDk2BWLI8WUPDS
	 QT+w4eRLC0ER0mBGJpRzxSzzYrouBUJ0OCJZJNck2mCYD7WvsZJek9KOkB8Nph03Rr
	 tS+sH0DqV/9miLNPM2lwhKLFafryPhYtnKl8aJcM=
Message-ID: <e4b0d323ed0bc159d863945251cf3f4c4064526c.camel@kernel.org>
Subject: Re: [PATCH] mm: Make kvfree safe to call
From: Jeff Layton <jlayton@kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>, Matthew Wilcox
	 <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm
 <linux-mm@kvack.org>,  LKML <linux-kernel@vger.kernel.org>, Alexander Viro
 <viro@zeniv.linux.org.uk>, Luis Henriques <lhenriques@suse.com>, Christoph
 Hellwig <hch@lst.de>, Carlos Maiolino <cmaiolino@redhat.com>
Date: Fri, 26 Jul 2019 17:25:03 -0400
In-Reply-To: <CAKgT0UcMND12oZ1869howDjcbvRj+KwabaMuRk8bmLZPWbJWcg@mail.gmail.com>
References: <20190726210137.23395-1-willy@infradead.org>
	 <CAKgT0UcMND12oZ1869howDjcbvRj+KwabaMuRk8bmLZPWbJWcg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.4 (3.32.4-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-07-26 at 14:10 -0700, Alexander Duyck wrote:
> On Fri, Jul 26, 2019 at 2:01 PM Matthew Wilcox <willy@infradead.org> wrote:
> > From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> > 
> > Since vfree() can sleep, calling kvfree() from contexts where sleeping
> > is not permitted (eg holding a spinlock) is a bit of a lottery whether
> > it'll work.  Introduce kvfree_safe() for situations where we know we can
> > sleep, but make kvfree() safe by default.
> > 
> > Reported-by: Jeff Layton <jlayton@kernel.org>
> > Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> > Cc: Luis Henriques <lhenriques@suse.com>
> > Cc: Christoph Hellwig <hch@lst.de>
> > Cc: Carlos Maiolino <cmaiolino@redhat.com>
> > Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
> 
> So you say you are adding kvfree_safe() in the patch description, but
> it looks like you are introducing kvfree_fast() below. Did something
> change and the patch description wasn't updated, or is this just the
> wrong description for this patch?
> 
> > ---
> >  mm/util.c | 26 ++++++++++++++++++++++++--
> >  1 file changed, 24 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/util.c b/mm/util.c
> > index bab284d69c8c..992f0332dced 100644
> > --- a/mm/util.c
> > +++ b/mm/util.c
> > @@ -470,6 +470,28 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
> >  }
> >  EXPORT_SYMBOL(kvmalloc_node);
> > 
> > +/**
> > + * kvfree_fast() - Free memory.
> > + * @addr: Pointer to allocated memory.
> > + *
> > + * kvfree_fast frees memory allocated by any of vmalloc(), kmalloc() or
> > + * kvmalloc().  It is slightly more efficient to use kfree() or vfree() if
> > + * you are certain that you know which one to use.
> > + *
> > + * Context: Either preemptible task context or not-NMI interrupt.  Must not
> > + * hold a spinlock as it can sleep.
> > + */
> > +void kvfree_fast(const void *addr)
> > +{
> > +       might_sleep();
> > +

    might_sleep_if(!in_interrupt());

That's what vfree does anyway, so we might as well exempt the case where
you are.

> > +       if (is_vmalloc_addr(addr))
> > +               vfree(addr);
> > +       else
> > +               kfree(addr);
> > +}
> > +EXPORT_SYMBOL(kvfree_fast);
> > +

That said -- is this really useful?

The only way to know that this is safe is to know what sort of
allocation it is, and in that case you can just call kfree or vfree as
appropriate.

> >  /**
> >   * kvfree() - Free memory.
> >   * @addr: Pointer to allocated memory.
> > @@ -478,12 +500,12 @@ EXPORT_SYMBOL(kvmalloc_node);
> >   * It is slightly more efficient to use kfree() or vfree() if you are certain
> >   * that you know which one to use.
> >   *
> > - * Context: Either preemptible task context or not-NMI interrupt.
> > + * Context: Any context except NMI.
> >   */
> >  void kvfree(const void *addr)
> >  {
> >         if (is_vmalloc_addr(addr))
> > -               vfree(addr);
> > +               vfree_atomic(addr);
> >         else
> >                 kfree(addr);
> >  }
> > --
> > 2.20.1
> > 

-- 
Jeff Layton <jlayton@kernel.org>


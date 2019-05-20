Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51E83C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 17:08:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A27320815
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 17:08:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="t1SUvr49"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A27320815
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9731B6B0003; Mon, 20 May 2019 13:08:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 923476B0005; Mon, 20 May 2019 13:08:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 812176B0006; Mon, 20 May 2019 13:08:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 47AAF6B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 13:08:05 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id u11so4310644plz.22
        for <linux-mm@kvack.org>; Mon, 20 May 2019 10:08:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=ol97WAmP2eVJA2nRz/+2miX8OAofXhZkUB5qRp3k8dg=;
        b=Bb40Zpu0sUI36JX5qUvE3Y6oGoopDDumq1BE+jkXAJ2sp7tlZHyZSp4W53kKnS6oW/
         ba0rrhE/eyUQCma5PDI6sgy6EXO7lh3Wd0cBYTdR+bQPdCQs5Hh/UZC+VqFuY+Kel3hf
         xq/jxpdZ0bvtFHJ7L4nksyuLsig40mhqQ6vARIYvoXm4nYSfhQcvKIZE2AiXlbdWTfs3
         n4cglCU0COTLhwtntKpBKozCnm2Psa80thFRkmvhnyXkwxFDVboyZGWqGqrJNESq/Elw
         kuG6rqipsN5qQYsKKHXlWr0bx3VZ8bj0tZ6NBZ9dZBvWANkY9Tllkb9gtpz9T/hPAlP+
         bIZQ==
X-Gm-Message-State: APjAAAW2b1aoDRpthxulLUfpNRkUGq714mIgrB8bLQeOfm+FdGg/+33I
	A+y1KSgxRwi3oBtynhrlr3W5C3np8F2fiexdigW2dHvudTTU7p5jn3MTUcQTILVk8A/g/Y7VvMY
	BwINDXeP3bigBvY9Wh5GBfYSfxsQWHDo9+UWRPT5WXoQcV8xaXRO7lPxNbNPtRz4/xw==
X-Received: by 2002:a17:902:6bc8:: with SMTP id m8mr75509579plt.227.1558372084957;
        Mon, 20 May 2019 10:08:04 -0700 (PDT)
X-Received: by 2002:a17:902:6bc8:: with SMTP id m8mr75509336plt.227.1558372082366;
        Mon, 20 May 2019 10:08:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558372082; cv=none;
        d=google.com; s=arc-20160816;
        b=rvnZDz5jcGhZdtRbbu+7ErHZngoxmne5B7vFCkJfKG5cvq2lCSWdyW2kgJZ9HI2jbG
         anEjTQ628onEelpX1ndj0Pcq8UYOAWK74xgoE/F1ErI2+Cs12peLHkKEMxQ4FCt0IRc9
         X1cVpVdrUb1e9gltt2+gon4O77cfXzMioi0mldJQrtL7izry7Ld3cqohyV+48KOqFDnd
         1nQXZ7tk65gb3mnLihnDMc+52FlmLBeaWoCz7k2nXCXa9NzUFubo6cVSpfNtjjrXBpqV
         Y6qvERhyiMZDXQvHBQrsolEztN/ltaqRw/Q9Q9G2X0wYaGJhYgkPLo1/KxHxMHYix7dg
         rqyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=ol97WAmP2eVJA2nRz/+2miX8OAofXhZkUB5qRp3k8dg=;
        b=Ar1RiDZuOISJze113qt95ctTt4oUNAuO4E+A+JwQR02Zh90Yxxd+9oa5rq+fWgXWGI
         SGA8K5Pn9Zz91mT2h45yG/ooCBgMUzPntDCz2FCf9klsxmgk36Zc7NsLqbnQWBhmMOHM
         IPcnAsAmr+r+1acVbvbeCPuWfUa18hGcCm78Vpw195+m+spmKwcrImr812/ryCikINy9
         pPdvNTdhcQ34S3oaU3wL5H3pWy+KbHI8qf58R/3b6YjIV5B7zwSjiPnRixcMptbQ4Ki6
         er3b80edsNEt/tP0LhQbplKkQ65aOSvAKv0WxTuteVeVKVUcTC46/76kvCjYrZJW9kzD
         fsyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=t1SUvr49;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h3sor16075833pld.22.2019.05.20.10.08.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 10:08:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=t1SUvr49;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=ol97WAmP2eVJA2nRz/+2miX8OAofXhZkUB5qRp3k8dg=;
        b=t1SUvr49nCz5spS7UjhK4JQ6Apy9p/w/1qE61fOdmFfmMryUBZ+WjIsoDVYyX0YN+x
         j5og+gJgIsflpdRHMeu4i6xsY2+UzVuGO1IiAwFKq8YNFVdJFLj22bPvRVxM+yAVqLff
         PAW3c3y2TigXGYgpCjxGUxipPCGGvoOz/MvCTNCPZ+zoHoiu1D+HVg1ssM9mD+mVjUiJ
         qFpPpLRxtAxloaRyKdKCYeCSth/6Bh8xtBLIJjeKCHHG8MsLiaqMtwh6HoObu3XCANYy
         hm+mE/IgGQR/lmsIIIq+EWSCEFhG9esI757NdeTwa4gSr1cwKurrdnZp96vRKZn5Hnrh
         XHaQ==
X-Google-Smtp-Source: APXvYqw9vVqYpqbwDVINtSfVyNRGl8P4j/ZT8VpIKlzNUAKaBErtJAKSArZb4J9wWyNkS2M6O6Yhxw==
X-Received: by 2002:a17:902:aa85:: with SMTP id d5mr75933523plr.245.1558372081719;
        Mon, 20 May 2019 10:08:01 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id 125sm26076542pge.45.2019.05.20.10.08.00
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 20 May 2019 10:08:00 -0700 (PDT)
Date: Mon, 20 May 2019 10:07:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Akinobu Mita <akinobu.mita@gmail.com>
cc: Nicolas Boichat <drinkcat@chromium.org>, 
    Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
    Joe Perches <joe@perches.com>, 
    Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, 
    Pekka Enberg <penberg@kernel.org>, 
    Mel Gorman <mgorman@techsingularity.net>, 
    LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm/failslab: By default, do not fail allocations with
 direct reclaim only
In-Reply-To: <CAC5umygGsW3Nju-mA-qE8kNBd9SSXeO=YXMkgFsFaceCytoAww@mail.gmail.com>
Message-ID: <alpine.DEB.2.21.1905201007170.96074@chino.kir.corp.google.com>
References: <20190520044951.248096-1-drinkcat@chromium.org> <CAC5umygGsW3Nju-mA-qE8kNBd9SSXeO=YXMkgFsFaceCytoAww@mail.gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 May 2019, Akinobu Mita wrote:

> > When failslab was originally written, the intention of the
> > "ignore-gfp-wait" flag default value ("N") was to fail
> > GFP_ATOMIC allocations. Those were defined as (__GFP_HIGH),
> > and the code would test for __GFP_WAIT (0x10u).
> >
> > However, since then, __GFP_WAIT was replaced by __GFP_RECLAIM
> > (___GFP_DIRECT_RECLAIM|___GFP_KSWAPD_RECLAIM), and GFP_ATOMIC is
> > now defined as (__GFP_HIGH|__GFP_ATOMIC|__GFP_KSWAPD_RECLAIM).
> >
> > This means that when the flag is false, almost no allocation
> > ever fails (as even GFP_ATOMIC allocations contain
> > __GFP_KSWAPD_RECLAIM).
> >
> > Restore the original intent of the code, by ignoring calls
> > that directly reclaim only (___GFP_DIRECT_RECLAIM), and thus,
> > failing GFP_ATOMIC calls again by default.
> >
> > Fixes: 71baba4b92dc1fa1 ("mm, page_alloc: rename __GFP_WAIT to __GFP_RECLAIM")
> > Signed-off-by: Nicolas Boichat <drinkcat@chromium.org>
> 
> Good catch.
> 
> Reviewed-by: Akinobu Mita <akinobu.mita@gmail.com>
> 
> > ---
> >  mm/failslab.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> >
> > diff --git a/mm/failslab.c b/mm/failslab.c
> > index ec5aad211c5be97..33efcb60e633c0a 100644
> > --- a/mm/failslab.c
> > +++ b/mm/failslab.c
> > @@ -23,7 +23,8 @@ bool __should_failslab(struct kmem_cache *s, gfp_t gfpflags)
> >         if (gfpflags & __GFP_NOFAIL)
> >                 return false;
> >
> > -       if (failslab.ignore_gfp_reclaim && (gfpflags & __GFP_RECLAIM))
> > +       if (failslab.ignore_gfp_reclaim &&
> > +                       (gfpflags & ___GFP_DIRECT_RECLAIM))
> >                 return false;
> 
> Should we use __GFP_DIRECT_RECLAIM instead of ___GFP_DIRECT_RECLAIM?
> Because I found the following comment in gfp.h
> 
> /* Plain integer GFP bitmasks. Do not use this directly. */
> 

Yes, we should use the two underscore version instead of the three.

Nicolas, after that's fixed up, feel free to add Acked-by: David Rientjes 
<rientjes@google.com>.

Thanks!


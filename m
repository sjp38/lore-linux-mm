Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40B36C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 10:36:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0481D208CB
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 10:36:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fOgBcyWW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0481D208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 901966B0003; Wed, 19 Jun 2019 06:36:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 88A1C8E0002; Wed, 19 Jun 2019 06:36:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 705978E0001; Wed, 19 Jun 2019 06:36:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 08F256B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 06:36:47 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id 22so2165341lft.2
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 03:36:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+vEo5ld3iyjHBFwUuEjWL+Gba8QM9jKd32c5zWkOfXU=;
        b=b5DqDNZ/0lcjbZS3tX31FSqA7b6O1vwi6IA38qRExDMTeG3vI3SlhkGjNYtq0lUBFr
         uUxk4c3TQOuOiKDFq7Em/cKsrtAxQcYQAtnNwwtQbfyiWuJk51NwOE+rBv7owYFTtjAf
         t/dnie9ou+nrze9h/28R41a9pA5Z1jubUR+4y/sqr9EavUTWrwPc3hLqwuKJinMV5FfI
         UgF1Q0c65hMq2cW2uFYMD0a4yupv76B3FtFOTZBvKQmXLXB2g6yDDZ3nbRqc98SzqE5l
         NV/AF3f8EUZKAOrd+gEYQaWn+I251La95+alBHbcBx//sjo/gWuujace97m8+qOpIh3h
         eAFQ==
X-Gm-Message-State: APjAAAX9QIS12JABlAHlauLQi7B5tdfd8BFS8IhbZg14tXVuXimpP9ma
	yngL8rBRpBR+7158CeOPaW9ufYUZM8Ii761lKR6J8A686M9z2desm+oh0XtgLMqXSzaY4714ioc
	JfwPaxEYaheeyzC1RmGBJ1aPcpL0PcexC/M+SMiXXmXBgBh3EbZphcerAKCEVhlho7w==
X-Received: by 2002:ac2:52ac:: with SMTP id r12mr41886452lfm.126.1560940606128;
        Wed, 19 Jun 2019 03:36:46 -0700 (PDT)
X-Received: by 2002:ac2:52ac:: with SMTP id r12mr41886415lfm.126.1560940605306;
        Wed, 19 Jun 2019 03:36:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560940605; cv=none;
        d=google.com; s=arc-20160816;
        b=a/wkr3hupWqp/hZ7xj7YujNpTlBJWRxViA8uEIV07oxOj1W577bRqfW9w4Y4DtEZY7
         cupvfL0v7riHFLSOaQMHcPf64Ii2uYlb9wMTczLKbiqwstAeRHTJhayM/5eN8qDgaLsM
         RM7FRWGnsz+JW8M8zk79hmFUy/wykLTAM58HKNvwSa4I9An+Rl6RkcgLxLdEiDjlK2oc
         Po889of+XB4ReiMa3YxOICmZV+l+rzpmm07KzjIXZgAlzUkqDnz/dG8a3OiHmrzFu6gV
         WbNTNYTaJh3QiEFbWvZnjZ73FsTFYNn2J3x7+zvdSzB1gvA2DE0lLXZXyRx0YzBoT7jV
         SAXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=+vEo5ld3iyjHBFwUuEjWL+Gba8QM9jKd32c5zWkOfXU=;
        b=EVIm/+BCd8nHEVllxJanroE1Wu4r5p0SXbqJ+bVLmyqv7LQhSrQavKiDDWJ7ART6He
         Y24zDv58GvaIovhx+B9ueJybwmwV/SQnb++Q33QZbsweUUDh+wq0kAdB8YqDKdw250KP
         B7PDDtsJXWRTLq6A+IyXPUnlM0686oyL+l0Utv/8T6he/WhpcJ+BpC5oFxP1iuksh8x/
         +KCwppIIVONNz1zs9uM0X29ey+k3GsMflxV2dYw2JxPzzHKbafE/gfpaSjrYN0iolOKa
         oV4t2186m3ki/Ip88VGsd3ywfznz2yandvWZSICeDRYtib8NcqxUPBv/ssSr6F0Gt4aG
         5mBw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fOgBcyWW;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a1sor9911427lji.35.2019.06.19.03.36.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 03:36:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fOgBcyWW;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=+vEo5ld3iyjHBFwUuEjWL+Gba8QM9jKd32c5zWkOfXU=;
        b=fOgBcyWWXD9P2VTaJp8pVqhCFDQL68ehA5gqT0yPI6bQbj514Ee+DULCsd6Dp3ZbOh
         DGSZXVuG7lYeqbUXZs93eOiIBvJGV33/slmAioY+QScWze4CArTSsWfog5HCd1bAHP+m
         WcHckthzkDjRHUnW8VFUHgqW2PUMrX46gUTcn8tQaddFvyHyWodiAbX5yapFWHi9eaAe
         j4FjHZ8pEns9hMWJQQ4ufug3wGHPTiAHYNiwGWjxAf3BlekJ/hzkgCYmRi5M1kvl9yZm
         NTEgNM0PZAGqI0KG/meyH4d7ejAAlEARet0RWBIMNpvTlBFYCIoAw4kXpFj6O9qUwUJA
         A3Hw==
X-Google-Smtp-Source: APXvYqy2z2pzaeKHA9hb6yNgYbbhdvOfcA4iWRJnQjmbNVPRzTzd9ruwFCZMUQXHwqCqKwOAy9ozAQ==
X-Received: by 2002:a2e:82c5:: with SMTP id n5mr27228732ljh.175.1560940604841;
        Wed, 19 Jun 2019 03:36:44 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id v14sm2624011lfb.50.2019.06.19.03.36.42
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Jun 2019 03:36:43 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Wed, 19 Jun 2019 12:36:36 +0200
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Uladzislau Rezki <urezki@gmail.com>, Joel Fernandes <joelaf@google.com>,
	Arnd Bergmann <arnd@arndb.de>, Roman Penyaev <rpenyaev@suse.de>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm/vmalloc: avoid bogus -Wmaybe-uninitialized warning
Message-ID: <20190619103636.rzjca5jxofc5anjw@pc636>
References: <20190618092650.2943749-1-arnd@arndb.de>
 <CAJWu+oqzd8MJqusRV0LAK=Xnm7VSRSu3QbNZ-j5h9_MbzcFhhg@mail.gmail.com>
 <20190618140622.bbak3is7yv32hfjn@pc636>
 <20190618135920.9dd7bdc78fc0ce33ee65d99c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190618135920.9dd7bdc78fc0ce33ee65d99c@linux-foundation.org>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 01:59:20PM -0700, Andrew Morton wrote:
> On Tue, 18 Jun 2019 16:06:22 +0200 Uladzislau Rezki <urezki@gmail.com> wrote:
> 
> > On Tue, Jun 18, 2019 at 09:40:28AM -0400, Joel Fernandes wrote:
> > > On Tue, Jun 18, 2019 at 5:27 AM Arnd Bergmann <arnd@arndb.de> wrote:
> > > >
> > > > gcc gets confused in pcpu_get_vm_areas() because there are too many
> > > > branches that affect whether 'lva' was initialized before it gets
> > > > used:
> > > >
> > > > mm/vmalloc.c: In function 'pcpu_get_vm_areas':
> > > > mm/vmalloc.c:991:4: error: 'lva' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> > > >     insert_vmap_area_augment(lva, &va->rb_node,
> > > >     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > > >      &free_vmap_area_root, &free_vmap_area_list);
> > > >      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > > > mm/vmalloc.c:916:20: note: 'lva' was declared here
> > > >   struct vmap_area *lva;
> > > >                     ^~~
> > > >
> > > > Add an intialization to NULL, and check whether this has changed
> > > > before the first use.
> > > >
> > > > Fixes: 68ad4a330433 ("mm/vmalloc.c: keep track of free blocks for vmap allocation")
> > > > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > > > ---
> > > >  mm/vmalloc.c | 9 +++++++--
> > > >  1 file changed, 7 insertions(+), 2 deletions(-)
> > > >
> > > > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > > > index a9213fc3802d..42a6f795c3ee 100644
> > > > --- a/mm/vmalloc.c
> > > > +++ b/mm/vmalloc.c
> > > > @@ -913,7 +913,12 @@ adjust_va_to_fit_type(struct vmap_area *va,
> > > >         unsigned long nva_start_addr, unsigned long size,
> > > >         enum fit_type type)
> > > >  {
> > > > -       struct vmap_area *lva;
> > > > +       /*
> > > > +        * GCC cannot always keep track of whether this variable
> > > > +        * was initialized across many branches, therefore set
> > > > +        * it NULL here to avoid a warning.
> > > > +        */
> > > > +       struct vmap_area *lva = NULL;
> > > 
> > > Fair enough, but is this 5-line comment really needed here?
> > > 
> > How it is rewritten now, probably not. I would just set it NULL and
> > leave the comment, but that is IMHO. Anyway
> > 
> 
> I agree - given that the patch does this:
> 
> @@ -972,7 +977,7 @@ adjust_va_to_fit_type(struct vmap_area *
>  	if (type != FL_FIT_TYPE) {
>  		augment_tree_propagate_from(va);
>  
> -		if (type == NE_FIT_TYPE)
> +		if (lva)
>  			insert_vmap_area_augment(lva, &va->rb_node,
>  				&free_vmap_area_root, &free_vmap_area_list);
>  	}
> 
> the comment simply isn't relevant any more.  Although I guess this
> might be a bit helpful:
> 
> @@ -977,7 +972,7 @@ adjust_va_to_fit_type(struct vmap_area *
>  	if (type != FL_FIT_TYPE) {
>  		augment_tree_propagate_from(va);
>  
> -		if (lva)
> +		if (lva)	/* type == NE_FIT_TYPE */
>  			insert_vmap_area_augment(lva, &va->rb_node,
>  				&free_vmap_area_root, &free_vmap_area_list);
>  	}
> 
That comment makes it much clear, thanks!

--
Vlad Rezki


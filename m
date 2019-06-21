Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA298C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 12:26:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F95B2083B
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 12:26:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="rNCL4zhw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F95B2083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E485A8E0003; Fri, 21 Jun 2019 08:26:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF93F8E0002; Fri, 21 Jun 2019 08:26:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE8398E0003; Fri, 21 Jun 2019 08:26:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id B08C68E0002
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 08:26:26 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n77so7308528qke.17
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 05:26:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=qJu/XBwrdsSLLRIcidZtwfJoKMutHo2qTycz/kmN2wg=;
        b=SM+qgNCjb6bNrq54oPjqNLSaQDLkxnq46T4d/sFUVYcQ0yVa46OsiEniXpfyzW+baS
         KpI+5eWIRN4KXDBGdUaGumFxo7bK6AfGG08KXZRdm9ADrMyq7uQkggJphy6CXyNGvYr8
         TLfdZ9p6rWvRcJV7YfIvG5itEd2UHe9MBwVBzq7XQ8oXkghFEc1Vl7eSTtAENcNtF40m
         qylmrFnP2vdqZnRSw+/NL4pP9lrZM+HHv0ktd83mzzO+yuELvOvTlHv22BDXrSw6o6gN
         s58kpgG8yXldZQlNfEsvxS+Zy6DY6KlW6Gf6nQ5WLi7GFWCL1DWwsXmSrkNyntg0HkWc
         1wrQ==
X-Gm-Message-State: APjAAAUAPbtIE5x079uc7/oyCo1VlqSiRq9QxLn9Nbk5fJiC8TZvkw+8
	KX6d4KmGnXp7RD6rJ6an7nnSO2O3zOO09zijOyIgBzifte/Lf4q42Sf73NxPlFTcLKyAtpV+9rq
	lNezVjB0ewr/WdeA+hKoNN7GgL11QbBAlDL23/GoVCp3n6SGpZYKeJcZJ8iud3jbfNw==
X-Received: by 2002:a37:a98c:: with SMTP id s134mr107182142qke.176.1561119986482;
        Fri, 21 Jun 2019 05:26:26 -0700 (PDT)
X-Received: by 2002:a37:a98c:: with SMTP id s134mr107182096qke.176.1561119985823;
        Fri, 21 Jun 2019 05:26:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561119985; cv=none;
        d=google.com; s=arc-20160816;
        b=g9SRVHHhkxhM0SrM6c3mnmFW5UBfpRbPzSrGCsjSVc/E1ROBjG+VHb08jQx8Ph0d27
         lTvwzlzgdyuJvxqFFJvFiC2fsqzRp7HOMh/k44afcB2yTjwB9gX5LE2MjRopqN3+i2vj
         a01zfpGT+OFpGh8bgC0ZlpBo005xQ3pyBynnzIwBhbEuhFN0yrziIusOXyvmLuAdOCZm
         JO4xI8H01f2Ih/TpTxTvEP8gDbl9qA6EbMOap+zs1QKe108Y1GnLNahHK3SXa7O7zk+G
         gSFf89eXBSsWnWZATqpVxeCry4I7n/K5aGT/jTpkEOCAhXsXEbwQCDOdQV8qeVhDqKEC
         C3fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=qJu/XBwrdsSLLRIcidZtwfJoKMutHo2qTycz/kmN2wg=;
        b=omMXzh5LHS09RK1ACO8M84HAX04t4Urc742xxfqWOjqb94OZxG7QqQS6ANlj9CmYd+
         9D6Ih5zpnPkKMQ8R172A23rpas7OsZUug3NzPSwF4KquuTGPVHMqzvLlVdKpAuAzaJMv
         uDo668qrmXrERXNt9Z5UPUZUrfSgmI0fJYwAhYRpYufwURJ+f0u3h7aDvi4eIAEEfls1
         N9Pv+BfUFAVcEA7cdznTurrH4ISsy3mdcnAIQA4pWzrlsmgORMlKmJgPL2pnS16rscJ+
         CsVakBOcXdOoano9UJ3896jGlFO2YTWSGBhyRQsAjZ/YpdLKz8xtfQGB1tCzsv/mkO+s
         YmeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=rNCL4zhw;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m17sor3895249qtp.16.2019.06.21.05.26.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 05:26:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=rNCL4zhw;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=qJu/XBwrdsSLLRIcidZtwfJoKMutHo2qTycz/kmN2wg=;
        b=rNCL4zhw8eHMFBzdfTNk3LaqHtJy2EdKZJhC4JXKAVokf50roNkhJcamXNbNQyIVbk
         +F17JkX4Da30UUmMIxKB2HEDgT2swpPABPB1JTWNYcIz2BSH6vtRK0RFRpu1WePTy9/F
         MCSwm4S5qGfQkVVEaPJIoSu7nRJqFislMwMYb3/BeYPK7gGaNHd771r4+0lydNcQWGxn
         vAwjd47h9gxP8ZfpLWwLEafFXMG3ZHoyNREYtPldn08LG37GPGOV0vCMUAC7aD6fvL68
         h5FfNck7iuH5lhV5mJ6KI5IRTJMNl8hmI9hIyrop1DU5T5FPvLCGLOc2NSltYwywZ05u
         hsng==
X-Google-Smtp-Source: APXvYqyGQfBNrLQhGqn1W0umgpDTMCzpvsh9uq4Mq2YLC5VhGLFENF58ZpwrlKTJ4RrZgekglzPwsw==
X-Received: by 2002:aed:39e5:: with SMTP id m92mr34477935qte.135.1561119985333;
        Fri, 21 Jun 2019 05:26:25 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id y42sm2003943qtc.66.2019.06.21.05.26.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 05:26:24 -0700 (PDT)
Message-ID: <1561119983.5154.33.camel@lca.pw>
Subject: Re: [PATCH -next v2] mm/page_alloc: fix a false memory corruption
From: Qian Cai <cai@lca.pw>
To: Alexander Potapenko <glider@google.com>, Kees Cook
 <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List
	 <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Date: Fri, 21 Jun 2019 08:26:23 -0400
In-Reply-To: <CAG_fn=VRehbrhvNRg0igZ==YvONug_nAYMqyrOXh3kO2+JaszQ@mail.gmail.com>
References: <1561063566-16335-1-git-send-email-cai@lca.pw>
	 <201906201801.9CFC9225@keescook>
	 <CAG_fn=VRehbrhvNRg0igZ==YvONug_nAYMqyrOXh3kO2+JaszQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-21 at 12:39 +0200, Alexander Potapenko wrote:
> On Fri, Jun 21, 2019 at 3:01 AM Kees Cook <keescook@chromium.org> wrote:
> > 
> > On Thu, Jun 20, 2019 at 04:46:06PM -0400, Qian Cai wrote:
> > > The linux-next commit "mm: security: introduce init_on_alloc=1 and
> > > init_on_free=1 boot options" [1] introduced a false positive when
> > > init_on_free=1 and page_poison=on, due to the page_poison expects the
> > > pattern 0xaa when allocating pages which were overwritten by
> > > init_on_free=1 with 0.
> > > 
> > > Fix it by switching the order between kernel_init_free_pages() and
> > > kernel_poison_pages() in free_pages_prepare().
> > 
> > Cool; this seems like the right approach. Alexander, what do you think?
> 
> Can using init_on_free together with page_poison bring any value at all?
> Isn't it better to decide at boot time which of the two features we're
> going to enable?

I think the typical use case is people are using init_on_free=1, and then decide
to debug something by enabling page_poison=on. Definitely, don't want
init_on_free=1 to disable page_poison as the later has additional checking in
the allocation time to make sure that poison pattern set in the free time is
still there.

> 
> > Reviewed-by: Kees Cook <keescook@chromium.org>
> > 
> > -Kees
> > 
> > > 
> > > [1] https://patchwork.kernel.org/patch/10999465/
> > > 
> > > Signed-off-by: Qian Cai <cai@lca.pw>
> > > ---
> > > 
> > > v2: After further debugging, the issue after switching order is likely a
> > >     separate issue as clear_page() should not cause issues with future
> > >     accesses.
> > > 
> > >  mm/page_alloc.c | 3 ++-
> > >  1 file changed, 2 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 54dacf35d200..32bbd30c5f85 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -1172,9 +1172,10 @@ static __always_inline bool
> > > free_pages_prepare(struct page *page,
> > >                                          PAGE_SIZE << order);
> > >       }
> > >       arch_free_page(page, order);
> > > -     kernel_poison_pages(page, 1 << order, 0);
> > >       if (want_init_on_free())
> > >               kernel_init_free_pages(page, 1 << order);
> > > +
> > > +     kernel_poison_pages(page, 1 << order, 0);
> > >       if (debug_pagealloc_enabled())
> > >               kernel_map_pages(page, 1 << order, 0);
> > > 
> > > --
> > > 1.8.3.1
> > > 
> > 
> > --
> > Kees Cook
> 
> 
> 


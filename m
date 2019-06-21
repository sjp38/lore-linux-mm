Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56B0FC43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 09:12:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0F87208C3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 09:12:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0F87208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4EFC86B0005; Fri, 21 Jun 2019 05:12:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49F948E0002; Fri, 21 Jun 2019 05:12:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 368CE8E0001; Fri, 21 Jun 2019 05:12:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DBF976B0005
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 05:12:03 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b21so8263314edt.18
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 02:12:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/jtLEA4EfdMqC51plN5XRKatomPcur5vcG0TFFK5OA8=;
        b=Q632ikVxuBhkfavgOvXGML7/oa1U2LxhgXc/vKjnozDoPuhOVePQjF9aqaACUPuvo9
         MvyxydDnvN+3DGYsxAevVMkx8aN5dbb+vmBA+MagSl9VaU5L/tml6AxWC+wgvlENmUzA
         YxfGngb3ACYeqW+qVoyQ25FesL3nVQHxQGB8v0tXmeMRrN767ouE0Y4Jzz3dOYhPBv4A
         i/P4kD6LAv6wBXJT3uS+bdvYc/THaQWnpuedwWQUV965Bw/zk9CqvrR6p+gaFVmhyg0d
         5KBfH3LvLISXUbyPfa2FTiKPeEbc1xAzbNDjNE7NSY1ic2aR+x1vGsw+2i/fEWFkzjOb
         7+6A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU8O9vTQnPPT2TcT9+cBIjGaPLJ96Bt6IPAKPzYedi27MvNJZeR
	FbelaY5y+CRb5aDQMaoo2yzSa1OvLKRhl1J2ZLDH4FFLcQqGGOLr4uDCpBQmaYR9XmIWUUbijBg
	yEApyvtg/jKV7+3FKHyFX8vgiiMEHINReI1/wU/Onvgy6DEfy/VVkD+tM9DafUGk=
X-Received: by 2002:a17:906:f10d:: with SMTP id gv13mr80219440ejb.151.1561108323453;
        Fri, 21 Jun 2019 02:12:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNz/qq5gdKc7eda60DQV2Yat5U03O0+OH8YOs0cRotanhEAG8ErFznYeoj4xw95Pb/23AD
X-Received: by 2002:a17:906:f10d:: with SMTP id gv13mr80219388ejb.151.1561108322662;
        Fri, 21 Jun 2019 02:12:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561108322; cv=none;
        d=google.com; s=arc-20160816;
        b=AMHJsUJGarLG7CGL6EmMWqzGFVTaIeq/SHxTkyK4xXqQ+2vgj7gjOCpK5rWyYphvJ8
         KDyLrX7Iqn5rn5Kw1Xai4U9YWylSHf03IGWH2OdAs1KLl5dAauFxGG3TTarXto9RYoMT
         qbhdv8IJ+mxjENKen+7fwEHXBQovozxbBzKaXJjemxvswSkIfAZuO7foYrxHwYbv1OQw
         zbvMaGxj6QMO8nll1pLZSsPOkBBWO5mcpxUSzUQEhXGuzxbQCDiSGtqoq7jGuf1kapUd
         Y9++gSQymmHKTjOuLbzyQFZwOF5/uiCWelGTKyefi2tmq0tTJ8R4tItm84lmV51075Cf
         XFVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/jtLEA4EfdMqC51plN5XRKatomPcur5vcG0TFFK5OA8=;
        b=DjeZ0nBC1WAp9B3D8q12Jmcm5obFXbLH01KmtmqUvrj6trLZ4SBanjR96IqyE77cYl
         tQLs8Jm5DKCzNZAL0ovSnVoU7R6tZTj7JZYQiZaRAu7KZAGsh5qGqCZzLOK0y2C6xV5O
         LACpFprXeNkk3nlLExodRx0hsl7YvOykfmsCufLGiAPJeKx7FF2n446F1psSAQVaETNP
         HoeOdOi5CQZgAyADxIXwPEZtdeVeqqYNH/fhHUYtbeSJiUDM7e/1cwezwa2db9KzUVct
         jfOpm4g/SgMa9fjstqoq7r7zfcoLggvbYInpjUaFDWq8t/VGEmr5IW7T9986FrMLkJKu
         h0aQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p24si1427931eju.120.2019.06.21.02.12.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 02:12:02 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DA07AAD17;
	Fri, 21 Jun 2019 09:12:01 +0000 (UTC)
Date: Fri, 21 Jun 2019 11:11:59 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Kees Cook <keescook@chromium.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-security-module <linux-security-module@vger.kernel.org>,
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Subject: Re: [PATCH v7 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-ID: <20190621091159.GD3429@dhcp22.suse.cz>
References: <20190617151050.92663-1-glider@google.com>
 <20190617151050.92663-2-glider@google.com>
 <20190621070905.GA3429@dhcp22.suse.cz>
 <CAG_fn=UFj0Lzy3FgMV_JBKtxCiwE03HVxnR8=f9a7=4nrUFXSw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=UFj0Lzy3FgMV_JBKtxCiwE03HVxnR8=f9a7=4nrUFXSw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 21-06-19 10:57:35, Alexander Potapenko wrote:
> On Fri, Jun 21, 2019 at 9:09 AM Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > > diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
> > > index fd5c95ff9251..2f75dd0d0d81 100644
> > > --- a/kernel/kexec_core.c
> > > +++ b/kernel/kexec_core.c
> > > @@ -315,7 +315,7 @@ static struct page *kimage_alloc_pages(gfp_t gfp_mask, unsigned int order)
> > >               arch_kexec_post_alloc_pages(page_address(pages), count,
> > >                                           gfp_mask);
> > >
> > > -             if (gfp_mask & __GFP_ZERO)
> > > +             if (want_init_on_alloc(gfp_mask))
> > >                       for (i = 0; i < count; i++)
> > >                               clear_highpage(pages + i);
> > >       }
> >
> > I am not really sure I follow here. Why do we want to handle
> > want_init_on_alloc here? The allocated memory comes from the page
> > allocator and so it will get zeroed there. arch_kexec_post_alloc_pages
> > might touch the content there but is there any actual risk of any kind
> > of leak?
> You're right, we don't want to initialize this memory if init_on_alloc is on.
> We need something along the lines of:
>   if (!static_branch_unlikely(&init_on_alloc))
>     if (gfp_mask & __GFP_ZERO)
>       // clear the pages
> 
> Another option would be to disable initialization in alloc_pages() using a flag.

Or we can simply not care and keen the code the way it is. First of all
it seems that nobody actually does use __GFP_ZERO unless I have missed
soemthing
	- kimage_alloc_pages(KEXEC_CONTROL_MEMORY_GFP, order); # GFP_KERNEL | __GFP_NORETRY
	- kimage_alloc_pages(gfp_mask, 0);
		- kimage_alloc_page(image, GFP_KERNEL, KIMAGE_NO_DEST);
		- kimage_alloc_page(image, GFP_HIGHUSER, maddr);

but even if we actually had a user do we care about double intialization
for something kexec related? It is not any hot path AFAIR.

-- 
Michal Hocko
SUSE Labs


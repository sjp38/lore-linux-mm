Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B010D6B0005
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 08:17:41 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id j8so88320338lfd.0
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 05:17:41 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id z7si3903802wmz.39.2016.04.29.05.17.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Apr 2016 05:17:40 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id w143so4592035wmw.3
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 05:17:40 -0700 (PDT)
Date: Fri, 29 Apr 2016 14:17:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Confusing olddefault prompt for Z3FOLD
Message-ID: <20160429121738.GM21977@dhcp22.suse.cz>
References: <9459.1461686910@turing-police.cc.vt.edu>
 <20160427123139.GA2230@dhcp22.suse.cz>
 <CAMJBoFPWNx6UTqyw1XF46fZYNi=nBjHXNdWz+SDokqG3xEkjAA@mail.gmail.com>
 <20160428115858.GE31489@dhcp22.suse.cz>
 <CAMJBoFM3HYpfPRD2di6=QF_Ebo1fOmNCLPWzXF2RgWKB4cB6GA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMJBoFM3HYpfPRD2di6=QF_Ebo1fOmNCLPWzXF2RgWKB4cB6GA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Thu 28-04-16 21:40:48, Vitaly Wool wrote:
> On Thu, Apr 28, 2016 at 1:58 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Thu 28-04-16 13:35:45, Vitaly Wool wrote:
[...]
> >> * zbud is 30% less object code
> >
> > This sounds like a lot but in fact:
> >    text    data     bss     dec     hex filename
> >    2063     104       8    2175     87f mm/zbud.o
> >    3467     104       8    3579     dfb mm/z3fold.o
> 
> I get significantly larger code on an ARM64 machine...

That is quite unexpected. I would assume that the arch specific growth
would be proportional for both modules.

[...]

> >> * zbud exports its own API while z3fold is designed to work via zpool
> >
> > $ git grep EXPORT mm/zbud.c include/linux/zbud.h
> > $
> >
> > So the API can be used only from the kernel, right? I haven't checked
> > users but why does the API actually matters.
> >
> > Or is there any other API I have missed.
> 
> Not sure really. zswap used to call zbud functions directly rather
> than via zpool. z3fold was only intended to be used via zpool. That of
> course may be changed, but I consider it right to have something
> proven and working side-by-side with the new stuff and if the new
> stuff supersedes the old one, well, we can remove the latter later.

On the other hand it is more code to maintain. I can see a reason to
have more implementations if they are not overlapping completely - e.g.
because they behave really differently for specific usecases which are
too hard to be covered by a single algorithm. Is this the case here?
If yes this should be really explained and justified. I really hate how
all the Z* stuff is hard to grasp because there are way too many
components already - each suited for a particular workload not
considering others. I would hope for a simplification in that area
rather than yet another option on top. Now, I might be just unfair here
because I am not deeply familiar with Z* stuff but just looking at the
configuration space makes my head hurt.

> >> * limiting the amount of zpool users doesn't make much sense to me,
> >>   after all :)
> >
> > I am not sure I understand this part. Could you be more specific?
> 
> Well, the thought was trivial: if there is an API which provides
> abstraction for compressed objects storage, why not have several users
> of it rather than 1,5?

Because the configuration space is already too complicated and poor user
has to decide what to use somehow. I would be completely lost on what to
use now... From a first thought I would rather go with a better
comprimation but is there any risk that I would end up using much more
CPU for that or that I might be just too unlucky and my data wouldn't
compress enough to fit in?

> What we need to do is to provide a better
> documentation (I must admit I wasn't that good in doing this) on when
> to use what.

That would be certainly appreciated.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

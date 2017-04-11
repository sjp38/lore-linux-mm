Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 409F76B03A1
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 09:46:23 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l44so8145652wrc.11
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 06:46:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z10si3143036wmh.69.2017.04.11.06.46.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Apr 2017 06:46:21 -0700 (PDT)
Date: Tue, 11 Apr 2017 15:46:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Add additional consistency check
Message-ID: <20170411134618.GN6729@dhcp22.suse.cz>
References: <20170331164028.GA118828@beast>
 <20170404113022.GC15490@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704041005570.23420@east.gentwo.org>
 <20170404151600.GN15132@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704041412050.27424@east.gentwo.org>
 <20170404194220.GT15132@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704041457030.28085@east.gentwo.org>
 <20170404201334.GV15132@dhcp22.suse.cz>
 <CAGXu5jL1t2ZZkwnGH9SkFyrKDeCugSu9UUzvHf3o_MgraDFL1Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jL1t2ZZkwnGH9SkFyrKDeCugSu9UUzvHf3o_MgraDFL1Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 10-04-17 21:58:22, Kees Cook wrote:
> On Tue, Apr 4, 2017 at 1:13 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Tue 04-04-17 14:58:06, Cristopher Lameter wrote:
> >> On Tue, 4 Apr 2017, Michal Hocko wrote:
> >>
> >> > On Tue 04-04-17 14:13:06, Cristopher Lameter wrote:
> >> > > On Tue, 4 Apr 2017, Michal Hocko wrote:
> >> > >
> >> > > > Yes, but we do not have to blow the kernel, right? Why cannot we simply
> >> > > > leak that memory?
> >> > >
> >> > > Because it is a serious bug to attempt to free a non slab object using
> >> > > slab operations. This is often the result of memory corruption, coding
> >> > > errs etc. The system needs to stop right there.
> >> >
> >> > Why when an alternative is a memory leak?
> >>
> >> Because the slab allocators fail also in case you free an object multiple
> >> times etc etc. Continuation is supported by enabling a special resiliency
> >> feature via the kernel command line. The alternative is selectable but not
> >> the default.
> >
> > I disagree! We should try to continue as long as we _know_ that the
> > internal state of the allocator is still consistent and a further
> > operation will not spread the corruption even more. This is clearly not
> > the case for an invalid pointer to kfree.
> >
> > I can see why checking for an early allocator corruption is not always
> > feasible and you can only detect after-the-fact but this is not the case
> > here and putting your system down just because some buggy code is trying
> > to free something it hasn't allocated is not really useful. I completely
> > agree with Linus that we overuse BUG way too much and this is just
> > another example of it.
> 
> Instead of the proposed BUG here, what's the correct "safe" return value?

I would assume that _you_ as the one who proposes the change would take
some time to read and understand the code and know this answer. This is
how we do changes to the kernel: have an objective, understand the code
and generate the patch.

I am really sad that this particular patch has shown that you didn't
bother to consider the later part and blindly applied something that you
haven't thought through properly. Please try harder next time.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

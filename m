Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id C1EFC6B0069
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 10:02:08 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id le9so211875662pab.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 07:02:08 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j29si22922105pfk.53.2016.08.22.07.02.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 07:02:07 -0700 (PDT)
Date: Mon, 22 Aug 2016 10:02:15 -0400
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: OOM detection regressions since 4.7
Message-ID: <20160822140215.GA16149@kroah.com>
References: <20160822093249.GA14916@dhcp22.suse.cz>
 <20160822093707.GG13596@dhcp22.suse.cz>
 <20160822100528.GB11890@kroah.com>
 <20160822105441.GH13596@dhcp22.suse.cz>
 <20160822133114.GA15302@kroah.com>
 <20160822134227.GM13596@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160822134227.GM13596@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 22, 2016 at 03:42:28PM +0200, Michal Hocko wrote:
> On Mon 22-08-16 09:31:14, Greg KH wrote:
> > On Mon, Aug 22, 2016 at 12:54:41PM +0200, Michal Hocko wrote:
> > > On Mon 22-08-16 06:05:28, Greg KH wrote:
> > > > On Mon, Aug 22, 2016 at 11:37:07AM +0200, Michal Hocko wrote:
> > > [...]
> > > > > > From 899b738538de41295839dca2090a774bdd17acd2 Mon Sep 17 00:00:00 2001
> > > > > > From: Michal Hocko <mhocko@suse.com>
> > > > > > Date: Mon, 22 Aug 2016 10:52:06 +0200
> > > > > > Subject: [PATCH] mm, oom: prevent pre-mature OOM killer invocation for high
> > > > > >  order request
> > > > > > 
> > > > > > There have been several reports about pre-mature OOM killer invocation
> > > > > > in 4.7 kernel when order-2 allocation request (for the kernel stack)
> > > > > > invoked OOM killer even during basic workloads (light IO or even kernel
> > > > > > compile on some filesystems). In all reported cases the memory is
> > > > > > fragmented and there are no order-2+ pages available. There is usually
> > > > > > a large amount of slab memory (usually dentries/inodes) and further
> > > > > > debugging has shown that there are way too many unmovable blocks which
> > > > > > are skipped during the compaction. Multiple reporters have confirmed that
> > > > > > the current linux-next which includes [1] and [2] helped and OOMs are
> > > > > > not reproducible anymore. A simpler fix for the stable is to simply
> > > > > > ignore the compaction feedback and retry as long as there is a reclaim
> > > > > > progress for high order requests which we used to do before. We already
> > > > > > do that for CONFING_COMPACTION=n so let's reuse the same code when
> > > > > > compaction is enabled as well.
> > > > > > 
> > > > > > [1] http://lkml.kernel.org/r/20160810091226.6709-1-vbabka@suse.cz
> > > > > > [2] http://lkml.kernel.org/r/f7a9ea9d-bb88-bfd6-e340-3a933559305a@suse.cz
> > > > > > 
> > > > > > Fixes: 0a0337e0d1d1 ("mm, oom: rework oom detection")
> > > > > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > > > > ---
> > > > > >  mm/page_alloc.c | 50 ++------------------------------------------------
> > > > > >  1 file changed, 2 insertions(+), 48 deletions(-)
> > > > 
> > > > So, if this goes into Linus's tree, can you let stable@vger.kernel.org
> > > > know about it so we can add it to the 4.7-stable tree?  Otherwise
> > > > there's not much I can do here now, right?
> > > 
> > > My plan would be actually to not push this to Linus because we have a
> > > proper fix for Linus tree. It is just that the fix is quite large and I
> > > felt like the stable should get the most simple fix possible, which is
> > > this partial revert. So, what I am trying to tell is to push a non-linus
> > > patch to stable as it is simpler.
> > 
> > I _REALLY_ hate taking any patches that are not in Linus's tree as 90%
> > of the time (well, almost always), it ends up being wrong and hurting us
> > in the end.
> 
> I do not like it either but if there is a simple and straightforward
> workaround for stable while the upstream can go with the _proper_ fix
> from the longer POV then I think this is perfectly justified. Stable
> should be always about the simplest fix for the problem IMHO.

No, stable should always be "what is in Linus's tree to get it fixed."

Again, almost every time we try to "just do this simple thing instead"
in a stable tree, it ends up being broken somehow.  We have the history
to back this up, look at our archives.

I'll gladly take 10+ patches to resolve something, _if_ it actually
resolves something.

But, if we argue about it for a month or so, then we don't have to worry
about it as everyone will be using 4.8 :)

> Of course, if Linus/Andrew doesn't like to take those compaction
> improvements this late then I will ask to merge the partial revert to
> Linus tree as well and then there is not much to discuss.

Ok, let me know how it goes and we can see what to do.

thanks.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

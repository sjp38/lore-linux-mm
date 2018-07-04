Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 330B96B0007
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 05:04:49 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id j80-v6so4035844itj.8
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 02:04:49 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0248.hostedemail.com. [216.40.44.248])
        by mx.google.com with ESMTPS id w65-v6si2241278itd.125.2018.07.04.02.04.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 02:04:48 -0700 (PDT)
Message-ID: <8dc61092669356f5417bc275e3b7c69ce637e63e.camel@perches.com>
Subject: Re: [PATCH] mm/memblock: replace u64 with phys_addr_t where
 appropriate
From: Joe Perches <joe@perches.com>
Date: Wed, 04 Jul 2018 02:04:44 -0700
In-Reply-To: <20180704072308.GA458@jagdpanzerIV>
References: <1530637506-1256-1-git-send-email-rppt@linux.vnet.ibm.com>
	 <20180703125722.6fd0f02b27c01f5684877354@linux-foundation.org>
	 <063c785caa11b8e1c421c656b2a030d45d6eb68f.camel@perches.com>
	 <20180704070305.GB4352@rapoport-lnx> <20180704072308.GA458@jagdpanzerIV>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, 2018-07-04 at 16:23 +0900, Sergey Senozhatsky wrote:
> On (07/04/18 10:03), Mike Rapoport wrote:
> > > %p[Ff] got deprecated by commit 04b8eb7a4ccd9ef9343e2720ccf2a5db8cfe2f67
> > > 
> > > I think it'd be simplest to just convert
> > > all the %pF and %pf uses all at once.
> > > 
> > > $ git grep --name-only "%p[Ff]" | \
> > >   xargs sed -i -e 's/%pF/%pS/' -e 's/%pf/%ps/'
> > > 
> > > and remove the appropriate Documentation bit.
> > > 
> > 
> > Something like this:
> > 
> > From 0d3e7cf494123c2640b9a892160d2e2430787004 Mon Sep 17 00:00:00 2001
> > From: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > Date: Wed, 4 Jul 2018 09:55:50 +0300
> > Subject: [PATCH] treewide: retire '%pF/%pf'
> > 
> > %p[Ff] got deprecated by commit 04b8eb7a4ccd9ef9343e2720ccf2a5db8cfe2f67
> > ("symbol lookup: introduce dereference_symbol_descriptor()")
> > 
> > Replace their uses with %p[Ss] with
> > 
> > $ git grep --name-only "%p[Ff]" | \
> >   xargs sed -i -e 's/%pF/%pS/' -e 's/%pf/%ps/'
> 
> 
> Sorry, NACK on lib/vsprintf.c part
> 
> I definitely didn't want to do this tree-wide pf->ps conversion when
> I introduced my patch set. pf/pF should have never existed, true,
> but I think we must support pf/pF in vsprintf(). Simply because it
> has been around for *far* too long.

And?  checkpatch warns about %p[Ff] uses.

> People tend to develop "habits",
> you know, I'm quite sure ppc/hppa/etc folks still do [and will] use
> pf/pF occasionally.

There's this saying about habits made to be broken.
This is one of those habits.

I'd expect more people probably get the %pS or %ps wrong
than use %pF.

And most people probably look for examples in code and
copy instead of thinking what's correct, so removing old
and deprecated uses from existing code is a good thing.

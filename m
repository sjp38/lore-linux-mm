Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id BB34A6B0035
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 10:24:38 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so4033170pad.39
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 07:24:38 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id cb10si312267pdb.227.2014.07.24.07.24.36
        for <linux-mm@kvack.org>;
        Thu, 24 Jul 2014 07:24:37 -0700 (PDT)
Date: Thu, 24 Jul 2014 15:24:17 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: arm64 flushing 255GB of vmalloc space takes too long
Message-ID: <20140724142417.GE13371@arm.com>
References: <CAMPhdO-j5SfHexP8hafB2EQVs91TOqp_k_SLwWmo9OHVEvNWiQ@mail.gmail.com>
 <20140709174055.GC2814@arm.com>
 <CAMPhdO_XqAL4oXcuJkp2PTQ-J07sGG4Nm5HjHO=yGqS+KuWQzg@mail.gmail.com>
 <53BF3D58.2010900@codeaurora.org>
 <20140711124553.GG11473@arm.com>
 <1406150734.12484.79.camel@deneb.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1406150734.12484.79.camel@deneb.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Salter <msalter@redhat.com>
Cc: Laura Abbott <lauraa@codeaurora.org>, Eric Miao <eric.y.miao@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, Russell King <linux@arm.linux.org.uk>

On Wed, Jul 23, 2014 at 10:25:34PM +0100, Mark Salter wrote:
> On Fri, 2014-07-11 at 13:45 +0100, Catalin Marinas wrote:
> > On Fri, Jul 11, 2014 at 02:26:48AM +0100, Laura Abbott wrote:
> > > Mark Salter actually proposed a fix to this back in May 
> > > 
> > > https://lkml.org/lkml/2014/5/2/311
> > > 
> > > I never saw any further comments on it though. It also matches what x86
> > > does with their TLB flushing. It fixes the problem for me and the threshold
> > > seems to be the best we can do unless we want to introduce options per
> > > platform. It will need to be rebased to the latest tree though.
> > 
> > There were other patches in this area and I forgot about this. The
> > problem is that the ARM architecture does not define the actual
> > micro-architectural implementation of the TLBs (and it shouldn't), so
> > there is no way to guess how many TLB entries there are. It's not an
> > easy figure to get either since there are multiple levels of caching for
> > the TLBs.
> > 
> > So we either guess some value here (we may not always be optimal) or we
> > put some time bound (e.g. based on sched_clock()) on how long to loop.
> > The latter is not optimal either, the only aim being to avoid
> > soft-lockups.
> 
> Sorry for the late reply...
> 
> So, what would you like to see wrt this, Catalin? A reworked patch based
> on time? IMO, something based on loop count or time seems better than
> the status quo of a CPU potentially wasting 10s of seconds flushing the
> tlb.

I think we could go with a loop for simplicity but with a larger number
of iterations only to avoid the lock-up (e.g. 1024, this would be 4MB
range). My concern is that for a few global mappings that may or may not
be in the TLB we nuke both the L1 and L2 TLBs (the latter can have over
1K entries). As for optimisation, I think we should look at the original
code generating such big ranges.

Would you mind posting a patch against the latest kernel?

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

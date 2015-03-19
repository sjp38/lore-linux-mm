Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3026B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 21:57:07 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so60440482pdb.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 18:57:07 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id bu12si39549731pdb.92.2015.03.18.18.57.05
        for <linux-mm@kvack.org>;
        Wed, 18 Mar 2015 18:57:06 -0700 (PDT)
Message-ID: <1426730222.5570.41.camel@intel.com>
Subject: Re: [LKP] [mm] cc87317726f: WARNING: CPU: 0 PID: 1
 atdrivers/iommu/io-pgtable-arm.c:413 __arm_lpae_unmap+0x341/0x380()
From: Huang Ying <ying.huang@intel.com>
Date: Thu, 19 Mar 2015 09:57:02 +0800
In-Reply-To: <201503182045.DEC48482.OtSOQOLVFFHFJM@I-love.SAKURA.ne.jp>
References: <1426227621.6711.238.camel@intel.com>
	 <CA+55aFxWTg_kCxGChLJGU=DFg0K_q842bkziktXu6B2fX=mXYQ@mail.gmail.com>
	 <20150317192413.GA7772@phnom.home.cmpxchg.org>
	 <1426643634.5570.14.camel@intel.com>
	 <201503182045.DEC48482.OtSOQOLVFFHFJM@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, torvalds@linux-foundation.org, mhocko@suse.cz, rientjes@google.com, akpm@linux-foundation.org, david@fromorbit.com, linux-kernel@vger.kernel.org, lkp@01.org, linux-mm@kvack.org

On Wed, 2015-03-18 at 20:45 +0900, Tetsuo Handa wrote:
> Huang Ying wrote:
> > On Tue, 2015-03-17 at 15:24 -0400, Johannes Weiner wrote:
> > > On Tue, Mar 17, 2015 at 10:15:29AM -0700, Linus Torvalds wrote:
> > > > Explicitly adding the emails of other people involved with that commit
> > > > and the original oom thread to make sure people are aware, since this
> > > > didn't get any response.
> > > > 
> > > > Commit cc87317726f8 fixed some behavior, but also seems to have turned
> > > > an oom situation into a complete hang. So presumably we shouldn't loop
> > > > *forever*. Hmm?
> > > 
> > > It seems we are between a rock and a hard place here, as we reverted
> > > specifically to that endless looping on request of filesystem people.
> > > They said[1] they rely on these allocations never returning NULL, or
> > > they might fail inside a transactions and corrupt on-disk data.
> > > 
> > > Huang, against which kernels did you first run this test on this exact
> > > setup?  Is there a chance you could try to run a kernel without/before
> > > 9879de7373fc?  I want to make sure I'm not missing something, but all
> > > versions preceding this commit should also have the same hang.  There
> > > should only be a tiny window between 9879de7373fc and cc87317726f8 --
> > > v3.19 -- where these allocations are allowed to fail.
> > 
> > I checked the test result of v3.19-rc6.  It shows that boot will hang at
> > the same position.
> 
> OK. That's the expected result. We are discussing about how to safely
> allow small allocations to fail, including how to handle stalls caused by
> allocations without __GFP_FS.
> 
> > 
> > BTW: the test is run on 32 bit system.
> 
> That sounds like the cause of your problem. The system might be out of
> address space available for the kernel (only 1GB if x86_32). You should
> try running tests on 64 bit systems.

We run test on 32 bit and 64 bit systems.  Try to catch problems on both
platforms.  I think we still need to support 32 bit systems?

Best Regards,
Huang, Ying


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

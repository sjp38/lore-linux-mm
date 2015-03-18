Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id BF7E66B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 07:45:34 -0400 (EDT)
Received: by igbue6 with SMTP id ue6so40898944igb.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 04:45:34 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j10si11817486icg.99.2015.03.18.04.45.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 04:45:34 -0700 (PDT)
Subject: Re: [LKP] [mm] cc87317726f: WARNING: CPU: 0 PID: 1 atdrivers/iommu/io-pgtable-arm.c:413 __arm_lpae_unmap+0x341/0x380()
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1426227621.6711.238.camel@intel.com>
	<CA+55aFxWTg_kCxGChLJGU=DFg0K_q842bkziktXu6B2fX=mXYQ@mail.gmail.com>
	<20150317192413.GA7772@phnom.home.cmpxchg.org>
	<1426643634.5570.14.camel@intel.com>
In-Reply-To: <1426643634.5570.14.camel@intel.com>
Message-Id: <201503182045.DEC48482.OtSOQOLVFFHFJM@I-love.SAKURA.ne.jp>
Date: Wed, 18 Mar 2015 20:45:15 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ying.huang@intel.com, hannes@cmpxchg.org
Cc: torvalds@linux-foundation.org, mhocko@suse.cz, rientjes@google.com, akpm@linux-foundation.org, david@fromorbit.com, linux-kernel@vger.kernel.org, lkp@01.org, linux-mm@kvack.org

Huang Ying wrote:
> On Tue, 2015-03-17 at 15:24 -0400, Johannes Weiner wrote:
> > On Tue, Mar 17, 2015 at 10:15:29AM -0700, Linus Torvalds wrote:
> > > Explicitly adding the emails of other people involved with that commit
> > > and the original oom thread to make sure people are aware, since this
> > > didn't get any response.
> > > 
> > > Commit cc87317726f8 fixed some behavior, but also seems to have turned
> > > an oom situation into a complete hang. So presumably we shouldn't loop
> > > *forever*. Hmm?
> > 
> > It seems we are between a rock and a hard place here, as we reverted
> > specifically to that endless looping on request of filesystem people.
> > They said[1] they rely on these allocations never returning NULL, or
> > they might fail inside a transactions and corrupt on-disk data.
> > 
> > Huang, against which kernels did you first run this test on this exact
> > setup?  Is there a chance you could try to run a kernel without/before
> > 9879de7373fc?  I want to make sure I'm not missing something, but all
> > versions preceding this commit should also have the same hang.  There
> > should only be a tiny window between 9879de7373fc and cc87317726f8 --
> > v3.19 -- where these allocations are allowed to fail.
> 
> I checked the test result of v3.19-rc6.  It shows that boot will hang at
> the same position.

OK. That's the expected result. We are discussing about how to safely
allow small allocations to fail, including how to handle stalls caused by
allocations without __GFP_FS.

> 
> BTW: the test is run on 32 bit system.

That sounds like the cause of your problem. The system might be out of
address space available for the kernel (only 1GB if x86_32). You should
try running tests on 64 bit systems.

> 
> Best Regards,
> Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id EC4BB6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 10:34:14 -0400 (EDT)
Received: by wibg7 with SMTP id g7so146146627wib.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 07:34:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h9si7202751wjy.213.2015.03.20.07.34.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Mar 2015 07:34:13 -0700 (PDT)
Date: Fri, 20 Mar 2015 15:34:10 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [LKP] [mm] cc87317726f: WARNING: CPU: 0
 PID:1atdrivers/iommu/io-pgtable-arm.c:413 __arm_lpae_unmap+0x341/0x380()
Message-ID: <20150320143410.GD4821@dhcp22.suse.cz>
References: <1426643634.5570.14.camel@intel.com>
 <201503182045.DEC48482.OtSOQOLVFFHFJM@I-love.SAKURA.ne.jp>
 <1426730222.5570.41.camel@intel.com>
 <201503202234.HIA00180.MQVLSFFtHOOFJO@I-love.SAKURA.ne.jp>
 <20150320133820.GB4821@dhcp22.suse.cz>
 <201503202302.EDF82384.OtFVHMFOLSJOFQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201503202302.EDF82384.OtFVHMFOLSJOFQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: ying.huang@intel.com, hannes@cmpxchg.org, torvalds@linux-foundation.org, rientjes@google.com, akpm@linux-foundation.org, david@fromorbit.com, linux-kernel@vger.kernel.org, lkp@01.org, linux-mm@kvack.org

On Fri 20-03-15 23:02:09, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 20-03-15 22:34:21, Tetsuo Handa wrote:
> > > Huang Ying wrote:
> > > > > > BTW: the test is run on 32 bit system.
> > > > > 
> > > > > That sounds like the cause of your problem. The system might be out of
> > > > > address space available for the kernel (only 1GB if x86_32). You should
> > > > > try running tests on 64 bit systems.
> > > > 
> > > > We run test on 32 bit and 64 bit systems.  Try to catch problems on both
> > > > platforms.  I think we still need to support 32 bit systems?
> > > 
> > > Yes, testing on both platforms is good. But please read
> > > http://lwn.net/Articles/627419/ , http://lwn.net/Articles/635354/ and
> > > http://lwn.net/Articles/636017/ . Then please add __GFP_NORETRY to memory
> > > allocations in btrfs code if it is appropriate.
> > 
> > I guess you meant __GFP_NOFAIL?
> > 
> No. btrfs's selftest (which is not using __GFP_NOFAIL) is already looping
> forever. If we want to avoid btrfs's selftest from looping forever, btrfs
> needs __GFP_NORETRY than __GFP_NOFAIL (until we establish a way to safely
> allow small allocations to fail).

Sigh. If the code is using GFP_NOFS allocation (which seem to be the
case because it worked with the 9879de7373fc) and the proper fix for
this IMO is to simply not retry endlessly for these allocations.  We
have to sort some other issues before we can make NOFS allocations fail
but let's not pile more workarounds on top in the meantime. But if btrfs
people really think __GFP_NORETRY then I do not really care much.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

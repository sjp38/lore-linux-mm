Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1ABEA6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 11:42:08 -0400 (EDT)
Received: by oiag65 with SMTP id g65so94286311oia.2
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 08:42:07 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y4si2608930oej.86.2015.03.20.08.42.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Mar 2015 08:42:07 -0700 (PDT)
Subject: Re: [LKP] [mm] cc87317726f: WARNING: CPU: 0 PID: 1 at drivers/iommu/io-pgtable-arm.c:413 __arm_lpae_unmap+0x341/0x380()
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1426730222.5570.41.camel@intel.com>
	<201503202234.HIA00180.MQVLSFFtHOOFJO@I-love.SAKURA.ne.jp>
	<20150320133820.GB4821@dhcp22.suse.cz>
	<201503202302.EDF82384.OtFVHMFOLSJOFQ@I-love.SAKURA.ne.jp>
	<20150320143410.GD4821@dhcp22.suse.cz>
In-Reply-To: <20150320143410.GD4821@dhcp22.suse.cz>
Message-Id: <201503210041.HJB73900.FVQFOFSLHOOMtJ@I-love.SAKURA.ne.jp>
Date: Sat, 21 Mar 2015 00:41:19 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: ying.huang@intel.com, hannes@cmpxchg.org, torvalds@linux-foundation.org, rientjes@google.com, akpm@linux-foundation.org, david@fromorbit.com, linux-kernel@vger.kernel.org, lkp@01.org, linux-mm@kvack.org

Michal Hocko wrote:
> On Fri 20-03-15 23:02:09, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Fri 20-03-15 22:34:21, Tetsuo Handa wrote:
> > > > Huang Ying wrote:
> > > > > > > BTW: the test is run on 32 bit system.
> > > > > > 
> > > > > > That sounds like the cause of your problem. The system might be out of
> > > > > > address space available for the kernel (only 1GB if x86_32). You should
> > > > > > try running tests on 64 bit systems.
> > > > > 
> > > > > We run test on 32 bit and 64 bit systems.  Try to catch problems on both
> > > > > platforms.  I think we still need to support 32 bit systems?
> > > > 
> > > > Yes, testing on both platforms is good. But please read
> > > > http://lwn.net/Articles/627419/ , http://lwn.net/Articles/635354/ and
> > > > http://lwn.net/Articles/636017/ . Then please add __GFP_NORETRY to memory
> > > > allocations in btrfs code if it is appropriate.
> > > 
> > > I guess you meant __GFP_NOFAIL?
> > > 
> > No. btrfs's selftest (which is not using __GFP_NOFAIL) is already looping
> > forever. If we want to avoid btrfs's selftest from looping forever, btrfs
> > needs __GFP_NORETRY than __GFP_NOFAIL (until we establish a way to safely
> > allow small allocations to fail).
> 
> Sigh. If the code is using GFP_NOFS allocation (which seem to be the
> case because it worked with the 9879de7373fc) and the proper fix for
> this IMO is to simply not retry endlessly for these allocations.

We can avoid looping forever by passing __GFP_NORETRY (from the caller side)
or by using sysctl_nr_alloc_retry == 1 (from the callee side). But

> We
> have to sort some other issues before we can make NOFS allocations fail
> but let's not pile more workarounds on top in the meantime. But if btrfs
> people really think __GFP_NORETRY then I do not really care much.

https://lkml.org/lkml/2015/3/19/221 suggests that changing each caller to
use either __GFP_NOFAIL or __GFP_NORETRY is the safer way to allow small
allocations to fail than using sysctl_nr_alloc_retry, for we don't want to
add __GFP_NOFAIL to allocations by page fault.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

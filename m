Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0918F6B007E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 07:21:38 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r12so513646wme.0
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 04:21:37 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id vh4si10292814wjb.25.2016.04.28.04.21.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 04:21:36 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id w143so22302223wmw.3
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 04:21:36 -0700 (PDT)
Date: Thu, 28 Apr 2016 13:21:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [LKP] [lkp] [mm, oom] faad2185f4: vm-scalability.throughput
 -11.8% regression
Message-ID: <20160428112135.GD31489@dhcp22.suse.cz>
References: <20160427031556.GD29014@yexl-desktop>
 <20160427073617.GA2179@dhcp22.suse.cz>
 <87fuu7iht0.fsf@yhuang-dev.intel.com>
 <20160427083733.GE2179@dhcp22.suse.cz>
 <87bn4vigpc.fsf@yhuang-dev.intel.com>
 <20160427091718.GG2179@dhcp22.suse.cz>
 <20160428051659.GA10843@aaronlu.sh.intel.com>
 <20160428085702.GB31489@dhcp22.suse.cz>
 <e7bfca34-2f7b-290f-0638-4ab1794b9fbd@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e7bfca34-2f7b-290f-0638-4ab1794b9fbd@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, kernel test robot <xiaolong.ye@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, lkp@01.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Thu 28-04-16 17:45:23, Aaron Lu wrote:
> On 04/28/2016 04:57 PM, Michal Hocko wrote:
> > On Thu 28-04-16 13:17:08, Aaron Lu wrote:
[...]
> >> I have the same doubt too, but the results look really stable(only for
> >> commit 0da9597ac9c0, see below for more explanation).
> > 
> > I cannot seem to find this sha1. Where does it come from? linux-next?
> 
> Neither can I...
> The commit should come from 0day Kbuild service I suppose, which is a
> robot to do automatic fetch/building etc.
> Could it be that the commit appeared in linux-next some day and then
> gone?

This wouldn't be unusual because mmotm part of the linux next is
constantly rebased.

[...]
> > OK, so we have 96G for consumers with 32G RAM and 96G of swap space,
> > right?  That would suggest they should fit in although the swapout could
> > be large (2/3 of the faulted memory) and the random pattern can cause
> > some trashing. Does the system bahave the same way with the stream anon
> > load? Anyway I think we should be able to handle such load, although it
> 
> By stream anon load, do you mean continuous write, without read?

Yes

> > is quite untypical from my experience because it can be pain with a slow
> > swap but ramdisk swap should be as fast as it can get so the swap in/out
> > should be basically noop. 
> > 
> >> So I guess the question here is, after the OOM rework, is the OOM
> >> expected for such a case? If so, then we can ignore this report.
> > 
> > Could you post the OOM reports please? I will try to emulate a similar
> > load here as well.
> 
> I attached the dmesg from one of the runs.
[...]
> [   77.434044] slabinfo invoked oom-killer: gfp_mask=0x26040c0(GFP_KERNEL|__GFP_COMP|__GFP_NOTRACK), order=2, oom_score_adj=0
[...]
> [  138.090480] kthreadd invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
[...]
> [  141.823925] lkp-setup-rootf invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0

All of them are order-2 and this was a known problem for "mm, oom:
rework oom detection" commit and later should make it much more
resistant to failures for higher (!costly) orders. So I would definitely
encourage you to retest with the current _complete_ mmotm tree.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

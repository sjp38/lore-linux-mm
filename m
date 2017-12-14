Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 070BE6B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 04:23:41 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id f9so2880955wra.2
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 01:23:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j127si2647208wma.144.2017.12.14.01.23.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Dec 2017 01:23:39 -0800 (PST)
Date: Thu, 14 Dec 2017 10:23:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: NUMA stats code cleanup and enhancement
Message-ID: <20171214092338.GF16951@dhcp22.suse.cz>
References: <20171130085322.tyys6xbzzvui7ogz@dhcp22.suse.cz>
 <0f039a89-5500-1bf5-c013-d39ba3bf62bd@intel.com>
 <20171130094523.vvcljyfqjpbloe5e@dhcp22.suse.cz>
 <9cd6cc9f-252a-3c6f-2f1f-e39d4ec0457b@intel.com>
 <20171208084755.GS20234@dhcp22.suse.cz>
 <f082f521-44a2-0585-3435-63dab24efbb7@intel.com>
 <20171212081126.GK4779@dhcp22.suse.cz>
 <d48b89f4-34d2-f3c8-f20a-b799f4878901@intel.com>
 <20171214072927.GB16951@dhcp22.suse.cz>
 <2176cf74-210a-01fe-3a7e-272a69b7bdc6@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2176cf74-210a-01fe-3a7e-272a69b7bdc6@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kemi <kemi.wang@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu 14-12-17 16:55:54, kemi wrote:
> 
> 
> On 2017a1'12ae??14ae?JPY 15:29, Michal Hocko wrote:
> > On Thu 14-12-17 09:40:32, kemi wrote:
> >>
> >>
> >> or sometimes 
> >> NUMA stats can't be disabled in their environments.
> > 
> > why?
> > 
> >> That's the reason
> >> why we spent time to do that optimization other than simply adding a runtime
> >> configuration interface.
> >>
> >> Furthermore, the code we optimized for is the core area of kernel that can
> >> benefit most of kernel actions, more or less I think.
> >>
> >> All right, let's think about it in another way, does a u64 percpu array per-node
> >> for NUMA stats really make code too much complicated and hard to maintain?
> >> I'm afraid not IMHO.
> > 
> > I disagree. The whole numa stat things has turned out to be nasty to
> > maintain. For a very limited gain. Now you are just shifting that
> > elsewhere. Look, there are other counters taken in the allocator, we do
> > not want to treat them specially. We have a nice per-cpu infrastructure
> > here so I really fail to see why we should code-around it. If that can
> > be improved then by all means let's do it.
> > 
> 
> Yes, I agree with you that we may improve current per-cpu infrastructure.
> May we have a chance to increase the size of vm_node_stat_diff from s8 to s16 for
> this "per-cpu infrastructure" (s32 in per-cpu counter infrastructure)? The 
> limitation of type s8 seems not enough with more and more cpu cores, especially
> for those monotone increasing type of counters like NUMA counters.
> 
>                                before     after(moving numa to per_cpu_nodestat
>                                               and change s8 to s16)   
> sizeof(struct per_cpu_nodestat)  28                 68
> 
> If ok, we can also keep that improvement in a nice way.

I wouldn't be opposed. Maybe we should make it nr_cpus sized.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

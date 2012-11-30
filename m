Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 3AD7D6B0088
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 05:52:55 -0500 (EST)
Date: Fri, 30 Nov 2012 10:52:47 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2 0/5] Add movablecore_map boot option
Message-ID: <20121130105247.GB8218@suse.de>
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com>
 <50B5CFAE.80103@huawei.com>
 <3908561D78D1C84285E8C5FCA982C28F1C95EDCE@ORSMSX108.amr.corp.intel.com>
 <50B68467.5020008@zytor.com>
 <20121129110045.GX8218@suse.de>
 <3908561D78D1C84285E8C5FCA982C28F1C95FF53@ORSMSX108.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F1C95FF53@ORSMSX108.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rob@landley.net" <rob@landley.net>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Len Brown <lenb@kernel.org>, "Wang, Frank" <frank.wang@intel.com>

On Fri, Nov 30, 2012 at 02:58:40AM +0000, Luck, Tony wrote:
> > If any significant percentage of memory is in ZONE_MOVABLE then the memory
> > hotplug people will have to deal with all the lowmem/highmem problems
> > that used to be faced by 32-bit x86 with PAE enabled. 
> 
> While these problems may still exist on large systems - I think it becomes
> harder to construct workloads that run into problems.  In those bad old days
> a significant fraction of lowmem was consumed by the kernel ... so it was
> pretty easy to find meta-data intensive workloads that would push it over
> a cliff.  Here we  are talking about systems with say 128GB per node divided
> into 64GB moveable and 64GB non-moveable (and I'd regard this as a rather
> low-end machine).  Unless the workload consists of zillions of tiny processes
> all mapping shared memory blocks, the percentage of memory allocated to
> the kernel is going to be tiny compared with the old 4GB days.
> 

Sure, if that's how the end-user decides to configure it. My concern is
what they'll do is configure node-0 to be ZONE_NORMAL and all other nodes
to be ZONE_MOVABLE -- 3 to 1 ratio "highmem" to "lowmem" effectively on
a 4-node machine or 7 to 1 on an 8-node. It'll be harder than it was in
the old days to trigger the problems but it'll still be possible and it
will generate bug reports down the road. Some will be obvious at least --
OOM killer triggered for GFP_KERNEL with plenty of free memory but all in
ZONE_MOVABLE. Others will be less obvious -- major stalls during IO tests
while ramping up with large amounts of reclaim activity visible even though
only 20-40% of memory is in use.

I'm not even getting into the impact this has on NUMA performance.

I'm not saying that ZONE_MOVABLE will not work. It will and it'll work
in the short-term but it's far from being a great long-term solution and
it is going to generate bug reports that will have to be supported by
distributions. Even if the interface to how it is configured gets ironed
out there still should be a replacement plan in place. FWIW, I dislike the
command-line configuration option. If it was me, I would have gone with
starting a machine with memory mostly off-lined and used sysfs files or
different sysfs strings written to the "online" file to determine if a
section was ZONE_MOVABLE or the next best alternative.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

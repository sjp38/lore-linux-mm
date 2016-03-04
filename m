Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 418996B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 01:37:42 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id y8so4674099igp.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 22:37:42 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 87si2919803ios.62.2016.03.03.22.37.40
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 22:37:41 -0800 (PST)
Date: Fri, 4 Mar 2016 15:38:07 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: Suspicious error for CMA stress test
Message-ID: <20160304063807.GA13317@js1304-P5Q-DELUXE>
References: <56D6F008.1050600@huawei.com>
 <56D79284.3030009@redhat.com>
 <CAAmzW4PUwoVF+F-BpOZUHhH6YHp_Z8VkiUjdBq85vK6AWVkyPg@mail.gmail.com>
 <56D832BD.5080305@huawei.com>
 <20160304020232.GA12036@js1304-P5Q-DELUXE>
 <20160304043232.GC12036@js1304-P5Q-DELUXE>
 <56D92595.60709@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56D92595.60709@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hanjun Guo <guohanjun@huawei.com>
Cc: Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Mar 04, 2016 at 02:05:09PM +0800, Hanjun Guo wrote:
> On 2016/3/4 12:32, Joonsoo Kim wrote:
> > On Fri, Mar 04, 2016 at 11:02:33AM +0900, Joonsoo Kim wrote:
> >> On Thu, Mar 03, 2016 at 08:49:01PM +0800, Hanjun Guo wrote:
> >>> On 2016/3/3 15:42, Joonsoo Kim wrote:
> >>>> 2016-03-03 10:25 GMT+09:00 Laura Abbott <labbott@redhat.com>:
> >>>>> (cc -mm and Joonsoo Kim)
> >>>>>
> >>>>>
> >>>>> On 03/02/2016 05:52 AM, Hanjun Guo wrote:
> >>>>>> Hi,
> >>>>>>
> >>>>>> I came across a suspicious error for CMA stress test:
> >>>>>>
> >>>>>> Before the test, I got:
> >>>>>> -bash-4.3# cat /proc/meminfo | grep Cma
> >>>>>> CmaTotal:         204800 kB
> >>>>>> CmaFree:          195044 kB
> >>>>>>
> >>>>>>
> >>>>>> After running the test:
> >>>>>> -bash-4.3# cat /proc/meminfo | grep Cma
> >>>>>> CmaTotal:         204800 kB
> >>>>>> CmaFree:         6602584 kB
> >>>>>>
> >>>>>> So the freed CMA memory is more than total..
> >>>>>>
> >>>>>> Also the the MemFree is more than mem total:
> >>>>>>
> >>>>>> -bash-4.3# cat /proc/meminfo
> >>>>>> MemTotal:       16342016 kB
> >>>>>> MemFree:        22367268 kB
> >>>>>> MemAvailable:   22370528 kB
> >>> [...]
> >>>>> I played with this a bit and can see the same problem. The sanity
> >>>>> check of CmaFree < CmaTotal generally triggers in
> >>>>> __move_zone_freepage_state in unset_migratetype_isolate.
> >>>>> This also seems to be present as far back as v4.0 which was the
> >>>>> first version to have the updated accounting from Joonsoo.
> >>>>> Were there known limitations with the new freepage accounting,
> >>>>> Joonsoo?
> >>>> I don't know. I also played with this and looks like there is
> >>>> accounting problem, however, for my case, number of free page is slightly less
> >>>> than total. I will take a look.
> >>>>
> >>>> Hanjun, could you tell me your malloc_size? I tested with 1 and it doesn't
> >>>> look like your case.
> >>> I tested with malloc_size with 2M, and it grows much bigger than 1M, also I
> >>> did some other test:
> >> Thanks! Now, I can re-generate erronous situation you mentioned.
> >>
> >>>  - run with single thread with 100000 times, everything is fine.
> >>>
> >>>  - I hack the cam_alloc() and free as below [1] to see if it's lock issue, with
> >>>    the same test with 100 multi-thread, then I got:
> >> [1] would not be sufficient to close this race.
> >>
> >> Try following things [A]. And, for more accurate test, I changed code a bit more
> >> to prevent kernel page allocation from cma area [B]. This will prevent kernel
> >> page allocation from cma area completely so we can focus cma_alloc/release race.
> >>
> >> Although, this is not correct fix, it could help that we can guess
> >> where the problem is.
> > More correct fix is something like below.
> > Please test it.
> 
> Hmm, this is not working:

Sad to hear that.

Could you tell me your system's MAX_ORDER and pageblock_order?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id DF2016B007E
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 21:09:07 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id 124so25881594pfg.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 18:09:07 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id n79si2066471pfj.101.2016.03.03.18.09.06
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 18:09:07 -0800 (PST)
Date: Fri, 4 Mar 2016 11:09:32 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: Suspicious error for CMA stress test
Message-ID: <20160304020932.GB12036@js1304-P5Q-DELUXE>
References: <56D6F008.1050600@huawei.com>
 <56D79284.3030009@redhat.com>
 <CAAmzW4PUwoVF+F-BpOZUHhH6YHp_Z8VkiUjdBq85vK6AWVkyPg@mail.gmail.com>
 <56D832BD.5080305@huawei.com>
 <56D887E1.8000602@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56D887E1.8000602@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Hanjun Guo <guohanjun@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Mar 03, 2016 at 10:52:17AM -0800, Laura Abbott wrote:
> On 03/03/2016 04:49 AM, Hanjun Guo wrote:
> >On 2016/3/3 15:42, Joonsoo Kim wrote:
> >>2016-03-03 10:25 GMT+09:00 Laura Abbott <labbott@redhat.com>:
> >>>(cc -mm and Joonsoo Kim)
> >>>
> >>>
> >>>On 03/02/2016 05:52 AM, Hanjun Guo wrote:
> >>>>Hi,
> >>>>
> >>>>I came across a suspicious error for CMA stress test:
> >>>>
> >>>>Before the test, I got:
> >>>>-bash-4.3# cat /proc/meminfo | grep Cma
> >>>>CmaTotal:         204800 kB
> >>>>CmaFree:          195044 kB
> >>>>
> >>>>
> >>>>After running the test:
> >>>>-bash-4.3# cat /proc/meminfo | grep Cma
> >>>>CmaTotal:         204800 kB
> >>>>CmaFree:         6602584 kB
> >>>>
> >>>>So the freed CMA memory is more than total..
> >>>>
> >>>>Also the the MemFree is more than mem total:
> >>>>
> >>>>-bash-4.3# cat /proc/meminfo
> >>>>MemTotal:       16342016 kB
> >>>>MemFree:        22367268 kB
> >>>>MemAvailable:   22370528 kB
> >[...]
> >>>
> >>>I played with this a bit and can see the same problem. The sanity
> >>>check of CmaFree < CmaTotal generally triggers in
> >>>__move_zone_freepage_state in unset_migratetype_isolate.
> >>>This also seems to be present as far back as v4.0 which was the
> >>>first version to have the updated accounting from Joonsoo.
> >>>Were there known limitations with the new freepage accounting,
> >>>Joonsoo?
> >>I don't know. I also played with this and looks like there is
> >>accounting problem, however, for my case, number of free page is slightly less
> >>than total. I will take a look.
> >>
> >>Hanjun, could you tell me your malloc_size? I tested with 1 and it doesn't
> >>look like your case.
> >
> >I tested with malloc_size with 2M, and it grows much bigger than 1M, also I
> >did some other test:
> >
> >  - run with single thread with 100000 times, everything is fine.
> >
> >  - I hack the cam_alloc() and free as below [1] to see if it's lock issue, with
> >    the same test with 100 multi-thread, then I got:
> >
> >-bash-4.3# cat /proc/meminfo | grep Cma
> >CmaTotal: 204800 kB
> >CmaFree: 225112 kB
> >
> >It only increased about 30M for free, not 6G+ in previous test, although
> >the problem is not solved, the problem is less serious, is it a synchronization
> >problem?
> >
> 
> 'only' 30M is still an issue although I think you are right about something related
> to synchronization. When I put the cma_mutex around free_contig_range I don't see

Hmm... I can see the issue even if putting the cma_mutex around
free_contig_range().

In other reply, I attached the code to temporary close the race.

> the issue. I wonder if free of the pages is racing with the undo_isolate_page_range
> on overlapping ranges caused by outer_start?

I don't know yet.
Anyway, it looks like that the problem that I want to fix by commit '3c60509'
still remains.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

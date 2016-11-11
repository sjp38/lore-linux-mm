Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 486CE28028E
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 01:36:52 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id a8so6105920pfg.0
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 22:36:52 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id l78si8707950pfg.206.2016.11.10.22.36.50
        for <linux-mm@kvack.org>;
        Thu, 10 Nov 2016 22:36:51 -0800 (PST)
Date: Fri, 11 Nov 2016 15:38:56 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v6 2/6] mm/cma: introduce new zone, ZONE_CMA
Message-ID: <20161111063856.GB16336@js1304-P5Q-DELUXE>
References: <1476414196-3514-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1476414196-3514-3-git-send-email-iamjoonsoo.kim@lge.com>
 <58184B28.8090405@hisilicon.com>
 <20161107061500.GA21159@js1304-P5Q-DELUXE>
 <58202881.5030004@hisilicon.com>
 <20161107072702.GC21159@js1304-P5Q-DELUXE>
 <582030CB.80905@hisilicon.com>
 <5820313A.80207@hisilicon.com>
 <20161108035942.GA31767@js1304-P5Q-DELUXE>
 <582177C7.7010706@hisilicon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <582177C7.7010706@hisilicon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Feng <puck.chen@hisilicon.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, saberlily.xia@hisilicon.com, Zhuangluan Su <suzhuangluan@hisilicon.com>, Dan Zhao <dan.zhao@hisilicon.com>

On Tue, Nov 08, 2016 at 02:59:19PM +0800, Chen Feng wrote:
> 
> 
> On 2016/11/8 11:59, Joonsoo Kim wrote:
> > On Mon, Nov 07, 2016 at 03:46:02PM +0800, Chen Feng wrote:
> >>
> >>
> >> On 2016/11/7 15:44, Chen Feng wrote:
> >>> On 2016/11/7 15:27, Joonsoo Kim wrote:
> >>>> On Mon, Nov 07, 2016 at 03:08:49PM +0800, Chen Feng wrote:
> >>>>>
> >>>>>
> >>>>> On 2016/11/7 14:15, Joonsoo Kim wrote:
> >>>>>> On Tue, Nov 01, 2016 at 03:58:32PM +0800, Chen Feng wrote:
> >>>>>>> Hello, I hava a question on cma zone.
> >>>>>>>
> >>>>>>> When we have cma zone, cma zone will be the highest zone of system.
> >>>>>>>
> >>>>>>> In android system, the most memory allocator is ION. Media system will
> >>>>>>> alloc unmovable memory from it.
> >>>>>>>
> >>>>>>> On low memory scene, will the CMA zone always do balance?
> >>>>>>
> >>>>>> Allocation request for low zone (normal zone) would not cause CMA zone
> >>>>>> to be balanced since it isn't helpful.
> >>>>>>
> >>>>> Yes. But the cma zone will run out soon. And it always need to do balance.
> >>>>>
> >>>>> How about use migrate cma before movable and let cma type to fallback movable.
> >>>>>
> >>>>> https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1263745.html
> >>>>
> >>>> ZONE_CMA approach will act like as your solution. Could you elaborate
> >>>> more on the problem of zone approach?
> >>>>
> >>>
> >>> The ZONE approach is that makes cma pages in a zone. It can cause a higher swapin/out
> >>> than use migrate cma first.
> > 
> > Interesting result. I should look at it more deeply. Could you explain
> > me why the ZONE approach causes a higher swapin/out?
> > 
> The result is that. I don't have a obvious reason. Maybe add a zone, need to do more balance
> to keep the watermark of cma-zone. cma-zone is always used firstly. Since the test-case
> alloced the same memory in total.

Please do more analysis.
Without the correct analysis, the result doesn't have any meaning. We
can't make sure that it is always better than the other. IMHO, number
is important but more important thing is a theory. Number is just
auxiliary method to prove the theory.

> 
> >>>
> >>> The higher swapin/out may have a performance effect to application. The application may
> >>> use too much time swapin memory.
> >>>
> >>> You can see my tested result attached for detail. And the baseline is result of [1].
> >>>
> >>>
> >> My test case is run 60 applications and alloc 512MB ION memory.
> >>
> >> Repeat this action 50 times
> > 
> > Could you tell me more detail about your test?
> > Kernel version? Total Memory? Total CMA Memory? Android system? What
> > type of memory does ION uses? Other statistics? Etc...
> 
> Tested on 4.1, android 7, 512MB-cma in 4G memory.
> ION use normal unmovable memory, I use it to simulate a camera open operator.

Okay. Kernel version would be the one of the reasons.

On 4.1, there is a fair zone allocator so behaviour of ZONE_CMA is
different with movable first policy. Allocation would be interleaving
between zones. It has pros and cons. The fair zone allocator is
removed in the recent kernel so please test with it on the recent
kernel for apple to apple comparison.

> > 
> > If it tested on the Android, I'm not sure that we need to consider
> > it's result. Android has a lowmemory killer which is quitely different
> > with normal reclaim behaviour.
> Why?

Lowmemory killer don't keep LRU ordering of the page. It uses LRU
ordering of the app and kill the app to reclaim the mermory. It makes
reclaim behaviour quiet different with original one. And, it largely
depends on userspace setting so we can't take care about it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

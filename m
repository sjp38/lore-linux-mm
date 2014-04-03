Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id C6F426B0044
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 19:25:00 -0400 (EDT)
Received: by mail-yk0-f175.google.com with SMTP id 131so2238814ykp.6
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 16:25:00 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id l5si7723296yhg.44.2014.04.03.16.25.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 03 Apr 2014 16:25:00 -0700 (PDT)
Message-ID: <533DEDC5.5070500@oracle.com>
Date: Thu, 03 Apr 2014 19:24:53 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm,tracing: improve current situation
References: <1396561440.4661.33.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1396561440.4661.33.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/03/2014 05:44 PM, Davidlohr Bueso wrote:
> Hi All,
> 
> During LSFMM Dave Jones discussed the current situation around
> testing/trinity in the mm. One of the conclusions was that basically we
> lack tools to gather the necessary information to make debugging a less
> painful process, making it pretty much a black box for a lot of cases.
> 
> One of the suggested ways to do so was to improve our tracing. Currently
> we have events for kmem, vmscan and oom (which really just traces the
> tunable updates) -- In addition Dave Hansen also also been trying to add
> tracing for TLB range flushing, hopefully that can make it in some time
> soon. However, this lacks the more general data that governs all of the
> core VM, such as vmas and of course the mm_struct.
> 
> To this end, I've started adding events to trace the vma lifecycle,
> including: creating, removing, splitting, merging, copying and
> adjusting. Currently it only prints out the start and end virtual
> addresses, such as:
> 
> bash-3661   [000]  ....  222.964847: split_vma: [8a8000-9a6000] => new: [9a6000-9b6000]
> 
> Now, on a more general scenario, I basically would like to know, 1) is
> this actually useful... I'm hoping that, if in fact something like this
> gets merged, it won't just sit there. 2) What other general data would
> be useful for debugging purposes? I'm happy to collect feedback and send
> out something we can all benefit from.

There's another thing we have to think about, which is the bottleneck of
getting that debug info out.

Turning on any sort of tracing/logging in mm/ would trigger huge amounts
of data flowing out. Any attempt to store that data anywhere would result
either in too much interference to the tests so that issues stop reproducing,
or way too much data to even be able to get through the guest <-> host pipe.

I was working on a similar idea, which is similar to what lockdep does now:
when you get a lockdep spew you see a nice output which also shows call
traces of relevant locks. What if, for example, we could make dump_page()
also dump the traces of where each of it's flags was set or cleared?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

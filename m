Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 0BFAD6B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 17:18:44 -0400 (EDT)
Received: by yhjj63 with SMTP id j63so2081363yhj.9
        for <linux-mm@kvack.org>; Wed, 11 Jul 2012 14:18:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1207111337430.3635@chino.kir.corp.google.com>
References: <1341878153-10757-1-git-send-email-minchan@kernel.org>
	<20120709170856.ca67655a.akpm@linux-foundation.org>
	<20120710002510.GB5935@bbox>
	<alpine.DEB.2.00.1207101756070.684@chino.kir.corp.google.com>
	<20120711022304.GA17425@bbox>
	<alpine.DEB.2.00.1207102223000.26591@chino.kir.corp.google.com>
	<4FFD15B2.6020001@kernel.org>
	<alpine.DEB.2.00.1207111337430.3635@chino.kir.corp.google.com>
Date: Thu, 12 Jul 2012 06:18:43 +0900
Message-ID: <CAEwNFnB1Z92f22ms=EsBEOOY4Q_JRA8rMPUvQmoqik7rt-EgcQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Warn about costly page allocation
From: Minchan Kim <minchan@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu, Jul 12, 2012 at 5:40 AM, David Rientjes <rientjes@google.com> wrote:
> On Wed, 11 Jul 2012, Minchan Kim wrote:
>
>> I agree it's an ideal but the problem is that it's too late.
>> Once product is released, we have to recall all products in the worst case.
>> The fact is that lumpy have helped high order allocation implicitly but we removed it
>> without any notification or information. It's a sort of regression and we can't say
>> them "Please report us if it happens". It's irresponsible, too.
>> IMHO, at least, what we can do is to warn about it before it's too late.
>>
>
> High order allocations that fail should still display a warning message
> when __GFP_NOWARN is not set, so I don't see what this additional warning
> adds.  I don't think it's responsible to ask admins to know what lumpy
> reclaim is, what memory compaction is, or when a system tends to have more
> high order allocations when memory compaction would be helpful.
>
> What we can do, though, is address bug reports as they are reported when
> high order allocations fail and previous kernels are successful.  I
> haven't seen any lately.

Did you read my description?

"
Let's think this scenario.

There is QA team in embedded company and they have tested their product.
In test scenario, they can allocate 100 high order allocation.
(they don't matter how many high order allocations in kernel are needed
during test. their concern is just only working well or fail of their
middleware/application) High order allocation will be serviced well
by natural buddy allocation without lumpy's help. So they released
the product and sold out all over the world.
Unfortunately, in real practice, sometime, 105 high order allocation was
needed rarely and fortunately, lumpy reclaim could help it so the product
doesn't have a problem until now.

If they use latest kernel, they will see the new config CONFIG_COMPACTION
which is very poor documentation, and they can't know it's replacement of
lumpy reclaim(even, they don't know lumpy reclaim) so they simply disable
that option for size optimization. Of course, QA team still test it but they
can't find the problem if they don't do test stronger than old.
It ends up release the product and sold out all over the world, again.
But in this time, we don't have both lumpy and compaction so the problem
would happen in real practice. A poor enginner from Korea have to flight
to the USA for the fix a ton of products. Otherwise, should recall products
from all over the world. Maybe he can lose a job. :(
"
It's not much exaggerated. who should we blame?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

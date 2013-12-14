Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id E55536B0035
	for <linux-mm@kvack.org>; Sat, 14 Dec 2013 00:43:10 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id rp16so3434763pbb.4
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 21:43:10 -0800 (PST)
Date: Fri, 13 Dec 2013 21:44:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 0/3] Change how we determine when to hand out THPs
Message-Id: <20131213214437.6fdbf7f2.akpm@linux-foundation.org>
In-Reply-To: <20131212180037.GA134240@sgi.com>
References: <20131212180037.GA134240@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Benjamin LaHaise <bcrl@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Glauber Costa <glommer@parallels.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On Thu, 12 Dec 2013 12:00:37 -0600 Alex Thorlton <athorlton@sgi.com> wrote:

> This patch changes the way we decide whether or not to give out THPs to
> processes when they fault in pages.

Please cc Andrea on this.

>  The way things are right now,
> touching one byte in a 2M chunk where no pages have been faulted in
> results in a process being handed a 2M hugepage, which, in some cases,
> is undesirable.  The most common issue seems to arise when a process
> uses many cores to work on small portions of an allocated chunk of
> memory.
> 
> Here are some results from a test that I wrote, which allocates memory
> in a way that doesn't benefit from the use of THPs:
> 
> # echo always > /sys/kernel/mm/transparent_hugepage/enabled
> # perf stat -a -r 5 ./thp_pthread -C 0 -m 0 -c 64 -b 128g
> 
>  Performance counter stats for './thp_pthread -C 0 -m 0 -c 64 -b 128g' (5 runs):
> 
>       93.534078104 seconds time elapsed
> ...
>
> 
> # echo never > /sys/kernel/mm/transparent_hugepage/enabled
> # perf stat -a -r 5 ./thp_pthread -C 0 -m 0 -c 64 -b 128g
> 
>  Performance counter stats for './thp_pthread -C 0 -m 0 -c 64 -b 128g' (5 runs):
>
> ...
>       76.467835263 seconds time elapsed
> ...
> 
> As you can see there's a significant performance increase when running
> this test with THP off.

yup.

> My proposed solution to the problem is to allow users to set a
> threshold at which THPs will be handed out.  The idea here is that, when
> a user faults in a page in an area where they would usually be handed a
> THP, we pull 512 pages off the free list, as we would with a regular
> THP, but we only fault in single pages from that chunk, until the user
> has faulted in enough pages to pass the threshold we've set.  Once they
> pass the threshold, we do the necessary work to turn our 512 page chunk
> into a proper THP.  As it stands now, if the user tries to fault in
> pages from different nodes, we completely give up on ever turning a
> particular chunk into a THP, and just fault in the 4K pages as they're
> requested.  We may want to make this tunable in the future (i.e. allow
> them to fault in from only 2 different nodes).

OK.  But all 512 pages reside on the same node, yes?  Whereas with thp
disabled those 512 pages would have resided closer to the CPUs which
instantiated them.  So the expected result will be somewhere in between
the 93 secs and the 76 secs?

That being said, I don't see a downside to the idea, apart from some
additional setup cost in kernel code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

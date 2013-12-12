Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id C1F4D6B0036
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 16:04:35 -0500 (EST)
Received: by mail-ie0-f178.google.com with SMTP id lx4so1545231iec.37
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 13:04:35 -0800 (PST)
Date: Thu, 12 Dec 2013 15:04:32 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [RFC PATCH 2/3] Add tunable to control THP behavior
Message-ID: <20131212210432.GB6034@sgi.com>
References: <cover.1386790423.git.athorlton@sgi.com>
 <20131212180050.GC134240@sgi.com>
 <CALCETrWfFRhjuoK8T9G8hecxsRxFPQ+qA0x7azoof1X5tuxruA@mail.gmail.com>
 <20131212204950.GA6034@sgi.com>
 <CALCETrWgVViOK8mp5wort9T6VWBAAN_MCGmoAGddudsWfr2Ypw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWgVViOK8mp5wort9T6VWBAAN_MCGmoAGddudsWfr2Ypw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Benjamin LaHaise <bcrl@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Glauber Costa <glommer@parallels.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> Right.  I like that behavior for my workload.  (Although I currently
> allocate huge pages -- when I wrote that code, THP interacted so badly
> with pagecache that it was a non-starter.  I think it's fixed now,
> though.)

In that case, it's probably best to just stick with current behavior,
and leave the threshold at 1, unless we implement something like I
discuss below.

> In that case, I guess I misunderstood your description.  Are saying
> that, once any node accesses this many pages in the potential THP,
> then the whole THP will be mapped?

Well, right now, this patch completely gives up on mapping a THP if two
different nodes take a page from our chunk before the threshold is hit,
so I think you're mostly understanding it correctly.

One thing we could consider is adding an option to map the THP on
the node with the *most* references to the potential THP, instead of
giving up on mapping the THP when multiple nodes reference it.  That
might be a good middle ground, but I can see some performance issues
coming into play there if the threshold is set too high, since we'll
have to move all the pages in the chunk to the node that hit the
threshold.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

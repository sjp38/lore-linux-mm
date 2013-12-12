Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 285806B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 15:52:40 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id c9so792750qcz.30
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 12:52:39 -0800 (PST)
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
        by mx.google.com with ESMTPS id ko6si19939758qeb.123.2013.12.12.12.52.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 12:52:39 -0800 (PST)
Received: by mail-qa0-f48.google.com with SMTP id w5so121715qac.7
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 12:52:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131212204950.GA6034@sgi.com>
References: <cover.1386790423.git.athorlton@sgi.com> <20131212180050.GC134240@sgi.com>
 <CALCETrWfFRhjuoK8T9G8hecxsRxFPQ+qA0x7azoof1X5tuxruA@mail.gmail.com> <20131212204950.GA6034@sgi.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 12 Dec 2013 12:52:18 -0800
Message-ID: <CALCETrWgVViOK8mp5wort9T6VWBAAN_MCGmoAGddudsWfr2Ypw@mail.gmail.com>
Subject: Re: [RFC PATCH 2/3] Add tunable to control THP behavior
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Benjamin LaHaise <bcrl@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Glauber Costa <glommer@parallels.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Dec 12, 2013 at 12:49 PM, Alex Thorlton <athorlton@sgi.com> wrote:
>
> > Is there a setting that will turn off the must-be-the-same-node
> > behavior?  There are workloads where TLB matters more than cross-node
> > traffic (or where all the pages are hopelessly shared between nodes,
> > but hugepages are still useful).
>
> That's pretty much how THPs already behave in the kernel, so if you want
> to allow THPs to be handed out to one node, but referenced from many
> others, you'd just set the threshold to 1, and let the existing code
> take over.
>

Right.  I like that behavior for my workload.  (Although I currently
allocate huge pages -- when I wrote that code, THP interacted so badly
with pagecache that it was a non-starter.  I think it's fixed now,
though.)


>
> As for the must-be-the-same-node behavior:  I'd actually say it's more
> like a "must have so much on one node" behavior, in that, if you set the
> threshold to 16, for example, 16 4K pages must be faulted in on the same
> node, in the same contiguous 2M chunk, before a THP will be created.
> What happens after that THP is created is out of our control, it could
> be referenced from anywhere.

In that case, I guess I misunderstood your description.  Are saying
that, once any node accesses this many pages in the potential THP,
then the whole THP will be mapped?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

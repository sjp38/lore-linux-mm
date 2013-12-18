Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9BB656B0036
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:07:08 -0500 (EST)
Received: by mail-ee0-f43.google.com with SMTP id c13so27977eek.30
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 11:07:08 -0800 (PST)
Message-ID: <52B1D814.5000607@redhat.com>
Date: Wed, 18 Dec 2013 12:15:00 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/3] Change how we determine when to hand out THPs
References: <20131212180037.GA134240@sgi.com> <20131213214437.6fdbf7f2.akpm@linux-foundation.org> <20131216171214.GA15663@sgi.com> <20131216175111.GD21218@redhat.com> <20131217162006.GH18680@sgi.com> <20131217175500.GB5441@redhat.com>
In-Reply-To: <20131217175500.GB5441@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Alex Thorlton <athorlton@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Benjamin LaHaise <bcrl@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Glauber Costa <glommer@parallels.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org

On 12/17/2013 12:55 PM, Andrea Arcangeli wrote:

> About creating heuristics to automatically detect the ideal value of
> the big-hammer per-app on/off switch (or even harder the ideal value
> of the per-app threshold), I think it's not going to happen because
> there are too few corner cases and it wouldn't be worth the cost of it
> (the cost would be significant no matter how implemented).
>
> Every time we try to make THP smarter at auto-disabling itself for the
> corner cases, we're slowing it down for everyone that gets a benefit
> from it, and there's no way around it. This is why I think the
> big-hammer prctl for the few corner cases is the best way to go.

There is one thing we could do in a slow path, that
would result in automatic disabling of THP under the
corner case of there not being enough memory in the
system.

We can teach the swapout code to discard zero-filled
pages, instead of swapping them out to disk.

That way we will "deflate" some of the excess memory
consumed by THP, and reduce the extra swap IO that
could be caused by THP using more memory.

Not sure who is interested in this particular corner
case, but it may be an interesting one to solve :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

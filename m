Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id DE20E6B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 00:35:42 -0400 (EDT)
Date: Tue, 23 Jul 2013 00:35:20 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] mm: page_alloc: avoid slowpath for more than
 MAX_ORDER allocation.
Message-ID: <20130723043520.GH715@cmpxchg.org>
References: <1374492762-17735-1-git-send-email-pintu.k@samsung.com>
 <20130722163836.GD715@cmpxchg.org>
 <1374544878.92541.YahooMailNeo@web160102.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374544878.92541.YahooMailNeo@web160102.mail.bf1.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Cc: Pintu Kumar <pintu.k@samsung.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@suse.de" <mgorman@suse.de>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "minchan@kernel.org" <minchan@kernel.org>, "cody@linux.vnet.ibm.com" <cody@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "cpgs@samsung.com" <cpgs@samsung.com>

On Mon, Jul 22, 2013 at 07:01:18PM -0700, PINTU KUMAR wrote:
> >Lastly, order >= MAX_ORDER is not supported by the page allocator, and
> >we do not want to punish 99.999% of all legitimate page allocations in
> >the fast path in order to catch an unlikely situation like this.
[...]
> >Having the check only in the slowpath is a good thing.
> >
> Sorry, I could not understand, why adding this check in slowpath is only good.
> We could have returned failure much before that.
> Without this check, we are actually allowing failure of "first allocation attempt" and then returning the cause of failure in slowpath.
> I thought it will be better to track the unlikely failure in the system as early as possible, at least from the embedded system prospective.
> Let me know your opinion.

This is a trade-off between two cases: we expect (almost) all
allocations to be order < MAX_ORDER, so we want that path as
lightweight as possible.  On the other hand, we expect that only very
rarely an allocation will specify order >= MAX_ORDER.  By doing the
check late, we make the common case faster at the expense of the rare
case.  That's the whole point of having a fast path and a slow path.

What you are proposing would punish 99.999% of all cases in order to
speed up the 0.001% cases.  In addition, these 0.001% of all cases
will fail the allocation, so performance is the least of their
worries.  It's a bad trade-off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 12ED56B0005
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 11:16:58 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id j78so8618980itj.2
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 08:16:58 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id y141si6634042ioy.306.2018.02.26.08.16.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 08:16:56 -0800 (PST)
Date: Mon, 26 Feb 2018 10:16:53 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] Protect larger order pages from breaking up
In-Reply-To: <eedfbd6c-8316-67fe-af60-157d3ee44c34@suse.cz>
Message-ID: <alpine.DEB.2.20.1802261009230.5389@nuc-kabylake>
References: <20180223030346.707128614@linux.com> <20180223030357.048558407@linux.com> <eedfbd6c-8316-67fe-af60-157d3ee44c34@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mel@skynet.ie>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Linux API <linux-api@vger.kernel.org>

On Mon, 26 Feb 2018, Vlastimil Babka wrote:

> > 	echo "3=2000" >/proc/zoneinfo
>
> Huh, that's rather weird interface to use. Writing to a general
> statistics/info file for such specific functionality? Please no.

Ok lets create /proc/sys/kernel/orders?\

Or put it into /sys/devices/syste/node/nodeX/orders

?

> > First performance tests in a virtual enviroment show
> > a hackbench improvement by 6% just by increasing
> > the page size used by the page allocator.
>
> That's IMHO a rather weak justification for introducing a new userspace
> API. What exactly has been set where? Could similar results be achieved
> by tuning highatomic reservers and/or min_free_kbytes? I especially
> wonder how much of the effects come from the associated watermarks
> adjustment (which can be affected by min_free_kbytes) and what is due to
> __rmqueue_smallest() changes. You changed the __rmqueue_smallest()
> condition since RFC per Thomas suggestion, but report the same results?

The highatomic reserves are for temporary allocations for jumbo frames.
The allocations here could be for numerous purposes.

The test demonstrates a performance gain by the user of higher order
pages. It does not demonstrate long term fragmentation results. For that
different benchmarks would have to be used. Maybe I can find something in
Mel's tests to get that tested.

Such test would have to verify that the system holds up despite large
order allocation. It would not demonstrate a performance benefit. However,
what we want is the performance benefit throughout the operation of the
system. So both tests are required.


> Well, also not a fan of this patch, TBH. It's rather ad-hoc and not
> backed up with results. Aside from the above points, I agree with the
> objections of others for the RFC posting. It's also rather awkward that
> watermarks are increased per the reservations, but when the reservations
> are "consumed" (nr_free < min && current_order == order), the increased
> watermarks are untouched. IMHO this further enlarges the effects of
> purely adjusted watermarks by this patch.

This is an RFC to see where we could do with this. I am looking for ways
to address the various shortcomings of this approach. There are others
approaches that have similar effects and that may be more desirable but
require more work (such as making dentries/inodes defragmentable via
migration or targeted reclaim).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

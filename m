Return-Path: <owner-linux-mm@kvack.org>
Date: Wed, 14 Aug 2013 16:58:36 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [RFC 0/3] Pin page control subsystem
In-Reply-To: <20130814164705.GD2706@gmail.com>
Message-ID: <000001407dc3c33b-4139d615-aecc-4745-a9b4-c84949f6a8f4-000000@email.amazonses.com>
References: <1376377502-28207-1-git-send-email-minchan@kernel.org> <00000140787b6191-ae3f2eb1-515e-48a1-8e64-502772af4700-000000@email.amazonses.com> <20130814001236.GC2271@bbox> <000001407dafbe92-7b2b4006-2225-4f0b-b23b-d66101a995aa-000000@email.amazonses.com>
 <20130814164705.GD2706@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, k.kozlowski@samsung.com, Seth Jennings <sjenning@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, guz.fnst@cn.fujitsu.com, Benjamin LaHaise <bcrl@kvack.org>, Dave Hansen <dave.hansen@intel.com>, lliubbo@gmail.com, aquini@redhat.com, Rik van Riel <riel@redhat.com>

On Thu, 15 Aug 2013, Minchan Kim wrote:

> When I look API of mmu_notifier, it has mm_struct so I guess it works
> for only user process. Right?

Correct. A process must have mapped the pages. If you can get a
kernel "process" to work then that process could map the pages.

> If so, I need to register it without user conext because zram, zswap
> and zcache works for only kernel side.

Hmmm... Ok but that now gets the complexity of page pinnning up to a very
weird level. Is there some way we can have a common way to deal with the
various ways that pinning is needed? Just off the top of my head (I may
miss some use cases) we have

1. mlock from user space
2. page pinning for reclaim
3. Page pinning for I/O from device drivers (like f.e. the RDMA subsystem)
4. Page pinning for low latency operations
5. Page pinning for migration
6. Page pinning for the perf buffers.
7. Page pinning for cross system access (XPMEM, GRU SGI)

Now we have another subsystem wanting different semantics of pinning. Is
there any way we can come up with a pinning mechanism that fits all use
cases, that is easyly understandable and maintainable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

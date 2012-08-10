Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 6D46B6B002B
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 10:12:42 -0400 (EDT)
Date: Fri, 10 Aug 2012 09:12:25 -0500 (CDT)
From: "Christoph Lameter (Open Source)" <cl@linux.com>
Subject: Re: [RFC PATCH] mm: introduce N_LRU_MEMORY to distinguish between
 normal and movable memory
In-Reply-To: <5024CADC.1010202@huawei.com>
Message-ID: <alpine.DEB.2.02.1208100909410.3903@greybox.home>
References: <1344482788-4984-1-git-send-email-guohanjun@huawei.com> <50233EF5.3050605@huawei.com> <alpine.DEB.2.02.1208090900450.15909@greybox.home> <5024CADC.1010202@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hanjun Guo <guohanjun@huawei.com>
Cc: Wu Jianguo <wujianguo@huawei.com>, Jiang Liu <jiang.liu@huawei.com>, Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

On Fri, 10 Aug 2012, Hanjun Guo wrote:

> On 2012/8/9 22:06, Christoph Lameter (Open Source) wrote:
> > On Thu, 9 Aug 2012, Hanjun Guo wrote:
> >
> >> Now, We have node masks for both N_NORMAL_MEMORY and
> >> N_HIGH_MEMORY to distinguish between normal and highmem on platforms such as x86.
> >> But we still don't have such a mechanism to distinguish between "normal" and "movable"
> >> memory.
> >
> > What is the exact difference that you want to establish?
>
> Hi Christoph,
>     Thanks for your comments very much!
>
> We want to identify the node only has ZONE_MOVABLE memory.
> for example:
> 	node 0: ZONE_DMA, ZONE_DMA32, ZONE_NORMAL--> N_LRU_MEMORY, N_NORMAL_MEMORY
> 	node 1: ZONE_MOVABLE			 --> N_LRU_MEMORY
> thus, in SLUB allocator, will not allocate memory control structures for node1.

So this would change the N_NORMAL_MEMORY definition so that N_NORMAL
means !LRU allocs possible? So far N_NORMAL_MEMORY has a wider scope of
meaning. We need an accurate definition of the meaning of all these
attributes.

> > For the slab case that you want to solve here you will need to know if the
> > node has *only* movable memory and will never have any ZONE_NORMAL memory.
> > If so then memory control structures for allocators that do not allow
> > movable memory will not need to be allocated for these node. The node can
> > be excluded from handling.
>
> I think this is what we are trying to do in this patch.
> did I miss something?

THe meaning of ZONE_NORMAL seems to change which causes confusion. Please
describe in detail what each of these attributes mean.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

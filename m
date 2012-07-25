Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 745946B004D
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 11:31:56 -0400 (EDT)
Date: Wed, 25 Jul 2012 10:31:51 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH v2] SLUB: enhance slub to handle memory nodes without
 normal memory
In-Reply-To: <500ED4B5.4010104@gmail.com>
Message-ID: <alpine.DEB.2.00.1207251029190.32678@router.home>
References: <alpine.DEB.2.00.1207181349370.22907@router.home> <1343123710-4972-1-git-send-email-jiang.liu@huawei.com> <alpine.DEB.2.00.1207240931560.29808@router.home> <500ED4B5.4010104@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, WuJianguo <wujianguo@huawei.com>, Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 25 Jul 2012, Jiang Liu wrote:

> > There is already a N_NORMAL_MEMORY node map that contains a list of node
> > that have *normal* memory usable by slab allocators etc. I think the
> > cleanest solution would be to clear the corresponding node bits for your
> > special movable only zones. Then you wont be needing to modify other
> > subsystems anymore.
> >
> Hi Chris,
> 	Thanks for your comments! I have thought about the solution mentioned,
> but seems it doesn't work. We have node masks for both N_NORMAL_MEMORY and
> N_HIGH_MEMORY to distinguish between normal and highmem on platforms such as x86.
> But we still don't have such a mechanism to distinguish between "normal" and "movable"
> memory. So for memory nodes with only movable zones, we still set N_NORMAL_MEMORY for
> them. One possible solution is to add a node mask for "N_NORMAL_OR_MOVABLE_MEMORY",
> but haven't tried that yet. Will have a try for that.

Hmmm... Maybe add another N_LRU_MEMORY bitmask and replace those
N_NORMAL_MEMORY uses with N_LRU_MEMORY as needed? Use N_NORMAL_MEMORY for
subsystems that need to do regular (non LRU) allocations that are not
movable?
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

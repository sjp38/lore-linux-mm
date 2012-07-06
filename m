Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id E6D586B0074
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 04:43:30 -0400 (EDT)
Message-ID: <4FF6A21C.9010509@huawei.com>
Date: Fri, 6 Jul 2012 16:30:20 +0800
From: Jiang Liu <jiang.liu@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 2/4] mm: make consistent use of PG_slab flag
References: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com> <1341287837-7904-2-git-send-email-jiang.liu@huawei.com> <alpine.DEB.2.00.1207050945310.4984@router.home> <4FF5BD9D.9040101@gmail.com> <alpine.DEB.2.00.1207051236310.8670@router.home>
In-Reply-To: <alpine.DEB.2.00.1207051236310.8670@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jiang Liu <liuj97@gmail.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2012-7-6 1:37, Christoph Lameter wrote:
>> Hi Chris,
>> 	I think there's a little difference with SLUB and SLOB for compound page.
>> For SLOB, it relies on the page allocator to allocate compound page to fulfill
>> request bigger than one page. For SLUB, it relies on the page allocator if the
>> request is bigger than two pages. So SLUB may allocate a 2-pages compound page
>> to host SLUB managed objects.
>> 	My proposal may be summarized as below:
>> 	1) PG_slab flag marks a memory object is allocated from slab allocator.
>> 	2) PG_slabobject marks a (compound) page hosts SLUB/SLOB managed objects.
>> 	3) Only set PG_slab/PG_slabobject on the head page of compound pages.
>> 	4) For SLAB, PG_slabobject is redundant and so not used.
>>
>> 	A summary of proposed usage of PG_slab(S) and PG_slabobject(O) with
>> SLAB/SLUB/SLOB allocators as below:
>> pagesize	SLAB			SLUB			SLOB
>> 1page		S			S,O			S,O
>> 2page		S			S,O			S
>>> =4page		S			S			S
> 
> There is no point of recognizing such objects because those will be
> kmalloc objects and they can only be freed in a subsystem specific way.
> There is no standard way to even figure out which subsystem allocated
> them. So for all practical purposes those are unrecoverable.

Hi Chris,
	This patch is not for hotplug, but is to fix some issues in current
kernel, such as:
	1) make show_mem() on ARM and unicore32 report consistent information
no matter which slab allocator is used.
	2) make /proc/kpagecount and /proc/kpageflags return accurate information.
	3) Get rid of risks in mm/memory_failure.c and arch/ia64/kernel/mca_drv.c
	Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

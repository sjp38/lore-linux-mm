Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D0F6D6B024D
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 01:48:07 -0400 (EDT)
Date: Thu, 22 Jul 2010 14:43:56 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 1/2][memcg] moving memcg's node info array to
 virtually contiguous array
Message-Id: <20100722144356.b9681621.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100721195831.6aa8dca5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100721195831.6aa8dca5.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jul 2010 19:58:31 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> These are just a _toy_ level patches yet. My final purpose is to use indexed array
> for mem_cgroup itself, it has IDs.
> 
> Background:
>   memory cgroup uses struct page_cgroup for tracking all used pages. It's defined as
> ==
> struct page_cgroup {
>         unsigned long flags;
>         struct mem_cgroup *mem_cgroup;
>         struct page *page;
>         struct list_head lru;           /* per cgroup LRU list */
> };
> ==
>   and this increase the cost of per-page-objects dramatically. Now, we have
>   troubles on this object.
>   1.  Recently, a blkio-tracking guy wants to add "blockio-cgroup" information
>       to page_cgroup. But our concern is extra 8bytes per page.
>   2.  At tracking dirty page status etc...we need some trick for safe access
>       to page_cgroup and memcgroup's information. For example, a small seqlock.
> 
> Now, each memory cgroup has its own ID (0-65535). So, if we can replace
> 8byte of pointer "pc->mem_cgroup" with an ID, which is 2 bytes, we may able
> to have another room. (Moreover, I think we can reduce the number of IDs...)
> 
> This patch is a trial for implement a virually-indexed on-demand array and
> an example of usage. Any commetns are welcome.
> 
So, your purpose is to:

- make the size of mem_croup small(by [2/2])
- manage all the mem_cgroup in virt-array indexed by its ID(it would be faster
  than using css_lookup)
- replace pc->mem_cgroup by its ID and make the size of page_cgroup small

right?

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

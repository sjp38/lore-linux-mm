Date: Mon, 25 Feb 2008 15:52:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] radix-tree based page_cgroup. [6/7] radix-tree
 based page cgroup
Message-Id: <20080225155211.f21fb44d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080225.154051.90170566.taka@valinux.co.jp>
References: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
	<20080225121744.a90704fb.kamezawa.hiroyu@jp.fujitsu.com>
	<20080225.154051.90170566.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, hugh@veritas.com, yamamoto@valinux.co.jp, ak@suse.de, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2008 15:40:51 +0900 (JST)
Hirokazu Takahashi <taka@valinux.co.jp> wrote:

> Hi,
> 
> I looked into the code a bit and I have some comments.
> 
> > Each radix-tree entry contains base address of array of page_cgroup.
> > As sparsemem does, this registered base address is subtracted by base_pfn
> > for that entry. See sparsemem's logic if unsure.
> > 
> > Signed-off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
>   (snip)
> 
> > +#define PCGRP_SHIFT	(8)
> > +#define PCGRP_SIZE	(1 << PCGRP_SHIFT)
> 
> I wonder where the value of PCGRP_SHIFT comes from.
> 
On 32bit systems, (I think 64bit should use vmalloc),
this order comes from sizeof(struct page_cgroup) * 2^8  <= 8192 ,  2 pages.


>   (snip)
> 
> > +static struct page_cgroup *alloc_init_page_cgroup(unsigned long pfn, int nid,
> > +					gfp_t mask)
> > +{
> > +	int size, order;
> > +	struct page *page;
> > +
> > +	size = PCGRP_SIZE * sizeof(struct page_cgroup);
> > +	order = get_order(PAGE_ALIGN(size));
> 
> I wonder if this alignment will waste some memory.
> 
Maybe. 

> > +	page = alloc_pages_node(nid, mask, order);
> 
> I think you should make "order" be 0 not to cause extra memory pressure
> if possible.
> 
Hmm, and increase depth of radix-tree ? 
But ok, starting from safe code is better. will make this order to be 0
and see what happens.

Thanks
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

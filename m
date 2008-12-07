Date: Sun, 7 Dec 2008 00:31:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [memcg BUG ?] failed to boot on IA64 with CONFIG_DISCONTIGMEM=y
Message-Id: <20081207003138.2651f14b.akpm@linux-foundation.org>
In-Reply-To: <20081205122458.a37ae8e0.kamezawa.hiroyu@jp.fujitsu.com>
References: <49389B69.9010902@cn.fujitsu.com>
	<20081205122024.3fcc1d0e.kamezawa.hiroyu@jp.fujitsu.com>
	<20081205122458.a37ae8e0.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 5 Dec 2008 12:24:58 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri, 5 Dec 2008 12:20:24 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Fri, 05 Dec 2008 11:09:29 +0800
> > Li Zefan <lizf@cn.fujitsu.com> wrote:
> > 
> > > Kernel version: 2.6.28-rc7
> > > Arch: IA64
> > > Memory model: DISCONTIGMEM
> > > 
> > > ELILO boot: Uncompressing Linux... done
> > > Loading file initrd-2.6.28-rc7-lizf.img...done
> > > (frozen)
> > > 
> > > 
> > > Booted successfully with cgroup_disable=memory, here is the dmesg:
> > > 
> > 
> > thx, will dig into...Maybe you're the first person using DISCONTIGMEM with
> > empty_node after page_cgroup-alloc-at-boot.
> > 
> > How about this ?
> 
> Ahhh..sorry.
> 
> this one please.
> ==
> 
> From: kamezawa.hiroyu@jp.fujitsu.com
> 
> page_cgroup should ignore empty-nodes.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  mm/page_cgroup.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> Index: mmotm-2.6.28-Dec03/mm/page_cgroup.c
> ===================================================================
> --- mmotm-2.6.28-Dec03.orig/mm/page_cgroup.c
> +++ mmotm-2.6.28-Dec03/mm/page_cgroup.c
> @@ -51,6 +51,9 @@ static int __init alloc_node_page_cgroup
>  	start_pfn = NODE_DATA(nid)->node_start_pfn;
>  	nr_pages = NODE_DATA(nid)->node_spanned_pages;
>  
> +	if (!nr_pages)
> +		return 0;
> +
>  	table_size = sizeof(struct page_cgroup) * nr_pages;
>  
>  	base = __alloc_bootmem_node_nopanic(NODE_DATA(nid),

Why did the kernel fail?

Either __alloc_bootmem_node_nopanic() succeeds, in which case the code
looks like it handles that OK.

Or __alloc_bootmem_node_nopanic() fails this zero-sized allocation, and
the code attempts to handle that, but fails to do so, which might be a
bug, and the above patch just papers over it.

Of course, a full description of the problem will clear all this up.
Better changelogs, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

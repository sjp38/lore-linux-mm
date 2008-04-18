Date: Fri, 18 Apr 2008 15:47:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcgroup: check and initialize page->cgroup in
 memmap_init_zone
Message-Id: <20080418154753.6a28a910.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48083506.7080909@cn.fujitsu.com>
References: <48080706.50305@cn.fujitsu.com>
	<48080930.5090905@cn.fujitsu.com>
	<48080B86.7040200@cn.fujitsu.com>
	<20080417201432.36b1c326.akpm@linux-foundation.org>
	<20080418123256.da4d1db0.kamezawa.hiroyu@jp.fujitsu.com>
	<20080418140946.e265c1f3.kamezawa.hiroyu@jp.fujitsu.com>
	<48083506.7080909@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shi Weihua <shiwh@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, balbir@linux.vnet.ibm.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 18 Apr 2008 13:43:34 +0800
Shi Weihua <shiwh@cn.fujitsu.com> wrote:

> KAMEZAWA Hiroyuki wrote::
> > On Fri, 18 Apr 2008 12:32:56 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> >>> Or perhaps that page was used and then later freed before we got to
> >>> memmap_init_zone() and was freed with a non-zero ->page_cgroup.  Which is
> >>> unlikely given that page.page_cgroup was only just added and is only
> >>> present if CONFIG_CGROUP_MEM_RES_CTLR.
> >>>
> >> Hmm, I'll try his .config and see what happens.
> >>
> > I reproduced the hang with his config and confirmed his fix works well.
> > But I can't find why...I'll dig a bit more.
> 
> If i use CONFIG_SPARSEMEM instead of CONFIG_DISCONTIGMEM, the kernel 
> boots successfully.
> 
AKAICT,
 CONFIG_DISCONTIGMEM      + 64KB page -> hang --------------(*)
 CONFIG_SPRASEMEM_VMEMMAP + 64KB page -> works well
 CONFIG_DISCONTIGMEM      + 16KB page -> works well
 CONFIG_SPARSEMEM_VMEMMAP + 16KB page -> works well

 CONFIG_DISCONTIGMEM + 64KB page + your patch -> works well

Hmm. maybe memmap(and all possible bootmem) isn't cleared well
in case (*). still chasing it.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

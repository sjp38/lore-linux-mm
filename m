Date: Tue, 11 Mar 2008 13:05:44 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] Move memory controller allocations to their own slabs
 (v2)
In-Reply-To: <47D66865.1080508@linux.vnet.ibm.com>
Message-ID: <Pine.LNX.4.64.0803111256110.18261@blonde.site>
References: <20080311061836.6664.5072.sendpatchset@localhost.localdomain>
 <47D63E9D.70500@openvz.org> <47D63FB1.7040502@linux.vnet.ibm.com>
 <47D6443D.9000904@openvz.org> <47D66865.1080508@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Mar 2008, Balbir Singh wrote:
> 
> On my 64 bit powerpc system (structure size could be different on other systems)
> 
> 1. sizeof page_cgroup is 40 bytes
>    which means kmalloc will allocate 64 bytes
> 2. With 4K pagesize SLAB with HWCACHE_ALIGN, 59 objects are packed per slab
> 3. With SLUB the value is 102 per slab

I expect you got those numbers with 2.6.25-rc4?  Towards the end of -rc5
there's a patch from Nick to make SLUB's treatment of HWCACHE_ALIGN the
same as SLAB's, so I expect you'd be back to a similar poor density with
SLUB too.  (But I'm replying without actually testing it out myself.)

I think you'd need a strong reason to choose HWCACHE_ALIGN for these.

Consider: the (normal configuration) x86_64 struct page size was 56
bytes for a long time (and still is without MEM_RES_CTLR), but we've
never inserted padding to make that a round 64 bytes (and they would
benefit additionally from some simpler arithmetic, not the case with
page_cgroups).  Though it's good to avoid unnecessary sharing and
multiple cacheline accesses, it's not so good as to justify almost
doubling the size of a very very common structure.  I think.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 18 Nov 2008 12:48:52 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH mmotm] memcg: unmap KM_USER0 at shmem_map_and_free_swp
 if do_swap_account
In-Reply-To: <20081118210838.c99887fd.nishimura@mxp.nes.nec.co.jp>
Message-ID: <Pine.LNX.4.64.0811181234430.9680@blonde.site>
References: <20081118180721.cb2fe744.nishimura@mxp.nes.nec.co.jp>
 <20081118182637.97ae0e48.kamezawa.hiroyu@jp.fujitsu.com>
 <20081118192135.300803ec.nishimura@mxp.nes.nec.co.jp>
 <20081118210838.c99887fd.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelianov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Nov 2008, Daisuke Nishimura wrote:

> memswap controller uses KM_USER0 at swap_cgroup_record and lookup_swap_cgroup.
> 
> But delete_from_swap_cache, which eventually calls swap_cgroup_record, can be
> called with KM_USER0 mapped in case of shmem.
> 
> So it should be unmapped before calling it.

Excellent find, but ...

> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
> After this patch, I think memswap controller of x86_32 will be
> on near level with that of x86_64.
> 
>  mm/shmem.c |   23 +++++++++++++++++++++++
>  1 files changed, 23 insertions(+), 0 deletions(-)

... sorry, no, please don't go around unmapping other people's kmaps
like this.  If the memswap controller needs its own kmap_atomic()s at
a level below other users, then it needs to define a new KM_MEMSWAP
in arch/*/include/asm/kmap_types.h and include/asm-*/kmap_types.h.

That's a lot of files which you may not wish to update to get working
right now: I think page_cgroup.c can _probably_ reuse KM_PTE1 as a
temporary measure, but please verify that's safe first.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

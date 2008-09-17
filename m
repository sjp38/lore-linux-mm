Date: Wed, 17 Sep 2008 18:18:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mm] memcg: fix handling of shmem migration(v2)
Message-Id: <20080917181845.ca72a8e3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080917165544.3873bbb2.nishimura@mxp.nes.nec.co.jp>
References: <20080917133149.b012a1c2.nishimura@mxp.nes.nec.co.jp>
	<20080917144659.2e363edc.kamezawa.hiroyu@jp.fujitsu.com>
	<20080917145003.fb4d0b95.kamezawa.hiroyu@jp.fujitsu.com>
	<20080917151951.9a181e7d.nishimura@mxp.nes.nec.co.jp>
	<20080917153826.8efbdc4b.kamezawa.hiroyu@jp.fujitsu.com>
	<20080917154511.683691d1.nishimura@mxp.nes.nec.co.jp>
	<20080917165544.3873bbb2.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Sep 2008 16:55:44 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Before this patch, if migrating shmem/tmpfs pages, newpage would be
> charged with PAGE_CGROUP_FLAG_FILE set, while oldpage has been charged
> without the flag.
> 
> The problem here is mem_cgroup_move_lists doesn't clear(or set)
> the PAGE_CGROUP_FLAG_FILE flag, so pc->flags of the newpage
> remains PAGE_CGROUP_FLAG_FILE set even when the pc is moved to
> another lru(anon) by mem_cgroup_move_lists. And this leads to
> incorrect MEM_CGROUP_ZSTAT.
> (In my test, I see an underflow of MEM_CGROUP_ZSTAT(active_file).
> As a result, mem_cgroup_calc_reclaim returns very huge number and
> causes soft lockup on page reclaim.)
> 
> I'm not sure if mem_cgroup_move_lists should handle PAGE_CGROUP_FLAG_FILE
> or not(I suppose it should be used to move between active <-> inactive,
> not anon <-> file), I added MEM_CGROUP_CHARGE_TYPE_SHMEM for precharge
> at shmem's page migration.
> 
> 
> ChangeLog: v1->v2
> - instead of modifying migrate.c, modify memcontrol.c only.
> - add MEM_CGROUP_CHARGE_TYPE_SHMEM.
> 
I'll fix mem_cgroup_charge_cache_page() to use TYPE_SHMEM later.
Thank you.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

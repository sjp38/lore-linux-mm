Date: Wed, 1 Oct 2008 15:17:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 9/12] memcg allocate all page_cgroup at boot
Message-Id: <20081001151734.7e241903.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48E311A8.3000802@linux.vnet.ibm.com>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
	<20080925153206.281243dc.kamezawa.hiroyu@jp.fujitsu.com>
	<48E2F6A9.9010607@linux.vnet.ibm.com>
	<20081001140748.637b9831.kamezawa.hiroyu@jp.fujitsu.com>
	<20081001143242.1b44de24.kamezawa.hiroyu@jp.fujitsu.com>
	<48E311A8.3000802@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Wed, 01 Oct 2008 11:29:04 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > __mem_cgroup_move_lists() will have some amount of changes. And we should
> > check dead lock again.
> 
> __mem_cgroup_move_lists() is called from mem_cgroup_isolate_pages() and
> mem_cgroup_move_lists(). In mem_cgroup_move_lists(), we have the page_cgroup
> lock. I think the current code works on the assumption (although not documented
> anywhere I've seen), that PAGE_CGROUP_FLAG_INACTIVE/ACTIVE/UNEVICTABLE bits are
> protected by lru_lock. Please look at
yes, I wrote them.

> 
> __mem_cgroup_remove_list
> __mem_cgroup_add_list
> __mem_cgroup_move_lists
> __mem_cgroup_charge_common (sets this flag, before the pc is associated with the
> page).
> 
But my point is lru_lock doesn't means page_cgroup is not locked by someone and
we must take always lock_page_cgroup() when we modify flags.

Then, mem_cgroup_isolate_page() should have to take lock.
But this means we have to care preemption for avoiding deadlock.
Maybe need some time to test.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

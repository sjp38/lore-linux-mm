Date: Fri, 28 Nov 2008 18:02:52 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC][PATCH -mmotm 0/2] misc patches for memory cgroup hierarchy
Message-Id: <20081128180252.b7a73c86.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

Hi.

I'm writing some patches for memory cgroup hierarchy.

I think KAMEZAWA-san's cgroup-id patches are the most important pathes now,
but I post these patches as RFC before going further.

Patch descriptions:
- [1/2] take account of memsw
    mem_cgroup_hierarchical_reclaim checks only mem->res now.
    It should also check mem->memsw when do_swap_account.
- [2/2] avoid oom
    In previous implementation, mem_cgroup_try_charge checked the return
    value of mem_cgroup_try_to_free_pages, and just retried if some pages
    had been reclaimed.
    But now, try_charge(and mem_cgroup_hierarchical_reclaim called from it)
    only checks whether the usage is less than the limit.
    I see oom easily in some tests which didn't cause oom before.

Both patches are for memory-cgroup-hierarchical-reclaim-v4 patch series.

My current plan for memory cgroup hierarchy:
- If hierarchy is enabled, limit of child should not exceed that of parent.
- Change other calls for mem_cgroup_try_to_free_page() to
  mem_cgroup_hierarchical_reclaim() if possible.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB5DRCPG006525
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 5 Dec 2008 22:27:12 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 57DE245DE4E
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 22:27:12 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D23D45DD72
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 22:27:12 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 240BA1DB803A
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 22:27:12 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CFF321DB803F
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 22:27:11 +0900 (JST)
Message-ID: <57801.10.75.179.61.1228483630.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20081205212450.574f498c.nishimura@mxp.nes.nec.co.jp>
References: <20081205212208.31d904e0.nishimura@mxp.nes.nec.co.jp>
    <20081205212450.574f498c.nishimura@mxp.nes.nec.co.jp>
Date: Fri, 5 Dec 2008 22:27:10 +0900 (JST)
Subject: Re: [RFC][PATCH -mmotm 3/4] memcg: avoid dead lock caused by
     racebetween oom and cpuset_attach
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura said:
> mpol_rebind_mm(), which can be called from cpuset_attach(), does
> down_write(mm->mmap_sem).
> This means down_write(mm->mmap_sem) can be called under cgroup_mutex.
>
> OTOH, page fault path does down_read(mm->mmap_sem) and calls
> mem_cgroup_try_charge_xxx(),
> which may eventually calls mem_cgroup_out_of_memory(). And
> mem_cgroup_out_of_memory()
> calls cgroup_lock().
> This means cgroup_lock() can be called under down_read(mm->mmap_sem).
>
good catch.

> If those two paths race, dead lock can happen.
>
> This patch avoid this dead lock by:
>   - remove cgroup_lock() from mem_cgroup_out_of_memory().
agree to this.

>   - define new mutex (memcg_tasklist) and serialize mem_cgroup_move_task()
>     (->attach handler of memory cgroup) and mem_cgroup_out_of_memory.
>
Hmm...seems temporal fix (and adding new global lock...)
But ok, we need fix. revist this later.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu,com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

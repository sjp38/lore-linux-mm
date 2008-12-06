Date: Sat, 6 Dec 2008 12:35:03 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [RFC][PATCH -mmotm 3/4] memcg: avoid dead lock caused by
 racebetween oom and cpuset_attach
Message-Id: <20081206123503.4e32c3fb.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <57801.10.75.179.61.1228483630.squirrel@webmail-b.css.fujitsu.com>
References: <20081205212208.31d904e0.nishimura@mxp.nes.nec.co.jp>
	<20081205212450.574f498c.nishimura@mxp.nes.nec.co.jp>
	<57801.10.75.179.61.1228483630.squirrel@webmail-b.css.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, d-nishimura@mtf.biglobe.ne.jp, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 5 Dec 2008 22:27:10 +0900 (JST)
"KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Daisuke Nishimura said:
> > mpol_rebind_mm(), which can be called from cpuset_attach(), does
> > down_write(mm->mmap_sem).
> > This means down_write(mm->mmap_sem) can be called under cgroup_mutex.
> >
> > OTOH, page fault path does down_read(mm->mmap_sem) and calls
> > mem_cgroup_try_charge_xxx(),
> > which may eventually calls mem_cgroup_out_of_memory(). And
> > mem_cgroup_out_of_memory()
> > calls cgroup_lock().
> > This means cgroup_lock() can be called under down_read(mm->mmap_sem).
> >
> good catch.
> 
Thanks.

> > If those two paths race, dead lock can happen.
> >
> > This patch avoid this dead lock by:
> >   - remove cgroup_lock() from mem_cgroup_out_of_memory().
> agree to this.
> 
> >   - define new mutex (memcg_tasklist) and serialize mem_cgroup_move_task()
> >     (->attach handler of memory cgroup) and mem_cgroup_out_of_memory.
> >
> Hmm...seems temporal fix (and adding new global lock...)
> But ok, we need fix. revist this later.
> 
I agree.

> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu,com>
> 
Thank you.


Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

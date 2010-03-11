Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 26C016B00FE
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 18:50:02 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2BNo0gF006220
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Mar 2010 08:50:00 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D626245DE53
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 08:49:59 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AE15E45DE51
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 08:49:59 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 870371DB8043
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 08:49:59 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 265111DB805B
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 08:49:56 +0900 (JST)
Date: Fri, 12 Mar 2010 08:46:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH mmotm 2.5/4] memcg: disable irq at page cgroup lock (Re:
 [PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
 infrastructure)
Message-Id: <20100312084614.a79f9ffd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100311165413.GD29246@redhat.com>
References: <20100308170711.4d8b02f0.nishimura@mxp.nes.nec.co.jp>
	<20100308173100.b5997fd4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100309001252.GB13490@linux>
	<20100309091914.4b5f6661.kamezawa.hiroyu@jp.fujitsu.com>
	<20100309102928.9f36d2bb.nishimura@mxp.nes.nec.co.jp>
	<20100309045058.GX3073@balbir.in.ibm.com>
	<20100310104309.c5f9c9a9.nishimura@mxp.nes.nec.co.jp>
	<20100310035624.GP3073@balbir.in.ibm.com>
	<20100311133123.ab10183c.nishimura@mxp.nes.nec.co.jp>
	<20100311134908.48d8b0fc.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311165413.GD29246@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, balbir@linux.vnet.ibm.com, linux-mm@kvack.org, Andrea Righi <arighi@develer.com>, linux-kernel@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Mar 2010 11:54:13 -0500
Vivek Goyal <vgoyal@redhat.com> wrote:

> On Thu, Mar 11, 2010 at 01:49:08PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu, 11 Mar 2010 13:31:23 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > On Wed, 10 Mar 2010 09:26:24 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2010-03-10 10:43:09]:
> > 
> > > I made a patch(attached) using both local_irq_disable/enable and local_irq_save/restore.
> > > local_irq_save/restore is used only in mem_cgroup_update_file_mapped.
> > > 
> > > And I attached a histogram graph of 30 times kernel build in root cgroup for each.
> > > 
> > >   before_root: no irq operation(original)
> > >   after_root: local_irq_disable/enable for all
> > >   after2_root: local_irq_save/restore for all
> > >   after3_root: mixed version(attached)
> > > 
> > > hmm, there seems to be a tendency that before < after < after3 < after2 ?
> > > Should I replace save/restore version to mixed version ?
> > > 
> > 
> > IMHO, starting from after2_root version is the easist.
> > If there is a chance to call lock/unlock page_cgroup can be called in
> > interrupt context, we _have to_ disable IRQ, anyway.
> > And if we have to do this, I prefer migration_lock rather than this mixture.
> > 
> > BTW, how big your system is ? Balbir-san's concern is for bigger machines.
> > But I'm not sure this change is affecte by the size of machines.
> > I'm sorry I have no big machine, now.
> 
> FWIW, I took andrea's patches (local_irq_save/restore solution) and
> compiled the kernel on 32 cores hyperthreaded (64 cpus) with make -j32
> in /dev/shm/. On this system, I can't see much difference.
> 
> I compiled the kernel 10 times and took average.
> 
> Without andrea's patches: 28.698 (seconds)
> With andrea's patches: 28.711 (seconds).
> Diff is .04%
> 
> This is all should be in root cgroup. Note, I have not mounted memory cgroup
> controller but it is compiled in. So I am assuming that root group
> accounting will still be taking place. Also assuming that it is not
> required to do actual IO to disk and /dev/shm is enough to see the results
> of local_irq_save()/restore.
> 

Thank you!. Hmm.then, irq_xxxx is not core of problem. The overhead problem
is using spinlock or not... 

Regards,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

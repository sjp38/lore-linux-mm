Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9842A6B009D
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 23:53:08 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2B4r6OP024713
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 11 Mar 2010 13:53:06 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E9DE545DE4D
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 13:53:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B875A45DE50
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 13:53:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 94CE81DB8047
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 13:53:05 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 44B411DB803A
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 13:53:05 +0900 (JST)
Date: Thu, 11 Mar 2010 13:49:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH mmotm 2.5/4] memcg: disable irq at page cgroup lock (Re:
 [PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
 infrastructure)
Message-Id: <20100311134908.48d8b0fc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100311133123.ab10183c.nishimura@mxp.nes.nec.co.jp>
References: <20100308105641.e2e714f4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308111724.3e48aee3.nishimura@mxp.nes.nec.co.jp>
	<20100308113711.d7a249da.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308170711.4d8b02f0.nishimura@mxp.nes.nec.co.jp>
	<20100308173100.b5997fd4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100309001252.GB13490@linux>
	<20100309091914.4b5f6661.kamezawa.hiroyu@jp.fujitsu.com>
	<20100309102928.9f36d2bb.nishimura@mxp.nes.nec.co.jp>
	<20100309045058.GX3073@balbir.in.ibm.com>
	<20100310104309.c5f9c9a9.nishimura@mxp.nes.nec.co.jp>
	<20100310035624.GP3073@balbir.in.ibm.com>
	<20100311133123.ab10183c.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, Andrea Righi <arighi@develer.com>, linux-kernel@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, Vivek Goyal <vgoyal@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 11 Mar 2010 13:31:23 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Wed, 10 Mar 2010 09:26:24 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2010-03-10 10:43:09]:

> I made a patch(attached) using both local_irq_disable/enable and local_irq_save/restore.
> local_irq_save/restore is used only in mem_cgroup_update_file_mapped.
> 
> And I attached a histogram graph of 30 times kernel build in root cgroup for each.
> 
>   before_root: no irq operation(original)
>   after_root: local_irq_disable/enable for all
>   after2_root: local_irq_save/restore for all
>   after3_root: mixed version(attached)
> 
> hmm, there seems to be a tendency that before < after < after3 < after2 ?
> Should I replace save/restore version to mixed version ?
> 

IMHO, starting from after2_root version is the easist.
If there is a chance to call lock/unlock page_cgroup can be called in
interrupt context, we _have to_ disable IRQ, anyway.
And if we have to do this, I prefer migration_lock rather than this mixture.

BTW, how big your system is ? Balbir-san's concern is for bigger machines.
But I'm not sure this change is affecte by the size of machines.
I'm sorry I have no big machine, now.

I'll consider yet another fix for race in account migration if I can.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

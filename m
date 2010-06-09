Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 297C76B01CC
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 01:18:23 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o595IJr1018109
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 9 Jun 2010 14:18:20 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6178845DE55
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 14:18:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 35F5045DE4F
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 14:18:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 203A51DB8017
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 14:18:19 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C358F1DB8012
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 14:18:18 +0900 (JST)
Date: Wed, 9 Jun 2010 14:14:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg remove css_get/put per pages
Message-Id: <20100609141401.ecdad9f1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100609094734.cbb744aa.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100608121901.3cab9bdf.kamezawa.hiroyu@jp.fujitsu.com>
	<20100608054003.GY4603@balbir.in.ibm.com>
	<20100609094734.cbb744aa.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 9 Jun 2010 09:47:34 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > Looks nice, Kamezawa-San could you please confirm the source of
> > raw_spin_lock_irqsave and trylock from /proc/lock_stat?
> >  
> Sure. But above result can be got when lockdep etc..are off.
> (it increase lock overhead)
> 
> But yes, new _raw_spin_lock seems strange.
> 
Here.
==
         ------------------------------
          &(&mm->page_table_lock)->rlock       20812995          [<ffffffff81124019>] handle_mm_fault+0x7a9/0x9b0
          &(&mm->page_table_lock)->rlock              9          [<ffffffff81120c5b>] __pte_alloc+0x4b/0xf0
          &(&mm->page_table_lock)->rlock              4          [<ffffffff8112c70d>] anon_vma_prepare+0xad/0x180
          &(&mm->page_table_lock)->rlock          83395          [<ffffffff811204b4>] unmap_vmas+0x3c4/0xa60
          ------------------------------
          &(&mm->page_table_lock)->rlock              7          [<ffffffff81120c5b>] __pte_alloc+0x4b/0xf0
          &(&mm->page_table_lock)->rlock       20812987          [<ffffffff81124019>] handle_mm_fault+0x7a9/0x9b0
          &(&mm->page_table_lock)->rlock              2          [<ffffffff8112c70d>] anon_vma_prepare+0xad/0x180
          &(&mm->page_table_lock)->rlock          83408          [<ffffffff811204b4>] unmap_vmas+0x3c4/0xa60

                &(&p->alloc_lock)->rlock:       6304532        6308276           0.14        1772.97     7098177.74       23165904       23222238           0.00        1980.76    12445023.62
                ------------------------
                &(&p->alloc_lock)->rlock        6308277          [<ffffffff81153e17>] __mem_cgroup_try_charge+0x327/0x590
                ------------------------
                &(&p->alloc_lock)->rlock        6308277          [<ffffffff81153e17>] __mem_cgroup_try_charge+0x327/0x590



==

Then, new raw_spin_lock is task_lock(). This is because task_lock(mm->owner) makes
cacheline ping pong ;(

So, this is not very good patch for multi-threaded programs, Sigh...
I'll consider how I can get safe access without locks again..

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

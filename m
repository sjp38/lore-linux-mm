Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 84EE76B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 19:09:44 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6DNaOxZ028061
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 14 Jul 2009 08:36:24 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C50A45DE50
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 08:36:24 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E402545DE4E
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 08:36:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B2CAA1DB8037
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 08:36:23 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 64BA61DB803E
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 08:36:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/4][resend]  Show kernel stack usage in /proc/meminfo and OOM log output
In-Reply-To: <20090713152952.9b1f6388.akpm@linux-foundation.org>
References: <20090713150114.6260.A69D9226@jp.fujitsu.com> <20090713152952.9b1f6388.akpm@linux-foundation.org>
Message-Id: <20090714083344.626C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 14 Jul 2009 08:36:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, cl@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> On Mon, 13 Jul 2009 15:02:25 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > ChangeLog
> >   Since v1
> >    - Rewrote the descriptin (Thanks Christoph!)
> > 
> > =====================
> > Subject: [PATCH] Show kernel stack usage in /proc/meminfo and OOM log output
> > 
> > The amount of memory allocated to kernel stacks can become significant and
> > cause OOM conditions. However, we do not display the amount of memory
> > consumed by stacks.
> > 
> > Add code to display the amount of memory used for stacks in /proc/meminfo.
> > 
> > ...
> >  
> > +static void account_kernel_stack(struct thread_info *ti, int account)
> > +{
> > +	struct zone *zone = page_zone(virt_to_page(ti));
> > +
> > +	mod_zone_page_state(zone, NR_KERNEL_STACK, account);
> > +}
> > +
> >  void free_task(struct task_struct *tsk)
> >  {
> >  	prop_local_destroy_single(&tsk->dirties);
> > +	account_kernel_stack(tsk->stack, -1);
> 
> But surely there are other less expensive ways of calculating this. 
> The number we want is small-known-constant * number-of-tasks.
> 
> number-of-tasks probably isn't tracked, but can be calculated along the
> lines of nr_running(), nr_uninterruptible() and nr_iowait().

But, nr_running() don't know zone information. we really need
per-zone tracking IMHO.


> number-of-tasks is also equal to number-of-task_structs and
> number-of_thread_infos which can be obtained from slab (if the arch
> implemented these via slab - uglier).

You know, Almost architecture doesn't use slab for kernel-stack.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

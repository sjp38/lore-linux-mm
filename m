Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E3FBA6B01F1
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 00:28:35 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3K4SWqu020770
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 20 Apr 2010 13:28:32 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E59F645DE7A
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 13:28:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 801E445DE70
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 13:28:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 17A7C1DB8047
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 13:28:31 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C6E1C1DB8045
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 13:28:29 +0900 (JST)
Date: Tue, 20 Apr 2010 13:24:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: error at compaction (Re: mmotm 2010-04-15-14-42 uploaded
Message-Id: <20100420132429.1049ca84.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <g2x28c262361004192058y64f4d316qcb1547909168e31f@mail.gmail.com>
References: <201004152210.o3FMA7KV001909@imap1.linux-foundation.org>
	<20100419190133.50a13021.kamezawa.hiroyu@jp.fujitsu.com>
	<20100419181442.GA19264@csn.ul.ie>
	<20100419193919.GB19264@csn.ul.ie>
	<s2v28c262361004191939we64e5490ld59b21dc4fa5bc8d@mail.gmail.com>
	<20100420120753.b161dea9.kamezawa.hiroyu@jp.fujitsu.com>
	<g2x28c262361004192058y64f4d316qcb1547909168e31f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 20 Apr 2010 12:58:43 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Tue, Apr 20, 2010 at 12:07 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 20 Apr 2010 11:39:46 +0900
> >> Dumb question. Why can't we call arch_alloc_page and kernel_map_pages
> >> as interrupt disabled? It's deadlock issue or latency issue?
> >> I don't found any comment about it.
> >> It should have added the comment around that functions. :)
> >>
> >
> > I guess it's from the same reason as vfree(), which can't be called under
> > irq-disabled.
> >
> > Both of them has to flush TLB of all cpus. At flushing TLB (of other cpus), cpus has
> > to send IPI via smp_call_function. What I know from old stories is below.
> >
> > At sendinf IPI, usual sequence is following. (This may be old.)
> >
> > A  A  A  A spin_lock(&ipi_lock);
> > A  A  A  A  A  A  A  A set up cpu mask for getting notification from other cpu for declearing
> > A  A  A  A  A  A  A  A "I received IPI and finished my own work".
> > A  A  A  A spin_unlock(&ipi_lock);
> >
> > Then,
> > A  A  A  A  A CPU0 A  A  A  A  A  A  A  A  A  A  A  A  A  A  CPU1
> >
> > A  A irq_disable (somewhere) A  A  A  A  A  A  spin_lock
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A send IPI and wait for notification.
> > A  A spin_lock()
> >
> > deadlock. A Seeing decription of kernel/smp.c::smp_call_function_many(), it says
> > this function should not be called under irq-disabled.
> > (Maybe the same kind of spin-wait deadlock can happen.)
> >
> 
> Thanks for kind explanation.
> Actually I guessed TLB issue but I can't find any glue point which
> connect tlb flush to smp_call_function_xxx. :(
> 
> Now look at the __native_flush_tlb_global.
> It just read and write cr4 with just mask off X86_CR4_PGE.
> So i don't know how connect this and smp_schedule_xxxx.
> Hmm,, maybe APIC?
> 
> Sorry for dumb question.
> 
Hmm...seeing again,

arch/x86/mm/pageattr.c::kernel_map_pages() says:

1293         /*
1294          * We should perform an IPI and flush all tlbs,
1295          * but that can deadlock->flush only current cpu:
1296          */

Wow. It just flush only local cpu. Then, no IPI.

Hmm...all other archs does the same thing ? If so, kernel_map_pages()
can be called under irq_disabled. The author of kernel_map_pages() 
is aware that this can be called under irq-disabled.

Hmm...

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

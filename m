Subject: Re: [RFC][PATCH] lru_add_drain_all() don't use
 schedule_on_each_cpu()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <2f11576a0810260637q21eaec62q4e2662742541e771@mail.gmail.com>
References: <2f11576a0810210851g6e0d86benef5d801871886dd7@mail.gmail.com>
	 <2f11576a0810211018g5166c1byc182f1194cfdd45d@mail.gmail.com>
	 <20081023235425.9C40.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <1225019176.32713.5.camel@twins>
	 <2f11576a0810260637q21eaec62q4e2662742541e771@mail.gmail.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Sun, 26 Oct 2008 14:49:06 +0100
Message-Id: <1225028946.32713.16.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Gautham Shenoy <ego@in.ibm.com>, Oleg Nesterov <oleg@tv-sign.ru>, Rusty Russell <rusty@rustcorp.com.au>, mpm <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Sun, 2008-10-26 at 22:37 +0900, KOSAKI Motohiro wrote:
> Hi Peter,
> 
> >> @@ -611,4 +613,8 @@ void __init swap_setup(void)
> >>  #ifdef CONFIG_HOTPLUG_CPU
> >>       hotcpu_notifier(cpu_swap_callback, 0);
> >>  #endif
> >> +
> >> +     vm_wq = create_workqueue("vm_work");
> >> +     BUG_ON(!vm_wq);
> >> +
> >>  }
> >
> > While I really hate adding yet another per-cpu thread for this, I don't
> > see another way out atm.
> 
> Can I ask the reason of your hate?
> if I don't know it, making improvement patch is very difficult to me.

There seems to be no drive to keep them down, ps -def output it utterly
dominated by kernel threads on a freshly booted machine with many cpus.

And while they are not _that_ expensive to have around, they are not
free either, I imagine the tiny-linux folks having an interest in
keeping these down too.

> > Oleg, Rusty, ego, you lot were discussing a similar extra per-cpu
> > workqueue, can we merge these two?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

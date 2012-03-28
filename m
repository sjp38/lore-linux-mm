Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 837526B00EA
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 20:02:42 -0400 (EDT)
Message-ID: <1332892874.2882.66.camel@pasglop>
Subject: Re: [PATCH v2.1 01/10] cpu: Introduce clear_tasks_mm_cpumask()
 helper
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 28 Mar 2012 11:01:14 +1100
In-Reply-To: <20120325174210.GA23605@redhat.com>
References: <20120324102609.GA28356@lizard> <20120324102751.GA29067@lizard>
	 <1332593021.16159.27.camel@twins> <20120324164316.GB3640@lizard>
	 <20120325174210.GA23605@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, Mike Frysinger <vapier@gentoo.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, user-mode-linux-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, Richard Weinberger <richard@nod.at>, linux-kernel@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, linux-mm@kvack.org, Paul Mundt <lethal@linux-sh.org>, John Stultz <john.stultz@linaro.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On Sun, 2012-03-25 at 19:42 +0200, Oleg Nesterov wrote:
> > Also, Per Peter Zijlstra's idea, now we don't grab tasklist_lock in
> > the new helper, instead we take the rcu read lock. We can do this
> > because the function is called after the cpu is taken down and
> marked
> > offline, so no new tasks will get this cpu set in their mm mask.
> 
> And only powerpc needs rcu_read_lock() and task_lock().
> 
> OTOH, I do not understand why powepc does this on CPU_DEAD...
> And probably CPU_UP_CANCELED doesn't need to clear mm_cpumask().
> 
> That said, personally I think these patches are fine, the common
> helper makes sense. 

Not strictly speaking a problem with this patch, but I was wondering...

Do we know for sure that the mmu context has been fully flushed out
before the unplug ? idle_task_exit() will do a context switch but in our
case that may not be enough.

Once the CPU is offline, tlb flushes won't hit it any more so it can get
out of sync (in some cases the offlining process is just some kind of
deep sleep loop that doesn't involve a TLB state loss).

Should we add a flush_tlb_mm of all those bits in that loop ? that would
be a tad expensive... we don't have a flush_tlb_all() as a generic kind
of accessors, but we could add something like that as a requirement for
ppc_md.cpu_die ?

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

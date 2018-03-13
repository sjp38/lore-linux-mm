Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 28BF26B0005
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 17:24:15 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s8so385754pgf.16
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 14:24:15 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l7si694871pgu.518.2018.03.13.14.24.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 14:24:14 -0700 (PDT)
Date: Tue, 13 Mar 2018 14:24:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [v5 1/2] mm: disable interrupts while initializing deferred
 pages
Message-Id: <20180313142412.d373318b81164c4cb4b864b3@linux-foundation.org>
In-Reply-To: <ff16234e-eb45-ca99-bfec-6d33967e9c8f@oracle.com>
References: <20180309220807.24961-1-pasha.tatashin@oracle.com>
	<20180309220807.24961-2-pasha.tatashin@oracle.com>
	<20180312130410.e2fce8e5e38bc2086c7fd924@linux-foundation.org>
	<20180313160430.hbjnyiazadt3jwa6@xakep.localdomain>
	<20180313115549.7badec1c6b85eb5a1cf21eb6@linux-foundation.org>
	<20180313194546.k62tni4g4gnds2nx@xakep.localdomain>
	<20180313131156.f156abe1822a79ec01c4800a@linux-foundation.org>
	<ff16234e-eb45-ca99-bfec-6d33967e9c8f@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, m.mizuma@jp.fujitsu.com, mhocko@suse.com, catalin.marinas@arm.com, takahiro.akashi@linaro.org, gi-oh.kim@profitbricks.com, heiko.carstens@de.ibm.com, baiyaowei@cmss.chinamobile.com, richard.weiyang@gmail.com, paul.burton@mips.com, miles.chen@mediatek.com, vbabka@suse.cz, mgorman@suse.de, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 13 Mar 2018 16:43:47 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> 
> > Soft lockup: kernel has run for too long without rescheduling
> > Hard lockup: kernel has run for too long with interrupts disabled
> > 
> > Both of these are detected by the NMI watchdog handler.
> > 
> > 9b6e63cbf85b89b2d fixes a soft lockup by adding a manual rescheduling
> > point.  Replacing that with touch_nmi_watchdog() won't work (I think). 
> > Presumably calling touch_softlockup_watchdog() will "work", in that it
> > suppresses the warning.  But it won't fix the thing which the warning
> > is actually warning about: starvation of the CPU scheduler.  That's
> > what the cond_resched() does.
> 
> But, unlike memmap_init_zone(), which can be used after boot, here we do
> not worry about kernel running for too long.  This is because we are
> booting, and no user programs are running.
> 
> So, it is acceptable to have a long uninterruptible span, as long
> as we making a useful progress. BTW, the boot CPU still has
> interrupts enabled during this span.
> 
> Comment in: include/linux/nmi.h, states:
> 
>  * If the architecture supports the NMI watchdog, touch_nmi_watchdog()
>  * may be used to reset the timeout - for code which intentionally
>  * disables interrupts for a long time. This call is stateless.
> 
> Which is exactly what we are trying to do here, now that these threads
> run with interrupts disabled.
> 
> Before, where they were running with interrupts enabled, and
> cond_resched() was enough to satisfy soft lockups.

hm, maybe.  But I'm not sure that touch_nmi_watchdog() will hold off a
soft lockup warning.  Maybe it will.

And please let's get the above thoughts into the changlog.

> > 
> > I'm not sure what to suggest, really.  Your changelog isn't the best:
> > "Vlastimil Babka reported about a window issue during which when
> > deferred pages are initialized, and the current version of on-demand
> > initialization is finished, allocations may fail".  Well...  where is
> > ths mysterious window?  Without such detail it's hard for others to
> > suggest alternative approaches.
> 
> Here is hopefully a better description of the problem:
> 
> Currently, during boot we preinitialize some number of struct pages to satisfy all boot allocations. Even if these allocations happen when we initialize the reset of deferred pages in page_alloc_init_late(). The problem is that we do not know how much kernel will need, and it also depends on various options.
> 
> So, with this work, we are changing this behavior to initialize struct pages on-demand, only when allocations happen.
> 
> During boot, when we try to allocate memory, the on-demand struct page initialization code takes care of it. But, once the deferred pages are initializing in:
> 
> page_alloc_init_late()
>    for_each_node_state(nid, N_MEMORY)
>       kthread_run(deferred_init_memmap())
> 
> We cannot use on-demand initialization, as these threads resize pgdat.
> 
> This whole thing is to take care of this time.
> 
> My first version of on-demand deferred page initialization would simply fail to allocate memory during this period of time. But, this new version waits for threads to finish initializing deferred memory, and successfully perform the allocation.
> 
> Because interrupt handler would wait for pgdat resize lock.

OK, thanks.  Please also add to changelog.

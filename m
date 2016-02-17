Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5CAC96B0255
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 17:42:42 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id x65so19014453pfb.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 14:42:42 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id p14si4657294pfi.230.2016.02.17.14.42.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 14:42:41 -0800 (PST)
Received: by mail-pa0-x22c.google.com with SMTP id yy13so18631048pab.3
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 14:42:41 -0800 (PST)
Date: Wed, 17 Feb 2016 14:42:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: add MM_SWAPENTS and page table when calculate tasksize
 in lowmem_scan()
In-Reply-To: <56C42F9B.2050309@huawei.com>
Message-ID: <alpine.DEB.2.10.1602171435400.15429@chino.kir.corp.google.com>
References: <56C2EDC1.2090509@huawei.com> <20160216173849.GA10487@kroah.com> <alpine.DEB.2.10.1602161629560.19997@chino.kir.corp.google.com> <56C42F9B.2050309@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, arve@android.com, riandrews@android.com, devel@driverdev.osuosl.org, zhong jiang <zhongjiang@huawei.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Wed, 17 Feb 2016, Xishi Qiu wrote:

> Hi David,
> 
> Thanks for your advice.
> 
> I have a stupid question, what's the main difference between lmk and oom?

Hi Xishi, it's not a stupid question at all!

Low memory killer appears to be implemented as a generic shrinker that 
iterates through the tasklist and tries to free memory before the generic 
oom killer.  It has two tunables, "adj" and "minfree": "minfree" describes 
what class of processes are eligible based on how many free pages are left 
on the system and "adj" defines that class by using oom_score_adj values.

So LMK is trying to free memory before all memory is depleted based on 
heuristics for systems that load the driver whereas the generic oom killer 
is called to kill a process when reclaim has failed to free any memory and 
there's no forward progress.

> 1) lmk is called when reclaim memory, and oom is called when alloc failed in slow path.

Yeah, and I don't think LMK provides any sort of guarantee against all 
memory being fully depleted before it can run, so it would probably be 
best effort.

> 2) lmk has several lowmem thresholds and oom is not.

Right, and it abuses oom_score_adj, which is a generic oom killer tunable 
to define priorities to kill at different levels of memory availability.

> 3) others?
> 

LMK also abuses TIF_MEMDIE which is used by the generic oom killer to 
allow a process to free memory.  Since the system is out of memory when it 
is called, a process often needs additional memory to even exit, so we set 
TIF_MEMDIE to ignore zone watermarks in the page allocator.  LMK should 
not be using this, there should already be memory available for it to 
allocate from.

To fix these issues with LMK, I think it should:

 - send SIGKILL to terminate a process in lowmem situations, but not
   set TIF_MEMDIE and implement its own way of determining when to kill
   additional processes, and

 - introduce its own tunable to define the priority of kill when it runs
   rather than oom_score_adj, which is a proportion of memory to bias
   against, not a priority at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

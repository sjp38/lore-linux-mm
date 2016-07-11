Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 58ADF6B0253
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 11:43:06 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id c52so142874036qte.2
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 08:43:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m145si891188qke.101.2016.07.11.08.43.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 08:43:05 -0700 (PDT)
Date: Mon, 11 Jul 2016 11:43:02 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: System freezes after OOM
In-Reply-To: <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com>
Message-ID: <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com>
References: <57837CEE.1010609@redhat.com> <f80dc690-7e71-26b2-59a2-5a1557d26713@redhat.com> <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ondrej Kozina <okozina@redhat.com>
Cc: Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On Mon, 11 Jul 2016, Ondrej Kozina wrote:

> On 07/11/2016 01:55 PM, Jerome Marchand wrote:
> > On 07/11/2016 01:03 PM, Stanislav Kozina wrote:
> > > Hi Jerome,
> > > 
> > > On upstream mailing lists there have been reports of freezing systems
> > > due to OOM. Ondra (on CC) managed to reproduce this inhouse, he'd like
> > > someone with mm skills to look at the problem since he doesn't
> > > understand why OOM comes into play when >90% of 2GB swap are still free.
> > > 
> > > Could you please take a look? It's following this email on upstream:
> > > https://lkml.org/lkml/2016/5/5/356
> > > 
> > > Thanks!
> > > -Stanislav
> > 
> > Hi Ondrej,
> > 
> > I can see [1] that there are several atomic memory allocation failures
> > before the OOM kill, several of them are in memory reclaim path, which
> > prevents it to free memory.
> > Normally the linux mm try to keep enough memory free at all time to
> > satisfy atomic allocation (cf. /proc/sys/vm/min_free_kbytes). Have you
> > try to increase that value?
> > It would be useful to understand why the reserve for atomic allocations
> > runs out. There might be a burst of atomic allocations that deplete the
> > reserve. What kind of workload is that?
> > 
> > Jerome
> > 
> > [1]:
> > https://okozina.fedorapeople.org/bugs/swap_on_dmcrypt/vmlog-1462458369-00000/sample-00011/dmesg
> > 
> 
> Hi Jerome,
> 
> first let thank you for looking into it! About the workload it's nothing
> special. I've started gcc build of a project in C++ in 3-4 threads so that I'd
> waste all physical memory to trigger it. I can build some simple utility to
> allocate memory in predefined chunks in some loop if it'd of any help. It was
> really quite simple to trigger this.
> 
> On a /proc/sys/vm/min_free_kbytes value. Let me try it...
> 
> Thanks Ondra
> 
> PS: Adding Mikulas on CC'ed (dm-crypt upstream) in case he has anything to
> add.

That allocation warning in wb_start_writeback was already silenced by the 
commit 78ebc2f7146156f488083c9e5a7ded9d5c38c58b. The warning in 
drivers/virtio/virtio_ring.c:alloc_indirect could be silenced as well (the 
driver does fallback in case of allocation failure, so this failure can't 
result in loss of functionality).


The general problem is that the memory allocator does 16 retries to 
allocate a page and then triggers the OOM killer (and it doesn't take into 
account how much swap space is free or how many dirty pages were really 
swapped out while it waited).

So, it could prematurely trigger OOM killer on any slow swapping device 
(including dm-crypt). Michal Hocko reworked the OOM killer in the patch 
0a0337e0d1d134465778a16f5cbea95086e8e9e0, but it still has the flaw that 
it triggers OOM if there is plenty of free swap space free.

Michal, would you accept a change to the OOM killer, to prevent it from 
triggerring when there is free swap space?

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

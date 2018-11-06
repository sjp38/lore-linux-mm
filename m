Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id C63356B038E
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 14:00:57 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id w17-v6so2233736ybe.13
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 11:00:57 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 1-v6si27759928ywz.277.2018.11.06.11.00.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 11:00:56 -0800 (PST)
Date: Tue, 6 Nov 2018 11:00:29 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [RFC PATCH v4 00/13] ktask: multithread CPU-intensive kernel work
Message-ID: <20181106190029.epktpxhimrca4f4a@ca-dmjordan1.us.oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <FC2EB02D-3D05-4A13-A92E-4171B37B15BA@cs.rutgers.edu>
 <20181106022024.ndn377ze6xljsxkb@ca-dmjordan1.us.oracle.com>
 <7E53DD63-4955-480D-8C0D-EB07E4FF011B@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7E53DD63-4955-480D-8C0D-EB07E4FF011B@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

On Mon, Nov 05, 2018 at 09:48:56PM -0500, Zi Yan wrote:
> On 5 Nov 2018, at 21:20, Daniel Jordan wrote:
> 
> > Hi Zi,
> >
> > On Mon, Nov 05, 2018 at 01:49:14PM -0500, Zi Yan wrote:
> >> On 5 Nov 2018, at 11:55, Daniel Jordan wrote:
> >>
> >> Do you think if it makes sense to use ktask for huge page migration (the data
> >> copy part)?
> >
> > It certainly could.
> >
> >> I did some experiments back in 2016[1], which showed that migrating one 2MB page
> >> with 8 threads could achieve 2.8x throughput of the existing single-threaded method.
> >> The problem with my parallel page migration patchset at that time was that it
> >> has no CPU-utilization awareness, which is solved by your patches now.
> >
> > Did you run with fewer than 8 threads?  I'd want a bigger speedup than 2.8x for
> > 8, and a smaller thread count might improve thread utilization.
> 
> Yes. When migrating one 2MB THP with migrate_pages() system call on a two-socket server
> with 2 E5-2650 v3 CPUs (10 cores per socket) across two sockets, here are the page migration
> throughput numbers:
> 
>              throughput       factor
> 1 thread      2.15 GB/s         1x
> 2 threads     3.05 GB/s         1.42x
> 4 threads     4.50 GB/s         2.09x
> 8 threads     5.98 GB/s         2.78x

Thanks.  Looks like in your patches you start a worker for every piece of the
huge page copy and have the main thread wait.  I'm curious what the workqueue
overhead is like on your machine.  On a newer Xeon it's ~50usec from queueing a
work to starting to execute it and another ~20usec to flush a work
(barrier_func), which could happen after the work is already done.  A pretty
significant piece of the copy time for part of a THP.

            bash 60728 [087] 155865.157116:                   probe:ktask_run: (ffffffffb7ee7a80)
            bash 60728 [087] 155865.157119:    workqueue:workqueue_queue_work: work struct=0xffff95fb73276000
            bash 60728 [087] 155865.157119: workqueue:workqueue_activate_work: work struct 0xffff95fb73276000
 kworker/u194:3- 86730 [095] 155865.157168: workqueue:workqueue_execute_start: work struct 0xffff95fb73276000: function ktask_thread
 kworker/u194:3- 86730 [095] 155865.157170:   workqueue:workqueue_execute_end: work struct 0xffff95fb73276000
 kworker/u194:3- 86730 [095] 155865.157171: workqueue:workqueue_execute_start: work struct 0xffffa676995bfb90: function wq_barrier_func
 kworker/u194:3- 86730 [095] 155865.157190:   workqueue:workqueue_execute_end: work struct 0xffffa676995bfb90
            bash 60728 [087] 155865.157207:       probe:ktask_run_ret__return: (ffffffffb7ee7a80 <- ffffffffb7ee7b7b)

> >
> > It would be nice to multithread at a higher granularity than 2M, too: a range
> > of THPs might also perform better than a single page.
> 
> Sure. But the kernel currently does not copy multiple pages altogether even if a range
> of THPs is migrated. Page copy function is interleaved with page table operations
> for every single page.
> 
> I also did some study and modified the kernel to improve this, which I called
> concurrent page migration in https://lwn.net/Articles/714991/. It further
> improves page migration throughput.

Ok, over 4x with 8 threads for 16 THPs.  Is 16 a typical number for migration,
or does it get larger?  What workloads do you have in mind with this change?

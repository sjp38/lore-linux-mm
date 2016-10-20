Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 889066B0038
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 06:56:03 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id m193so1743994lfm.7
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 03:56:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x6si305947lfd.67.2016.10.20.03.56.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Oct 2016 03:56:01 -0700 (PDT)
Date: Thu, 20 Oct 2016 12:55:59 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mmap_sem bottleneck
Message-ID: <20161020105559.GH14609@dhcp22.suse.cz>
References: <ea12b8ee-1892-fda1-8a83-20fdfdfa39c4@linux.vnet.ibm.com>
 <20161017125717.GK23322@dhcp22.suse.cz>
 <e1e865c5-51ab-fce1-0958-b5c668da4dac@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e1e865c5-51ab-fce1-0958-b5c668da4dac@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, Andi Kleen <ak@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>, Davidlohr Bueso <dbueso@suse.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Thu 20-10-16 09:23:37, Laurent Dufour wrote:
> On 17/10/2016 14:57, Michal Hocko wrote:
> > On Mon 17-10-16 14:33:53, Laurent Dufour wrote:
> >> Hi all,
> >>
> >> I'm sorry to resurrect this topic, but with the increasing number of
> >> CPUs, this becomes more frequent that the mmap_sem is a bottleneck
> >> especially between the page fault handling and the other threads memory
> >> management calls.
> >>
> >> In the case I'm seeing, there is a lot of page fault occurring while
> >> other threads are trying to manipulate the process memory layout through
> >> mmap/munmap.
> >>
> >> There is no *real* conflict between these operations, the page fault are
> >> done a different page and areas that the one addressed by the mmap/unmap
> >> operations. Thus threads are dealing with different part of the
> >> process's memory space. However since page fault handlers and mmap/unmap
> >> operations grab the mmap_sem, the page fault handling are serialized
> >> with the mmap operations, which impact the performance on large system.
> > 
> > Could you quantify how much overhead are we talking about here?
> 
> I recorded perf data using a sampler which recreates the bottleneck
> issueby simulating the database initialization process which spawns a
> thread per cpu in charge of allocating a piece of memory and request a
> disk reading in it.
> 
> The perf data shows that 23% of the time is spent waiting for the
> mm semaphore in do_page_fault(). This has been recording using a 4.8-rc8
> kernel on pppc64le architecture.
> 
> >> For the record, the page fault are done while reading data from a file
> >> system, and I/O are really impacted by this serialization when dealing
> >> with a large number of parallel threads, in my case 192 threads (1 per
> >> online CPU). But the source of the page fault doesn't really matter I guess.
> > 
> > But we are dropping the mmap_sem for the IO and retry the page fault.
> > I am not sure I understood you correctly here though.
> > 
> >> I took time trying to figure out how to get rid of this bottleneck, but
> >> this is definitively too complex for me.
> >> I read this mailing history, and some LWN articles about that and my
> >> feeling is that there is no clear way to limit the impact of this
> >> semaphore. Last discussion on this topic seemed to happen last march
> >> during the LSFMM submit (https://lwn.net/Articles/636334/). But this
> >> doesn't seem to have lead to major changes, or may be I missed them.
> > 
> > At least mmap/munmap write lock contention could be reduced by the above
> > proposed range locking. Jan Kara has implemented a prototype [1] of the
> > lock for mapping which could be used for mmap_sem as well) but it had
> > some perfomance implications AFAIR. There wasn't a strong usecase for
> > this so far. If there is one, please describe it and we can think what
> > to do about it.
> 
> When recreating the issue with a sampler there is no file system I/O in
> the picture, just pure mmap/memcpy and a lot of threads (I need about
> 192 CPUs to recreate it).
> But there is a real use case, beyond that. The SAP HANA database is
> using all the available CPUs to read the database from the disk when
> starting. When run on top flash storage and a large number of CPUs
> (>192), we hit the mm semaphore bottleneck which impact the loading
> performance by serializing the memory management.

Yeah, I have heard about those but didn't get any numbers yet. Those are
really useful!

> I think there is a place for enhancements in the user space part (the
> database loader), but the mm semaphore is still a bottleneck when a
> massively multi-threaded process is dealing with its memory while page
> faulting on it.
> Unfortunately, this requires big system to recreate such an issue which
> make it harder to track and investigate.
> 
> 
> > There were also some attempts to replace mmap_sem by RCU AFAIR but my
> > vague recollection is that they had some issues as well.
> > 
> > [1] http://linux-kernel.2935.n7.nabble.com/PATCH-0-6-RFC-Mapping-range-lock-td592872.html
> 
> I took a look to this series which is very interesting but it is
> quite old now, and I'm wondering if it is still applicable.

The principal idea is not really hard and the range locks should be
applicable without any problems. The harder path is the break down mmap
calls to parts which know their range and use that locking and which
need exclusion for the range selection. I remember Davidlohr was
exploring that quite some time ago. 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

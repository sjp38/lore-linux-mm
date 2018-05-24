Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A589B6B0006
	for <linux-mm@kvack.org>; Thu, 24 May 2018 15:06:52 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e15-v6so1839884wmh.6
        for <linux-mm@kvack.org>; Thu, 24 May 2018 12:06:52 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a4-v6si5728170wrc.437.2018.05.24.12.06.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 12:06:50 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4OJ3mXN059521
	for <linux-mm@kvack.org>; Thu, 24 May 2018 15:06:49 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2j611ce34s-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 24 May 2018 15:06:49 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 24 May 2018 20:06:47 +0100
Date: Thu, 24 May 2018 22:06:40 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] userfaultfd: prevent non-cooperative events vs
 mcopy_atomic races
References: <1527061324-19949-1-git-send-email-rppt@linux.vnet.ibm.com>
 <0e1ce040-1beb-fd96-683c-1b18eb635fd6@virtuozzo.com>
 <20180524115613.GA16908@rapoport-lnx>
 <e42a383f-491a-b42a-347c-effe4b86b982@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e42a383f-491a-b42a-347c-effe4b86b982@virtuozzo.com>
Message-Id: <20180524190639.GD16908@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Andrei Vagin <avagin@virtuozzo.com>

On Thu, May 24, 2018 at 07:40:07PM +0300, Pavel Emelyanov wrote:
> On 05/24/2018 02:56 PM, Mike Rapoport wrote:
> > On Thu, May 24, 2018 at 02:24:37PM +0300, Pavel Emelyanov wrote:
> >> On 05/23/2018 10:42 AM, Mike Rapoport wrote:
> >>> If a process monitored with userfaultfd changes it's memory mappings or
> >>> forks() at the same time as uffd monitor fills the process memory with
> >>> UFFDIO_COPY, the actual creation of page table entries and copying of the
> >>> data in mcopy_atomic may happen either before of after the memory mapping
> >>> modifications and there is no way for the uffd monitor to maintain
> >>> consistent view of the process memory layout.
> >>>
> >>> For instance, let's consider fork() running in parallel with
> >>> userfaultfd_copy():
> >>>
> >>> process        		         |	uffd monitor
> >>> ---------------------------------+------------------------------
> >>> fork()        		         | userfaultfd_copy()
> >>> ...        		         | ...
> >>>     dup_mmap()        	         |     down_read(mmap_sem)
> >>>     down_write(mmap_sem)         |     /* create PTEs, copy data */
> >>>         dup_uffd()               |     up_read(mmap_sem)
> >>>         copy_page_range()        |
> >>>         up_write(mmap_sem)       |
> >>>         dup_uffd_complete()      |
> >>>             /* notify monitor */ |
> >>>
> >>> If the userfaultfd_copy() takes the mmap_sem first, the new page(s) will be
> >>> present by the time copy_page_range() is called and they will appear in the
> >>> child's memory mappings. However, if the fork() is the first to take the
> >>> mmap_sem, the new pages won't be mapped in the child's address space.
> >>
> >> But in this case child should get an entry, that emits a message to uffd when step upon!
> >> And uffd will just userfaultfd_copy() it again. No?
> >  
> > There will be a message, indeed. But there is no way for monitor to tell
> > whether the pages it copied are present or not in the child.
> 
> If there's a message, then they are not present, that's for sure :)

If the pages are not present and child tries to access them, the monitor
will get page fault notification and everything is fine.
However, if the pages *are present*, the child can access them without uffd
noticing. And if we copy them into child it'll see the wrong data.
Since we are talking about background copy, we'd need to decide whether the
pages should be copied or not regardless #PF notifications.
 
> > Since the monitor cannot assume that the process will access all its memory
> > it has to copy some pages "in the background". A simple monitor may look
> > like:
> > 
> > 	for (;;) {
> > 		wait_for_uffd_events(timeout);
> > 		handle_uffd_events();
> > 		uffd_copy(some not faulted pages);
> > 	}
> > 
> > Then, if the "background" uffd_copy() races with fork, the pages we've
> > copied may be already present in parent's mappings before the call to
> > copy_page_range() and may be not.
> > 
> > If the pages were not present, uffd_copy'ing them again to the child's
> > memory would be ok.
> 
> Yes.
> 
> > But if uffd_copy() was first to catch mmap_sem, and we would uffd_copy them
> > again, child process will get memory corruption.
> 
> You mean the background uffd_copy()?

Yes.

> But doesn't it race even with regular PF handling, not only the fork? How
> do we handle this race?

With the regular #PF handing, the faulting thread patiently waits until
page fault is resolved. With fork(), mremap() etc the thread that caused
the event resumes once the uffd message is read by the monitor. That's
surely way before monitor had chance to somehow process that message.

> -- Pavel
> 

-- 
Sincerely yours,
Mike.

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5106B0253
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 18:52:53 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c73so124493942pfb.7
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 15:52:53 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s21si2139506pgh.403.2017.02.06.15.52.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 15:52:52 -0800 (PST)
Date: Mon, 6 Feb 2017 15:52:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [v2,2/5] userfaultfd: non-cooperative: add event for memory
 unmaps
Message-Id: <20170206155251.f98b9ce54a4e1e1c5be50b48@linux-foundation.org>
In-Reply-To: <20170205184629.GA28665@roeck-us.net>
References: <1485542673-24387-3-git-send-email-rppt@linux.vnet.ibm.com>
	<20170205184629.GA28665@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, 5 Feb 2017 10:46:29 -0800 Guenter Roeck <linux@roeck-us.net> wrote:

> On Fri, Jan 27, 2017 at 08:44:30PM +0200, Mike Rapoport wrote:
> > When a non-cooperative userfaultfd monitor copies pages in the background,
> > it may encounter regions that were already unmapped. Addition of
> > UFFD_EVENT_UNMAP allows the uffd monitor to track precisely changes in the
> > virtual memory layout.
> > 
> > Since there might be different uffd contexts for the affected VMAs, we
> > first should create a temporary representation for the unmap event for each
> > uffd context and then notify them one by one to the appropriate userfault
> > file descriptors.
> > 
> > The event notification occurs after the mmap_sem has been released.
> > 
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> 
> Just in case 0day didn't report it yet, this patch causes build errors
> with various architectures.
> 
> mm/nommu.c:1201:15: error: conflicting types for 'do_mmap'
>  unsigned long do_mmap(struct file *file,
>                ^
> In file included from mm/nommu.c:19:0:
> 	include/linux/mm.h:2095:22: note:
> 		previous declaration of 'do_mmap' was here
> 
> mm/nommu.c:1580:5: error: conflicting types for 'do_munmap'
> int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
>     ^
> In file included from mm/nommu.c:19:0:
> 	include/linux/mm.h:2099:12: note:
> 		previous declaration of 'do_munmap' was here

This was fixed in
http://ozlabs.org/~akpm/mmots/broken-out/userfaultfd-non-cooperative-add-event-for-memory-unmaps-fix.patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

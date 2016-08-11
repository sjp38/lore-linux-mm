Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 14AE56B0265
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 13:17:30 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id r91so4050961uar.0
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 10:17:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o76si787041qke.283.2016.08.11.10.17.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Aug 2016 10:17:29 -0700 (PDT)
Date: Thu, 11 Aug 2016 19:17:26 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: userfaultfd: unexpected behavior with MODE_MISSING | MODE_WP
 regions
Message-ID: <20160811171726.xlna3ni4dp2ed4a4@redhat.com>
References: <ef90a2b0-eff4-2269-4a93-35f23ec8b1af@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ef90a2b0-eff4-2269-4a93-35f23ec8b1af@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Evgeny Yakovlev <eyakovlev@virtuozzo.com>
Cc: linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hello Evgeny,

On Thu, Aug 11, 2016 at 04:51:30PM +0300, Evgeny Yakovlev wrote:
>   * 1. First fault is expected UFFD_PAGEFAULT_FLAG_WRITE set which we 
> resolve
>   * with zeropage

What if you resolve it with bzero(4096);UFFDIO_COPY? Does the problem
go away?

If the zeropage is mapped by UFFDIO_ZEROPAGE, there's no way to turn
that into a writable zeropage ever again because
userfaultfd_writeprotect is basically a no-vma-mangling mmap_sem-read
mprotect and it can't trigger faults. Instead a fault in do_wp_page is
required to get rid of the zeropage and copy it off.

If the problem goes away if you s/UFFDIO_ZEROPAGE/bzero(4096);
UFFDIO_COPY/ as I would expect, there would be two ways to solve it:

1) forbid UFFDIO_ZEROPAGE and not return the UFFDIO_ZEROPAGE ioctl in
   uffdio_register.ioctls, if UFFDIO_REGISTER is called with
   uffdio_register.mode = ...WP|..MISSING so userland is aware it
   can't use that.

2) teach UFFDIO_WRITEPROTECT not just to mangle pagetables but also
   trigger a write fault on any zeropage if it's called with
   uffdio_writeprotect.mode without UFFDIO_WRITEPROTECT_MODE_WP being
   set. This will require a bit more work to fix.

The latter would increase performance if not all zeropages needs to be
turned writable.

Feedback welcome on what solution would you prefer.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 516EB6B0038
	for <linux-mm@kvack.org>; Fri, 10 Oct 2014 05:55:38 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id l4so2723641lbv.38
        for <linux-mm@kvack.org>; Fri, 10 Oct 2014 02:55:37 -0700 (PDT)
Received: from plane.gmane.org (plane.gmane.org. [80.91.229.3])
        by mx.google.com with ESMTPS id r5si8452178lal.3.2014.10.10.02.55.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 Oct 2014 02:55:25 -0700 (PDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1XcWue-0008Mg-AT
	for linux-mm@kvack.org; Fri, 10 Oct 2014 11:55:04 +0200
Received: from proxye.avm.de ([212.42.244.241])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Fri, 10 Oct 2014 11:55:04 +0200
Received: from kugel by proxye.avm.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Fri, 10 Oct 2014 11:55:04 +0200
From: Thomas Martitz <kugel@rockbox.org>
Subject: Re: [PATCH 14/17] userfaultfd: add new syscall to provide memory externalization
Date: Fri, 10 Oct 2014 09:39:10 +0000 (UTC)
Message-ID: <loom.20141010T113521-675@post.gmane.org>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com> <1412356087-16115-15-git-send-email-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Andrea Arcangeli <aarcange <at> redhat.com> writes:

> 
> Once an userfaultfd is created MADV_USERFAULT regions talks through
> the userfaultfd protocol with the thread responsible for doing the
> memory externalization of the process.
> 
> The protocol starts by userland writing the requested/preferred
> USERFAULT_PROTOCOL version into the userfault fd (64bit write), if
> kernel knows it, it will ack it by allowing userland to read 64bit
> from the userfault fd that will contain the same 64bit
> USERFAULT_PROTOCOL version that userland asked. Otherwise userfault
> will read __u64 value -1ULL (aka USERFAULTFD_UNKNOWN_PROTOCOL) and it
> will have to try again by writing an older protocol version if
> suitable for its usage too, and read it back again until it stops
> reading -1ULL. After that the userfaultfd protocol starts.
> 
> The protocol consists in the userfault fd reads 64bit in size
> providing userland the fault addresses. After a userfault address has
> been read and the fault is resolved by userland, the application must
> write back 128bits in the form of [ start, end ] range (64bit each)
> that will tell the kernel such a range has been mapped. Multiple read
> userfaults can be resolved in a single range write. poll() can be used
> to know when there are new userfaults to read (POLLIN) and when there
> are threads waiting a wakeup through a range write (POLLOUT).
> 
> Signed-off-by: Andrea Arcangeli <aarcange <at> redhat.com>
> ---
>  arch/x86/syscalls/syscall_32.tbl |   1 +
>  arch/x86/syscalls/syscall_64.tbl |   1 +
>  fs/Makefile                      |   1 +
>  fs/userfaultfd.c                 | 643
+++++++++++++++++++++++++++++++++++++++
>  include/linux/syscalls.h         |   1 +
>  include/linux/userfaultfd.h      |  42 +++
>  init/Kconfig                     |  11 +
>  kernel/sys_ni.c                  |   1 +
>  mm/huge_memory.c                 |  24 +-
>  mm/memory.c                      |   5 +-
>  10 files changed, 720 insertions(+), 10 deletions(-)
>  create mode 100644 fs/userfaultfd.c
>  create mode 100644 include/linux/userfaultfd.h
> 


Hello,

I am wondering if, instead of a new syscall, a suitable fd could be obtained
by opening a special file (say /dev/userfault, analogous to /dev/shm). This
has the added bonus that system admins can tweak access to this feature via
normal file permissions. And if the file doesn't exist then the kernel has
simply no support for it.

I was wondering the same for memfd() when it was added to the kernel but
this time I decided to actually ask :)

Best regards

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

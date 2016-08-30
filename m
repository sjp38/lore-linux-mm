Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C53806B0069
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 15:21:04 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id s207so86473451oie.0
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 12:21:04 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id t8si29065021otf.11.2016.08.30.12.20.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 12:20:49 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id y134so1555425pfg.3
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 12:20:49 -0700 (PDT)
Subject: Re: [PATCH] mlock.2: document that is a bad idea to fork() after
 mlock()
References: <20160830085911.5336-1-bigeasy@linutronix.de>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <1f2afdf9-0fcc-fdb3-4ea3-e1770d4434f3@gmail.com>
Date: Wed, 31 Aug 2016 07:20:40 +1200
MIME-Version: 1.0
In-Reply-To: <20160830085911.5336-1-bigeasy@linutronix.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rt-users@vger.kernel.org

Hello Sebastian

On 08/30/2016 08:59 PM, Sebastian Andrzej Siewior wrote:
> fork() will remove the write PTE bit from the page table on each VMA
> which will be copied via COW. A such such, the memory is available but
> marked read only in the page table and will fault on write access.
> This renders the previous mlock() operation almost useless because in a
> multi threaded application the RT thread may block on mmap_sem while the
> thread with low priority is holding the mmap_sem (for instance because
> it is allocating memory which needs to be mapped in).
> 
> There is actually nothing we can do to mitigate the outcome. We could
> add a warning to the kernel for people that are not yet aware of the
> updated documentation.
> 
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Thanks! Patch applied.

Cheers,

Michael

> ---
>  man2/mlock.2 | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
> 
> diff --git a/man2/mlock.2 b/man2/mlock.2
> index e34bb3b4e045..27f80f6664ef 100644
> --- a/man2/mlock.2
> +++ b/man2/mlock.2
> @@ -350,6 +350,20 @@ settings are not inherited by a child created via
>  and are cleared during an
>  .BR execve (2).
>  
> +Note that
> +.BR fork (2)
> +will prepare the address space for a copy-on-write operation. The consequence
> +is that any write access that follows will cause a page fault which in turn may
> +cause high latencies for a real-time process. Therefore it is crucial not to
> +invoke
> +.BR fork (2)
> +after the
> +.BR mlockall ()
> +or
> +.BR mlock ()
> +operation not even from thread which runs at a low priority within a process
> +which also has a thread running at elevated priority.
> +
>  The memory lock on an address range is automatically removed
>  if the address range is unmapped via
>  .BR munmap (2).
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

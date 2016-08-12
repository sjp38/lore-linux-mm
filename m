Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C6716B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 09:43:16 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id x130so40358972ite.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 06:43:16 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0091.outbound.protection.outlook.com. [104.47.2.91])
        by mx.google.com with ESMTPS id h9si4478709oib.31.2016.08.12.06.43.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 12 Aug 2016 06:43:14 -0700 (PDT)
Subject: Re: userfaultfd: unexpected behavior with MODE_MISSING | MODE_WP
 regions
References: <ef90a2b0-eff4-2269-4a93-35f23ec8b1af@virtuozzo.com>
 <20160811171726.xlna3ni4dp2ed4a4@redhat.com>
From: Evgeny Yakovlev <eyakovlev@virtuozzo.com>
Message-ID: <9696fafa-dfcf-052a-e916-013508303dc2@virtuozzo.com>
Date: Fri, 12 Aug 2016 16:43:05 +0300
MIME-Version: 1.0
In-Reply-To: <20160811171726.xlna3ni4dp2ed4a4@redhat.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>


Hello Andrea,

On 11.08.2016 20:17, Andrea Arcangeli wrote:
> Hello Evgeny,
>
> On Thu, Aug 11, 2016 at 04:51:30PM +0300, Evgeny Yakovlev wrote:
>>    * 1. First fault is expected UFFD_PAGEFAULT_FLAG_WRITE set which we
>> resolve
>>    * with zeropage
> What if you resolve it with bzero(4096);UFFDIO_COPY? Does the problem
> go away?

Yes, i don't see additional WP fault now, only expected missing write fault.

> If the zeropage is mapped by UFFDIO_ZEROPAGE, there's no way to turn
> that into a writable zeropage ever again because
> userfaultfd_writeprotect is basically a no-vma-mangling mmap_sem-read
> mprotect and it can't trigger faults. Instead a fault in do_wp_page is
> required to get rid of the zeropage and copy it off.

Maybe i am missing something but why do we then get WP faults on that 
page right after we UFFDIO_ZEROPAGE it? We never call writeprotect on 
zeropaged page and still get a WP fault on it which we can't resolve 
properly.

> If the problem goes away if you s/UFFDIO_ZEROPAGE/bzero(4096);
> UFFDIO_COPY/ as I would expect, there would be two ways to solve it:
>
> 1) forbid UFFDIO_ZEROPAGE and not return the UFFDIO_ZEROPAGE ioctl in
>     uffdio_register.ioctls, if UFFDIO_REGISTER is called with
>     uffdio_register.mode = ...WP|..MISSING so userland is aware it
>     can't use that.
>
> 2) teach UFFDIO_WRITEPROTECT not just to mangle pagetables but also
>     trigger a write fault on any zeropage if it's called with
>     uffdio_writeprotect.mode without UFFDIO_WRITEPROTECT_MODE_WP being
>     set. This will require a bit more work to fix.
>
> The latter would increase performance if not all zeropages needs to be
> turned writable.
>
> Feedback welcome on what solution would you prefer.

Our use case is as follows. We have a huge region and most of it we need 
to be writable. Most of the time we just gradually resolve missing 
faults as they appear. We only enable write protection on some selective 
already present pages to have a way to track attempted page modification 
for a short period of time. We register initial region as MISSING | WP 
so that we don't have to register a new page-sized region each time we 
need to write-protect a single page inside a region.

>
> Thanks,
> Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

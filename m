Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 48D9A440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 13:36:04 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id p62so218166oih.1
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 10:36:04 -0700 (PDT)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id r205si3810243oia.315.2017.08.24.10.36.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 10:36:02 -0700 (PDT)
Received: by mail-oi0-x22f.google.com with SMTP id j144so1359376oib.1
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 10:36:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170824165546.GA3121@infradead.org>
References: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150353213097.5039.6729469069608762658.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170824165546.GA3121@infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 24 Aug 2017 10:36:02 -0700
Message-ID: <CAPcyv4iN0QpUSgOUvisnNQsiV1Pp=4dh7CwAV8FFj=_rFU=aug@mail.gmail.com>
Subject: Re: [PATCH v6 3/5] mm: introduce mmap3 for safely defining new mmap flags
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Aug 24, 2017 at 9:55 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Wed, Aug 23, 2017 at 04:48:51PM -0700, Dan Williams wrote:
>> The mmap(2) syscall suffers from the ABI anti-pattern of not validating
>> unknown flags. However, proposals like MAP_SYNC and MAP_DIRECT need a
>> mechanism to define new behavior that is known to fail on older kernels
>> without the support. Define a new mmap3 syscall that checks for
>> unsupported flags at syscall entry and add a 'mmap_supported_mask' to
>> 'struct file_operations' so generic code can validate the ->mmap()
>> handler knows about the specified flags. This also arranges for the
>> flags to be passed to the handler so it can do further local validation
>> if the requested behavior can be fulfilled.
>
> What is the reason to not go with __MAP_VALID hack?  Adding new
> syscalls is extremely painful, it will take forever to trickle this
> through all architectures (especially with the various 32-bit
> architectures having all kinds of different granularities for the
> offset) and then the various C libraries, never mind applications.

I'll let Andy and Kirill restate their concerns, but one of the
arguments that swayed me is that any new mmap flag with this hack must
be documented to only work with MAP_SHARED and that MAP_PRIVATE is
silently ignored. I agree with the mess and delays it causes for other
archs and libc, but at the same time this is for new applications and
libraries that know to look for the new flag, so they need to do the
extra work to check for the new syscall.

However, if the fcntl lease approach works for the DMA cases then we
only have the one mmap flag to add for now, so maybe the weird
MAP_{SHARED|PRIVATE} semantics are tolerable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

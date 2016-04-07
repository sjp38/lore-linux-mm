Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id CE1976B0005
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 17:29:00 -0400 (EDT)
Received: by mail-ob0-f178.google.com with SMTP id fp4so61302317obb.2
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 14:29:00 -0700 (PDT)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id sw5si3544471obc.4.2016.04.07.14.29.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 14:29:00 -0700 (PDT)
Message-ID: <1460064033.20338.74.camel@hpe.com>
Subject: Re: [PATCH] x86 get_unmapped_area: Add PMD alignment for DAX PMD
 mmap
From: Toshi Kani <toshi.kani@hpe.com>
Date: Thu, 07 Apr 2016 15:20:33 -0600
In-Reply-To: <20160407174111.GG2781@linux.intel.com>
References: <1459951089-14911-1-git-send-email-toshi.kani@hpe.com>
	 <20160406165027.GA2781@linux.intel.com> <1459964672.20338.41.camel@hpe.com>
	 <20160407174111.GG2781@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: mingo@kernel.org, bp@suse.de, hpa@zytor.com, tglx@linutronix.de, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, x86@kernel.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org

On Thu, 2016-04-07 at 13:41 -0400, Matthew Wilcox wrote:
> On Wed, Apr 06, 2016 at 11:44:32AM -0600, Toshi Kani wrote:
> > > 
> > > The NVML chooses appropriate addresses and gets a properly aligned
> > > address without any kernel code.
> >
> > An application like NVML can continue to specify a specific address to
> > mmap(). A Most existing applications, however, do not specify an address
> > to mmap(). A With this patch, specifying an address will remain
> > optional.
>
> The point is that this *can* be done in userspace.A A You need to sell us
> on the advantages of doing it in the kernel.

Sure. A As I said, the point is that we do not need to modify existing
applications for using DAX PMD mappings.

For instance, fio with "ioengine=mmap" performs I/Os with mmap().
https://github.com/caius/fio/blob/master/engines/mmap.c

With this change, unmodified fio can be used for testing with DAX PMD
mappings. A There are many examples like this, and I do not think we want to
modify all applications that we want to evaluate/test with.

> > > I think this is the wrong place for it, if we decide that this is the
> > > right thing to do.A A The filesystem has a get_unmapped_area() which
> > > should be used instead.
> >
> > Yes, I considered adding a filesystem entry point, but decided going
> > this way because:
> > A -A arch_get_unmapped_area() andA arch_get_unmapped_area_topdown() are
> > arch-specific code. A Therefore, this filesystem entry point will need
> > arch-specific implementation.A 
> > A - There is nothing filesystem specific about requesting PMD alignment.
>
> See http://article.gmane.org/gmane.linux.kernel.mm/149227 for Hugh's
> approach for shmem.A A I strongly believe that if we're going to do this
> i the kernel, we should build on this approach, and not hack something
> into each architecture's generic get_unmapped_area.

Thanks for the pointer. A Yes, we can call current->mm->get_unmapped_area()
with size + PMD_SIZE, and adjust with the alignment in a filesystem entry
point. A I will update the patch with this approach.

-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

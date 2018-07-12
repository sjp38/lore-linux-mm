Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 440AF6B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 03:26:18 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id 13-v6so38782584oiq.1
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 00:26:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r188-v6si13110308oig.400.2018.07.12.00.26.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 00:26:16 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6C7NoXN138418
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 03:26:16 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k60m4e5q9-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 03:26:15 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 12 Jul 2018 08:26:13 +0100
Date: Thu, 12 Jul 2018 10:26:07 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 11/11] docs/mm: add description of boot time memory
 management
References: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1530370506-21751-12-git-send-email-rppt@linux.vnet.ibm.com>
 <20180703122324.GA23824@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180703122324.GA23824@dhcp22.suse.cz>
Message-Id: <20180712072606.GB4422@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jonathan Corbet <corbet@lwn.net>, Randy Dunlap <rdunlap@infradead.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

Hi,

On Tue, Jul 03, 2018 at 02:23:24PM +0200, Michal Hocko wrote:
> On Sat 30-06-18 17:55:06, Mike Rapoport wrote:
> > Both bootmem and memblock are have pretty good internal documentation
> > coverage. With addition of some overview we get a nice description of the
> > early memory management.
> > 
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> 
> Yes this looks reasonable. I would just mention the available debugging
> options and CONFIG_ARCH_DISCARD_MEMBLOCK.

I'd really prefer to add it as a separate patch rather then resending the
whole series.

> Other than that looks goot to get a rough idea. Improvements can be done
> on top of course.
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks for the review. I think Jon was mostly concerned about the patch
"mm/memblock: add a name for memblock flags enumeration" [1]. Could you
please review it as well?

[1] https://lore.kernel.org/lkml/1530370506-21751-7-git-send-email-rppt@linux.vnet.ibm.com/

> > ---
> >  Documentation/core-api/boot-time-mm.rst | 92 +++++++++++++++++++++++++++++++++
> >  Documentation/core-api/index.rst        |  1 +
> >  2 files changed, 93 insertions(+)
> >  create mode 100644 Documentation/core-api/boot-time-mm.rst
> > 
> > diff --git a/Documentation/core-api/boot-time-mm.rst b/Documentation/core-api/boot-time-mm.rst
> > new file mode 100644
> > index 0000000..03cb164
> > --- /dev/null
> > +++ b/Documentation/core-api/boot-time-mm.rst
> > @@ -0,0 +1,92 @@
> > +===========================
> > +Boot time memory management
> > +===========================
> > +
> > +Early system initialization cannot use "normal" memory management
> > +simply because it is not set up yet. But there is still need to
> > +allocate memory for various data structures, for instance for the
> > +physical page allocator. To address this, a specialized allocator
> > +called the :ref:`Boot Memory Allocator <bootmem>`, or bootmem, was
> > +introduced. Several years later PowerPC developers added a "Logical
> > +Memory Blocks" allocator, which was later adopted by other
> > +architectures and renamed to :ref:`memblock <memblock>`. There is also
> > +a compatibility layer called `nobootmem` that translates bootmem
> > +allocation interfaces to memblock calls.
> > +
> > +The selection of the early allocator is done using
> > +``CONFIG_NO_BOOTMEM`` and ``CONFIG_HAVE_MEMBLOCK`` kernel
> > +configuration options. These options are enabled or disabled
> > +statically by the architectures' Kconfig files.
> > +
> > +* Architectures that rely only on bootmem select
> > +  ``CONFIG_NO_BOOTMEM=n && CONFIG_HAVE_MEMBLOCK=n``.
> > +* The users of memblock with the nobootmem compatibility layer set
> > +  ``CONFIG_NO_BOOTMEM=y && CONFIG_HAVE_MEMBLOCK=y``.
> > +* And for those that use both memblock and bootmem the configuration
> > +  includes ``CONFIG_NO_BOOTMEM=n && CONFIG_HAVE_MEMBLOCK=y``.
> > +
> > +Whichever allocator is used, it is the responsibility of the
> > +architecture specific initialization to set it up in
> > +:c:func:`setup_arch` and tear it down in :c:func:`mem_init` functions.
> > +
> > +Once the early memory management is available it offers a variety of
> > +functions and macros for memory allocations. The allocation request
> > +may be directed to the first (and probably the only) node or to a
> > +particular node in a NUMA system. There are API variants that panic
> > +when an allocation fails and those that don't. And more recent and
> > +advanced memblock even allows controlling its own behaviour.
> > +
> > +.. _bootmem:
> > +
> > +Bootmem
> > +=======
> > +
> > +(mostly stolen from Mel Gorman's "Understanding the Linux Virtual
> > +Memory Manager" `book`_)
> > +
> > +.. _book: https://www.kernel.org/doc/gorman/
> > +
> > +.. kernel-doc:: mm/bootmem.c
> > +   :doc: bootmem overview
> > +
> > +.. _memblock:
> > +
> > +Memblock
> > +========
> > +
> > +.. kernel-doc:: mm/memblock.c
> > +   :doc: memblock overview
> > +
> > +
> > +Functions and structures
> > +========================
> > +
> > +Common API
> > +----------
> > +
> > +The functions that are described in this section are available
> > +regardless of what early memory manager is enabled.
> > +
> > +.. kernel-doc:: mm/nobootmem.c
> > +
> > +Bootmem specific API
> > +--------------------
> > +
> > +These interfaces available only with bootmem, i.e when ``CONFIG_NO_BOOTMEM=n``
> > +
> > +.. kernel-doc:: include/linux/bootmem.h
> > +.. kernel-doc:: mm/bootmem.c
> > +   :nodocs:
> > +
> > +Memblock specific API
> > +---------------------
> > +
> > +Here is the description of memblock data structures, functions and
> > +macros. Some of them are actually internal, but since they are
> > +documented it would be silly to omit them. Besides, reading the
> > +descriptions for the internal functions can help to understand what
> > +really happens under the hood.
> > +
> > +.. kernel-doc:: include/linux/memblock.h
> > +.. kernel-doc:: mm/memblock.c
> > +   :nodocs:
> > diff --git a/Documentation/core-api/index.rst b/Documentation/core-api/index.rst
> > index f5a66b7..93d5a46 100644
> > --- a/Documentation/core-api/index.rst
> > +++ b/Documentation/core-api/index.rst
> > @@ -28,6 +28,7 @@ Core utilities
> >     printk-formats
> >     circular-buffers
> >     gfp_mask-from-fs-io
> > +   boot-time-mm
> >  
> >  Interfaces for kernel debugging
> >  ===============================
> > -- 
> > 2.7.4
> 
> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.

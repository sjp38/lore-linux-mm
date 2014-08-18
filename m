Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id D516A6B0035
	for <linux-mm@kvack.org>; Mon, 18 Aug 2014 15:58:23 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so8512849pab.1
        for <linux-mm@kvack.org>; Mon, 18 Aug 2014 12:58:23 -0700 (PDT)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id p6si23365040pds.184.2014.08.18.12.58.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 18 Aug 2014 12:58:22 -0700 (PDT)
Message-ID: <1408391280.26567.79.camel@misato.fc.hp.com>
Subject: Re: [RFC 9/9] prd: Add support for page struct mapping
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 18 Aug 2014 13:48:00 -0600
In-Reply-To: <53F07342.30006@gmail.com>
References: <53EB5536.8020702@gmail.com> <53EB5960.50200@plexistor.com>
	 <1408134524.26567.38.camel@misato.fc.hp.com> <53F07342.30006@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <openosd@gmail.com>
Cc: Boaz Harrosh <boaz@plexistor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

On Sun, 2014-08-17 at 12:17 +0300, Boaz Harrosh wrote:
> On 08/15/2014 11:28 PM, Toshi Kani wrote:
> > On Wed, 2014-08-13 at 15:26 +0300, Boaz Harrosh wrote:
> >> From: Yigal Korman <yigal@plexistor.com>
 :
> >> All is actually needed for this is to allocate page-sections
> >> and map them into kernel virtual memory. Note that these sections
> >> are not associated with any zone, because that would add them to
> >> the page_allocators.
> > 
> > Can we just use memory hotplug and call add_memory(), instead of
> > directly calling sparse_add_one_section()?  Memory hotplug adds memory
> > as off-line state, and sets all pages reserved.  So, I do not think the
> > page allocators will mess with them (unless you put them online).  It
> > can also maps the pages with large page size.
> > 
> > Thanks,
> > -Toshi
> > 
> 
> Thank you Toshi for your reply
> 
> I was thinking about that as well at first, but I was afraid, once I call
> add_memory() what will prevent the user from enabling that memory through the sysfs
> interface later, it looks to me that add_memory() will add all the necessary knobs
> to do it.
> 
> It is very important to keep a clear distinction, pmem is *not* memory what-so-ever
> it is however memory-mapped and needs these accesses enabled for it, hence the need
> for page-struct so we can DMA it off the buss.
> 
> I am very afraid of any thing that will associate a "zone" with this memory.
> Also the:
> 	firmware_map_add_hotplug(start, start + size, "System RAM");
> 
> "System RAM" it is not. 

I think add_memory() can be easily extended (or modified to provide a
separate interface) for persistent memory, and avoid creating the sysfs
interface and change the handling with firmware_map.  But I can also see
your point that persistent memory should not be added to zone at all.

Anyway, I am a bit concerned with the way to create direct mappings with
map_vm_area() within the prd driver.  Can we use init_memory_mapping()
as it's used by add_memory() and supports large page size?  The size of
persistent memory will grow up quickly.  Also, I'd prefer to have an mm
interface that takes care of page allocations and mappings, and avoid a
driver to deal with them.

> And also I think that for DDR4 NvDIMMs we will fail with:
> 	ret = check_hotplug_memory_range(start, size);
> 

Can you elaborate why DDR4 will fail with the function above?

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

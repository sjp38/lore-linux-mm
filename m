Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id E1C286B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 14:51:35 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id p63so2034754wmp.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 11:51:35 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id lk6si10455449wjb.21.2016.01.27.11.51.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 11:51:34 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id n5so263962wmn.3
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 11:51:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+ZsKJ5dRTtmqj-ErKn=hx8xqornAZ3i2kHWWNfLubrCQkZTiA@mail.gmail.com>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
	<1414185652-28663-11-git-send-email-matthew.r.wilcox@intel.com>
	<CA+ZsKJ7LgOjuZ091d-ikhuoA+ZrCny4xBGVupv0oai8yB5OqFQ@mail.gmail.com>
	<100D68C7BA14664A8938383216E40DE0421657C5@fmsmsx111.amr.corp.intel.com>
	<CA+ZsKJ4EMKRgdFQzUjRJOE48=tTJzHf66-60PnVRj7pxvmNgVg@mail.gmail.com>
	<20160125165209.GH2948@linux.intel.com>
	<CA+ZsKJ5dRTtmqj-ErKn=hx8xqornAZ3i2kHWWNfLubrCQkZTiA@mail.gmail.com>
Date: Wed, 27 Jan 2016 11:51:34 -0800
Message-ID: <CA+ZsKJ5_szQoJK_JMt_4KKTRsA9O_ksCTsGZzsTta6ZtB5Y1MQ@mail.gmail.com>
Subject: Re: [PATCH v12 10/20] dax: Replace XIP documentation with DAX documentation
From: Jared Hulbert <jaredeh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Carsten Otte <cotte@de.ibm.com>, Chris Brandt <Chris.Brandt@renesas.com>

On Mon, Jan 25, 2016 at 1:18 PM, Jared Hulbert <jaredeh@gmail.com> wrote:
> On Mon, Jan 25, 2016 at 8:52 AM, Matthew Wilcox <willy@linux.intel.com> wrote:
>> On Sun, Jan 24, 2016 at 01:03:49AM -0800, Jared Hulbert wrote:
>>> I our defense we didn't know we were sinning at the time.
>>
>> Fair enough.  Cache flushing is Hard.
>>
>>> Can you walk me through the cache flushing hole?  How is it okay on
>>> X86 but not VIVT archs?  I'm missing something obvious here.
>>>
>>> I thought earlier that vm_insert_mixed() handled the necessary
>>> flushing.  Is that even the part you are worried about?
>>
>> No, that part should be fine.  My concern is about write() calls to files
>> which are also mmaped.  See Documentation/cachetlb.txt around line 229,
>> starting with "There exists another whole class of cpu cache issues" ...
>
> oh wow.  So aren't all the copy_to/from_user() variants specifically
> supposed to handle such cases?
>
>>> What flushing functions would you call if you did have a cache page.
>>
>> Well, that's the problem; they don't currently exist.
>>
>>> There are all kinds of cache flushing functions that work without a
>>> struct page. If nothing else the specialized ASM instructions that do
>>> the various flushes don't use struct page as a parameter.  This isn't
>>> the first I've run into the lack of a sane cache API.  Grep for
>>> inval_cache in the mtd drivers, should have been much easier.  Isn't
>>> the proper solution to fix update_mmu_cache() or build out a pageless
>>> cache flushing API?
>>>
>>> I don't get the explicit mapping solution.  What are you mapping
>>> where?  What addresses would be SHMLBA?  Phys, kernel, userspace?
>>
>> The problem comes in dax_io() where the kernel stores to an alias of the
>> user address (or reads from an alias of the user address).  Theoretically,
>> we should flush user addresses before we read from the kernel's alias,
>> and flush the kernel's alias after we store to it.
>
> Reasoning this out loud here.  Please correct.
>
> For the dax read case:
> - kernel virt is mapped to pfn
> - data is memcpy'd from kernel virt
>
> For the dax write case:
> - kernel virt is mapped to pfn
> - data is memcpy'd to kernel virt
> - user virt map to pfn attempts to read
>
> Is that right?  I see the x86 does a nocache copy_to/from operation,
> I'm not familiar with the semantics of that call and it would take me
> a while to understand the assembly but I assume it's doing some magic
> opcodes that forces the writes down to physical memory with each
> load/store.  Does the the caching model of the x86 arch update the
> cache entries tied to the physical memory on update?
>
> For architectures that don't do auto coherency magic...
>
> For reads:
> - User dcaches need flushing before kernel virtual mapping to ensure
> kernel reads latest data.  If the user has unflushed data in the
> dcache it would not be reflected in the read copy.
> This failure mode only is a problem if the filesystem is RW.
>
> For writes:
> - Unlike the read case we don't need up to date data for the user's
> mapping of a pfn.  However, the user will need to caches invalidated
> to get fresh data, so we should make sure to writeback any affected
> lines in the user caches so they don't get lost if we do an
> invalidate.  I suppose uncommitted data might corrupt the new data
> written from the kernel mapping if the cachelines get flushed later.
> - After the data is memcpy'ed to the kernel virt map the cache, and
> possibly the write buffers, should be flushed.  Without this flush the
> data might not ever get to the user mapped versions.
> - Assuming the user maps were all flushed at the outset they should be
> reloaded with fresh data on access.
>
> Do I get it more or less?

I assume the silence means I don't get it.

Moving along...

The need to flush kernel aliases and user alias without a struct page
was articulated and cited as the reason why the DAX doesn't work with
ARM, MIPS, and SPARC.

One of the following routines should work for kernel flushing, right?
--  flush_cache_vmap(unsigned long start, unsigned long end)
--  flush_kernel_vmap_range(void *vaddr, int size)
--  invalidate_kernel_vmap_range(void *vaddr, int size)

For user aliases I'm less confident with here, but at first glance I
don't see why these wouldn't work?
-- flush_cache_page(struct vm_area_struct *vma, unsigned long addr,
unsigned long pfn)
-- flush_cache_range(struct vm_area_struct *vma, unsigned long start,
unsigned long end)

Help?!  I missing something here.

>> But if we create a new address for the kernel to use which lands on the
>> same cache line as the user's address (and this is what SHMLBA is used
>> to indicate), there is no incoherency between the kernel's view and the
>> user's view.  And no new cache flushing API is needed.
>
> So... how exactly would one force the kernel address to be at the
> SHMLBA boundary?
>
>> Is that clearer?  I'm not always good at explaining these things in a
>> way which makes sense to other people :-(
>
> Yeah.  I think I'm at 80% comprehension here.  Or at least I think I
> am.  Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

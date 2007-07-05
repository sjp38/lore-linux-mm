Message-ID: <468C634D.9050306@yahoo.com.au>
Date: Thu, 05 Jul 2007 13:19:41 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [BUGFIX][PATCH] DO flush icache before set_pte() on ia64.
References: <20070704150504.423f6c54.kamezawa.hiroyu@jp.fujitsu.com>	<468B3EAA.9070905@yahoo.com.au>	<20070704163826.d0b7465b.kamezawa.hiroyu@jp.fujitsu.com>	<468C51A7.3070505@yahoo.com.au> <20070705114726.2449f270.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070705114726.2449f270.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Mike.stroya@hp.com, GOTO <y-goto@jp.fujitsu.com>, dmosberger@gmail.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 05 Jul 2007 12:04:23 +1000
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>>>In my understanding :
>>>PG_arch_1 is used for showing "there is no inconsistent data on any level of
>>>cache". PG_uptodate is used for showing "this page includes the newest data
>>>and contents are valid."
>>>...maybe not used for the same purpose.
>>
>>I think that's right, but why is set_pte-time the critical point for the
>>flush? It is actually possible to write into an executable page via the
>>dcache *after* it has ptes pointing to it.
> 
> yes. I think there are 2 cases.
> - copy-on-write case..... OS handles this.
> - page is writable and app just rewrites it ...... the app should handle this.

Well it may not be "the" app, but any app on the system might write to
a page shared by any other app. OK we could just add the vague qualifier
about "don't do stupid stuff", but that should be only AFTER it is
determined that handling the corner cases is too hard.


>> From what I can work out, it is something like "at this point the page
>>should be uptodate, so at least the icache won't contain *inconsistent*
>>data, just old data which userspace should take care of flushing if it
>>modifies". Is that always true?
> 
>  
> I think it's true. But, in this case, i-cache doesn't contain *incositent* data.
> There are inconsistency between L2-Dcache and L3-mixed-cache. At L2-icache-miss,
> a cpu fetches data from L3 cache.
> This case seems defficult to be generalized...

If there is something in the icache line that isn't the last data to
be stored at that address, isn't that inconsistent?


>>Could the page get modified by means
>>other than a direct write(2)? And even in the case of a write(2) writer,
>>how do they know if another process is mapping that particular page for
>>exec at that time? Should they always flush? Flushing would require they
>>have a virtual address on the page to begin with anyway, doesn't it? So
>>they'd have to mmap it... phew.
>>
>>I guess it is mostly safe because it is probably very uncommon to do
>>such a thing, and chances are no non-write(2) write activity happens to
>>a page after it is brought uptodate. But I don't know if that has been
>>audited. I would really like to see the kernel always manage all aspects
>>of its pagecache though. I realise performance considerations may make
>>this not always possible... but it might be possible to do efficiently
>>using mapcount these days?
> 
> 
> generic_file_write() does flush_dcahe_page() but no flush_icache_page()...
> 
> Then..maybe this will be necessary...
> ==
> 	flush_dcache_page(page);
> 	if (page_mapcount(page) > 0 && page_is_mapped_as_text(page))
> 		flush_icache_page(page);
> ==
> But I don't know whether write(2) to mapped text file is expected to work well.

The point of the flush_dcache is that you have just written to dcache via
the kernel virtual address and need to handle any aliases. So if you did
want to handle this with ia64, you would do it all in flush_dcache_page.

flush_icache_page AFAIKS allows you to attempt some funny tricks to avoid
flushing @ flush_dcache_page-time. It is better than the lazy_mmu_update
thingy (because it is actually done in the right place -- ie. *before* the
set_pte), however it is still pretty tricky.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

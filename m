Date: Thu, 5 Jul 2007 11:47:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] DO flush icache before set_pte() on ia64.
Message-Id: <20070705114726.2449f270.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <468C51A7.3070505@yahoo.com.au>
References: <20070704150504.423f6c54.kamezawa.hiroyu@jp.fujitsu.com>
	<468B3EAA.9070905@yahoo.com.au>
	<20070704163826.d0b7465b.kamezawa.hiroyu@jp.fujitsu.com>
	<468C51A7.3070505@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Mike.stroya@hp.com, GOTO <y-goto@jp.fujitsu.com>, dmosberger@gmail.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 05 Jul 2007 12:04:23 +1000
Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> > In my understanding :
> > PG_arch_1 is used for showing "there is no inconsistent data on any level of
> > cache". PG_uptodate is used for showing "this page includes the newest data
> > and contents are valid."
> > ...maybe not used for the same purpose.
> 
> I think that's right, but why is set_pte-time the critical point for the
> flush? It is actually possible to write into an executable page via the
> dcache *after* it has ptes pointing to it.
yes. I think there are 2 cases.
- copy-on-write case..... OS handles this.
- page is writable and app just rewrites it ...... the app should handle this.

> 
>  From what I can work out, it is something like "at this point the page
> should be uptodate, so at least the icache won't contain *inconsistent*
> data, just old data which userspace should take care of flushing if it
> modifies". Is that always true?
 
I think it's true. But, in this case, i-cache doesn't contain *incositent* data.
There are inconsistency between L2-Dcache and L3-mixed-cache. At L2-icache-miss,
a cpu fetches data from L3 cache.
This case seems defficult to be generalized...


> Could the page get modified by means
> other than a direct write(2)? And even in the case of a write(2) writer,
> how do they know if another process is mapping that particular page for
> exec at that time? Should they always flush? Flushing would require they
> have a virtual address on the page to begin with anyway, doesn't it? So
> they'd have to mmap it... phew.
> 
> I guess it is mostly safe because it is probably very uncommon to do
> such a thing, and chances are no non-write(2) write activity happens to
> a page after it is brought uptodate. But I don't know if that has been
> audited. I would really like to see the kernel always manage all aspects
> of its pagecache though. I realise performance considerations may make
> this not always possible... but it might be possible to do efficiently
> using mapcount these days?

generic_file_write() does flush_dcahe_page() but no flush_icache_page()...

Then..maybe this will be necessary...
==
	flush_dcache_page(page);
	if (page_mapcount(page) > 0 && page_is_mapped_as_text(page))
		flush_icache_page(page);
==
But I don't know whether write(2) to mapped text file is expected to work well.

> > BTW, a page filled by DMA should have PG_arch_1 :(
> 
> The consequences of not are superfluous flushes?
> 
Yes, DMA flushes all levels of cache.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Subject: Re: [RFC] Limit the size of the pagecache
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=utf-8
Date: Wed, 24 Jan 2007 08:55:33 +0100
Message-Id: <1169625333.4493.16.camel@taijtu>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Aubrey Li <aubreylee@gmail.com>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Robin Getz <rgetz@blackfin.uclinux.org>, "Henn, erich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-01-23 at 16:49 -0800, Christoph Lameter wrote:
> This is a patch using some of Aubrey's work plugging it in what is IMHO 
> the right way. Feel free to improve on it. I have gotten repeatedly 
> requests to be able to limit the pagecache. With the revised VM statistics 
> this is now actually possile. I'd like to know more about possible uses of 
> such a feature.
> 
> 
> 
> 
> It may be useful to limit the size of the page cache for various reasons
> such as
> 
> 1. Insure that anonymous pages that may contain performance
>    critical data is never subject to swap.

This is what we have mlock for, no?

> 2. Insure rapid turnaround of pages in the cache.

This sounds like we either need more fadvise hints and/or understand why
the VM doesn't behave properly.

> 3. Reserve memory for other uses? (Aubrey?)

He wants to make a nommu system act like a mmu system; this will just
never ever work. Memory fragmentation is a real issue not some gimmick
thought up by the hardware folks to sell these mmu chips.

> We add a new variable "pagecache_ratio" to /proc/sys/vm/ that
> defaults to 100 (all memory usable for the pagecache).
> 
> The size of the pagecache is the number of file backed
> pages in a zone which is available through NR_FILE_PAGES.
> 
> We skip zones that contain too many page cache pages in
> the page allocator which may cause us to enter reclaim.
> 
> If we enter reclaim and the number of page cache pages
> is too high then we switch off swapping during reclaim
> to avoid touching anonymous pages.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Code looks nice, however earlier responses have raised good points. Esp.
the one pointing out you'd need to defeat swappiness too.

That said, I'm not much in favour of a limit pagecache knob.

Esp. the "my customers are scared of the 99.9% memory used scenario" is
a clear case of educate them. We don't go fix psychological problems
with code.

The only maybe valid point would be 2, and I'd like to see if we can't
solve that differently - a better use-once logic comes to mind.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

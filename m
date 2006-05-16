Message-ID: <4469D3F8.8020305@yahoo.com.au>
Date: Tue, 16 May 2006 23:30:32 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 00/14] remap_file_pages protection support
References: <20060430172953.409399000@zion.home.lan> <4456D5ED.2040202@yahoo.com.au> <200605030225.54598.blaisorblade@yahoo.it> <445CC949.7050900@redhat.com> <445D75EB.5030909@yahoo.com.au> <4465E981.60302@yahoo.com.au> <20060513181945.GC9612@goober>
In-Reply-To: <20060513181945.GC9612@goober>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Valerie Henson <val_henson@linux.intel.com>
Cc: Ulrich Drepper <drepper@redhat.com>, Blaisorblade <blaisorblade@yahoo.it>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, Val Henson <val.henson@intel.com>
List-ID: <linux-mm.kvack.org>

Valerie Henson wrote:
> On Sun, May 14, 2006 at 12:13:21AM +1000, Nick Piggin wrote:
> 
>>OK, I got interested again, but can't get Val's ebizzy to give me
>>a find_vma constrained workload yet (though the numbers back up
>>my assertion that the vma cache is crap for threaded apps).
> 
> 
> Hey Nick,
> 
> Glad to see you're using it!  There are (at least) two ways to do what
> you want:
> 
> 1. Increase the number of threads - this gives you two vma's per
>    thread, one for stack, one for guard page:
> 
>    $ ./ebizzy -t 100
> 
> 2. Apply the patch at the end of this email and use -p "prevent
>    coalescing", -m "always mmap" and appropriate number of chunks,
>    size, and records to search - this works for me:
> 
>    $ ./ebizzy -p -m -n 10000 -s 4096 -r 100000
> 
> The original program mmapped everything with the same permissions and
> no alignment restrictions, so all the mmaps were coalesced into one.
> This version alternates PROT_WRITE permissions on the mmap'd areas
> after they are written, so you get lots of vma's:
> 
> val@goober:~/ebizzy$ ./ebizzy -p -m -n 10000 -s 4096 -r 100000
> 
> [2]+  Stopped                 ./ebizzy -p -m -n 10000 -s 4096 -r 100000
> val@goober:~/ebizzy$ wc -l /proc/`pgrep ebizzy`/maps
> 10019 /proc/10917/maps
> 
> I haven't profiled to see if this brings find_vma to the top, though.
> 

Hi Val,

Thanks, I've tried with your most recent ebizzy and with 256 threads and
50,000 vmas (which gives really poor mmap_cache hits), I'm still unable
to get find_vma above a few % of kernel time.

With 50,000 vmas, my per-thread vma cache is much less effective, I guess
because access is pretty random (hopefully more realistic patterns would
get a bigger improvement).

I also tried running kbuild under UML, and could not make find_vma take
much time either [in this case, the per-thread vma cache patch roughly
doubles the number of hits, from about 15%->30% (in the host)].

So I guess it's time to go back into my hole. If anyone does come across
a find_vma constrained workload (especially with threads), I'd be very
interested.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

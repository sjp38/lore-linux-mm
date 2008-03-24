Subject: Re: [PATCH 3/6] compcache: TLSF Allocator interface
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <4cefeab80803241034m6f62c01fq669129db9959f47f@mail.gmail.com>
References: <200803242034.24264.nitingupta910@gmail.com>
	 <1206377777.6437.123.camel@lappy>
	 <4cefeab80803241034m6f62c01fq669129db9959f47f@mail.gmail.com>
Content-Type: text/plain
Date: Mon, 24 Mar 2008 19:56:53 +0100
Message-Id: <1206385013.6437.140.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nitin Gupta <nitingupta910@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-03-24 at 23:04 +0530, Nitin Gupta wrote:
> On Mon, Mar 24, 2008 at 10:26 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > On Mon, 2008-03-24 at 20:34 +0530, Nitin Gupta wrote:
> >  > Two Level Segregate Fit (TLSF) Allocator is used to allocate memory for
> >  > variable size compressed pages. Its fast and gives low fragmentation.
> >  > Following links give details on this allocator:
> >  >  - http://rtportal.upv.es/rtmalloc/files/tlsf_paper_spe_2007.pdf
> >  >  - http://code.google.com/p/compcache/wiki/TLSFAllocator
> >  >
> >  > This kernel port of TLSF (v2.3.2) introduces several changes but underlying
> >  > algorithm remains the same.
> >  >
> >  > Changelog TLSF v2.3.2 vs this kernel port
> >  >  - Pool now dynamically expands/shrinks.
> >  >    It is collection of contiguous memory regions.
> >  >  - Changes to pool create interface as a result of above change.
> >  >  - Collect and export stats (/proc/tlsfinfo)
> >  >  - Cleanups: kernel coding style, added comments, macros -> static inline, etc.
> >
> >  Can you explain why you need this allocator, why don't the current
> >  kernel allocators work for you?
> >
> >
> 
> kmalloc() allocates one of pre-defined sizes (as defined in
> kmalloc_sizes.h). This will surely cause severe fragmentation with
> these variable sized compressed pages.
> 
> Whereas, TLSF maintains very fine grained size lists. In all the
> workloads I tested, it showed <5% fragmentation. Also, its very simple
> as just ~700 LOC.

Yeah, it also suffers from a horrible coding style, can use excessive
amounts of vmalloc space, isn't hooked into the reclaim process as an
allocator should be and has a severe lack of per-cpu data making it a
pretty big bottleneck on anything with more than a few cores.

Now, it might be needed, might work better, and the scalability issue
might not be a problem when used for swap, but still, you don't treat
any of these points in your changelog.

FWIW, please split up the patches in a sane way. This series looks like
it wants to be 2 or 3 patches. The first introducing all of TLSF (this
split per file is horrible). The second doing all of the block device,
and a possible last doing documentation and such.

Also, how bad was kmalloc() compared to this TLSF, we need numbers :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

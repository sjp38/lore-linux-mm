Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 70BEB6B0008
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 10:44:55 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 31so12063552wrr.2
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 07:44:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 26sor921189edw.43.2018.03.27.07.44.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 07:44:53 -0700 (PDT)
Date: Tue, 27 Mar 2018 17:44:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCH 19/22] x86/mm: Implement free_encrypt_page()
Message-ID: <20180327144417.szgqjpa6wqzluppc@node.shutemov.name>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-20-kirill.shutemov@linux.intel.com>
 <a692b2ff-b590-b731-ad14-18238f471a1c@intel.com>
 <20180320125046.zcefctri5rzronau@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180320125046.zcefctri5rzronau@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 20, 2018 at 03:50:46PM +0300, Kirill A. Shutemov wrote:
> On Mon, Mar 05, 2018 at 11:07:16AM -0800, Dave Hansen wrote:
> > On 03/05/2018 08:26 AM, Kirill A. Shutemov wrote:
> > > +void free_encrypt_page(struct page *page, int keyid, unsigned int order)
> > > +{
> > > +	int i;
> > > +	void *v;
> > > +
> > > +	for (i = 0; i < (1 << order); i++) {
> > > +		v = kmap_atomic_keyid(page, keyid + i);
> > > +		/* See comment in prep_encrypt_page() */
> > > +		clflush_cache_range(v, PAGE_SIZE);
> > > +		kunmap_atomic(v);
> > > +	}
> > > +}
> > 
> > Have you measured how slow this is?
> 
> Well, it's pretty bad.
> 
> Tight loop of allocation/free a page (measured from within kernel) is
> 4-6 times slower:
> 
> Encryption off
> Order-0, 10000000 iterations: 50496616 cycles
> Order-0, 10000000 iterations: 46900080 cycles
> Order-0, 10000000 iterations: 46873540 cycles
> 
> Encryption on
> Order-0, 10000000 iterations: 222021882 cycles
> Order-0, 10000000 iterations: 222315381 cycles
> Order-0, 10000000 iterations: 222289110 cycles
> 
> Encryption off
> Order-9, 100000 iterations: 46829632 cycles
> Order-9, 100000 iterations: 46919952 cycles
> Order-9, 100000 iterations: 37647873 cycles
> 
> Encryption on
> Order-9, 100000 iterations: 222407715 cycles
> Order-9, 100000 iterations: 222111657 cycles
> Order-9, 100000 iterations: 222335352 cycles
> 
> On macro benchmark it's not that dramatic, but still bad -- 16% down:
> 
> Encryption off
> 
>  Performance counter stats for 'sh -c make -j100 -B -k >/dev/null' (5 runs):
> 
>     6769369.623773      task-clock (msec)         #   33.869 CPUs utilized            ( +-  0.02% )
>          1,086,729      context-switches          #    0.161 K/sec                    ( +-  0.83% )
>            193,153      cpu-migrations            #    0.029 K/sec                    ( +-  0.72% )
>        104,971,541      page-faults               #    0.016 M/sec                    ( +-  0.01% )
> 20,179,502,944,932      cycles                    #    2.981 GHz                      ( +-  0.02% )
> 15,244,481,306,390      stalled-cycles-frontend   #   75.54% frontend cycles idle     ( +-  0.02% )
> 11,548,852,154,412      instructions              #    0.57  insn per cycle
>                                                   #    1.32  stalled cycles per insn  ( +-  0.00% )
>  2,488,836,449,779      branches                  #  367.661 M/sec                    ( +-  0.00% )
>     94,445,965,563      branch-misses             #    3.79% of all branches          ( +-  0.01% )
> 
>      199.871815231 seconds time elapsed                                          ( +-  0.17% )
> 
> Encryption on
> 
>  Performance counter stats for 'sh -c make -j100 -B -k >/dev/null' (5 runs):
> 
>     8099514.432371      task-clock (msec)         #   34.959 CPUs utilized            ( +-  0.01% )
>          1,169,589      context-switches          #    0.144 K/sec                    ( +-  0.51% )
>            198,008      cpu-migrations            #    0.024 K/sec                    ( +-  0.77% )
>        104,953,906      page-faults               #    0.013 M/sec                    ( +-  0.01% )
> 24,158,282,050,086      cycles                    #    2.983 GHz                      ( +-  0.01% )
> 19,183,031,041,329      stalled-cycles-frontend   #   79.41% frontend cycles idle     ( +-  0.01% )
> 11,600,772,560,767      instructions              #    0.48  insn per cycle
>                                                   #    1.65  stalled cycles per insn  ( +-  0.00% )
>  2,501,453,131,164      branches                  #  308.840 M/sec                    ( +-  0.00% )
>     94,566,437,048      branch-misses             #    3.78% of all branches          ( +-  0.01% )
> 
>      231.684539584 seconds time elapsed                                          ( +-  0.15% )
> 
> I'll check what we can do here.

Okay, I've rework the patchset (will post later) to store KeyID per-page
in page_ext->flags. The KeyID is preserved for freed pages and we can
avoid cache flushing if the new KeyID we want to use for the page matches
the previous one.

With the change microbenchmark I used before is useless as it will keep
allocating the same page avoiding cache flushes all the time.

On macrobenchmark (kernel build) we still see slow down, but it's ~3.6%
instead of 16%.  It's more acceptable.

I guess we can do better than this and I will look more into performance
once whole stack will be functional.

 Performance counter stats for 'sh -c make -j100 -B -k >/dev/null' (5 runs):

    7045275.657792      task-clock (msec)         #   34.007 CPUs utilized            ( +-  0.02% )
         1,122,659      context-switches          #    0.159 K/sec                    ( +-  0.50% )
           197,678      cpu-migrations            #    0.028 K/sec                    ( +-  0.50% )
       104,958,956      page-faults               #    0.015 M/sec                    ( +-  0.01% )
21,003,977,611,574      cycles                    #    2.981 GHz                      ( +-  0.02% )
16,057,772,099,500      stalled-cycles-frontend   #   76.45% frontend cycles idle     ( +-  0.02% )
11,563,935,077,599      instructions              #    0.55  insn per cycle
                                                  #    1.39  stalled cycles per insn  ( +-  0.00% )
 2,492,841,089,612      branches                  #  353.832 M/sec                    ( +-  0.00% )
    94,613,299,643      branch-misses             #    3.80% of all branches          ( +-  0.02% )

     207.171360888 seconds time elapsed                                          ( +-  0.07% )

-- 
 Kirill A. Shutemov

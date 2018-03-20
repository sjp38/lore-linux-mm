Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 04D066B0009
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 08:51:17 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d23so857444wmd.1
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 05:51:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c5sor1931263ede.41.2018.03.20.05.51.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Mar 2018 05:51:15 -0700 (PDT)
Date: Tue, 20 Mar 2018 15:50:46 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCH 19/22] x86/mm: Implement free_encrypt_page()
Message-ID: <20180320125046.zcefctri5rzronau@node.shutemov.name>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-20-kirill.shutemov@linux.intel.com>
 <a692b2ff-b590-b731-ad14-18238f471a1c@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a692b2ff-b590-b731-ad14-18238f471a1c@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 05, 2018 at 11:07:16AM -0800, Dave Hansen wrote:
> On 03/05/2018 08:26 AM, Kirill A. Shutemov wrote:
> > +void free_encrypt_page(struct page *page, int keyid, unsigned int order)
> > +{
> > +	int i;
> > +	void *v;
> > +
> > +	for (i = 0; i < (1 << order); i++) {
> > +		v = kmap_atomic_keyid(page, keyid + i);
> > +		/* See comment in prep_encrypt_page() */
> > +		clflush_cache_range(v, PAGE_SIZE);
> > +		kunmap_atomic(v);
> > +	}
> > +}
> 
> Have you measured how slow this is?

Well, it's pretty bad.

Tight loop of allocation/free a page (measured from within kernel) is
4-6 times slower:

Encryption off
Order-0, 10000000 iterations: 50496616 cycles
Order-0, 10000000 iterations: 46900080 cycles
Order-0, 10000000 iterations: 46873540 cycles

Encryption on
Order-0, 10000000 iterations: 222021882 cycles
Order-0, 10000000 iterations: 222315381 cycles
Order-0, 10000000 iterations: 222289110 cycles

Encryption off
Order-9, 100000 iterations: 46829632 cycles
Order-9, 100000 iterations: 46919952 cycles
Order-9, 100000 iterations: 37647873 cycles

Encryption on
Order-9, 100000 iterations: 222407715 cycles
Order-9, 100000 iterations: 222111657 cycles
Order-9, 100000 iterations: 222335352 cycles

On macro benchmark it's not that dramatic, but still bad -- 16% down:

Encryption off

 Performance counter stats for 'sh -c make -j100 -B -k >/dev/null' (5 runs):

    6769369.623773      task-clock (msec)         #   33.869 CPUs utilized            ( +-  0.02% )
         1,086,729      context-switches          #    0.161 K/sec                    ( +-  0.83% )
           193,153      cpu-migrations            #    0.029 K/sec                    ( +-  0.72% )
       104,971,541      page-faults               #    0.016 M/sec                    ( +-  0.01% )
20,179,502,944,932      cycles                    #    2.981 GHz                      ( +-  0.02% )
15,244,481,306,390      stalled-cycles-frontend   #   75.54% frontend cycles idle     ( +-  0.02% )
11,548,852,154,412      instructions              #    0.57  insn per cycle
                                                  #    1.32  stalled cycles per insn  ( +-  0.00% )
 2,488,836,449,779      branches                  #  367.661 M/sec                    ( +-  0.00% )
    94,445,965,563      branch-misses             #    3.79% of all branches          ( +-  0.01% )

     199.871815231 seconds time elapsed                                          ( +-  0.17% )

Encryption on

 Performance counter stats for 'sh -c make -j100 -B -k >/dev/null' (5 runs):

    8099514.432371      task-clock (msec)         #   34.959 CPUs utilized            ( +-  0.01% )
         1,169,589      context-switches          #    0.144 K/sec                    ( +-  0.51% )
           198,008      cpu-migrations            #    0.024 K/sec                    ( +-  0.77% )
       104,953,906      page-faults               #    0.013 M/sec                    ( +-  0.01% )
24,158,282,050,086      cycles                    #    2.983 GHz                      ( +-  0.01% )
19,183,031,041,329      stalled-cycles-frontend   #   79.41% frontend cycles idle     ( +-  0.01% )
11,600,772,560,767      instructions              #    0.48  insn per cycle
                                                  #    1.65  stalled cycles per insn  ( +-  0.00% )
 2,501,453,131,164      branches                  #  308.840 M/sec                    ( +-  0.00% )
    94,566,437,048      branch-misses             #    3.78% of all branches          ( +-  0.01% )

     231.684539584 seconds time elapsed                                          ( +-  0.15% )

I'll check what we can do here.

-- 
 Kirill A. Shutemov

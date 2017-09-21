Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B4AE16B0033
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 16:05:45 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 11so13355037pge.4
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 13:05:45 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id i193si1517502pgc.806.2017.09.21.13.05.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Sep 2017 13:05:44 -0700 (PDT)
Date: Thu, 21 Sep 2017 13:05:43 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] KSM: Replace jhash2 with xxhash
Message-ID: <20170921200543.GH4311@tassilo.jf.intel.com>
References: <20170921074519.9333-1-nefelim4ag@gmail.com>
 <8760ccdpwm.fsf@linux.intel.com>
 <CAGqmi74Qi0VRKG87N4txEZRaZ3JHYW8622E0KhKynRYuD56J=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGqmi74Qi0VRKG87N4txEZRaZ3JHYW8622E0KhKynRYuD56J=g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: linux-mm@kvack.org

> > Which CPU is that?
> 
> Intel(R) Core(TM) i5-7200U CPU @ 2.50GHz
> ---
> I've access to some VM (Not KVM) with:
> Intel(R) Xeon(R) CPU E5-2420 0 @ 1.90GHz
> PAGE_SIZE: 4096, loop count: 1048576
> jhash2:   0x15433d14            time: 3661 ms,  th: 1173.144082 MiB/s
> xxhash32: 0x3df3de36            time: 1163 ms,  th: 3691.581922 MiB/s
> xxhash64: 0x5d9e67755d3c9a6a    time: 715 ms,   th: 6006.628034 MiB/s
> 
> As additional info, xxhash work with ~ same as jhash2 speed at 32 byte
> input data.
> For input smaller than 32 byte, jhash2 win, for input bigger, xxhash win.

Please put that information into the changelog when you repost.

> 
> 
> >> So replace jhash with xxhash,
> >> and use fastest version for current target ARCH.
> >
> > Can you do some macro-benchmarking too? Something that uses
> > KSM and show how the performance changes.
> >
> > You could manually increase the scan rate to make it easier
> > to see.
> 
> Try use that patch with my patch to allow process all VMA on system [1].
> I switch sleep_millisecs 20 -> 1
> 
> (I use htop to see CPU load of ksmd)
> 
> CPU: Intel(R) Xeon(R) CPU E5-2420 0 @ 1.90GHz
> For jhash2: ~18%
> For xxhash64: ~11%

Ok that's a great result. Is a speedup also visible with the default
sleep_millisecs value? 

> >> @@ -51,6 +52,12 @@
> >>  #define DO_NUMA(x)   do { } while (0)
> >>  #endif
> >>
> >> +#if BITS_PER_LONG == 64
> >> +typedef      u64     xxhash;
> >> +#else
> >> +typedef      u32     xxhash;
> >> +#endif
> >
> > This should be in xxhash.h ?
> 
> This is a "hack", for compile time chose appropriate hash function.
> xxhash ported from upstream code,
> upstream version don't do that (IMHO), as this useless in most cases.
> That only can be useful for memory only hashes.
> Because for persistent data it's obvious to always use one hash type 32/64.

I don't think it's a hack. It makes sense. Just should be done centrally
in Linux, not in a specific user.
> 
> > xxhash_t would seem to be a better name.
> >
> >> -     u32 checksum;
> >> +     xxhash checksum;
> >>       void *addr = kmap_atomic(page);
> >> -     checksum = jhash2(addr, PAGE_SIZE / 4, 17);
> >> +#if BITS_PER_LONG == 64
> >> +     checksum = xxh64(addr, PAGE_SIZE, 0);
> >> +#else
> >> +     checksum = xxh32(addr, PAGE_SIZE, 0);
> >> +#endif
> >
> > This should also be generic in xxhash.h
> 
> This *can* be generic in xxhash.h, when that solution will be used
> somewhere in the kernel code, not in the KSM only, not?

Yes.

> 
> Because for now i didn't find other places with "big enough" input
> data, to replace jhash2 with xxhash.

Right, but we may get them.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

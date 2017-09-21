Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C1486B0033
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 18:07:01 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p5so13816504pgn.7
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 15:07:01 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id u9si1705951pge.605.2017.09.21.15.07.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Sep 2017 15:07:00 -0700 (PDT)
Date: Thu, 21 Sep 2017 15:06:59 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] KSM: Replace jhash2 with xxhash
Message-ID: <20170921220659.GI4311@tassilo.jf.intel.com>
References: <20170921074519.9333-1-nefelim4ag@gmail.com>
 <8760ccdpwm.fsf@linux.intel.com>
 <CAGqmi74Qi0VRKG87N4txEZRaZ3JHYW8622E0KhKynRYuD56J=g@mail.gmail.com>
 <20170921200543.GH4311@tassilo.jf.intel.com>
 <CAGqmi76=ntcE5tvYGKOQynpTfUfUotwXZQuU4iUC+H_6rua7Yw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGqmi76=ntcE5tvYGKOQynpTfUfUotwXZQuU4iUC+H_6rua7Yw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: linux-mm@kvack.org

On Fri, Sep 22, 2017 at 12:37:25AM +0300, Timofey Titovets wrote:
> With defaults:
> jhash2: ~4.7%
> xxhash64: ~3.3%
> 
> 3.3/4.7 ~= 0.7 -> Profit: ~30%
> 11/18   ~= 0.6 -> Profit: ~40%
> (if i calculate correctly of course)

Sounds good.

Please add all performance information to the changelog.

> 
> >> >> @@ -51,6 +52,12 @@
> >> >>  #define DO_NUMA(x)   do { } while (0)
> >> >>  #endif
> >> >>
> >> >> +#if BITS_PER_LONG == 64
> >> >> +typedef      u64     xxhash;
> >> >> +#else
> >> >> +typedef      u32     xxhash;
> >> >> +#endif
> >> >
> >> > This should be in xxhash.h ?
> >>
> >> This is a "hack", for compile time chose appropriate hash function.
> >> xxhash ported from upstream code,
> >> upstream version don't do that (IMHO), as this useless in most cases.
> >> That only can be useful for memory only hashes.
> >> Because for persistent data it's obvious to always use one hash type 32/64.
> >
> > I don't think it's a hack. It makes sense. Just should be done centrally
> > in Linux, not in a specific user.
> 
> So, i must add separate patch for xxhash.h?

Yes.

> If yes, may be you can suggest which list must be in copy?
> (i can't find any info about maintainers of ./lib/ in MAINTAINERS)

Just copy linux-kernel. It would be all merged together.

> If we decide to patch xxhash.h,
> may be that will be better to wrap above if-else by something like:
> /*
>  * Only for in memory use
>  */
> xxhash_t xxhash(const void *input, size_t length, uint64_t seed);

Yes that's fine.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 95DFC6B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 21:19:31 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id m200-v6so6480783ywd.20
        for <linux-mm@kvack.org>; Mon, 21 May 2018 18:19:31 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id g205-v6si3720673ywa.444.2018.05.21.18.19.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 21 May 2018 18:19:30 -0700 (PDT)
Date: Mon, 21 May 2018 21:19:20 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: Why do we let munmap fail?
Message-ID: <20180522011920.GA29393@thunk.org>
References: <e6bdfa05-fa80-41d1-7b1d-51cf7e4ac9a1@intel.com>
 <CAKOZuev=Pa6FkvxTPbeA1CcYG+oF2JM+JVL5ELHLZ--7wyr++g@mail.gmail.com>
 <20eeca79-0813-a921-8b86-4c2a0c98a1a1@intel.com>
 <CAKOZuesoh7svdmdNY9md3N+vWGurigDLZ5_xDjwgU=uYdKkwqg@mail.gmail.com>
 <2e7fb27e-90b4-38d2-8ae1-d575d62c5332@intel.com>
 <CAKOZueu8ckN1b-cYOxPhL5f7Bdq+LLRP20NK3x7Vtw79oUT3pg@mail.gmail.com>
 <20c9acc2-fbaf-f02d-19d7-2498f875e4c0@intel.com>
 <CAKOZuesScfm_5=2FYurY3ojdhQtcwPWY+=hayJ5cG7pQU1LP9g@mail.gmail.com>
 <20180522002239.GA4860@bombadil.infradead.org>
 <CAKOZuevBprpJ-fVKGCmuQz3dTMjKRfqp-cUuCyUzdkuQTQRNoQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZuevBprpJ-fVKGCmuQz3dTMjKRfqp-cUuCyUzdkuQTQRNoQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>
Cc: willy@infradead.org, dave.hansen@intel.com, linux-mm@kvack.org, Tim Murray <timmurray@google.com>, Minchan Kim <minchan@kernel.org>

On Mon, May 21, 2018 at 05:38:06PM -0700, Daniel Colascione wrote:
> 
> One approach to dealing with this badness, the one I proposed earlier, is
> to prevent that giant mmap from appearing in the first place (because we'd
> cap vsize). If that giant mmap never appears, you can't generate a huge VMA
> tree by splitting it.
> 
> Maybe that's not a good approach. Maybe processes really need mappings that
> big. If they do, then maybe the right approach is to just make 8 billion
> VMAs not "DoS the system". What actually goes wrong if we just let the VMA
> tree grow that large? So what if VMA lookup ends up taking a while --- the
> process with the pathological allocation pattern is paying the cost, right?
>

Fine.  Let's pick a more reasonable size --- say, 1GB.  That's still
2**18 4k pages.  Someone who munmap's every other 4k page is going to
create 2**17 VMA's.  That's a lot of VMA's.  So now the question is do
we pre-preserve enough VMA's for this worst case scenario, for all
processes in the system?  Or do we fail or otherwise kill the process
who is clearly attempting a DOS attack on the system?

If your goal is that munmap must ***never*** fail, then effectively
you have to preserve enough resources for 50% of all 4k pages in all
of the virtual address spaces in use by all of the processes in the
system.  That's a horrible waste of resources, just to guarantee that
munmap(2) must never fail.

Personally, I think it's not worth it.

Why is it so important to you that munmap(2) must not fail?  Is it not
enough to say that if you mmap(2) a region, if you munmap(2) that
exact same size region as you mmap(2)'ed, it must not fail?  That's a
much easier guarantee to make....

						- Ted

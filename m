Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A68806B0365
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 15:05:43 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id r103so7090390wrb.0
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 12:05:43 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id y123si1908856wmd.16.2017.06.22.12.05.42
        for <linux-mm@kvack.org>;
        Thu, 22 Jun 2017 12:05:42 -0700 (PDT)
Date: Thu, 22 Jun 2017 21:05:22 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 06/11] x86/mm: Rework lazy TLB mode and TLB freshness
 tracking
Message-ID: <20170622190522.ou2wiyepupiasi2a@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org>
 <70f3a61658aa7c1c89f4db6a4f81d8df9e396ade.1498022414.git.luto@kernel.org>
 <20170622145013.n3slk7ip6wpany5d@pd.tnic>
 <CALCETrUA-+9ORRXFrYdyEg5ZQOEbDFrwq4uuRWDb89V49QRBWw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALCETrUA-+9ORRXFrYdyEg5ZQOEbDFrwq4uuRWDb89V49QRBWw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Mike Travis <mike.travis@hpe.com>, Dimitri Sivanich <sivanich@hpe.com>, Andrew Banman <abanman@hpe.com>

On Thu, Jun 22, 2017 at 10:47:29AM -0700, Andy Lutomirski wrote:
> I figured that some future reader of this patch might actually want to
> see this text, though.

Oh, don't get me wrong: with commit messages more is more, in the
general case. That's why I said "if".

> >> The UV tlbflush code is rather dated and should be changed.
> 
> And I'd definitely like the UV maintainers to notice this part, now or
> in the future :)  I don't want to personally touch the UV code with a
> ten-foot pole, but it really should be updated by someone who has a
> chance of getting it right and being able to test it.

Ah, could be because they moved recently and have hpe addresses now.
Lemme add them.

> >> +
> >> +     if (cpumask_test_cpu(cpu, mm_cpumask(mm)))
> >> +             cpumask_clear_cpu(cpu, mm_cpumask(mm));
> >
> > It seems we haz a helper for that: cpumask_test_and_clear_cpu() which
> > does BTR straightaway.
> 
> Yeah, but I'm doing this for performance.  I think that all the
> various one-line helpers do a LOCKed op right away, and I think it's
> faster to see if we can avoid the LOCKed op by trying an ordinary read
> first.

Right, the test part of the operation is unlocked so if that is the
likely case, it is a win.

> OTOH, maybe this is misguided -- if the cacheline lives somewhere else
> and we do end up needing to update it, we'll end up first sharing it
> and then making it exclusive, which increases the amount of cache
> coherency traffic, so maybe I'm optimizing for the wrong thing. What
> do you think?

Yeah, but we'll have to do that anyway for the locked operation. Ok,
let's leave it split like it is.

> It did in one particular buggy incarnation.  It would also trigger if,
> say, suspend/resume corrupts CR3.  Admittedly this is unlikely, but
> I'd rather catch it.  Once PCID is on, corruption seems a bit less
> farfetched -- this assertion will catch anyone who accidentally does
> write_cr3(read_cr3_pa()).

Ok, but let's put a comment over it pls as it is not obvious when
something like that can happen.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

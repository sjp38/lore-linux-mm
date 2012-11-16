Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id ECBF86B004D
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 13:04:09 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so2195434eek.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 10:04:08 -0800 (PST)
Date: Fri, 16 Nov 2012 19:04:04 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 06/43] mm: numa: Make pte_numa() and pmd_numa() a generic
 implementation
Message-ID: <20121116180404.GA4728@gmail.com>
References: <1353064973-26082-1-git-send-email-mgorman@suse.de>
 <1353064973-26082-7-git-send-email-mgorman@suse.de>
 <50A648FF.2040707@redhat.com>
 <20121116144109.GA8218@suse.de>
 <CA+55aFzH_-6FuwTF1GVDzLK+7c0MGLsLdPFjzzwU78GVUEMbBw@mail.gmail.com>
 <20121116160852.GA4302@gmail.com>
 <20121116165606.GE8218@suse.de>
 <20121116171243.GA4697@gmail.com>
 <20121116174853.GF8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121116174853.GF8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> That said, your approach just ends up being heavier. [...]

Well, it's more fundamental than just whether to inline or not 
(which I think should be a separate optimization and I won't 
object to two-instruction variants the slightest) - but you 
ended up open-coding change_protection() 
via:

   change_prot_numa_range() et al

which is a far bigger problem...

Do you have valid technical arguments in favor of that 
duplication?

If you just embrace the PROT_NONE reuse approach of numa/core 
then 90% of the differences in your tree will disappear and 
you'll have a code base very close to where numa/core was 3 
weeks ago already, modulo a handful of renames.

It's not like PROT_NONE will go away anytime soon.

PROT_NONE is available on every architecture, and we use the 
exact semantics of it in the scheduler, we just happen to drive 
it from a special worklet instead of a syscall, and happen to 
have a callback to the faults when they happen...

Please stay open to that approach.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

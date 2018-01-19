Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 090826B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:55:25 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id n2so1781906pgs.0
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 04:55:25 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y20si8002470pgv.215.2018.01.19.04.55.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 19 Jan 2018 04:55:23 -0800 (PST)
Date: Fri, 19 Jan 2018 04:55:03 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Message-ID: <20180119125503.GA2897@bombadil.infradead.org>
References: <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
 <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
 <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <201801181712.BFD13039.LtHOSVMFJQFOFO@I-love.SAKURA.ne.jp>
 <20180118122550.2lhsjx7hg5drcjo4@node.shutemov.name>
 <d8347087-18a6-1709-8aa8-3c6f2d16aa94@linux.intel.com>
 <20180118145830.GA6406@redhat.com>
 <20180118165629.kpdkezarsf4qymnw@node.shutemov.name>
 <CA+55aFy43ypm0QvA5SqNR4O0ZJETbkR3NDR=dnSdvejc_nmSJQ@mail.gmail.com>
 <20180118234955.nlo55rw2qsfnavfm@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180118234955.nlo55rw2qsfnavfm@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Tony Luck <tony.luck@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>

On Fri, Jan 19, 2018 at 02:49:55AM +0300, Kirill A. Shutemov wrote:
> > So that's why you can't do pointer diffs between two arrays. Not
> > because you can't subtract the two pointers, but because the
> > *division* part of the C pointer diff rules leads to issues.
> 
> Thanks a lot for the explanation!
> 
> I wounder if this may be a problem in other places?
> 
> For instance, perf uses address of a mutex to determinate the lock
> ordering. See mutex_lock_double(). The mutex is embedded into struct
> perf_event_context, which is allocated with kzalloc() so I don't see how
> we can presume that alignment is consistent between them.
> 
> I don't think it's the only example in kernel. Are we just lucky?

If you're just *comparing* the addresses of two objects, GCC doesn't
care what the size of the object is.  ie there's a difference between
'if (b < a)' and 'if ((a - b) < n)'.

But yes, if you go by the strict wording of the standard:

  When two pointers are compared, the result depends on the relative
  locations in the address space of the objects pointed to. [...] In
  all other cases, the behavior is undefined

http://www.open-std.org/jtc1/sc22/WG14/www/docs/n1256.pdf

So really we should be casting 'b' and 'a' to uintptr_t to be fully
compliant with the spec.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

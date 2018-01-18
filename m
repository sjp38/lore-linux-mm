Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA3026B0038
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 18:50:03 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id f3so54963wmc.8
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 15:50:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y8sor5475456edb.5.2018.01.18.15.50.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jan 2018 15:50:02 -0800 (PST)
Date: Fri, 19 Jan 2018 02:49:55 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Message-ID: <20180118234955.nlo55rw2qsfnavfm@node.shutemov.name>
References: <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
 <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
 <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
 <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <201801181712.BFD13039.LtHOSVMFJQFOFO@I-love.SAKURA.ne.jp>
 <20180118122550.2lhsjx7hg5drcjo4@node.shutemov.name>
 <d8347087-18a6-1709-8aa8-3c6f2d16aa94@linux.intel.com>
 <20180118145830.GA6406@redhat.com>
 <20180118165629.kpdkezarsf4qymnw@node.shutemov.name>
 <CA+55aFy43ypm0QvA5SqNR4O0ZJETbkR3NDR=dnSdvejc_nmSJQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFy43ypm0QvA5SqNR4O0ZJETbkR3NDR=dnSdvejc_nmSJQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Tony Luck <tony.luck@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>

On Thu, Jan 18, 2018 at 09:26:25AM -0800, Linus Torvalds wrote:
> On Thu, Jan 18, 2018 at 8:56 AM, Kirill A. Shutemov
> <kirill@shutemov.name> wrote:
> >
> > I can't say I fully grasp how 'diff' got this value and how it leads to both
> > checks being false.
> 
> I think the problem is that page difference when they are in different sections.
> 
> When you do
> 
>      pte_page(*pvmw->pte) - pvmw->page
> 
> then the compiler takes the pointer difference, and then divides by
> the size of "struct page" to get an index.
> 
> But - and this is important - it does so knowing that the division it
> does will have no modulus: the two 'struct page *' pointers are really
> in the same array, and they really are 'n*sizeof(struct page)' apart
> for some 'n'.
> 
> That means that the compiler can optimize the division. In fact, for
> this case, gcc will generate
> 
>         subl    %ebx, %eax
>         sarl    $3, %eax
>         imull   $-858993459, %eax, %eax
> 
> because 'struct page' is 40 bytes in size, and that magic sequence
> happens to divide by 40 (first divide by 8, then that magical "imull"
> will divide by 5 *IFF* the thing is evenly divisible by 5 (and not too
> big - but the shift guarantees that).
> 
> Basically, it's a magic trick, because real divides are very
> expensive, but you can fake them more quickly if you can limit the
> input domain.
> 
> But what does it mean if the two "struct page *" are not in the same
> array, and the two arrays were allocated not aligned exactly 40 bytes
> away, but some random number of pages away?
> 
> You get *COMPLETE*GARBAGE* when you do the above optimized divide.
> Suddenly the divide had a modulus (because the base of the two arrays
> weren't 40-byte aligned), and the "trick" doesn't work.
> 
> So that's why you can't do pointer diffs between two arrays. Not
> because you can't subtract the two pointers, but because the
> *division* part of the C pointer diff rules leads to issues.

Thanks a lot for the explanation!

I wounder if this may be a problem in other places?

For instance, perf uses address of a mutex to determinate the lock
ordering. See mutex_lock_double(). The mutex is embedded into struct
perf_event_context, which is allocated with kzalloc() so I don't see how
we can presume that alignment is consistent between them.

I don't think it's the only example in kernel. Are we just lucky?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

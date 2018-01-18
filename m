Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2BE7D6B0069
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 12:26:28 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id b184so8128074iof.21
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 09:26:28 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g141sor3626001ioe.96.2018.01.18.09.26.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jan 2018 09:26:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180118165629.kpdkezarsf4qymnw@node.shutemov.name>
References: <201801160115.w0G1FOIG057203@www262.sakura.ne.jp>
 <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
 <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
 <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
 <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <201801181712.BFD13039.LtHOSVMFJQFOFO@I-love.SAKURA.ne.jp>
 <20180118122550.2lhsjx7hg5drcjo4@node.shutemov.name> <d8347087-18a6-1709-8aa8-3c6f2d16aa94@linux.intel.com>
 <20180118145830.GA6406@redhat.com> <20180118165629.kpdkezarsf4qymnw@node.shutemov.name>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 18 Jan 2018 09:26:25 -0800
Message-ID: <CA+55aFy43ypm0QvA5SqNR4O0ZJETbkR3NDR=dnSdvejc_nmSJQ@mail.gmail.com>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Tony Luck <tony.luck@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>

On Thu, Jan 18, 2018 at 8:56 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
>
> I can't say I fully grasp how 'diff' got this value and how it leads to both
> checks being false.

I think the problem is that page difference when they are in different sections.

When you do

     pte_page(*pvmw->pte) - pvmw->page

then the compiler takes the pointer difference, and then divides by
the size of "struct page" to get an index.

But - and this is important - it does so knowing that the division it
does will have no modulus: the two 'struct page *' pointers are really
in the same array, and they really are 'n*sizeof(struct page)' apart
for some 'n'.

That means that the compiler can optimize the division. In fact, for
this case, gcc will generate

        subl    %ebx, %eax
        sarl    $3, %eax
        imull   $-858993459, %eax, %eax

because 'struct page' is 40 bytes in size, and that magic sequence
happens to divide by 40 (first divide by 8, then that magical "imull"
will divide by 5 *IFF* the thing is evenly divisible by 5 (and not too
big - but the shift guarantees that).

Basically, it's a magic trick, because real divides are very
expensive, but you can fake them more quickly if you can limit the
input domain.

But what does it mean if the two "struct page *" are not in the same
array, and the two arrays were allocated not aligned exactly 40 bytes
away, but some random number of pages away?

You get *COMPLETE*GARBAGE* when you do the above optimized divide.
Suddenly the divide had a modulus (because the base of the two arrays
weren't 40-byte aligned), and the "trick" doesn't work.

So that's why you can't do pointer diffs between two arrays. Not
because you can't subtract the two pointers, but because the
*division* part of the C pointer diff rules leads to issues.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

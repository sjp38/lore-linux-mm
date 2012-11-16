Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id B3BAF6B0074
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 10:32:22 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id lz20so3536531obb.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 07:32:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121116144109.GA8218@suse.de>
References: <1353064973-26082-1-git-send-email-mgorman@suse.de>
 <1353064973-26082-7-git-send-email-mgorman@suse.de> <50A648FF.2040707@redhat.com>
 <20121116144109.GA8218@suse.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 16 Nov 2012 07:32:01 -0800
Message-ID: <CA+55aFzH_-6FuwTF1GVDzLK+7c0MGLsLdPFjzzwU78GVUEMbBw@mail.gmail.com>
Subject: Re: [PATCH 06/43] mm: numa: Make pte_numa() and pmd_numa() a generic implementation
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Nov 16, 2012 at 6:41 AM, Mel Gorman <mgorman@suse.de> wrote:
>
> I would have preferred asm-generic/pgtable.h myself and use
> __HAVE_ARCH_whatever tricks

PLEASE NO!

Dammit, why is this disease still so prevalent, and why do people
continue to do this crap?

__HAVE_ARCH_xyzzy is a f*cking retarded thing to do, and that's
actually an insult to retarded people.

Use either:

 - Kconfig entries for bigger features where that makes sense, and
using the Kconfig files allows you to use the Kconfig logic for things
(ie there are dependencies etc, so you can avoid having to have
complicated conditionals in the #ifdef's, and instead introduce them
as rules in Kconfig files).

 - the SAME F*CKING NAME for the #ifdef, not some totally different
namespace with __HAVE_ARCH_xyzzy crap.

So if your architecture wants to override one (or more) of the
pte_*numa() functions, just make it do so. And do it with

  static inline pmd_t pmd_mknuma(pmd_t pmd)
  {
          pmd = pmd_set_flags(pmd, _PAGE_NUMA);
          return pmd_clear_flags(pmd, _PAGE_PRESENT);
  }
  #define pmd_mknuma pmd_mknuma

and then you can have the generic code have code like

   #ifndef pmd_mknuma
   .. generic version goes here ..
   #endif

and the advantage is two-fold:

 - none of the "let's make up another name to test for this"

 - "git grep" actually _works_, and the end results make sense, and
you can clearly see the logic of where things are declared, and which
one is used.

The __ARCH_HAVE_xyzzy (and some places call it __HAVE_ARCH_xyzzy)
thing is a disease.

That said, the __weak thing works too (and greps fine, as long as you
use the proper K&R C format, not the idiotic "let's put the name of
the function on a different line than the type of the function"
format), it just doesn't allow inlining.

In this case, I suspect the inlined function is generally a single
instruction, is it not? In which case I really do think that inlining
makes sense.

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

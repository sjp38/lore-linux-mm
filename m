Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A21BC6B02F3
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 02:09:55 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y39so35902386wry.10
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 23:09:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 91si2059123wrn.181.2017.06.13.23.09.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Jun 2017 23:09:53 -0700 (PDT)
Subject: Re: [PATCH v2 05/10] x86/mm: Rework lazy TLB mode and TLB freshness
 tracking
References: <cover.1497415951.git.luto@kernel.org>
 <039935bc914009103fdaa6f72f14980c19562de5.1497415951.git.luto@kernel.org>
From: Juergen Gross <jgross@suse.com>
Message-ID: <1619e0d4-683d-c129-a132-383c7495d285@suse.com>
Date: Wed, 14 Jun 2017 08:09:51 +0200
MIME-Version: 1.0
In-Reply-To: <039935bc914009103fdaa6f72f14980c19562de5.1497415951.git.luto@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On 14/06/17 06:56, Andy Lutomirski wrote:
> x86's lazy TLB mode used to be fairly weak -- it would switch to
> init_mm the first time it tried to flush a lazy TLB.  This meant an
> unnecessary CR3 write and, if the flush was remote, an unnecessary
> IPI.
> 
> Rewrite it entirely.  When we enter lazy mode, we simply remove the
> cpu from mm_cpumask.  This means that we need a way to figure out
> whether we've missed a flush when we switch back out of lazy mode.
> I use the tlb_gen machinery to track whether a context is up to
> date.
> 
> Note to reviewers: this patch, my itself, looks a bit odd.  I'm
> using an array of length 1 containing (ctx_id, tlb_gen) rather than
> just storing tlb_gen, and making it at array isn't necessary yet.
> I'm doing this because the next few patches add PCID support, and,
> with PCID, we need ctx_id, and the array will end up with a length
> greater than 1.  Making it an array now means that there will be
> less churn and therefore less stress on your eyeballs.
> 
> NB: This is dubious but, AFAICT, still correct on Xen and UV.
> xen_exit_mmap() uses mm_cpumask() for nefarious purposes and this
> patch changes the way that mm_cpumask() works.  This should be okay,
> since Xen *also* iterates all online CPUs to find all the CPUs it
> needs to twiddle.

There is a allocation failure path in xen_drop_mm_ref() which might
be wrong with this patch. As this path should be taken only very
unlikely I'd suggest to remove the test for mm_cpumask() bit zero in
this path.


Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

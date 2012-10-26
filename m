Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id EA5466B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 10:14:36 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id c4so1302379eek.14
        for <linux-mm@kvack.org>; Fri, 26 Oct 2012 07:14:35 -0700 (PDT)
Date: Fri, 26 Oct 2012 16:14:30 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 26/31] sched, numa, mm: Add fault driven placement and
 migration policy
Message-ID: <20121026141430.GA12158@gmail.com>
References: <20121025121617.617683848@chello.nl>
 <20121025124834.467791319@chello.nl>
 <CA+55aFwJdn8Kz9UByuRfGNtf9Hkv-=8xB+WRd47uHZU1YMagZw@mail.gmail.com>
 <20121026071532.GC8141@gmail.com>
 <20121026135024.GA11640@gmail.com>
 <1351260672.16863.81.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351260672.16863.81.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> On Fri, 2012-10-26 at 15:50 +0200, Ingo Molnar wrote:
> > 
> > Oh, just found the reason:
> > 
> > the ptep_modify_prot_start()/modify()/commit() sequence is 
> > SMP-unsafe - it has to be done under the mmap_sem 
> > write-locked.
> > 
> > It is safe against *hardware* updates to the PTE, but not 
> > safe against itself.
> 
> Shouldn't the pte_lock serialize all that still? All sites 
> that modify PTE contents should hold the pte_lock (and do 
> afaict).

Hm, indeed.

Is there no code under down_read() (in the page fault path) that 
modifies the pte via just pure atomics?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

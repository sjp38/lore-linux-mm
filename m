Date: Sun, 11 Dec 2005 18:49:43 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [RFC 3/6] Make nr_pagecache a per zone counter
Message-ID: <20051211204943.GA4375@dmt.cnet>
References: <20051210005440.3887.34478.sendpatchset@schroedinger.engr.sgi.com> <20051210005456.3887.94412.sendpatchset@schroedinger.engr.sgi.com> <20051211183241.GD4267@dmt.cnet> <20051211194840.GU11190@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051211194840.GU11190@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Dec 11, 2005 at 08:48:40PM +0100, Andi Kleen wrote:
> > By the way, why does nr_pagecache needs to be an atomic variable on UP systems?
> 
> At least on X86 UP atomic doesn't use the LOCK prefix and is thus quite
> cheap. I would expect other architectures who care about UP performance
> (= not IA64) to be similar.

But in practice the variable does not need to be an atomic type for UP, but
simply a word, since stores are atomic on UP systems, no?

Several arches seem to use additional atomicity instructions on 
atomic functions:

PPC:
static __inline__ void atomic_add(int a, atomic_t *v)
{
        int t;

        __asm__ __volatile__(
"1:     lwarx   %0,0,%3         # atomic_add\n\
        add     %0,%2,%0\n"
        PPC405_ERR77(0,%3)
"       stwcx.  %0,0,%3 \n\
        bne-    1b"
        : "=&r" (t), "=m" (v->counter)
        : "r" (a), "r" (&v->counter), "m" (v->counter)
        : "cc");
}

"lwarx" and "stwcx." wouldnt be necessary for updating nr_pagecache 
on UP.


SPARC:
int __atomic_add_return(int i, atomic_t *v)
{
        int ret;
        unsigned long flags;
        spin_lock_irqsave(ATOMIC_HASH(v), flags);

        ret = (v->counter += i);

        spin_unlock_irqrestore(ATOMIC_HASH(v), flags);
        return ret;
}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

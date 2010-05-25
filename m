Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B9D376B01B0
	for <linux-mm@kvack.org>; Tue, 25 May 2010 15:57:18 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id o4PJvEDp017387
	for <linux-mm@kvack.org>; Tue, 25 May 2010 12:57:15 -0700
Received: from pwj9 (pwj9.prod.google.com [10.241.219.73])
	by hpaq12.eem.corp.google.com with ESMTP id o4PJvCix005787
	for <linux-mm@kvack.org>; Tue, 25 May 2010 12:57:13 -0700
Received: by pwj9 with SMTP id 9so3377856pwj.38
        for <linux-mm@kvack.org>; Tue, 25 May 2010 12:57:11 -0700 (PDT)
Date: Tue, 25 May 2010 12:57:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
In-Reply-To: <AANLkTin5PNELUXc6oCHadVyX-YcAEalRSppjz4GMyIBh@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1005251247090.20631@chino.kir.corp.google.com>
References: <20100521211452.659982351@quilx.com> <20100524070309.GU2516@laptop> <alpine.DEB.2.00.1005240852580.5045@router.home> <20100525020629.GA5087@laptop> <AANLkTik2O-_Fbh-dq0sSLFJyLU7PZi4DHm85lCo4sugS@mail.gmail.com> <20100525070734.GC5087@laptop>
 <AANLkTimhTfz_mMWNh_r18yapNxSDjA7wRDnFM6L5aIdE@mail.gmail.com> <alpine.DEB.2.00.1005250257100.8045@chino.kir.corp.google.com> <AANLkTin5PNELUXc6oCHadVyX-YcAEalRSppjz4GMyIBh@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Tue, 25 May 2010, Pekka Enberg wrote:

> > The code may be much cleaner and simpler than slab, but nobody (to date)
> > has addressed the significant netperf TCP_RR regression that slub has, for
> > example. I worked on a patchset to do that for a while but it wasn't
> > popular because it added some increments to the fastpath for tracking
> > data.
> 
> Yes and IIRC I asked you to resend the series because while I care a
> lot about performance regressions, I simply don't have the time or the
> hardware to reproduce and fix the weird cases you're seeing.
> 

My patchset still never attained parity with slab even though it improved 
slub's performance for that specific benchmark on my 16-core machine with 
64G of memory:

	# threads	SLAB		SLUB		SLUB+patchset
	16		69892		71592		69505
	32		126490		95373		119731
	48		138050		113072		125014
	64		169240		149043		158919
	80		192294		172035		179679
	96		197779		187849		192154
	112		217283		204962		209988
	128		229848		217547		223507
	144		238550		232369		234565
	160		250333		239871		244789
	176		256878		242712		248971
	192		261611		243182		255596

CONFIG_SLUB_STATS demonstrates that the kmalloc-256 and kmalloc-2048 are
performing quite poorly without the changes:

	cache		ALLOC_FASTPATH	ALLOC_SLOWPATH
	kmalloc-256	98125871	31585955
	kmalloc-2048	77243698	52347453

	cache		FREE_FASTPATH	FREE_SLOWPATH
	kmalloc-256	173624		129538000
	kmalloc-2048	90520		129500630

When you have these type of results, it's obvious why slub is failing to 
achieve the same performance as slab.  With the slub fastpath percpu work 
that has been done recently, it might be possible to resurrect my patchset 
and get more positive feedback because the penalty won't be as a 
significant, but the point is that slub still fails to achieve the same 
results that slab can with heavy networking loads.  Thus, I think any 
discussion about removing slab is premature until it's no longer shown to 
be a clear winner in comparison to its replacement, whether that is slub, 
slqb, sleb, or another allocator.  I agree that slub is clearly better in 
terms of maintainability, but we simply can't use it because of its 
performance for networking loads.

If you want to duplicate these results on machines with a larger number of 
cores, just download netperf, run with CONFIG_SLUB on both netserver and 
netperf machines, and use this script:

#!/bin/bash

TIME=60				# seconds
HOSTNAME=<hostname>		# netserver

NR_CPUS=$(grep ^processor /proc/cpuinfo | wc -l)
echo NR_CPUS=$NR_CPUS

run_netperf() {
	for i in $(seq 1 $1); do
		netperf -H $HOSTNAME -t TCP_RR -l $TIME &
	done
}

ITERATIONS=0
while [ $ITERATIONS -lt 12 ]; do
	RATE=0
	ITERATIONS=$[$ITERATIONS + 1]	
	THREADS=$[$NR_CPUS * $ITERATIONS]
	RESULTS=$(run_netperf $THREADS | grep -v '[a-zA-Z]' | awk '{ print $6 }')

	for j in $RESULTS; do
		RATE=$[$RATE + ${j/.*}]
	done
	echo threads=$THREADS rate=$RATE
done

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

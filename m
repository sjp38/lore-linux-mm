Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F34766B00EE
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 12:24:28 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p72GOMA3014312
	for <linux-mm@kvack.org>; Tue, 2 Aug 2011 09:24:23 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by wpaz37.hot.corp.google.com with ESMTP id p72GOIVX017710
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 2 Aug 2011 09:24:21 -0700
Received: by pzk2 with SMTP id 2so14409276pzk.9
        for <linux-mm@kvack.org>; Tue, 02 Aug 2011 09:24:18 -0700 (PDT)
Date: Tue, 2 Aug 2011 09:24:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
In-Reply-To: <alpine.DEB.2.00.1108020913180.18965@router.home>
Message-ID: <alpine.DEB.2.00.1108020915370.1114@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1107290145080.3279@tiger> <alpine.DEB.2.00.1107291002570.16178@router.home> <alpine.DEB.2.00.1107311136150.12538@chino.kir.corp.google.com> <alpine.DEB.2.00.1107311253560.12538@chino.kir.corp.google.com> <1312145146.24862.97.camel@jaguar>
 <alpine.DEB.2.00.1107311426001.944@chino.kir.corp.google.com> <CAOJsxLHB9jPNyU2qztbEHG4AZWjauCLkwUVYr--8PuBBg1=MCA@mail.gmail.com> <alpine.DEB.2.00.1108012101310.6871@chino.kir.corp.google.com> <alpine.DEB.2.00.1108020913180.18965@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2 Aug 2011, Christoph Lameter wrote:

> > Yes, slub _did_ use more memory than slab until the alignment of
> > struct page.  That cost an additional 128MB on each of these 64GB
> > machines, while the total slab usage on the client machine systemwide is
> > ~75MB while running netperf TCP_RR with 160 threads.
> 
> I guess that calculation did not include metadata structures (alien caches
> and the NR_CPU arrays in kmem_cache) etc? These are particularly costly on SLAB.
> 

It certainly is costly on slab, but that 75MB number is from a casual 
observation of grep Slab /proc/meminfo while running the benchmark.  For 
slub, that turns into ~55MB.  The true slub usage, though, includes the 
struct page alignment for cmpxchg16b which added 128MB of padding into its 
memory usage even though it appears to be unattributed to slub.  A casual 
grep MemFree /proc/meminfo reveals the lost 100MB for the slower 
allocator, in this case.  And the per-cpu partial list will add even 
additional slab usage for slub, so this is where my "throwing more memory 
at slub to get better performance" came from.  I understand that this is a 
large NUMA machine, though, and the cost of slub may be substantially 
lower on smaller machines.

If you look through the various arch defconfigs, you'll see that we 
actually do a pretty good job of enabling CONFIG_SLAB for large systems.  
I wish we had a clear dividing line in the x86 kconfig that would at least 
guide users toward one allocator over another though, otherwise they 
receive little help.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

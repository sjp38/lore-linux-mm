Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id C760F6B009E
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 03:52:44 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so1788563bkc.14
        for <linux-mm@kvack.org>; Tue, 11 Dec 2012 00:52:43 -0800 (PST)
Date: Tue, 11 Dec 2012 09:52:38 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/49] Automatic NUMA Balancing v10
Message-ID: <20121211085238.GA21673@gmail.com>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
 <20121207110113.GB21482@gmail.com>
 <20121209203630.GC1009@suse.de>
 <20121210113945.GA7550@gmail.com>
 <20121210152405.GJ1009@suse.de>
 <20121211010201.GP1009@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121211010201.GP1009@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> On Mon, Dec 10, 2012 at 03:24:05PM +0000, Mel Gorman wrote:
> > For example, I think that point 5 above is the potential source of the
> > corruption because. You're not flushing the TLBs for the PTEs you are
> > updating in batch. Granted, you're relaxing rather than restricting access
> > so it should be ok and at worse cause a spurious fault but I also find
> > it suspicious that you do not recheck pte_same under the PTL when doing
> > the final PTE update.
> 
> Looking again, the lack of a pte_same check should be ok. The 
> addr, addr_start, ptep and ptep_start is a little messy but 
> also look fine. You're not accidentally crossing a PMD 
> boundary. You should be protected against huge pages being 
> collapsed underneath you as you hold mmap_sem for read. If the 
> first page in the pmd (or VMA) is not present then target_nid 
> == -1 which gets passed into __do_numa_page. This check
> 
>         if (target_nid == -1 || target_nid == page_nid)
>                 goto out;
> 
> then means you never actually migrate for that whole PMD and 
> will just clear the PTEs. [...]

Yes.

> [...] Possibly wrong, but not what we're looking for. [...]

It's a detail - I thought not touching partial 2MB pages is just 
as valid as picking some other page to represent it, and went 
for the simpler option.

But yes, I agree that using the first present page would be 
better, as it would better handle partial vmas not 
starting/ending at a 2MB boundary - which happens frequently in 
practice.

> [...] Holding PTL across task_numa_fault is bad, but not the 
> bad we're looking for.

No, holding the PTL across task_numa_fault() is fine, because 
this bit got reworked in my tree rather significantly, see:

 6030a23a1c66 sched: Move the NUMA placement logic to a worklet

and followup patches.

> /me scratches his head
> 
> Machine is still unavailable so in an attempt to rattle this 
> out I prototyped the equivalent patch for balancenuma and then 
> went back to numacore to see could I spot a major difference.  
> Comparing them, there is no guarantee you clear pte_numa for 
> the address that was originally faulted if there was a racing 
> fault that cleared it underneath you but in itself that should 
> not be an issue. Your use of ptep++ instead of 
> pte_offset_map() might break on 32-bit with NUMA support if 
> PTE pages are stored in highmem. Still the wrong wrong.

Yes.

> If the bug is indeed here, it's not obvious. I don't know why 
> I'm triggering it or why it only triggers for specjbb as I 
> cannot imagine what the JVM would be doing that is that weird 
> or that would not have triggered before. Maybe we both suffer 
> this type of problem but that numacores rate of migration is 
> able to trigger it.

Agreed.

> > Basically if I felt that handling ptes in batch like this 
> > was of critical important I would have implemented it very 
> > differently on top of balancenuma. I would have only taken 
> > the PTL lock if updating the PTE to keep contention down and 
> > redid racy checks under PTL, I'd have only used trylock for 
> > every non-faulted PTE and I would only have migrated if it 
> > was a remote->local copy. I certainly would not hold PTL 
> > while calling task_numa_fault(). I would have kept the 
> > handling ona per-pmd basis when it was expected that most 
> > PTEs underneath should be on the same node.
> 
> This is prototype only but what I was using as a reference to 
> see could I spot a problem in yours. It has not been even boot 
> tested but avoids remote->remote copies, contending on PTL or 
> holding it longer than necessary (should anyway)

So ... because time is running out and it would be nice to 
progress with this for v3.8, I'd suggest the following approach:

 - Please send your current tree to Linus as-is. You already 
   have my Acked-by/Reviewed-by for its scheduler bits, and my
   testing found your tree to have no regression to mainline,
   plus it's a nice win in a number of NUMA-intense workloads.
   So it's a good, monotonic step forward in terms of NUMA
   balancing, very close to what the bits I'm working on need as
   infrastructure.

 - I'll rebase all my devel bits on top of it. Instead of
   removing the migration bandwidth I'll simply increase it for
   testing - this should trigger similarly aggressive behavior.
   I'll try to touch as little of the mm/ code as possible, to
   keep things debuggable.

If the JVM segfault is a bug introduced by some non-obvious 
difference only present in numa/core and fixed in your tree then 
the bug will be fixed magically and we can forget about it.

If it's something latent in your tree as well, then at least we 
will be able to stare at the exact same tree, instead of 
endlessly wondering about small, unnecessary differences.

( My gut feeling is that it's 50%/50%, I really cannot exclude
  any of the two possibilities. )

Agreed?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

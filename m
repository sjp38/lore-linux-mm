Date: Tue, 01 Jul 2003 07:24:03 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: What to expect with the 2.6 VM
Message-ID: <7950000.1057069435@[10.10.2.4]>
In-Reply-To: <20030701085939.GG20413@holomorphy.com>
References: <Pine.LNX.4.53.0307010238210.22576@skynet> <20030701022516.GL3040@dualathlon.random> <20030701032531.GC20413@holomorphy.com> <20030701043902.GP3040@dualathlon.random> <20030701063317.GF20413@holomorphy.com> <20030701074915.GQ3040@dualathlon.random> <20030701085939.GG20413@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Andrea Arcangeli <andrea@suse.de>
Cc: Joel.Becker@oracle.com, Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> First I ask, "What is this exercising?" That answer is largely process
> creation and destruction and SMP scheduling latency when there are very
> rapidly fluctuating imbalances.
> 
> After observing that, the benchmark is flawed because
> (a) it doesn't run long enough to produce stable numbers
> (b) the results are apparently measured with gettimeofday(), which is
> 	wildly inaccurate for such short-lived phenomena

Bullshit. Use a maximal config file, and run it multiple times. I have
sub 0.5% variance. 

> (c) large differences in performance appear to come about as a result
> 	of differing versions of common programs (i.e. gcc)

So use the same frigging gcc each time. Why you want to screw with
userspace at the same time as the kernel is a mystery to me. If you
change gcc, you're also changing what's compiling your kernel, so you'll
get different binaries - ergo the whole argument is fallacious anyway,
and *any* benchmarking you're doing is completely innacurrate.

>> if you want to change mlock to drop the pte_chains then it would
>> definitely make mlock a VM bypass, even if not as strong as the
>> remap_file_pages that bypass the vma layer too (not only the
>> pte/pte_chain side).
> 
> Well, the thing is it's closer to the primitive. You're suggesting
> making remap_file_pages() both locked and unaligned with the vma, where
> it seems to me the real underlying mechanism is using the semantics of
> locked memory to avoid creating pte_chains. Bypassing vma's doesn't
> seem to be that exciting. There are only a couple of places where an
> assumption remap_file_pages() breaks matters, i.e. vmtruncate() and
> try_to_unmap_one_obj(), and that can be dodged with exhaustive search
> in the non-anobjrmap VM's and is naturally handled by chaining the
> distinct virtual addresses where pages are mapped against the page by
> the anobjrmap VM's.

If we just lock the damned things in memory, OR flag them at create
time (or at least before use), none of this is an issue anyway - we
get rid of all the conversion stuff. Seeing as this is mainly for big 
DBs, I still don't see why mem locking it is a problem - no reason 
for it to fuck up the rest of the VM.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

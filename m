Date: Tue, 22 Jan 2008 12:00:00 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Increasing partial pages
In-Reply-To: <20080118191430.GD20490@parisc-linux.org>
Message-ID: <Pine.LNX.4.64.0801221142330.27692@schroedinger.engr.sgi.com>
References: <20080116195949.GO18741@parisc-linux.org>
 <Pine.LNX.4.64.0801161219050.9694@schroedinger.engr.sgi.com>
 <20080116214127.GA11559@parisc-linux.org> <Pine.LNX.4.64.0801161347160.11353@schroedinger.engr.sgi.com>
 <20080116221618.GB11559@parisc-linux.org> <Pine.LNX.4.64.0801161421240.12024@schroedinger.engr.sgi.com>
 <20080118191430.GD20490@parisc-linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 Jan 2008, Matthew Wilcox wrote:

> > I repeatedly saw patches from Intel to do minor changes to SLAB that 
> > increase performance by 0.5% or so (like the recent removal of a BUG_ON 
> > for performance reasons). These do not regress again when you build a 
> > newer kernel release?
> 
> No, they don't.  Unless someone's broken something (eg putting pages on
> the LRU in the wrong order so we don't get merges any more ;-)

I tried over the weekend to get reproducable results after applying each 
patch using tbench (shows a similar regression to what you are seeing 
1-4%) but each kernel build has different performance charateristics. 
Probably due to the way code is aligned in cachelines? Here are the slab 
numbes for a number of runs with different kernel builds:

2.6.24-rc8 slab (x86_64 8p SMP 8G)

Throughput 2316.87 MB/sec 8 procs
Throughput 2257.49 MB/sec 8 procs
Throughput 2264.11 MB/sec 8 procs
Throughput 2280.62 MB/sec 8 procs

So a ~3% variance!

I was able to get a feel (from the measurements that are jumping around) 
that some patches may cause tbench performance to drop a bit. In 
particular the patch before the cmpxchg_local must add the page->end 
field. The cmpxchg_local patch must offset that cost in order to make this 
a performance increase.

It would be great if you could get stable results on these (with multiple 
differently compiled kernels! Apply some patch that should have no 
performance impact but adds some code to verify). I saw an overall slight 
performance decrease on tbench (still doubting how much I can trust those 
numbers) so lets not merge the series upstream until we have more data).

Patches that I would recommend to test individually if you could do it 
(get the series via git pull 
git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git performance):

0006-Use-non-atomic-unlock.patch

	Surprisingly this one caused a 1% regression in some of my tests. 
        Maybe the cacheline is held longer if no atomic op is used during 
        unlock?

0005-Add-parameter-to-add_partial-to-avoid-having-two-fun.patch

	I mostly saw performance increases (1-2%) on this one.


0009-SLUB-Avoid-folding-functions-into-__slab_alloc-and.patch

0010-Move-kmem_cache_node-determination-into-add_full-par.patch


The cmpxchg stuff is a group of 3 patches. The first two should cause a 
slight performance decrease which needs at least to be offset by the third
one.

0014-SLUB-Use-unique-end-pointer-for-each-slab-page.patch
0015-slub-provide-unique-end-marker-for-each-slab-fix.patch
0017-SLUB-Alternate-fast-paths-using-cmpxchg_local.patch


0018-SLUB-Do-our-own-locking-to-avoid-extraneous-memory.patch
0019-SLUB-Own-locking-checkpatch-fixes.patch

0021-SLUB-Restructure-slab_alloc-to-flow-in-execution-se.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

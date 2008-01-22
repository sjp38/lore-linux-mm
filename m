Date: Tue, 22 Jan 2008 15:35:41 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: SLUB: Increasing partial pages
Message-ID: <20080122223541.GR27250@parisc-linux.org>
References: <20080116195949.GO18741@parisc-linux.org> <Pine.LNX.4.64.0801161219050.9694@schroedinger.engr.sgi.com> <20080116214127.GA11559@parisc-linux.org> <Pine.LNX.4.64.0801161347160.11353@schroedinger.engr.sgi.com> <20080116221618.GB11559@parisc-linux.org> <Pine.LNX.4.64.0801161421240.12024@schroedinger.engr.sgi.com> <20080118191430.GD20490@parisc-linux.org> <Pine.LNX.4.64.0801221142330.27692@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801221142330.27692@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 22, 2008 at 12:00:00PM -0800, Christoph Lameter wrote:
> It would be great if you could get stable results on these (with multiple 
> differently compiled kernels! Apply some patch that should have no 
> performance impact but adds some code to verify). I saw an overall slight 
> performance decrease on tbench (still doubting how much I can trust those 
> numbers) so lets not merge the series upstream until we have more data).
> 
> Patches that I would recommend to test individually if you could do it 
> (get the series via git pull 
> git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git performance):

The thing is that each run takes approximately 4 hours on a machine
which has other patches to try too.  I'm not comfortable with asking my
colleagues to try various combinations on a whim.  What I've asked for
is:

2.6.24-rc8 w/ SLAB
2.6.24-rc8 w/ SLUB
2.6.24-rc8 w/ SLUB and your 22 patches applied.

So that should be done in about 12 hours time.

Obviously, if we see problems with all 22 patches, we'll try bisection
search ... and I think you've identified some good points to split at
below, but testing all possible combinations of these 22 patches with
and without some other random changes isn't feasible.

I also don't understand the dependency tree -- you seem to be saying
that we could apply patch 6 without patches 1-5 and test that.

> 0006-Use-non-atomic-unlock.patch
> 
> 	Surprisingly this one caused a 1% regression in some of my tests. 
>         Maybe the cacheline is held longer if no atomic op is used during 
>         unlock?
> 
> 0005-Add-parameter-to-add_partial-to-avoid-having-two-fun.patch
> 
> 	I mostly saw performance increases (1-2%) on this one.
> 
> 
> 0009-SLUB-Avoid-folding-functions-into-__slab_alloc-and.patch
> 
> 0010-Move-kmem_cache_node-determination-into-add_full-par.patch
> 
> 
> The cmpxchg stuff is a group of 3 patches. The first two should cause a 
> slight performance decrease which needs at least to be offset by the third
> one.
> 
> 0014-SLUB-Use-unique-end-pointer-for-each-slab-page.patch
> 0015-slub-provide-unique-end-marker-for-each-slab-fix.patch
> 0017-SLUB-Alternate-fast-paths-using-cmpxchg_local.patch
> 
> 
> 0018-SLUB-Do-our-own-locking-to-avoid-extraneous-memory.patch
> 0019-SLUB-Own-locking-checkpatch-fixes.patch
> 
> 0021-SLUB-Restructure-slab_alloc-to-flow-in-execution-se.patch

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

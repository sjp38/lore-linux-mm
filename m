Date: Wed, 24 May 2006 15:12:10 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: update_mmu_cache vs. lazy_mmu_prot_update
In-Reply-To: <Pine.LNX.4.64.0605231433001.11697@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0605241453340.12355@blonde.wat.veritas.com>
References: <000001c67eae$3e29bd90$e734030a@amr.corp.intel.com>
 <Pine.LNX.4.64.0605231433001.11697@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, David Howells <dhowells@redhat.com>, Rohit Seth <rohitseth@google.com>, linux-mm@kvack.org, agl@us.ibm.com, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 May 2006, Christoph Lameter wrote:
> On Tue, 23 May 2006, Chen, Kenneth W wrote:
> 
> > My memory recollects that it was done just like what you suggested:
> > overloading update_mmu_cache for ia64, but it was vetoed by several mm
> > experts.  And as a result a new function was introduced.
> 
> lazy_mmu_prot_update is always called after update_mmu_cache except
> when we change permissions (hugetlb_change_protection() and 
> change_pte_range()). 
> 
> So if we conflate those two then arches may have to be updated to avoid 
> flushing the mmu if we only modified protections.

Ah, I missed those two lone usages of lazy_mmu_prot_update, thanks.
That makes sense, and fits with Ken's recollection: to have added
update_mmu_cache in those two places would have slowed down the
other architectures.

> I think update_mmu_cache() should be dropped in page_wrprotect_one() in 
> order to be consistent scheme. And avoiding mmu flushes will increase the 
> performance of page_wrprotect_one.. lazy_mmu_prot_update must be there 
> since we are changing permissions.

Agreed.

I'd still like to rename lazy_mmu_prot_update, and refactor it, but
that can be a later unrelated cleanup.  What makes sense to me is to
call it update_mmu_cache_prot, and #define the ia64 update_mmu_cache
to that: so we can unclutter common code from most of the
lazy_mmu_prot_update lines, leaving just those two significant
instances of update_mmu_cache_prot that you highlight.

And of the two instances of update_mmu_cache in mm/fremap.c:
it seems to me that the first, in install_page, ought to have a
lazy_mmu_prot_update (and will get it automatically by the #define
I suggest); whereas the second, in install_file_pte, ought not to
have an update_mmu_cache since it's installing a !present entry.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

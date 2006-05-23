Date: Tue, 23 May 2006 14:40:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: update_mmu_cache vs. lazy_mmu_prot_update
In-Reply-To: <000001c67eae$3e29bd90$e734030a@amr.corp.intel.com>
Message-ID: <Pine.LNX.4.64.0605231433001.11697@schroedinger.engr.sgi.com>
References: <000001c67eae$3e29bd90$e734030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Hugh Dickins' <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, David Howells <dhowells@redhat.com>, Rohit Seth <rohitseth@google.com>, linux-mm@kvack.org, agl@us.ibm.com, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 May 2006, Chen, Kenneth W wrote:

> > Except that, instead of agreeing it should be renamed, I say it should
> > be deleted entirely.  It seems to represent that ia64 has an empty
> > update_mmu_cache, and someone decided to add a new interface instead
> > of giving ia64 that work to do in its update_mmu_cache.
> 
> My memory recollects that it was done just like what you suggested:
> overloading update_mmu_cache for ia64, but it was vetoed by several mm
> experts.  And as a result a new function was introduced.

lazy_mmu_prot_update is always called after update_mmu_cache except
when we change permissions (hugetlb_change_protection() and 
change_pte_range()). 

So if we conflate those two then arches may have to be updated to avoid 
flushing the mmu if we only modified protections.

I think update_mmu_cache() should be dropped in page_wrprotect_one() in 
order to be consistent scheme. And avoiding mmu flushes will increase the 
performance of page_wrprotect_one.. lazy_mmu_prot_update must be there 
since we are changing permissions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F41956B005C
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 10:04:53 -0400 (EDT)
Date: Fri, 12 Jun 2009 22:04:26 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] HWPOISON: fix tasklist_lock/anon_vma locking order
Message-ID: <20090612140426.GA8481@localhost>
References: <20090611142239.192891591@intel.com> <20090611144430.540500784@intel.com> <20090612100308.GD25568@one.firstfloor.org> <20090612132714.GB6751@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090612132714.GB6751@localhost>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 09:27:14PM +0800, Wu Fengguang wrote:
> On Fri, Jun 12, 2009 at 06:03:08PM +0800, Andi Kleen wrote:
> > On Thu, Jun 11, 2009 at 10:22:41PM +0800, Wu Fengguang wrote:
> > > To avoid possible deadlock. Proposed by Nick Piggin:
> > 
> > I disagree with the description. There's no possible deadlock right now.
> > It would be purely out of paranoia.
> > 
> > > 
> > >   You have tasklist_lock(R) nesting outside i_mmap_lock, and inside anon_vma
> > >   lock. And anon_vma lock nests inside i_mmap_lock.
> > > 
> > >   This seems fragile. If rwlocks ever become FIFO or tasklist_lock changes
> > 
> > I was a bit dubious on this reasoning. If rwlocks become FIFO a lot of
> > stuff will likely break.
> > 
> > >   type (maybe -rt kernels do it), then you could have a task holding
> > 
> > I think they tried but backed off quickly again
> > 
> > It's ok with a less scare-mongering description.
> 
> Why not merge it into the original patch and add a simple changelog
> line there? I tried the last 6.5 patchset and it didn't apply cleanly
> to the latest -mm tree. And this patch was updated:

Andy, please apply this patch too. It fixed a kernel panic: when
invalid PFN is feed to the debug injection interface, action_result()
will try to do a pfn_to_page() on it..

Thanks,
Fengguang

---
 mm/memory-failure.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- sound-2.6.orig/mm/memory-failure.c
+++ sound-2.6/mm/memory-failure.c
@@ -439,7 +439,9 @@ void memory_failure(unsigned long pfn, i
 	struct page *p;
 
 	if (!pfn_valid(pfn)) {
-		action_result(pfn, "memory outside kernel control", IGNORED);
+		printk(KERN_ERR
+		       "MCE %#lx: memory outside kernel control: Ignored\n",
+		       pfn);
 		return;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

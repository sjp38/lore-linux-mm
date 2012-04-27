Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 8A45D6B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 20:15:40 -0400 (EDT)
Date: Fri, 27 Apr 2012 02:15:33 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch v2] thp, memcg: split hugepage for memcg oom on cow
Message-ID: <20120427001533.GD1791@redhat.com>
References: <alpine.DEB.2.00.1204031854530.30629@chino.kir.corp.google.com>
 <4F838385.9070309@jp.fujitsu.com>
 <alpine.DEB.2.00.1204092241180.27689@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1204092242050.27689@chino.kir.corp.google.com>
 <20120411142023.GB1789@redhat.com>
 <alpine.DEB.2.00.1204231612060.17030@chino.kir.corp.google.com>
 <20120426090642.GC1791@redhat.com>
 <alpine.DEB.2.00.1204261402020.28376@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1204261402020.28376@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Thu, Apr 26, 2012 at 02:05:11PM -0700, David Rientjes wrote:
> On Thu, 26 Apr 2012, Johannes Weiner wrote:
> 
> > > I agree it's more robust if do_huge_pmd_wp_page() were modified later and 
> > > mistakenly returned VM_FAULT_OOM without the page being split, but 
> > > __split_huge_page_pmd() has the drawback of also requiring to retake 
> > > mm->page_table_lock to test whether orig_pmd is still legitimate so it 
> > > will be slower.  Do you feel strongly about the way it's currently written 
> > > which will be faster at runtime?
> > 
> > If you can't accomodate for a hugepage, this code runs 511 times in
> > the worst case before you also can't fit a regular page anymore.  And
> > compare it to the cost of the splitting itself and the subsequent 4k
> > COW break faults...
> > 
> > I don't think it's a path worth optimizing for at all, especially if
> > it includes sprinkling undocumented split_huge_pages around, and the
> > fix could be as self-contained as something like this...
> > 
> 
> I disagree that we should be unnecessarily taking mm->page_table_lock 
> which is already strongly contended if all cpus are pagefaulting on the 
> same process (and I'll be posting a patch to address specifically those 
> slowdowns since thp is _much_ slower on page fault tests) when we can 
> already do it in do_huge_pmd_wp_page().  If you'd like to add a comment 
> for the split_huge_page() in that function if it's not clear enough from 
> my VM_FAULT_OOM comment in handle_mm_fault(), then feel free to add it but 
> I thought it was rather trivial to understand.

Come on, it's not "trivial to understand" why the page in the parent
is split because the child failed to allocate a replacement, shortly
before returning "out of memory".  You have to look at a different
file to make sense of it.  Such cross-dependencies between functions
simply suck and made problems in the past.  The least you could do is
properly document them in _both_ places if you insist on adding them
in the first place.

Btw, is restarting the full page table walk even necessary?  You
already have the pmd, know/hope it's been split, and hold the mmap_sem
for reading, so it can't go back to being huge or none.  You should be
able to fall through to the pte lookup and handle_pte_fault(), no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

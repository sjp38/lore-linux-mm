Subject: Re: [RFC][PATCH 1/3] tracking dirty pages in shared mappings -V4
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <44644196.9070402@cyberone.com.au>
References: <1146861313.3561.13.camel@lappy>
	 <445CA22B.8030807@cyberone.com.au> <1146922446.3561.20.camel@lappy>
	 <445CA907.9060002@cyberone.com.au> <1146929357.3561.28.camel@lappy>
	 <Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>
	 <1147116034.16600.2.camel@lappy>
	 <Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>
	 <1147207458.27680.19.camel@lappy> <20060511080220.48688b40.akpm@osdl.org>
	 <4463EA16.5090208@cyberone.com.au> <20060511213045.32b41aa6.akpm@osdl.org>
	 <1147417561.8951.17.camel@twins> <44644196.9070402@cyberone.com.au>
Content-Type: text/plain
Date: Fri, 12 May 2006 10:52:41 +0200
Message-Id: <1147423961.8951.26.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, clameter@sgi.com, torvalds@osdl.org, ak@suse.de, rohitseth@google.com, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2006-05-12 at 18:04 +1000, Nick Piggin wrote:
> Peter Zijlstra wrote:
> 
> >On Thu, 2006-05-11 at 21:30 -0700, Andrew Morton wrote:
> >
> >>Nick Piggin <piggin@cyberone.com.au> wrote:
> >>
> >>> >So let's see.  We take a write fault, we mark the page dirty then we return
> >>> >to userspace which will proceed with the write and will mark the pte dirty.
> >>> >
> >>> >Later, the VM will write the page out.
> >>> >
> >>> >Later still, the pte will get cleaned by reclaim or by munmap or whatever
> >>> >and the page will be marked dirty and the page will again be written out. 
> >>> >Potentially needlessly.
> >>> >
> >>>
> >>> page_wrprotect also marks the page clean,
> >>>
> >>Oh.  I missed that when reading the comment which describes
> >>page_wrprotect() (I do go on).
> >>
> >
> >Yes, this name is not the best of names :-(
> >
> >I was aware of this, but since in my mind the counting through
> >protection 
> >faults was the prime idea, I stuck to page_wrprotect().
> >
> >But I'm hard pressed to come up with a better one. Nick proposes:
> > page_mkclean()
> >But that also doesn't cover the whole of it from my perspective.
> >
> 
> What's your perspective?
> 
> With mmap shared accounting, the _whole VM's_ perspective is that clean
> MAP_SHARED ptes are marked readonly.
> 
> The logical operation is marking the page's ptes clean. The VM mechanism
> also marks the ptes readonly as a side effect of that. Think about it:
> writeback does not want to make the page write protected, it wants to make
> it clean.

As said, I was looking at the added functionality on its own; that is, 
counting dirty pages by trapping write faults.

However your view; the big picture; does make more sense. I shall
rename.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

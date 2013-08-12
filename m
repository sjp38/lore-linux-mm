Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id E8B166B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 14:52:52 -0400 (EDT)
Received: by mail-ea0-f180.google.com with SMTP id h10so3641675eaj.39
        for <linux-mm@kvack.org>; Mon, 12 Aug 2013 11:52:51 -0700 (PDT)
Date: Mon, 12 Aug 2013 20:52:47 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
Message-ID: <20130812185247.GA20451@gmail.com>
References: <20130629071245.GA5084@gmail.com>
 <1372710497.22432.224.camel@schen9-DESK>
 <20130702064538.GB3143@gmail.com>
 <1373997195.22432.297.camel@schen9-DESK>
 <20130723094513.GA24522@gmail.com>
 <20130723095124.GW27075@twins.programming.kicks-ass.net>
 <20130723095306.GA26174@gmail.com>
 <1375143209.22432.419.camel@schen9-DESK>
 <1375833325.2134.36.camel@buesod1.americas.hpqcorp.net>
 <1375836988.22432.435.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375836988.22432.435.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>


* Tim Chen <tim.c.chen@linux.intel.com> wrote:

> On Tue, 2013-08-06 at 16:55 -0700, Davidlohr Bueso wrote:
> 
> > I got good numbers, recovering the performance drop I noticed with the
> > i_mmap_mutex to rwsem patches.
> 
> That's good.  I remembered that the earlier version of the patch not 
> only recovered the performance drop, but also provide some boost when 
> you switch from i_mmap_mutex to rwsem for aim7.  Do you see similar 
> boost with this version?
> 
> >  Looking forward to a more upstreamable
> > patchset that deals with this work, including the previous patches.
> > 
> > One thing that's bugging me about this series though is the huge amount
> > of duplicated code being introduced to rwsems from mutexes. We can share
> > common functionality such as mcs locking (perhaps in a new file under
> > lib/), can_spin_on_owner() and owner_running(), perhaps moving those
> > functions into sheduler code, were AFAIK they were originally.
> 
> I think that MCS locking is worth breaking out as its
> own library.  After we've done that, the rest of
> the duplication are minimal. It is easier
> to keep them separate as there are some rwsem 
> specific logic that may require tweaking
> to can_spin_on_owner and owner_running.  

That's what I would strongly suggest to be the approach of these patches: 
first the MCS locking factoring out, then changes in rwsem behavior.

I'd suggest the librarization should be done using inlines or so, so that 
we don't touch the current (pretty good) mutex.o code generation. I.e. 
code library only on the source code level.

Done that way we could also apply the librarization first, without having 
to worry about performance aspects. Having the code shared will also make 
sure that an improvement to the mutex slowpaths automatically carries over 
into rwems and vice versa.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

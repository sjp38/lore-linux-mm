Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6BAAD6B004F
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 15:11:40 -0400 (EDT)
Date: Thu, 27 Aug 2009 20:11:05 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 13/12] ksm: fix munlock during exit_mmap deadlock
In-Reply-To: <4A95AE06.305@redhat.com>
Message-ID: <Pine.LNX.4.64.0908271958330.1973@sister.anvils>
References: <20090825145832.GP14722@random.random> <20090825152217.GQ14722@random.random>
 <Pine.LNX.4.64.0908251836050.30372@sister.anvils> <20090825181019.GT14722@random.random>
 <Pine.LNX.4.64.0908251958170.5871@sister.anvils> <20090825194530.GU14722@random.random>
 <Pine.LNX.4.64.0908261910530.15622@sister.anvils> <20090826194444.GB14722@random.random>
 <Pine.LNX.4.64.0908262048270.21188@sister.anvils> <4A95A10C.5040008@redhat.com>
 <20090826211400.GE14722@random.random> <4A95AE06.305@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, "Justin M. Forbes" <jmforbes@linuxtx.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Aug 2009, Izik Eidus wrote:
> Andrea Arcangeli wrote:
> > On Wed, Aug 26, 2009 at 11:54:36PM +0300, Izik Eidus wrote:
> >   
> > > But before getting into this, why is it so important to break the ksm
> > > pages when madvise(UNMERGEABLE) get called?
> > >     

Good question.

> >
> > The moment ksm pages are swappable, there's no apparent reason why
> > anybody should ask the kernel to break any ksm page if the application
> > themselfs aren't writing to them in the first place (triggering
> > copy-on-write in app context which already handles TIF_MEMDIE just
> > fine).
> >   
> 
> I think I am the one that should be blamed for breaking the ksm pages when
> running unmeregable (If I remember right),

No, I think it was me to blame for that: looking back at the /dev/ksm KSM
and your draft of madvise KSM, I don't see breaking on unmerge in either.

> but I think Hugh had a good case why we want to keep it... ? (If I remember
> right again...)

There were several reasons for adding it, but all rather weak.

The "good case" you're half-remembering is probably that if we didn't
break ksm when doing madvise MADV_UNMERGEABLE, we'd lose track of any
KSM pages in the vma we're removing VM_MERGEABLE from (since we only
ever scan VM_MERGEABLEs), and so would be liable to build up more and
more unswappable KSM pages, well beyond the limit which can be imposed
by max_kernel_pages.

It is important to keep that accounting right, at least for so long as
they're unswappable; but it amounts to only a weak case, because we
could perfectly well have two vm_flags, one to say actively try to
merge here, and another to say there might still be KSM pages here.
(Perhaps with some restructuring that could instead be driven from
the stable tree end, rather than through the mm_slots and vmas.)

Reasons for avoiding two vm_flags: simplicity; minimizing KSM
footprint outside of ksm.c; and... VM_MERGEABLE has selfishly taken
bit 31 of vm_flags, the next vm_flag is going to involve some thought
on the best way to expand it (on 32-bit arches).  It's not an atomic
field so it shouldn't be hard; we used to minimize the use of 64-bit
on 32-bit but maybe gcc's unsigned long long handling is pretty good
nowadays and it's no issue?  Or maybe the issue was always avoiding
64-bit arithmetic, no issue with bitflags?  I don't know myself.

Other reasons for breaking ksm when unmerging: my sense that we ought
to provide a way to undo whatever is done (useful when testing, but
does that make it worth the effort? particularly if much of the testing
goes into testing precisely that feature!); and a notion that people
worried about covert channels would want to be able to undo merging
absolutely (but would they have been using MADV_MERGEABLE in the
first place, even have KSM configured in and running? seems unlikely).

It may be that MADV_UNMERGEABLE isn't really needed (I think I even
admitted once that probably nobody would use it other than we testing
it).  Yet I hesitate to rip it out: somehow it still seems right to
have it in there.  Why did you have unregistering in the /dev/ksm KSM?

> 
> > In oom deadlock terms madvise(UNMERGEABLE) is the only place that is
> > 100% fine at breaking KSM pages, because it runs with right tsk->mm
> > and page allocation will notice TIF_MEMDIE set on tsk.
> >
> > If we remove "echo 2" only remaining "unsafe" spot is the break_cow in
> > kksmd context when memcmp fails and similar during the scan.
> >
> >   
> I didnt talk here about the bug..., I talked about the behavior...
> It is the feeling that the oom will kill applications calling into
> UNMERGEABLE, even thought this application shouldn't die, just because it had
> big amount of memory shared and it unmerged it in the wrong time?...

The OOM killer makes its choices based upon total_vm (and some other
things): doesn't even consider rss, and certainly not KSM sharing.
So whenever out-of-memory, the OOM killer might choose to kill a very
highly KSM-merged process, freeing very little memory, just because
it _appears_ big from the outside.  There's nothing special to the
unmerging case, other than that being a good way to require lots of
page allocations in a single system call.  I don't see anything
unfair about it being killed at the point of unmerging: much more
unfair that it be killed when highly merged.

> 
> But probably this thoughts have no end, and we are better stick with something
> practical that can work clean and simple...
> 
> So what I think is this:
> echo 2 is something we want in this version beacuse we dont support swapping
> of the shared pages, so we got to allow some how to break the pages...
> 
> and echo 2 got to have UNMERGEABLE break the shared pages when its madvise get
> called...
> 
> So maybe it is just better to leave it like that?
> > > When thinking about it, lets say I want to use ksm to scan 2 applications
> > > and merged their STATIC identical data, and then i want to stop scanning
> > > them after i know ksm merged the pages, as soon as i will try to
> > > unregister this 2 applications ksm will unmerge the pages, so we dont
> > > allow such thing for the user (we can tell him ofcurse for such case to
> > > use normal way of sharing, so this isnt a really strong case for this)
> > >     
> >
> > For the app it will be tricky to know when the pages are merged
> > though, right now it could only wait a "while"... so I don't really
> > see madvise(UNMERGEABLE) as useful regardless how we implement
> > it... but then this goes beyond the scope of this bug because as said
> > madvise(UNMERGEABLE) is the only place that breaks ksm pages as safe
> > as regular write fault in oom context because of it running in the
> > process context (not echo 2 or kksmd context).
> >   
> Yea, I agree about that this case was idiotic :), Actually I thought about
> case where application get little bit more info, but leave it, it is not worth
> it, traditional sharing is much better for such cases.

I didn't seem idiotic to me, but I hadn't realized the ksmd timelapse
uncertainty Andrea points out.  Well, I'm not keen to change the way
it's working at present, but I do think you're right to question all
these aspects of unmerging.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

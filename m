From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: remove zero_page (was Re: -mm merge plans for 2.6.24)
Date: Wed, 10 Oct 2007 00:30:28 +1000
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org> <Pine.LNX.4.64.0710100424050.24074@blonde.wat.veritas.com> <alpine.LFD.0.999.0710092202000.3838@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.0.999.0710092202000.3838@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710100030.28806.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wednesday 10 October 2007 15:20, Linus Torvalds wrote:
> On Wed, 10 Oct 2007, Hugh Dickins wrote:
> > On Tue, 9 Oct 2007, Nick Piggin wrote:
> > > by it ;) To prove my point: the *first* approach I posted to fix this
> > > problem was exactly a patch to special-case the zero_page refcounting
> > > which was removed with my PageReserved patch. Neither Hugh nor yourself
> > > liked it one bit!
> >
> > True (speaking for me; I forget whether Linus ever got to see it).
>
> The problem is, those first "remove ref-counting" patches were ugly
> *regardless* of ZERO_PAGE.
>
> We (yes, largely I) fixed up the mess since. The whole vm_normal_page()
> and the magic PFN_REMAP thing got rid of a lot of the problems.
>
> And I bet that we could do something very similar wrt the zero page too.
>
> Basically, the ZERO page could act pretty much exactly like a PFN_REMAP
> page: the VM would not touch it. No rmap, no page refcounting, no nothing.
>
> This following patch is not meant to be even half-way correct (it's not
> even _remotely_ tested), but is just meant to be a rough "grep for
> ZERO_PAGE in the VM, and see what happens if you don't ref-count it".
>
> Would something like the below work? I dunno. But I suspect it would. I

Sure it will work. It's not completely trivial like your patch,
though. The VM has to know about ZERO_PAGE if you also want it
to do the "optimised" wp (what you have won't work because it
will break all other "not normal" pages which are non-zero I think).

And your follow_page_page path is not going to do the right thing
for ZERO_PAGE either I think.



> doubt anybody has the energy to actually try to actually follow through on
> it, which is why I'm not pushing on it any more, and why I'll accept

Sure they have.

http://marc.info/?l=linux-mm&m=117515508009729&w=2

OK, this patch was open coding the tests rather than putting them in
vm_normal_page, but vm_normal_page doesn't magically make it a whole
lot cleaner (a _little_ bit cleaner, I agree, but in my current patch
I still need a vm_normal_or_zero_page() function).


> Nick's patch to just remove ZERO_PAGE, but I really *am* very unhappy
> about this.

Well that's not very good...


> The "page refcounting cleanups" in the VM back when were really painful.
> And dammit, I felt like I was the one who had to clean them up after you
> guys. Which makes me really testy on this subject.

OK, but in this case we'll not have a big hard-to-revert set of
changes that fundamentally alter assumptions throughout the vm.
It will be more a case of "if somebody screams, put the zero page
back", won't it?


> Totally half-assed untested patch to follow, not meant for anything but a
> "I think this kind of approach should have worked too" comment.
>
> So I'm not pushing the patch below, I'm just fighting for people realizing
> that
>
>  - the kernel has *always* (since pretty much day 1) done that ZERO_PAGE
>    thing. This means that I would not be at all surprised if some
>    application basically depends on it. I've written test-programs that
>    depends on it - maybe people have written other code that basically has
>    been written for and tested with a kernel that has basically always
>    made read-only zero pages extra cheap.
>
>    So while it may be true that removing ZERO_PAGE won't affect anybody, I
>    don't think it's a given, and I also don't think it's sane calling
>    people "crazy" for depending on something that has always been true
>    under Linux for the last 15+ years. There are few behaviors that have
>    been around for that long.

That's the main question. Maybe my wording was a little strong, but
I simply personally couldn't think of sane uses of zero page. I'm
not prepared to argue that none could possibly exist.

It just seems like now might be a good time to just _try_ removing
the zero page, because of this peripheral problem caused by my
refcounting patch. If it doesn't work out, then at least we'll be
wiser for it, we can document why the zero page is needed, and add
it back with the refcounting exceptions.


>  - make sure the commit message is accurate as to need for this (ie not
>    claim that the ZERO_PAGE itself was the problem, and give some actual
>    performance numbers on what is going on)

OK, maybe this is where we are not on the same page.
There are 2 issues really. Firstly, performance problem of
refcounting the zero-page -- we've established that it causes
this livelock and that we should stop refcounting it, right?

Second issue is the performance difference between removing the
zero page completely, and de-refcounting it (it's obviously
incorrect to argue for zero page removal for performance reasons
if the performance improvement is simply coming from avoiding
the refcounting). The problem with that is I simply don't know
any tests that use the ZERO_PAGE significantly enough to measure
a difference. The 1000 COW faults vs < 1 unmap per second thing
was simply to show that, on the micro level, performance won't
have regressed by removing the zero page.

So I'm not arguing to remove the zero page because performance
is so much better than having a de-refcounted zero page! I'm
saying that we should remove the refcounting one way or the
other. If you accept that, then I argue that we should try
removing zero page completely rather than just de-refcounting
it, because that allows nice simplifications and hopefully nobody
will miss the zero page.

Does that make sense?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

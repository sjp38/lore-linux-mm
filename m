Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3C49382F65
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 19:26:22 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so70839504pac.3
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 16:26:22 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id j6si16624628pbq.56.2015.10.21.16.26.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 16:26:21 -0700 (PDT)
Received: by pabrc13 with SMTP id rc13so67881727pab.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 16:26:21 -0700 (PDT)
Date: Wed, 21 Oct 2015 16:26:09 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/12] mm: rmap use pte lock not mmap_sem to set
 PageMlocked
In-Reply-To: <56255FE4.5070609@suse.cz>
Message-ID: <alpine.LSU.2.11.1510211544540.3905@eggly.anvils>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils> <alpine.LSU.2.11.1510182148040.2481@eggly.anvils> <56248C5B.3040505@suse.cz> <alpine.LSU.2.11.1510190341490.3809@eggly.anvils> <20151019131308.GB15819@node.shutemov.name>
 <alpine.LSU.2.11.1510191218070.4652@eggly.anvils> <20151019201003.GA18106@node.shutemov.name> <56255FE4.5070609@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrey Konovalov <andreyknvl@google.com>, Dmitry Vyukov <dvyukov@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, 19 Oct 2015, Vlastimil Babka wrote:
> On 10/19/2015 10:10 PM, Kirill A. Shutemov wrote:
> > On Mon, Oct 19, 2015 at 12:53:17PM -0700, Hugh Dickins wrote:
> > > On Mon, 19 Oct 2015, Kirill A. Shutemov wrote:
> > > > On Mon, Oct 19, 2015 at 04:20:05AM -0700, Hugh Dickins wrote:
> > > > > > Note how munlock_vma_pages_range() via __munlock_pagevec() does
> > > > > > TestClearPageMlocked() without (or "between") pte or page lock. But
> > > > > > the pte
> > > > > > lock is being taken after clearing VM_LOCKED, so perhaps it's safe
> > > > > > against
> > > > > > try_to_unmap_one...
> > > > > 
> > > > > A mind-trick I found helpful for understanding the barriers here, is
> > > > > to imagine that the munlocker repeats its "vma->vm_flags &=
> > > > > ~VM_LOCKED"
> > > > > every time it takes the pte lock: it does not actually do that, it
> > > > > doesn't need to of course; but that does help show that ~VM_LOCKED
> > > > > must be visible to anyone getting that pte lock afterwards.
> > > > 
> > > > How can you make sure that any other codepath that changes vm_flags
> > > > would
> > > > not make (vm_flags & VM_LOCKED) temporary true while dealing with other
> > > > flags?
> > > > 
> > > > Compiler can convert things like "vma->vm_flags &= ~VM_FOO;" to
> > > > whatever
> > > > it wants as long as end result is the same. It's very unlikely that it
> > > > will generate code to set all bits to one and then clear all which
> > > > should
> > > > be cleared, but it's theoretically possible.
> 
> I think Linus would be very vocal about such compiler implementation. And I
> can imagine a lot of things in the kernel would break by those spuriously set
> bits. There must be a lot of stuff that's "theoretically possible within the
> standard" but no sane compiler does. I believe even compiler guys are not
> that insane. IIRC we've seen bugs like this and they were always treated as
> bugs and fixed.
> The example I've heard often used for theoretically possible but insane stuff
> is that the compiler could make code randomly write over anything that's not
> volatile, as long as it restored the original values upon e.g. returning from
> the function. That just can't happen.
> 
> > > I think that's in the realm of the fanciful.  But yes, it quite often
> > > turns out that what I think is fanciful, is something that Paul has
> > > heard compiler writers say they want to do, even if he has managed
> > > to discourage them from doing it so far.
> > 
> > Paul always has links to pdfs with this kind of horror. ;)
> > 
> > > But more to the point, when you write of "end result", the compiler
> > > would have no idea that releasing mmap_sem is the point at which
> > > end result must be established:
> 
> Isn't releasing a lock one of those "release" barriers where previously
> issued writes must become visible before the unlock takes place?

Yes, as I understand it.

> 
> > > wouldn't it have to establish end
> > > result before the next unlock operation, and before the end of the
> > > compilation unit?
> 
> Now I'm lost in what you mean.

I just meant what you suggest above; plus, if the compiler cannot see
any unlock within its scope, it must complete the write before returning.

> 
> > > pte unlock being the relevant unlock operation
> > > in this case, at least with my patch if not without.
> 
> Hm so IIUC Kirill's point is that try_to_unmap_one() is checking VM_LOCKED
> under pte lock, but somebody else might be modifying vm_flags under mmap_sem,
> and thus we have no protection.

Yes, in trying to understand what it was that lost you above, I finally
grasped Kirill's (perfectly well stated) point: whereas I was focussed on
the valid interplay between try_to_unmap_one() and mlock(2) and munlock(2),
he was concerned about a non-mlocker-munlocker doing something else to
vm_flags (under exclusive mmap_sem) while we're in try_to_unmap_one().

Which indeed would be a problem (a problem of the "left page unevictable
when it's not in any locked vma" kind) if the kernel is to be built with
one of these hypothetical compilers which implements
vm_flags &= VM_WHATEVER or vm_flags |= VM_WHATEVER with an intermediate
vm_flags = -1 stage.

And we'd feel better about it if I could point to somewhere which
already absolutely depends upon this not happening; but I'll admit that
the first places I looked to for support, turned out already to have the
WRITE_ONCE when modifying.  And I don't feel quite as confident of Linus's
outrage in the "&=" or "|=" case, as in the straight "=" assignment case.

I'm pretty sure I could find examples if I spent the time on it (er, how
convincing an argument is that??), but there do seem to be a lot of more
urgent things to attend to, than looking for those examples, or rushing
to add some kind of notation in lots of places.

Clearly I should add a couple of comments, to the commit description if
not to the code: one to add the case you've convinced me I was also fixing,
one to acknowledge Kirill's point about creative compilers.  That I will
do, before the patch hits Linus's tree, but not written yet.

And we could argue over whether I should restore the trylock of mmap_sem
(but this time under pte lock).  Personally I'm against restoring it:
it limits the effectiveness of the re-mlock technique, to handle a
hypothetical case, which we all(?) agree is not an imminent problem,
and should eventually be handled in a better way.

Hugh

> 
> > > > 
> > > > I think we need to have at lease WRITE_ONCE() everywhere we update
> > > > vm_flags and READ_ONCE() where we read it without mmap_sem taken.
> 
> It wouldn't hurt to check if seeing a stale value or using non-atomic RMW can
> be a problem somewhere. In this case it's testing, not changing, so RMW is
> not an issue. But the check shouldn't consider arbitrary changes made by a
> potentially crazy compiler.
> 
> > > Not a series I'll embark upon myself,
> > > and the patch at hand doesn't make things worse.
> > 
> > I think it does.
> 
> So what's the alternative? Hm could we keep the trylock on mmap_sem under pte
> lock? The ordering is wrong, but it's a trylock, so no danger of deadlock?
> 
> > The patch changes locking rules for ->vm_flags without proper preparation
> > and documentation. It will strike back one day.
> > I know we have few other cases when we access ->vm_flags without mmap_sem,
> > but this doesn't justify introducing one more potentially weak codepath.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

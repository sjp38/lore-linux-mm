Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B0B5C6B028D
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 16:25:37 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 21so244561485pfy.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 13:25:37 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id m28si9349564pfk.200.2016.09.23.13.25.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 13:25:36 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id q2so45174836pfj.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 13:25:36 -0700 (PDT)
Date: Fri, 23 Sep 2016 13:25:28 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/2] mm: vma_merge: fix vm_page_prot SMP race condition
 against rmap_walk
In-Reply-To: <20160923191840.GK3485@redhat.com>
Message-ID: <alpine.LSU.2.11.1609231238390.20686@eggly.anvils>
References: <20160918003654.GA25048@redhat.com> <1474309513-20313-1-git-send-email-aarcange@redhat.com> <alpine.LSU.2.11.1609220224230.12486@eggly.anvils> <20160923191840.GK3485@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Jan Vorlicek <janvorli@microsoft.com>, Aditya Mandaleeka <adityam@microsoft.com>

On Fri, 23 Sep 2016, Andrea Arcangeli wrote:

> Hello Hugh,
> 
> On Thu, Sep 22, 2016 at 03:36:36AM -0700, Hugh Dickins wrote:
> > I suppose: this one seems overblown to me, and risks more change
> > (as the CONFIG_DEBUG_VM_RB=y crashes showed).
> 
> When DEBUG_VM_RB=n there was no bug that I know of. So I don't think
> the fact there was a false positive in the validation code that didn't
> immediately cope with the new changes, should be a major concern.
> 
> > But I've come back to it several times, not found any incorrectness,
> > and was just about ready to Ack it (once the VM_RB fix is folded in,
> > though I've not studied that yet): when I noticed that what I'd liked
> > least about this one, looks unnecessary too - see below.
> 
> The reason the VM_RB=y incremental fix to the validation code is not a
> few liner, is to micro-optimize it. I call directly
> __vma_unlink_common to be sure the additional parameter is eliminated
> at build time if CONFIG_DEBUG_VM_RB=n, and it never risks to go
> through the stack in production.
> 
> > At the bottom I've appended my corrected version of Andrea's
> > earlier patches for comparison: maybe better for stable?
> 
> I think it's perfectly suitable for -stable, if there is urgency to
> merge it in -stable. OTOH with regard to urgency, this isn't
> exploitable and the bug was there for 10+ years?

Thanks; and agreed, no desperate urgency.

> 
> > > +static inline void __vma_unlink_prev(struct mm_struct *mm,
> > > +				     struct vm_area_struct *vma,
> > > +				     struct vm_area_struct *prev)
> > > +{
> > > +	__vma_unlink_common(mm, vma, prev, true);
> > > +}
> > > +
> > > +static inline void __vma_unlink(struct mm_struct *mm,
> > > +				struct vm_area_struct *vma)
> > > +{
> > > +	__vma_unlink_common(mm, vma, NULL, false);
> > > +}
> > > +
> > 
> > Umm, how many functions do we need to unlink a vma?
> > Perhaps I'm missing some essential, but what's wrong with a single
> > __vma_unlink(mm, vma)?  (Could omit mm, but probably better with it.)
> 
> Of course that would work, I did that initially. I only had
> __vma_unlink and I just removed the "prev" parameter from it.
> 
> > The existing __vma_unlink(mm, vma, prev) dates, of course, from
> > long before Linus added vma->vm_prev in 2.6.36.  It doesn't really
> > need its prev arg nowadays, and I wonder if that misled you into
> > all this prev and has_prev stuff?
> 
> After removing "prev" from __vma_unlink I reintroduced
> __vma_unlink_prev as a microoptimization for remove_next = 1/2
> cases.
> 
> In those two cases we have already "prev" and it's guaranteed not
> null. So by keeping the _common version __always_inline the parameters
> of the _common disappears in the assembly and in turn the
> __vma_unlink_prev is a bit faster.
> 
> Perhaps it's not worth to do these kind of microoptimizations? The
> only reason I reintroduced a version of __vma_unlink_prev that gets
> prev not NULL as parameter was explicitly to microoptimize with
> __always_inline.

Thanks for explaining your process.

In my opinion, it is definitely not worth such micro-optimizations as
clutter up the code in this way, unless it is really an important hot
codepath that will benefit (memset for example) - which I doubt this is.
If I were wicked, I'd ask you for the performance numbers to justify it.

> 
> > (Yes, of course it needs to handle the NULL vma->vm_prev mm->mmap
> > case, but that doesn't need these three functions.)
> > 
> > But I see this area gets touched again in yesterday's 3/4 to fix
> > the VM_RB issue.  I haven't tried applying that patch on top to
> > see what the result looks like, but I hope simpler than this.
> 
> Right, to handle the case of DEBUG_VM_RB=y I need to pass a different
> "ignore" parameter in remove_next == 3, so it's even more worth to
> microoptimize now that I'm forced to have a different kind of call
> anyway, and I can't just call __vma_unlink(next).
> 
> Once the two patches are folded, __vma_unlink is renamed to
> __vma_unlink_prev that is a more accurate name anyway I think, given
> the parameters and that assumption it does on prev being not NULL.
> 
> > > +		if (remove_next != 3)
> > > +			__vma_unlink_prev(mm, next, vma);
> > > +		else
> > > +			/* vma is not before next if they've been swapped */
> > > +			__vma_unlink(mm, next);
> > 
> > And if the VM_RB issue doesn't complicate it, this would just amount to
> >    		__vma_unlink(mm, next);
> > without any remove_next 3 variation.
> 
> Yes, and VM_RB complicates it.

Yes, it annoys me too, when I have to pass some additional arg down,
just to be available to a rarely set debug option.

> 
> > > +		if (remove_next != 3) {
> > 
> > if (vma == orig_vma), and you won't need the remove_next 3 state at all.
> 
> I think that would be less readable. I don't want to risk to mistake
> case 1/2/3. I could use an enum and REMOVE_NEXT, REMOVE_NEXT_NEXT,
> REMOVE_PREV, or I could use -1 instead of 3 to show it's removing prev
> if you wish, but I would prefer not to use vma == orig_vma to detect
> remove_next != 3. It can't improve performance either.
> 
> orig_vma is purely for trans_huge split when the vma->vm_start/end
> (and next->vm_start if adjust_next) boundary changes.
> 
> The only point of orig_vma is to replace this statement: "remove_next
> != 3 : vma : next". I wouldn't mix up the detection of case 1/2/3 with
> that micro-optimization.

Fair enough.  As you know, I wasn't all that keen on remove_next 3,
since remove_next 1 and remove_next 2 actually described what they
were doing.  But I've no objection to retaining it, and understand
why you'd prefer to keep orig_vma for its specific use, rather than
to control the flow.  I merely spotted a possibility for removing
remove_next 3 once the vma_unlink()s were simplified.

> 
> > Here's my fixup of Andrea's earlier version, not swapping vma and next
> > as the above does, but applying properties of next to vma as before.
> > Maybe this version should go in first, so that it's available as an
> > easier and safer candidate for stable backports: whatever akpm prefers.
> 
> I think this is a more conservative and in turn safer approach for
> urgent -stable or for urgent backports. Performance-wise I doubt any
> difference is measurable.
> 
> For the longer term upstream, I think removing the oddness factor from
> case 8 for good is better, as we may get bitten by it again and it's
> also quite counter intuitive for the callers of vma_merge to receive a
> vma that isn't already fully in sync with all the parameters passed to
> vma_merge. And having to overwrite the "different" bits by hand. I
> feel the oddness in case 8 should be dropped for good and it's not
> much more complicated to do so (especially if we ignore the
> __vma_unlink details which are a fully self contained problem and they
> cannot add up to the complexity of vma_merge/vma_adjust).

As I remarked in other mail, case 8 will always be odd, but you're
shifting the oddness to where you believe it will be more future-proof.
And you may be proved right.  Or...

> 
> I successfully tested your fix with the testcase that exercises the
> race and reviewed your fix and it's certainly correct too to solve the
> race against rmap_walks that access vma_page_prot/vm_flags. The fix in
> -mm however is solving the race condition for all fields, if any
> rmap_walk accessed more than those two fields, and without having to
> copy them off.
> 
> Tested-by: Andrea Arcangeli <aarcange@redhat.com>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
> 
> Overall I'm fine either ways, but I had to elaborate my preference :).

Sure, and thank you for doing so.  We each have our preference,
and we can each live with the other.  Andrew can decide whichever,
and no great hurry.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 79B3F6B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 20:15:20 -0400 (EDT)
Date: Thu, 1 Nov 2012 09:21:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC v2] Support volatile range for anon vma
Message-ID: <20121101002118.GA26256@bbox>
References: <1351560594-18366-1-git-send-email-minchan@kernel.org>
 <20121031143524.0509665d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121031143524.0509665d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Stultz <john.stultz@linaro.org>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, sanjay@google.com, pjt@google.com, David Rientjes <rientjes@google.com>

Hi Andrew,

On Wed, Oct 31, 2012 at 02:35:24PM -0700, Andrew Morton wrote:
> On Tue, 30 Oct 2012 10:29:54 +0900
> Minchan Kim <minchan@kernel.org> wrote:
> 
> > This patch introudces new madvise behavior MADV_VOLATILE and
> > MADV_NOVOLATILE for anonymous pages. It's different with
> > John Stultz's version which considers only tmpfs while this patch
> > considers only anonymous pages so this cannot cover John's one.
> > If below idea is proved as reasonable, I hope we can unify both
> > concepts by madvise/fadvise.
> > 
> > Rationale is following as.
> > Many allocators call munmap(2) when user call free(3) if ptr is
> > in mmaped area. But munmap isn't cheap because it have to clean up
> > all pte entries and unlinking a vma so overhead would be increased
> > linearly by mmaped area's size.
> 
> Presumably the userspace allocator will internally manage memory in
> large chunks, so the munmap() call frequency will be much lower than
> the free() call frequency.  So the performance gains from this change
> might be very small.
> 
> The whole point of the patch is to improve performance, but we have no
> evidence that it was successful in doing that!  I do think we'll need
> good quantitative testing results before proceeding with such a patch,
> please.

Absolutely. That's why I send it as RFC.
In this time, I would like to reach a concensus on that this idea
makes sense before further investigating because we have lots of
experienced developer pool and one of them might know this is really
needed or not.

> 
> Also, it is very desirable that we involve the relevant userspace
> (glibc, etc) developers in this.  And I understand that the google
> tcmalloc project will probably have interest in this - I've cc'ed
> various people@google in the hope that they can provide input (please).

Thanks! I should have done. Such input is really one I need now.

> 
> Also, it is a userspace API change.  Please cc mtk.manpages@gmail.com.

This is RFC so we don't have anything fixed until now.
I will Cc'ed him after everything I should solve goes out and
interface is fixed.

> 
> Also, I assume that you have userspace test code.  At some stage,
> please consider adding a case to tools/testing/selftests.  Such a test
> would require to creation of memory pressure, which is rather contrary
> to the selftests' current philosopy of being a bunch of short-running
> little tests.  Perhaps you can come up with something.  But I suggest
> that such work be done later, once it becomes clearer that this code is
> actually headed into the kernel.

Yes.

> 
> > Allocator should call madvise(MADV_NOVOLATILE) before reusing for
> > allocating that area to user. Otherwise, accessing of volatile range
> > will meet SIGBUS error.
> 
> Well, why?  It would be easy enough for the fault handler to give
> userspace a new, zeroed page at that address.

Absolutely. It would be convenient but as a matter of fact, I am considering
to unify John Stultz's fallocate volatile range which consider only tmpfs
pages so madvise/fadvise might be better candidate as API.
In tmpfs case, John implemented it as returning zero page when someone
access volatile region like you mentioned but in this kernel summit, Hugh
pointed out and wanted to return SIGBUS and I think it makes debug better.

Another option is we can put a flag in API which indicates that VM will
return zero page or SIGBUS when user access volatile range so user can do
what they want.

> 
> Or we could simply leave the old page in place at that address.  If the
> page gets touched, we clear MADV_NOVOLATILE on its VMA and give the
> page (or all the not-yet-reclaimed pages) back to userspace at their
> old addresses.
> 
> Various options suggest themselves here.  You've chosen one of them but
> I would like to see a pretty exhaustive description of the reasoning
> behind that decision.

Will do.

> 
> Also, I wonder about the interaction with other vma manipulation
> operations.  For example, can a VMA get split when in the MADV_VOLATILE
> state?  If so, what happens?  

Both VMAs would be volatile although one of either has never reclaimed
pages. I understand it's not an optimal but I expect user will not do 
such operations(ex, mprotect, mremap) frequently on volatile vma.

If they do, maybe I need to come up with something but It wouldn't be easy.

> 
> Also, I see no reason why the code shouldn't work OK with nonlinear VMAs,
> but I bet this wasn't tested ;)

Yes. I didn't consider that yet. AFAIK, nonlinear vma is related to
file-mapped vma while this patch consider only anon vma which is good for
first step.

> 
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -86,6 +86,22 @@ static long madvise_behavior(struct vm_area_struct * vma,
> >  		if (error)
> >  			goto out;
> >  		break;
> > +	case MADV_VOLATILE:
> > +		if (vma->vm_flags & VM_LOCKED) {
> > +			error = -EINVAL;
> > +			goto out;
> > +		}
> > +		new_flags |= VM_VOLATILE;
> > +		vma->purged = false;
> > +		break;
> > +	case MADV_NOVOLATILE:
> > +		if (!(vma->vm_flags & VM_VOLATILE)) {
> > +			error = -EINVAL;
> > +			goto out;
> 
> I wonder if this really should return an error.  Other madvise()
> options don't do this, and running MADV_NOVOLATILE against a
> not-volatile area seems pretty benign and has clearly defined before-
> and after- states.

Will fix.

Thanks for the review, Andrew.

> 
> > +		}
> > +
> > +		new_flags &= ~VM_VOLATILE;
> > +		break;
> >  	}
> >  
> >  	if (new_flags == vma->vm_flags) {
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

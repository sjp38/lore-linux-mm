Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 42B1B6B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 17:35:26 -0400 (EDT)
Date: Wed, 31 Oct 2012 14:35:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v2] Support volatile range for anon vma
Message-Id: <20121031143524.0509665d.akpm@linux-foundation.org>
In-Reply-To: <1351560594-18366-1-git-send-email-minchan@kernel.org>
References: <1351560594-18366-1-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Stultz <john.stultz@linaro.org>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, sanjay@google.com, pjt@google.com, David Rientjes <rientjes@google.com>

On Tue, 30 Oct 2012 10:29:54 +0900
Minchan Kim <minchan@kernel.org> wrote:

> This patch introudces new madvise behavior MADV_VOLATILE and
> MADV_NOVOLATILE for anonymous pages. It's different with
> John Stultz's version which considers only tmpfs while this patch
> considers only anonymous pages so this cannot cover John's one.
> If below idea is proved as reasonable, I hope we can unify both
> concepts by madvise/fadvise.
> 
> Rationale is following as.
> Many allocators call munmap(2) when user call free(3) if ptr is
> in mmaped area. But munmap isn't cheap because it have to clean up
> all pte entries and unlinking a vma so overhead would be increased
> linearly by mmaped area's size.

Presumably the userspace allocator will internally manage memory in
large chunks, so the munmap() call frequency will be much lower than
the free() call frequency.  So the performance gains from this change
might be very small.

The whole point of the patch is to improve performance, but we have no
evidence that it was successful in doing that!  I do think we'll need
good quantitative testing results before proceeding with such a patch,
please.

Also, it is very desirable that we involve the relevant userspace
(glibc, etc) developers in this.  And I understand that the google
tcmalloc project will probably have interest in this - I've cc'ed
various people@google in the hope that they can provide input (please).

Also, it is a userspace API change.  Please cc mtk.manpages@gmail.com.

Also, I assume that you have userspace test code.  At some stage,
please consider adding a case to tools/testing/selftests.  Such a test
would require to creation of memory pressure, which is rather contrary
to the selftests' current philosopy of being a bunch of short-running
little tests.  Perhaps you can come up with something.  But I suggest
that such work be done later, once it becomes clearer that this code is
actually headed into the kernel.

> Allocator should call madvise(MADV_NOVOLATILE) before reusing for
> allocating that area to user. Otherwise, accessing of volatile range
> will meet SIGBUS error.

Well, why?  It would be easy enough for the fault handler to give
userspace a new, zeroed page at that address.

Or we could simply leave the old page in place at that address.  If the
page gets touched, we clear MADV_NOVOLATILE on its VMA and give the
page (or all the not-yet-reclaimed pages) back to userspace at their
old addresses.

Various options suggest themselves here.  You've chosen one of them but
I would like to see a pretty exhaustive description of the reasoning
behind that decision.

Also, I wonder about the interaction with other vma manipulation
operations.  For example, can a VMA get split when in the MADV_VOLATILE
state?  If so, what happens?  

Also, I see no reason why the code shouldn't work OK with nonlinear VMAs,
but I bet this wasn't tested ;)

> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -86,6 +86,22 @@ static long madvise_behavior(struct vm_area_struct * vma,
>  		if (error)
>  			goto out;
>  		break;
> +	case MADV_VOLATILE:
> +		if (vma->vm_flags & VM_LOCKED) {
> +			error = -EINVAL;
> +			goto out;
> +		}
> +		new_flags |= VM_VOLATILE;
> +		vma->purged = false;
> +		break;
> +	case MADV_NOVOLATILE:
> +		if (!(vma->vm_flags & VM_VOLATILE)) {
> +			error = -EINVAL;
> +			goto out;

I wonder if this really should return an error.  Other madvise()
options don't do this, and running MADV_NOVOLATILE against a
not-volatile area seems pretty benign and has clearly defined before-
and after- states.

> +		}
> +
> +		new_flags &= ~VM_VOLATILE;
> +		break;
>  	}
>  
>  	if (new_flags == vma->vm_flags) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

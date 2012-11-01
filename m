Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 7ED986B0070
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 21:40:05 -0400 (EDT)
Date: Thu, 1 Nov 2012 10:46:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC v2] Support volatile range for anon vma
Message-ID: <20121101014604.GE26256@bbox>
References: <1351560594-18366-1-git-send-email-minchan@kernel.org>
 <20121031143524.0509665d.akpm@linux-foundation.org>
 <CAPM31RKm89s6PaAnfySUD-f+eGdoZP6=9DHy58tx_4Zi8Z9WPQ@mail.gmail.com>
 <CAHGf_=om34CQoPqgmVE5v8oVxntaJQ-bvFeEPMnfe_R+uvxqrQ@mail.gmail.com>
 <CAPM31RJwrM2f8fg0--Xcea+tHYcB2C_khXy3k-h=O2x4MMfwmw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPM31RJwrM2f8fg0--Xcea+tHYcB2C_khXy3k-h=O2x4MMfwmw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Turner <pjt@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Stultz <john.stultz@linaro.org>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, sanjay@google.com, David Rientjes <rientjes@google.com>

On Wed, Oct 31, 2012 at 06:15:33PM -0700, Paul Turner wrote:
> On Wed, Oct 31, 2012 at 3:56 PM, KOSAKI Motohiro
> <kosaki.motohiro@gmail.com> wrote:
> >>> > Allocator should call madvise(MADV_NOVOLATILE) before reusing for
> >>> > allocating that area to user. Otherwise, accessing of volatile range
> >>> > will meet SIGBUS error.
> >>>
> >>> Well, why?  It would be easy enough for the fault handler to give
> >>> userspace a new, zeroed page at that address.
> >>
> >> Note: MADV_DONTNEED already has this (nice) property.
> >
> > I don't think I strictly understand this patch. but maybe I can answer why
> > userland and malloc folks don't like MADV_DONTNEED.
> >
> > glibc malloc discard freed memory by using MADV_DONTNEED
> > as tcmalloc. and it is often a source of large performance decrease.
> > because of MADV_DONTNEED discard memory immediately and
> > right after malloc() call fall into page fault and pagesize memset() path.
> > then, using DONTNEED increased zero fill and cache miss rate.
> >
> > At called free() time, malloc don't have a knowledge when next big malloc()
> > is called. then, immediate discarding may or may not get good performance
> > gain. (Ah, ok, the rate is not 5:5. then usually it is worth. but not everytime)
> >
> 
> Ah; In tcmalloc allocations (and their associated free-lists) are
> binned into separate lists as a function of object-size which helps to
> mitigate this.
> 
> I'd make a separate more general argument here:
> If I'm allocating a large (multi-kilobyte object) the cost of what I'm
> about to do with that object is likely fairly large -- The fault/zero
> cost a probably fairly small proportional cost, which limits the
> optimization value.

While I look at thread trial of Rik which is same goal while implementation
is different, I found this number.

https://lkml.org/lkml/2007/4/20/390

I believe optimiation is valuable. Of course, I need simillar testing for
proving it.

> 
> >
> > In past, several developers tryied to avoid such situation, likes
> >
> > - making zero page daemon and avoid pagesize zero fill at page fault
> > - making new vma or page flags and mark as discardable w/o swap and
> >   vmscan treat it. (like this and/or MADV_FREE)
> > - making new process option and avoid page zero fill from page fault path.
> >   (yes, it is big incompatibility and insecure. but some embedded folks thought
> >    they are acceptable downside)
> > - etc
> >
> >
> > btw, I'm not sure this patch is better for malloc because current MADV_DONTNEED
> > don't need mmap_sem and works very effectively when a lot of threads case.
> > taking mmap_sem might bring worse performance than DONTNEED. dunno.
> 
> MADV_VOLATILE also seems to end up looking quite similar to a
> user-visible (range-based) cleancache.
> 
> A second popular use-case for such semantics is the case of
> discardable cache elements (e.g. web browser).  I suspect we'd want to
> at least mention these in the changelog.  (Alternatively, what does a
> cleancache-backed-fs exposing these semantics look like?)
> 

It's a trial of John Stultz(http://lwn.net/Articles/518130/, there was another
trial long time ago https://lkml.org/lkml/2005/11/1/384) and I want to
expand the concept from file-backed page to anonymous page so this patch
is a trial for anonymous page. So, usecase of my patch have focussed on
malloc/free case.
I hope both are able to be unified.

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

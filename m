Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 4F7EF6B009D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 18:21:05 -0500 (EST)
Date: Wed, 12 Dec 2012 08:21:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC v3] Support volatile range for anon vma
Message-ID: <20121211232101.GA32158@blaptop>
References: <1355193255-7217-1-git-send-email-minchan@kernel.org>
 <50C77F47.10601@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50C77F47.10601@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi John,

On Tue, Dec 11, 2012 at 10:45:27AM -0800, John Stultz wrote:
> On 12/10/2012 06:34 PM, Minchan Kim wrote:
> >This still is [RFC v3] because just passed my simple test
> >with TCMalloc tweaking.
> >
> >I hope more inputs from user-space allocator people and test patch
> >with their allocator because it might need design change of arena
> >management design for getting real vaule.
> >
> >Changelog from v2
> >
> >  * Removing madvise(addr, length, MADV_NOVOLATILE).
> >  * add vmstat about the number of discarded volatile pages
> >  * discard volatile pages without promotion in reclaim path
> >
> >This is based on v3.6.
> >
> >- What's the madvise(addr, length, MADV_VOLATILE)?
> >
> >   It's a hint that user deliver to kernel so kernel can *discard*
> >   pages in a range anytime.
> >
> >- What happens if user access page(ie, virtual address) discarded
> >   by kernel?
> >
> >   The user can see zero-fill-on-demand pages as if madvise(DONTNEED).
> >
> >- What happens if user access page(ie, virtual address) doesn't
> >   discarded by kernel?
> >
> >   The user can see old data without page fault.
> >
> >- What's different with madvise(DONTNEED)?
> >
> >   System call semantic
> >
> >   DONTNEED makes sure user always can see zero-fill pages after
> >   he calls madvise while VOLATILE can see zero-fill pages or
> >   old data.
> I still need to really read and understand the patch, but at a high
> level I'm not sure how this works. So does the VOLATILE flag get
> cleared on any access, even if the pages have not been discarded?

No. It is cleared when user try to access discareded pages so
This patch is utter crap. I missed that point.
Thanks for pointing out, John.

Hmm, in the end, we need NOVOLATILE.

> What happens if an application wants to store non-volatile data in
> an area that was once marked volatile. If there was never memory
> pressure, it seems the volatility would persist with no way of
> removing it.

Yes. that's why this patch is crap and I'm insane. :(

> 
> Either way, I feel that with this revision, specifically dropping
> the NOVOLATILE call and the SIGBUS optimization the Mozilla folks
> suggested, your implementation has drifted quite far from the
> concept I'm pushing. While I hope we can still align the underlying
> mm implementation, I might ask that you use a different term for the
> semantics you propose, so we don't add too much confusion to the
> discussion.
> 
> Maybe you could call it DONTNEED_DEFERRED or something?
> 
> In the meantime, I'll be reading your patch in detail and seeing how
> we might be able to combine our differing approaches.

You don't need it. Ignore this patch.
I will rework.

Thanks.

> 
> thanks
> -john
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

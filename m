Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 088A56B0062
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 20:54:54 -0400 (EDT)
Date: Tue, 7 Aug 2012 09:56:20 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/5] [RFC][HACK] Add LRU_VOLATILE support to the VM
Message-ID: <20120807005620.GB19515@bbox>
References: <1343447832-7182-1-git-send-email-john.stultz@linaro.org>
 <1343447832-7182-5-git-send-email-john.stultz@linaro.org>
 <20120806030451.GA11468@bbox>
 <aa61fb77-258b-4b6f-843f-689bc5c984cc@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aa61fb77-258b-4b6f-843f-689bc5c984cc@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org

On Mon, Aug 06, 2012 at 08:46:18AM -0700, Dan Magenheimer wrote:
> > From: Minchan Kim [mailto:minchan@kernel.org]
> > To: John Stultz
> > Subject: Re: [PATCH 4/5] [RFC][HACK] Add LRU_VOLATILE support to the VM
> 
> Hi Minchan --
> 
> Thanks for cc'ing me on this!
> 
> > Targets for the LRU list could be following as in future
> > 
> > 1. volatile pages in this patchset.
> > 2. ephemeral pages of tmem
> > 3. madivse(DONTNEED)
> > 4. fadvise(NOREUSE)
> > 5. PG_reclaimed pages
> > 6. clean pages if we write CFLRU(clean first LRU)
> > 
> > So if any guys have objection, please raise your hands
> > before further progress.
> 
> I agree that the existing shrinker mechanism is too primitive
> and the kernel needs to take into account more factors in
> deciding how to quickly reclaim pages from a broader set
> of sources.  However, I think it is important to ensure
> that both the "demand" side and the "supply" side are
> studied.  There has to be some kind of prioritization policy
> among all the RAM consumers so that a lower-priority
> alloc_page doesn't cause a higher-priority "volatile" page
> to be consumed.  I suspect this policy will be VERY hard to
> define and maintain.

Yes. It's another story.
At the moment, VM doesn't consider such priority-inversion problem
excpet giving the more memory to privileged processes. It's so simple
but works well till now.

> 
> Related, ephemeral pages in tmem are not truly volatile

"volatile" term is used by John for only his special patch so
I like Ereclaim(Easy Reclaim) rather than volatile.

> as there is always at least one tmem data structure pointing
> to it.  I haven't followed this thread previously so my apologies
> if it already has this, but the LRU_VOLATILE list might
> need to support a per-page "garbage collection" callback.

Right. That's why this patch provides purgepage in address_space_operations.
I think zcache could attach own address_space_operations to the page
which is allocated by zbud for instance, zcache_purgepage which is called by VM
when the page is reclaimed. So zcache don't need custom LRU policy(but still need
linked list for managing zbuddy) and pass the decision to the VM.


> 
> Dan
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

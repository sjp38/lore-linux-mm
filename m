Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0956B0198
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 03:45:25 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id r10so554722pdi.7
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 00:45:25 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id zm8si838398pac.112.2014.03.20.00.45.23
        for <linux-mm@kvack.org>;
        Thu, 20 Mar 2014 00:45:24 -0700 (PDT)
Date: Thu, 20 Mar 2014 16:45:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/3] Volatile Ranges (v11)
Message-ID: <20140320074529.GB5902@bbox>
References: <1394822013-23804-1-git-send-email-john.stultz@linaro.org>
 <20140318122425.GD3191@dhcp22.suse.cz>
 <532A3872.1080101@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <532A3872.1080101@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Michal Hocko <mhocko@suse.cz>, John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dgiani@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hello Dave,

On Wed, Mar 19, 2014 at 05:38:10PM -0700, Dave Hansen wrote:
> On 03/18/2014 05:24 AM, Michal Hocko wrote:
> > On Fri 14-03-14 11:33:30, John Stultz wrote:
> > [...]
> >> Volatile ranges provides a method for userland to inform the kernel that
> >> a range of memory is safe to discard (ie: can be regenerated) but
> >> userspace may want to try access it in the future.  It can be thought of
> >> as similar to MADV_DONTNEED, but that the actual freeing of the memory
> >> is delayed and only done under memory pressure, and the user can try to
> >> cancel the action and be able to quickly access any unpurged pages. The
> >> idea originated from Android's ashmem, but I've since learned that other
> >> OSes provide similar functionality.
> > 
> > Maybe I have missed something (I've only glanced through the patches)
> > but it seems that marking a range volatile doesn't alter neither
> > reference bits nor position in the LRU. I thought that a volatile page
> > would be moved to the end of inactive LRU with the reference bit
> > dropped. Or is this expectation wrong and volatility is not supposed to
> > touch page aging?
> 
> I'm not really convinced it should alter the aging.  Things could
> potentially go in and out of volatile state frequently, and requiring
> aging means we've got to go after them page-by-page or pte-by-pte at
> best.  That doesn't seem like something we want to do in a path we want
> to be fast.

Since vrange syscall design was changed from range-based to pte-based,
it shouldn't be fast. Sure, vrange(VOLAILTE) could be fast with just
mark it VMA_VOALTILE to vma->vm_flags but vrange(NOVOLATILE) should
look every pages in the range so it could be slow.
Even vrange(VOLATILE) call is fast now, I want to accout volatile
pages to expose it to the user by vmstat so that user could see
current status of the system memory, which makes userspace more happy
and predicatble. If we add such stat, vrange(VOLATILE) should look
every pages in the range so it could be slow, too.

> 
> Why not just let normal page aging deal with them?  It seems to me like
> like trying to infer intended lru position from volatility is the wrong
> thing.  It's quite possible we'd have two pages in the same range that
> we want in completely different parts of the LRU.  Maybe the structure
> has a hot page and a cold one, and we would ideally want the cold one
> swapped out and not the hot one.

Yes, it would be really arguble and it depends on the user's usecase.
That's why I'd like to add VRANGE_NORMAL_AGING which just don't move
the page in curret position of the LRU. It would be useful when it used
with VRANGE_SIGBUS because they could handle partial pages.

Otherwise, I'd like to move that pages into inacive's tail so that it
should prevent reclaiming of the hot pages.
If there is no memory pressure, we could get a chance to reuse volatile
pages so it could rotate back to the head of LRU when VM reclaim logic is
triggered.

I agree with John's opinion that just make approach simple as possible
and extend it later so that we should make a room in syscall semantic
and make an agreement what should be default at the moment.

Thanks.
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

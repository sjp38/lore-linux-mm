Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 63C806B0182
	for <linux-mm@kvack.org>; Wed, 19 Mar 2014 20:38:19 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so119014pab.22
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 17:38:18 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id zh8si107695pac.400.2014.03.19.17.38.12
        for <linux-mm@kvack.org>;
        Wed, 19 Mar 2014 17:38:13 -0700 (PDT)
Message-ID: <532A3872.1080101@sr71.net>
Date: Wed, 19 Mar 2014 17:38:10 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Volatile Ranges (v11)
References: <1394822013-23804-1-git-send-email-john.stultz@linaro.org> <20140318122425.GD3191@dhcp22.suse.cz>
In-Reply-To: <20140318122425.GD3191@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dgiani@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/18/2014 05:24 AM, Michal Hocko wrote:
> On Fri 14-03-14 11:33:30, John Stultz wrote:
> [...]
>> Volatile ranges provides a method for userland to inform the kernel that
>> a range of memory is safe to discard (ie: can be regenerated) but
>> userspace may want to try access it in the future.  It can be thought of
>> as similar to MADV_DONTNEED, but that the actual freeing of the memory
>> is delayed and only done under memory pressure, and the user can try to
>> cancel the action and be able to quickly access any unpurged pages. The
>> idea originated from Android's ashmem, but I've since learned that other
>> OSes provide similar functionality.
> 
> Maybe I have missed something (I've only glanced through the patches)
> but it seems that marking a range volatile doesn't alter neither
> reference bits nor position in the LRU. I thought that a volatile page
> would be moved to the end of inactive LRU with the reference bit
> dropped. Or is this expectation wrong and volatility is not supposed to
> touch page aging?

I'm not really convinced it should alter the aging.  Things could
potentially go in and out of volatile state frequently, and requiring
aging means we've got to go after them page-by-page or pte-by-pte at
best.  That doesn't seem like something we want to do in a path we want
to be fast.

Why not just let normal page aging deal with them?  It seems to me like
like trying to infer intended lru position from volatility is the wrong
thing.  It's quite possible we'd have two pages in the same range that
we want in completely different parts of the LRU.  Maybe the structure
has a hot page and a cold one, and we would ideally want the cold one
swapped out and not the hot one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

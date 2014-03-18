Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f169.google.com (mail-ve0-f169.google.com [209.85.128.169])
	by kanga.kvack.org (Postfix) with ESMTP id ED8496B010F
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 13:53:03 -0400 (EDT)
Received: by mail-ve0-f169.google.com with SMTP id pa12so7674108veb.0
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 10:53:03 -0700 (PDT)
Received: from mail-vc0-f171.google.com (mail-vc0-f171.google.com [209.85.220.171])
        by mx.google.com with ESMTPS id u5si2808966vdo.148.2014.03.18.10.53.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 10:53:03 -0700 (PDT)
Received: by mail-vc0-f171.google.com with SMTP id lg15so7632972vcb.2
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 10:53:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140318122425.GD3191@dhcp22.suse.cz>
References: <1394822013-23804-1-git-send-email-john.stultz@linaro.org>
	<20140318122425.GD3191@dhcp22.suse.cz>
Date: Tue, 18 Mar 2014 10:53:03 -0700
Message-ID: <CALAqxLU30YQs9PQaybWnTXOkVWGVX2Y7zOSLJH3Y4YSq_KDp3Q@mail.gmail.com>
Subject: Re: [PATCH 0/3] Volatile Ranges (v11)
From: John Stultz <john.stultz@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dgiani@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Mar 18, 2014 at 5:24 AM, Michal Hocko <mhocko@suse.cz> wrote:
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

Hrmm. So you're right, I had talked about how we'd end up purging
pages in a range together (as opposed to just randomly) because the
pages would have been marked together. On this pass, I was trying to
avoid touching all the pages on every operation, but I'll try to add
the referencing to keep it consistent with what was discussed (and
we'll get a sense of the performance impact).

Though subtleties like this are still open for discussion. For
instance, Minchan would like to see the volatile pages moved to the
front of the LRU instead of the back.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0536A6B0037
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 19:41:13 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so7761016pbc.39
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 16:41:13 -0700 (PDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so7823360pdj.2
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 16:41:11 -0700 (PDT)
Message-ID: <52534692.7010400@linaro.org>
Date: Mon, 07 Oct 2013 16:41:06 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 05/14] vrange: Add new vrange(2) system call
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org> <1380761503-14509-6-git-send-email-john.stultz@linaro.org> <52533C12.9090007@zytor.com> <5253404D.2030503@linaro.org> <52534331.2060402@zytor.com>
In-Reply-To: <52534331.2060402@zytor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 10/07/2013 04:26 PM, H. Peter Anvin wrote:
> On 10/07/2013 04:14 PM, John Stultz wrote:
>>> I see from the change history of the patch that this was an madvise() at
>>> some point, but was changed into a separate system call at some point,
>>> does anyone remember why that was?  A quick look through my LKML
>>> archives doesn't really make it clear.
>> The reason we can't use madvise, is that to properly handle error cases
>> and report the pruge state, we need an extra argument.
>>
>> In much earlier versions, we just returned an error when setting
>> NONVOLATILE if the data was purged. However, since we have to possibly
>> do allocations when marking a range as non-volatile, we needed a way to
>> properly handle that allocation failing. We can't just return ENOMEM, as
>> we may have already marked purged memory as non-volatile.
>>
>> Thus, that's why with vrange, we return the number of bytes modified,
>> along with the purge state. That way, if an error does occur we can
>> return the purge state of the bytes successfully modified, and only
>> return an error if nothing was changed, much like when a write fails.
>>
> I am not clear at all what the "purge state" is in this case.


You mark a chunk of memory as volatile, then at some point later, mark
its as non-volatile. The purge state tells you if the memory is still
there, or if we threw it out due to memory pressure. This lets the
application regnerate the purged data before continuing on.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 5B6646B0038
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 19:54:30 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so7797713pdj.35
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 16:54:30 -0700 (PDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so8070101pab.27
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 16:54:27 -0700 (PDT)
Message-ID: <525349AE.1070904@linaro.org>
Date: Mon, 07 Oct 2013 16:54:22 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 05/14] vrange: Add new vrange(2) system call
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org> <1380761503-14509-6-git-send-email-john.stultz@linaro.org> <52533C12.9090007@zytor.com> <5253404D.2030503@linaro.org> <52534331.2060402@zytor.com> <52534692.7010400@linaro.org> <525347BE.7040606@zytor.com>
In-Reply-To: <525347BE.7040606@zytor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 10/07/2013 04:46 PM, H. Peter Anvin wrote:
> On 10/07/2013 04:41 PM, John Stultz wrote:
>> You mark a chunk of memory as volatile, then at some point later, mark
>> its as non-volatile. The purge state tells you if the memory is still
>> there, or if we threw it out due to memory pressure. This lets the
>> application regnerate the purged data before continuing on.
>>
> And wouldn't this apply to MADV_DONTNEED just as well?  Perhaps what we
> should do is an enhanced madvise() call?
Well, I think MADV_DONTNEED doesn't *have* do to anything at all. Its
advisory after all. So it may immediately wipe out any data, but it may not.

Those advisory semantics work fine w/ VRANGE_VOLATILE. However,
VRANGE_NONVOLATILE is not quite advisory, its telling the system that it
requires the memory at the specified range to not be volatile, and we
need to correctly inform userland how much was changed and if any of the
memory we did change to non-volatile was purged since being set volatile.

In that way it is sort of different from madvise. Some sort of an
madvise2 could be done, but then the extra purge state argument would be
oddly defined for any other mode.

Is your main concern here just wanting to have a zero-fill mode with
volatile ranges? Or do you really want to squeeze this in to the madvise
call interface?

thanks
-john


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

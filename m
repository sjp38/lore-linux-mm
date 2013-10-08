Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 030436B0037
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 20:07:36 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so7809701pdj.35
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 17:07:36 -0700 (PDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so7925960pab.25
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 17:07:33 -0700 (PDT)
Message-ID: <52534CC1.1090009@linaro.org>
Date: Mon, 07 Oct 2013 17:07:29 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 05/14] vrange: Add new vrange(2) system call
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org> <1380761503-14509-6-git-send-email-john.stultz@linaro.org> <52533C12.9090007@zytor.com> <5253404D.2030503@linaro.org> <20131008000357.GC25780@bbox>
In-Reply-To: <20131008000357.GC25780@bbox>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 10/07/2013 05:03 PM, Minchan Kim wrote:
> Hello, John and Peter
>
> On Mon, Oct 07, 2013 at 04:14:21PM -0700, John Stultz wrote:
>> On 10/07/2013 03:56 PM, H. Peter Anvin wrote:
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
> As well, we might need addtional argument VRANGE_FULL/VRANGE_PARTIAL
> for vrange system call. I discussed it long time ago but omitted it
> for early easy review phase. It is requested by Mozilla fork and of course
> I think it makes sense to me.
>
> https://lkml.org/lkml/2013/3/22/20
>
> In short, if you mark a range with VRANGE_FULL, kernel can discard all
> of pages within the range if memory is tight while kernel can discard
> part of pages in the vrange if you mark the range with VRANGE_PARTIAL.

Yea, I'm still not particularly fond of userland being able to specify
the purging semantics, but as we discussed earlier, this can be debated
in finer detail as an extension to the merged interface. :)

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

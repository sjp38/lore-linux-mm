Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 643316B0044
	for <linux-mm@kvack.org>; Sat,  3 Nov 2012 03:58:17 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id c4so2714001eek.14
        for <linux-mm@kvack.org>; Sat, 03 Nov 2012 00:58:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <506B6CE0.1060800@linaro.org>
References: <1348888593-23047-1-git-send-email-john.stultz@linaro.org>
 <20121002173928.2062004e@notabene.brown> <506B6CE0.1060800@linaro.org>
From: Michael Kerrisk <mtk.manpages@gmail.com>
Date: Sat, 3 Nov 2012 08:57:55 +0100
Message-ID: <CAHO5Pa2XiZ5_ZJ19amzKoRi=-=g2st-VahF1XHm9ovbYyPhgdw@mail.gmail.com>
Subject: Re: [PATCH 0/3] Volatile Ranges (v7) & Lots of words
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: NeilBrown <neilb@suse.de>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Hellwig <hch@infradead.org>, Linux API <linux-api@vger.kernel.org>, Jake Edge <jake@lwn.net>, Michael Kerrisk <mtk.linux.lists@gmail.com>

[CC += linux-api, since this is an API change.]

Hi John,

A couple of other questions that occurred to me...

What are the expected/planned semantics of volatile ranges for mlocked
pages? I noticed that Minchan's patch series
(https://lwn.net/Articles/522154/) gives an error on attempt to mark
locked pages as volatile (which seems sensible). I didn't see anything
similar in your patches. Perhaps it's not easy to do because of the
non-VMA-based implementation? Something to think about.

On Wed, Oct 3, 2012 at 12:38 AM, John Stultz <john.stultz@linaro.org> wrote:
> On 10/02/2012 12:39 AM, NeilBrown wrote:
>>
>> On Fri, 28 Sep 2012 23:16:30 -0400 John Stultz <john.stultz@linaro.org>
>> wrote:
>>
>>   For example, allowing sub-page volatile region seems to be above and
>> beyond
>>   the call of duty.  You cannot mmap sub-pages, so why should they be
>> volatile?
>
> Although if someone marked a page and a half as volatile, would it be
> reasonable to throw away the second half of that second page? That seems
> unexpected to me. So we're really only marking the whole pages specified as
> volatlie,  similar to how FALLOC_FL_PUNCH_HOLE behaves.
>
> But if it happens that the adjacent range is also a partial page, we can
> coalesce them possibly into an purgable whole page. I think it makes sense,
> especially from a userland point of view and wasn't really complicated to
> add.

I must confess that I'm puzzled by this facility to lock sub-page
range ranges as well. What's the use case? What I'm thinking is: the
goal of volatile ranges is to help improve system performance by
freeing up a (sizeable) block of pages. Why then would the user care
too much about marking with sub-page granularity, or that such ranges
might be merged? After all, the system calls to do this marking are
expensive, and so for performance reasons, I suppose that a process
would like to keep those system calls to a minimum.

[...]

>>   I think discarding whole ranges at a time is very sensible, and so
>> merging
>>   adjacent ranges is best avoided.  If you require page-aligned ranges
>> this
>>   becomes trivial - is that right?
>
> True. If we avoid coalescing non-whole page ranges, keeping non-overlapping
> ranges independent is fairly easy.

Regarding coalescing of adjacent ranges. Here's one possible argument
against it (Jake Edge alerted me to this). If an application marked
adjacent ranges using separate system calls, that might be an
indication that the application intends to to have different access
patterns against the two ranges: one frequent, the other rare. In that
case, I suppose it would be better if the ranges were not merged.

Cheers,

Michael

-- 
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

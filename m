Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2F1276B009C
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 15:43:09 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id oA1Jh5Jt019789
	for <linux-mm@kvack.org>; Mon, 1 Nov 2010 12:43:05 -0700
Received: from wyf23 (wyf23.prod.google.com [10.241.226.87])
	by wpaz24.hot.corp.google.com with ESMTP id oA1Jh4AO026568
	for <linux-mm@kvack.org>; Mon, 1 Nov 2010 12:43:04 -0700
Received: by wyf23 with SMTP id 23so6037637wyf.14
        for <linux-mm@kvack.org>; Mon, 01 Nov 2010 12:43:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4CCF0BE3.2090700@redhat.com>
References: <20101028191523.GA14972@google.com>
	<20101101012322.605C.A69D9226@jp.fujitsu.com>
	<20101101182416.GB31189@google.com>
	<4CCF0BE3.2090700@redhat.com>
Date: Mon, 1 Nov 2010 12:43:03 -0700
Message-ID: <AANLkTi=src1L0gAFsogzCmejGOgg5uh=9O4Uw+ZmfBg4@mail.gmail.com>
Subject: Re: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for
 protecting the working set
From: Mandeep Singh Baines <msb@chromium.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 1, 2010 at 11:50 AM, Rik van Riel <riel@redhat.com> wrote:
> On 11/01/2010 02:24 PM, Mandeep Singh Baines wrote:
>
>> Under memory pressure, I see the active list get smaller and smaller. Its
>> getting smaller because we're scanning it faster and faster, causing more
>> and more page faults which slows forward progress resulting in the active
>> list getting smaller still. One way to approach this might to make the
>> scan rate constant and configurable. It doesn't seem right that we scan
>> memory faster and faster under low memory. For us, we'd rather OOM than
>> evict pages that are likely to be accessed again so we'd prefer to make
>> a conservative estimate as to what belongs in the working set. Other
>> folks (long computations) might want to reclaim more aggressively.
>
> Have you actually read the code?
>

I have but really just recently. I consider myself an mm newb so take any
conclusion I make with a grain of salt.

> The active file list is only ever scanned when it is larger
> than the inactive file list.
>

Yes, this prevents you from reclaiming the active list all at once. But if the
memory pressure doesn't go away, you'll start to reclaim the active list
little by little. First you'll empty the inactive list, and then
you'll start scanning
the active list and pulling pages from inactive to active. The problem is that
there is no minimum time limit to how long a page will sit in the inactive list
before it is reclaimed. Just depends on scan rate which does not depend
on time.

In my experiments, I saw the active list get smaller and smaller
over time until eventually it was only a few MB at which point the system came
grinding to a halt due to thrashing.

I played around with making the active/inactive ratio configurable. I
sent a patch out
for an inactive_file_ratio. So instead of the default 50%, you'd make the
ratio configurable.

inactive_file_ratio = (inactive * 100) / (inactive + active)

I saw less thrashing at 10% but this patch wasn't nearly as effective
as min_filelist_kbytes.
I can resend the patch if you think its interesting.

>>> Q2: In the above you used min_filelist_kbytes=50000. How do you decide
>>> such value? Do other users can calculate proper value?
>>>
>>
>> 50M was small enough that we were comfortable with keeping 50M of file
>> pages
>> in memory and large enough that it is bigger than the working set. I
>> tested
>> by loading up a bunch of popular web sites in chrome and then observing
>> what
>> happend when I ran out of memory. With 50M, I saw almost no thrashing and
>> the system stayed responsive even under low memory. but I wanted to be
>> conservative since I'm really just guessing.
>>
>> Other users could calculate their value by doing something similar.
>
> Maybe we can scale this by memory amount?
>
> Say, make sure the total amount of page cache in the system
> is at least 2* as much as the sum of all the zone->pages_high
> watermarks, and refuse to evict page cache if we have less
> than that?
>
> This may need to be tunable for a few special use cases,
> like HPC and virtual machine hosting nodes, but it may just
> do the right thing for everybody else.
>
> Another alternative could be to really slow down the
> reclaiming of page cache once we hit this level, so virt
> hosts and HPC nodes can still decrease the page cache to
> something really small ... but only if it is not being
> used.
>
> Andrew, could a hack like the above be "good enough"?
>
> Anybody - does the above hack inspire you to come up with
> an even better idea?
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

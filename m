Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B25CE6B021B
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 19:41:49 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o3FNfj8T007099
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 16:41:45 -0700
Received: from vws20 (vws20.prod.google.com [10.241.21.148])
	by kpbe17.cbf.corp.google.com with ESMTP id o3FNfi9V030816
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 16:41:44 -0700
Received: by vws20 with SMTP id 20so219636vws.23
        for <linux-mm@kvack.org>; Thu, 15 Apr 2010 16:41:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100415233339.GW2493@dastard>
References: <20100415013436.GO2493@dastard>
	 <20100415130212.D16E.A69D9226@jp.fujitsu.com>
	 <20100415131106.D174.A69D9226@jp.fujitsu.com>
	 <64BE60A8-EEF9-4AC6-AF0A-0ED3CB544726@freebsd.org>
	 <20100415093214.GV2493@dastard>
	 <85DB7083-8E78-4884-9E76-5BD803C530EF@freebsd.org>
	 <20100415233339.GW2493@dastard>
Date: Thu, 15 Apr 2010 16:41:44 -0700
Message-ID: <k2hd26f1ae01004151641l371404d9sb0fd36c5d7ff3388@mail.gmail.com>
Subject: Re: [PATCH 1/4] vmscan: delegate pageout io to flusher thread if
	current is kswapd
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 4:33 PM, Dave Chinner <david@fromorbit.com> wrote:
> On Thu, Apr 15, 2010 at 10:27:09AM -0700, Suleiman Souhlal wrote:
>>
>> On Apr 15, 2010, at 2:32 AM, Dave Chinner wrote:
>>
>> >On Thu, Apr 15, 2010 at 01:05:57AM -0700, Suleiman Souhlal wrote:
>> >>
>> >>On Apr 14, 2010, at 9:11 PM, KOSAKI Motohiro wrote:
>> >>
>> >>>Now, vmscan pageout() is one of IO throuput degression source.
>> >>>Some IO workload makes very much order-0 allocation and reclaim
>> >>>and pageout's 4K IOs are making annoying lots seeks.
>> >>>
>> >>>At least, kswapd can avoid such pageout() because kswapd don't
>> >>>need to consider OOM-Killer situation. that's no risk.
>> >>>
>> >>>Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> >>
>> >>What's your opinion on trying to cluster the writes done by pageout,
>> >>instead of not doing any paging out in kswapd?
>> >
>> >XFS already does this in ->writepage to try to minimise the impact
>> >of the way pageout issues IO. It helps, but it is still not as good
>> >as having all the writeback come from the flusher threads because
>> >it's still pretty much random IO.
>>
>> Doesn't the randomness become irrelevant if you can cluster enough
>> pages?
>
> No. If you are doing full disk seeks between random chunks, then you
> still lose a large amount of throughput. e.g. if the seek time is
> 10ms and your IO time is 10ms for each 4k page, then increasing the
> size ito 64k makes it 10ms seek and 12ms for the IO. We might increase
> throughput but we are still limited to 100 IOs per second. We've
> gone from 400kB/s to 6MB/s, but that's still an order of magnitude
> short of the 100MB/s full size IOs with little in way of seeks
> between them will acheive on the same spindle...

What I meant was that, theoretically speaking, you could increase the
maximum amount of pages that get clustered so that you could get
100MB/s, although it most likely wouldn't be a good idea with the
current patch.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

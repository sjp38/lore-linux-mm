Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 00ED16B01F1
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 22:56:35 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o3K2uTKL008494
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 04:56:31 +0200
Received: from vws1 (vws1.prod.google.com [10.241.21.129])
	by wpaz9.hot.corp.google.com with ESMTP id o3K2uRCC008973
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 19:56:28 -0700
Received: by vws1 with SMTP id 1so239381vws.32
        for <linux-mm@kvack.org>; Mon, 19 Apr 2010 19:56:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100415103053.GA5336@cmpxchg.org>
References: <64BE60A8-EEF9-4AC6-AF0A-0ED3CB544726@freebsd.org>
	 <20100415171142.D192.A69D9226@jp.fujitsu.com>
	 <20100415172215.D19B.A69D9226@jp.fujitsu.com>
	 <20100415103053.GA5336@cmpxchg.org>
Date: Mon, 19 Apr 2010 19:56:27 -0700
Message-ID: <u2i604427e01004191956zc0a40b06t6689041af6156b78@mail.gmail.com>
Subject: Re: [PATCH 1/4] vmscan: delegate pageout io to flusher thread if
	current is kswapd
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Suleiman Souhlal <ssouhlal@freebsd.org>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, suleiman@google.com
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 3:30 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Thu, Apr 15, 2010 at 05:26:27PM +0900, KOSAKI Motohiro wrote:
>> Cc to Johannes
>>
>> > >
>> > > On Apr 14, 2010, at 9:11 PM, KOSAKI Motohiro wrote:
>> > >
>> > > > Now, vmscan pageout() is one of IO throuput degression source.
>> > > > Some IO workload makes very much order-0 allocation and reclaim
>> > > > and pageout's 4K IOs are making annoying lots seeks.
>> > > >
>> > > > At least, kswapd can avoid such pageout() because kswapd don't
>> > > > need to consider OOM-Killer situation. that's no risk.
>> > > >
>> > > > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> > >
>> > > What's your opinion on trying to cluster the writes done by pageout,
>> > > instead of not doing any paging out in kswapd?
>> > > Something along these lines:
>> >
>> > Interesting.
>> > So, I'd like to review your patch carefully. can you please give me on=
e
>> > day? :)
>>
>> Hannes, if my remember is correct, you tried similar swap-cluster IO
>> long time ago. now I can't remember why we didn't merged such patch.
>> Do you remember anything?
>
> Oh, quite vividly in fact :) =A0For a lot of swap loads the LRU order
> diverged heavily from swap slot order and readaround was a waste of
> time.
>
> Of course, the patch looked good, too, but it did not match reality
> that well.
>
> I guess 'how about this patch?' won't get us as far as 'how about
> those numbers/graphs of several real-life workloads? =A0oh and here
> is the patch...'.

Hannes,

We recently ran into this problem while running some experiments on
ext4 filesystem. We experienced the scenario where we are writing a
large file or just opening a large file with limited memory allocation
(using containers), and the process got OOMed. The memory assigned to
the container is reasonably large, and the OOM can not be reproduced
on ext2 with the same configurations.

Later we figured this might be due to the delayed block allocation
from ext4. Vmscan sends a single page to ext4->writepage(), then ext4
punts if the block is DA'ed and re-dirties the page. On the other
hand, the flusher thread use ext4->writepages() which does include the
block allocation.

We looked at the OOM log under ext4, all pages within the container
were in inactive list and either Dirty or WriteBack. Also, the zones
are all marked as "all_unreclaimable" which indicates the reclaim path
has scanned the LRU quite lot times without making progress. If the
delayed block allocation is the cause for pageout() not being able to
flush dirty pages and then triggers OOMs, should we signal the fs to
force write out dirty pages under memory pressure?

--Ying

>
>> > > =A0 =A0 =A0Cluster writes to disk due to memory pressure.
>> > >
>> > > =A0 =A0 =A0Write out logically adjacent pages to the one we're pagin=
g out
>> > > =A0 =A0 =A0so that we may get better IOs in these situations:
>> > > =A0 =A0 =A0These pages are likely to be contiguous on disk to the on=
e we're
>> > > =A0 =A0 =A0writing out, so they should get merged into a single disk=
 IO.
>> > >
>> > > =A0 =A0 =A0Signed-off-by: Suleiman Souhlal <suleiman@google.com>
>
> For random IO, LRU order will have nothing to do with mapping/disk order.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

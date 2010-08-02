Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C5658600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 19:33:38 -0400 (EDT)
Received: by iwn2 with SMTP id 2so5219783iwn.14
        for <linux-mm@kvack.org>; Mon, 02 Aug 2010 16:36:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100802115748.GA5308@localhost>
References: <20100802003616.5b31ed8b@digital-domain.net>
	<20100802081253.GA27492@localhost>
	<20100802171954.4F95.A69D9226@jp.fujitsu.com>
	<20100802115748.GA5308@localhost>
Date: Tue, 3 Aug 2010 08:36:29 +0900
Message-ID: <AANLkTimPicvVXnfc1qkuWekzmEz18E=t50yhzaxpToae@mail.gmail.com>
Subject: Re: Bug 12309 - Large I/O operations result in poor interactive
	performance and high iowait times
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Clayton <andrew@digital-domain.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, "pvz@pvz.pp.se" <pvz@pvz.pp.se>, "bgamari@gmail.com" <bgamari@gmail.com>, "larppaxyz@gmail.com" <larppaxyz@gmail.com>, "seanj@xyke.com" <seanj@xyke.com>, "kernel-bugs.dev1world@spamgourmet.com" <kernel-bugs.dev1world@spamgourmet.com>, "akatopaz@gmail.com" <akatopaz@gmail.com>, "frankrq2009@gmx.com" <frankrq2009@gmx.com>, "thomas.pi@arcor.de" <thomas.pi@arcor.de>, "spawels13@gmail.com" <spawels13@gmail.com>, "vshader@gmail.com" <vshader@gmail.com>, "rockorequin@hotmail.com" <rockorequin@hotmail.com>, "ylalym@gmail.com" <ylalym@gmail.com>, "theholyettlz@googlemail.com" <theholyettlz@googlemail.com>, "hassium@yandex.ru" <hassium@yandex.ru>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 2, 2010 at 8:57 PM, Wu Fengguang <fengguang.wu@intel.com> wrote=
:
>> > So swapping is another major cause of responsiveness lags.
>> >
>> > I just tested the heavy swapping case with the patches to remove
>> > the congestion_wait() and wait_on_page_writeback() stalls on high
>> > order allocations. The patches work as expected. No single stall shows
>> > up with the debug patch posted in http://lkml.org/lkml/2010/8/1/10.
>> >
>> > However there are still stalls on get_request_wait():
>> > - kswapd trying to pageout anonymous pages
>> > - _any_ process in direct reclaim doing pageout()
>>
>> Well, not any.
>>
>> current check is following.
>>
>> -----------------------------------------------------------
>> static int may_write_to_queue(struct backing_dev_info *bdi)
>> {
>> =A0 =A0 =A0 =A0 if (current->flags & PF_SWAPWRITE)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> =A0 =A0 =A0 =A0 if (!bdi_write_congested(bdi))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> =A0 =A0 =A0 =A0 if (bdi =3D=3D current->backing_dev_info)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> =A0 =A0 =A0 =A0 return 0;
>> }
>> -----------------------------------------------------------
>>
>> It mean congestion ignorerance is happend when followings
>> =A0 (1) the task is kswapd
>> =A0 (2) the task is flusher thread
>> =A0 (3) this reclaim is called from zone reclaim (note: I'm thinking thi=
s is bug)
>> =A0 (4) this reclaim is called from __generic_file_aio_write()
>>
>> (4) is root cause of this latency issue. this behavior was introduced
>> by following.
>
> Yes and no.
>
> (1)-(4) are good summaries for regular files. However !bdi_write_congeste=
d(bdi)
> is now unconditionally true for the swapper_space, which means any proces=
s can
> do swap out to a congested queue and block there.
>
> pageout() has the following comment for the cases:
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * If the page is dirty, only perform writeback if that wr=
ite
> =A0 =A0 =A0 =A0 * will be non-blocking. =A0To prevent this allocation fro=
m being
> =A0 =A0 =A0 =A0 * stalled by pagecache activity. =A0But note that there m=
ay be
> =A0 =A0 =A0 =A0 * stalls if we need to run get_block(). =A0We could test
> =A0 =A0 =A0 =A0 * PagePrivate for that.
> =A0 =A0 =A0 =A0 *
> =A0 =A0 =A0 =A0 * If this process is currently in __generic_file_aio_writ=
e() against
> =A0 =A0 =A0 =A0 * this page's queue, we can perform writeback even if tha=
t
> =A0 =A0 =A0 =A0 * will block.
> =A0 =A0 =A0 =A0 *
> =A0 =A0 =A0 =A0 * If the page is swapcache, write it back even if that wo=
uld
> =A0 =A0 =A0 =A0 * block, for some throttling. This happens by accident, b=
ecause
> =A0 =A0 =A0 =A0 * swap_backing_dev_info is bust: it doesn't reflect the
> =A0 =A0 =A0 =A0 * congestion state of the swapdevs. =A0Easy to fix, if ne=
eded.
> =A0 =A0 =A0 =A0 */
>
>>
>> -------------------------------------------------------------------
>> commit 94bc3c9279ae182ca996d89dc9a56b66b06d5d8f
>> Author: akpm <akpm>
>> Date: =A0 Mon Sep 23 05:17:02 2002 +0000
>>
>> =A0 =A0 [PATCH] low-latency page reclaim
>>
>> =A0 =A0 Convert the VM to not wait on other people's dirty data.
>>
>> =A0 =A0 =A0- If we find a dirty page and its queue is not congested, do =
some writeback.
>>
>> =A0 =A0 =A0- If we find a dirty page and its queue _is_ congested then j=
ust
>> =A0 =A0 =A0 =A0refile the page.
>>
>> =A0 =A0 =A0- If we find a PageWriteback page then just refile the page.
>>
>> =A0 =A0 =A0- There is additional throttling for write(2) callers. =A0Wit=
hin
>> =A0 =A0 =A0 =A0generic_file_write(), record their backing queue in ->cur=
rent.
>> =A0 =A0 =A0 =A0Within page reclaim, if this tasks encounters a page whic=
h is dirty
>> =A0 =A0 =A0 =A0or under writeback onthis queue, block on it. =A0This giv=
es some more
>> =A0 =A0 =A0 =A0writer throttling and reduces the page refiling frequency=
.
>>
>> =A0 =A0 It's somewhat CPU expensive - under really heavy load we only ge=
t a 50%
>> =A0 =A0 reclaim rate in pages coming off the tail of the LRU. =A0This ca=
n be
>> =A0 =A0 fixed by splitting the inactive list into reclaimable and
>> =A0 =A0 non-reclaimable lists. =A0But the CPU load isn't too bad, and la=
tency is
>> =A0 =A0 much, much more important in these situations.
>>
>> =A0 =A0 Example: with `mem=3D512m', running 4 instances of `dbench 100',=
 2.5.34
>> =A0 =A0 took 35 minutes to compile a kernel. =A0With this patch, it took=
 three
>> =A0 =A0 minutes, 45 seconds.
>>
>> =A0 =A0 I haven't done swapcache or MAP_SHARED pages yet. =A0If there's =
tons of
>> =A0 =A0 dirty swapcache or mmap data around we still stall heavily in pa=
ge
>> =A0 =A0 reclaim. =A0That's less important.
>>
>> =A0 =A0 This patch also has a tweak for swapless machines: don't even bo=
ther
>> =A0 =A0 bringing anon pages onto the inactive list if there is no swap o=
nline.
>>
>> =A0 =A0 BKrev: 3d8ea3cekcPCHjOJ65jQtjjrJMyYeA
>>
>> diff --git a/mm/filemap.c b/mm/filemap.c
>> index a27d273..9118a57 100644
>> --- a/mm/filemap.c
>> +++ b/mm/filemap.c
>> @@ -1755,6 +1755,9 @@ generic_file_write_nolock(struct file *file, const=
 struct iovec *iov,
>> =A0 =A0 =A0 =A0 if (unlikely(pos < 0))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>>
>> + =A0 =A0 =A0 /* We can write back this queue in page reclaim */
>> + =A0 =A0 =A0 current->backing_dev_info =3D mapping->backing_dev_info;
>> +
>> =A0 =A0 =A0 =A0 pagevec_init(&lru_pvec);
>>
>> =A0 =A0 =A0 =A0 if (unlikely(file->f_error)) {
>> -------------------------------------------------------------------
>>
>> But is this still necessary? now we have per-hask dirty accounting, the
>> write hog tasks have already got some waiting penalty.
>>
>> As I said, per-task dirty accounting only makes a penalty to lots writin=
g
>> tasks. but the above makes a penalty to all of write(2) user.
>
> Right. We will be transferring file writeback to the flusher threads,
> the whole may_write_to_queue() test can be removed at that time.
> For one thing, conditional page out is disregarding the LRU age.
>
>> >
>> > Since 90% pages are dirty anonymous pages, the chances to stall is hig=
h.
>> > kswapd can hardly make smooth progress. The applications end up doing
>> > direct reclaim by themselves, which also ends up stuck in pageout().
>> > They are not explicitly stalled in vmscan code, but implicitly in
>> > get_request_wait() when trying to swapping out the dirty pages.
>> >
>> > It sure hurts responsiveness with so many applications stalled on
>> > get_request_wait(). But question is, what can we do otherwise? The
>> > system is running short of memory and cannot keep up freeing enough
>> > memory anyway. So page allocations have to be throttled somewhere..
>> >
>> > But wait.. What if there are only 50% anonymous pages? In this case
>> > applications don't necessarily need to sleep in get_request_wait().
>> > The memory pressure is not really high. The poor man's solution is to
>> > disable swapping totally, as the bug reporters find to be helpful..
>> >
>> > One easy fix is to skip swap-out when bdi is congested and priority is
>> > close to DEF_PRIORITY. However it would be unfair to selectively
>> > (largely in random) keep some pages and reclaim the others that
>> > actually have the same age.
>> >
>> > A more complete fix may be to introduce some swap_out LRU list(s).
>> > Pages in it will be swap out as fast as possible by a dedicated
>> > kernel thread. And pageout() can freely add pages to it until it
>> > grows larger than some threshold, eg. 30% reclaimable memory, at which
>> > point pageout() will stall on the list. The basic idea is to switch
>> > the random get_request_wait() stalls to some more global wise stalls.
>>
>> Yup, I'd prefer this idea. but probably it should retrieve writeback gen=
eral,
>> not only swapout.
>
> What in my mind is (without any throttling)
>
> =A0 =A0 =A0 =A0if (PageSwapcache(page)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (bdi_write_congested(bdi))

You mentioned following as.

"However !bdi_write_congested(bdi) is now unconditionally true for the
swapper_space, which means any process can do swap out to a congested
queue and block there."

But you used bdi_write_congested in here.
Which is right?

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

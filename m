Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 019AF6B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 00:23:41 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id d13so263474552oib.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 21:23:40 -0800 (PST)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id b185si194983oif.244.2017.01.25.21.23.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 21:23:39 -0800 (PST)
Received: by mail-oi0-x244.google.com with SMTP id u143so17217444oif.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 21:23:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170125232713.GB20811@bbox>
References: <1485344318-6418-1-git-send-email-vinmenon@codeaurora.org> <20170125232713.GB20811@bbox>
From: vinayak menon <vinayakm.list@gmail.com>
Date: Thu, 26 Jan 2017 10:53:38 +0530
Message-ID: <CAOaiJ-mk=SmNR4oK+udhJNxHzmobf28wSu+nf449c=1cHMBDAg@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: do not pass reclaimed slab to vmpressure
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, shiraz.hashim@gmail.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

Hi Minchan

On Thu, Jan 26, 2017 at 4:57 AM, Minchan Kim <minchan@kernel.org> wrote:
> Hello Vinayak,
>
> On Wed, Jan 25, 2017 at 05:08:38PM +0530, Vinayak Menon wrote:
>> It is noticed that during a global reclaim the memory
>> reclaimed via shrinking the slabs can sometimes result
>> in reclaimed pages being greater than the scanned pages
>> in shrink_node. When this is passed to vmpressure, the
>
> I don't know you are saying zsmalloc. Anyway, it's one of those which
> free larger pages than requested. I should fix that but was not sent
> yet, unfortunately.

As I understand, the problem is not related to a particular shrinker.
In shrink_node, when subtree's reclaim efficiency is passed to vmpressure,
the 4th parameter (sc->nr_scanned - nr_scanned) includes only the LRU
scanned pages, but the 5th parameter (sc->nr_reclaimed - nr_reclaimed) includes
the reclaimed slab pages also since in the previous step
"reclaimed_slab" is added
to it. i.e the slabs scanned are not included in scanned passed to vmpressure.
This results in reclaimed going higher than scanned in vmpressure resulting in
false events.

>
>> unsigned arithmetic results in the pressure value to be
>> huge, thus resulting in a critical event being sent to
>> root cgroup. Fix this by not passing the reclaimed slab
>> count to vmpressure, with the assumption that vmpressure
>> should show the actual pressure on LRU which is now
>> diluted by adding reclaimed slab without a corresponding
>> scanned value.
>
> I can't guess justfication of your assumption from the description.
> Why do we consider only LRU pages for vmpressure? Could you elaborate
> a bit?
>
When we encountered the false events from vmpressure, thought the problem
could be that slab scanned is not included in sc->nr_scanned, like it is done
for reclaimed. But later thought vmpressure works only on the scanned and
reclaimed from LRU. I can explain what I understand, let me know if this is
incorrect.
vmpressure is an index which tells the pressure on LRU, and thus an
indicator of thrashing. In shrink_node when we come out of the inner do-while
loop after shrinking the lruvec, the scanned and reclaimed corresponds to the
pressure felt on the LRUs which in turn indicates the pressure on VM. The
moment we add the slab reclaimed pages to the reclaimed, we dilute the
actual pressure felt on LRUs. When slab scanned/reclaimed is not included
in the vmpressure, the values will indicate the actual pressure and if there
were a lot of slab reclaimed pages it will result in lesser pressure
on LRUs in the next run which will again be indicated by vmpressure. i.e. the
pressure on LRUs indicate actual pressure on VM even if slab reclaimed is
not included. Moreover, what I understand from code is, the reclaimed_slab
includes only the inodesteals and the pages freed by slab allocator, and does
not include the pages reclaimed by other shrinkers like
lowmemorykiller, zsmalloc
etc. That means even now we are including only a subset of reclaimed pages
to vmpressure. Also, considering the case of a userspace lowmemorykiller
which works on vmpressure on root cgroup, if the slab reclaimed in included in
vmpressure, the lowmemorykiller will wait till most of the slab is
shrinked before
kicking in to kill a task. No ?

Thanks,
Vinayak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

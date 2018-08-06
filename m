Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D9846B0005
	for <linux-mm@kvack.org>; Sun,  5 Aug 2018 23:25:34 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id q2-v6so5446707plh.12
        for <linux-mm@kvack.org>; Sun, 05 Aug 2018 20:25:34 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id i186-v6si13240734pfb.362.2018.08.05.20.25.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Aug 2018 20:25:33 -0700 (PDT)
Message-ID: <5B67C0B2.3040407@intel.com>
Date: Mon, 06 Aug 2018 11:29:54 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/2] virtio_balloon: replace oom notifier with shrinker
References: <1533285146-25212-1-git-send-email-wei.w.wang@intel.com> <1533285146-25212-3-git-send-email-wei.w.wang@intel.com> <20180803221423-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180803221423-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, penguin-kernel@i-love.sakura.ne.jp

On 08/04/2018 03:15 AM, Michael S. Tsirkin wrote:
> On Fri, Aug 03, 2018 at 04:32:26PM +0800, Wei Wang wrote:
>> The OOM notifier is getting deprecated to use for the reasons:
>> - As a callout from the oom context, it is too subtle and easy to
>>    generate bugs and corner cases which are hard to track;
>> - It is called too late (after the reclaiming has been performed).
>>    Drivers with large amuont of reclaimable memory is expected to
>>    release them at an early stage of memory pressure;
>> - The notifier callback isn't aware of oom contrains;
>> Link: https://lkml.org/lkml/2018/7/12/314
>>
>> This patch replaces the virtio-balloon oom notifier with a shrinker
>> to release balloon pages on memory pressure. The balloon pages are
>> given back to mm adaptively by returning the number of pages that the
>> reclaimer is asking for (i.e. sc->nr_to_scan).
>>
>> Currently the max possible value of sc->nr_to_scan passed to the balloon
>> shrinker is SHRINK_BATCH, which is 128. This is smaller than the
>> limitation that only VIRTIO_BALLOON_ARRAY_PFNS_MAX (256) pages can be
>> returned via one invocation of leak_balloon. But this patch still
>> considers the case that SHRINK_BATCH or shrinker->batch could be changed
>> to a value larger than VIRTIO_BALLOON_ARRAY_PFNS_MAX, which will need to
>> do multiple invocations of leak_balloon.
>>
>> Historically, the feature VIRTIO_BALLOON_F_DEFLATE_ON_OOM has been used
>> to release balloon pages on OOM. We continue to use this feature bit for
>> the shrinker, so the shrinker is only registered when this feature bit
>> has been negotiated with host.
>>
>> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
>> Cc: Michael S. Tsirkin <mst@redhat.com>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>
> Could you add data at how was this tested and how did guest
> behaviour change. Which configurations see an improvement?
>

Yes. Please see the differences from the "*1" and "*2" cases below.

Taking this chance, I use "*2" and "*3" to show Michal etc the 
differences of applying and not applying the shrinker fix patch here: 
https://lkml.org/lkml/2018/8/3/384


*1. V3 patches
1)After inflating some amount of memory, actual=1000001536 Bytes
free -m
               total        used        free      shared buff/cache   
available
Mem:           7975        7289         514          10 171         447
Swap:         10236           0       10236

2) dd if=478MB_file of=/dev/null, actual=1058721792 Bytes
free -m
               total        used        free      shared buff/cache   
available
Mem:           7975        7233         102          10 639         475
Swap:         10236           0       10236

The advantage is that the inflated pages are given back to mm based on 
the number, i.e. ~56MB(diff "actual" above) of the reclaimer is asking 
for. This is more adaptive.



*2. V2 paches, balloon_pages_to_shrink=1000000 pages (around 4GB), with 
the shrinker fix patches applied.
1)After inflating some amount of memory, actual=1000001536 Bytes
free -m
               total        used        free      shared buff/cache   
available
Mem:           7975        7288         530          10 157         455
Swap:         10236           0       10236

2)dd if=478MB_file of=/dev/null, actual=5096001536 Bytes
free -m
               total        used        free      shared buff/cache   
available
Mem:           7975        3381        3953          10 640        4327
Swap:         10236           0       10236

In the above example, we set 4GB to shrink to make the difference 
obvious. Though the claimer only needs to reclaim ~56MB memory, 4GB 
inflated pages are given back to mm, which is unnecessary. From the 
user's perspective, it has no idea of how many pages to given back at 
the time of setting the module parameter (balloon_pages_to_shrink). So I 
think the above "*1" is better.



*3.  V2 paches, balloon_pages_to_shrink=1000000 pages (around 4GB), 
without the shrinker fix patches applied.
1) After inflating some amount of memory, actual=1000001536 Bytes
free -m
                total        used        free      shared buff/cache   
available
Mem:           7975        7292         524          10 158         450
Swap:         10236           0       10236

2) dd if=478MB_file of=/dev/null, actual=8589934592 Bytes
free -m
              total        used        free      shared  buff/cache 
available
Mem:           7975          53        7281          10 640        7656
Swap:         10236           0       10236

Compared to *2, all the balloon pages are shrunk, but users expect 4GB 
to shrink. The reason is that do_slab_shrink has a mistake in 
calculating schrinkctl->nr_scanned, which should be the actual number of 
pages that the shrinker has freed, but do slab_shrink still treat that 
value as 128 (but 4GB has actually been freed).


Best,
Wei

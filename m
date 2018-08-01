Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D8D6E6B0007
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 07:08:11 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f13-v6so10866767pgs.15
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 04:08:11 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id f23-v6si16799439plj.494.2018.08.01.04.08.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 04:08:10 -0700 (PDT)
Message-ID: <5B619599.1000307@intel.com>
Date: Wed, 01 Aug 2018 19:12:25 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/2] virtio_balloon: replace oom notifier with shrinker
References: <1532683495-31974-1-git-send-email-wei.w.wang@intel.com> <1532683495-31974-3-git-send-email-wei.w.wang@intel.com> <20180730090041.GC24267@dhcp22.suse.cz>
In-Reply-To: <20180730090041.GC24267@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mst@redhat.com, akpm@linux-foundation.org

On 07/30/2018 05:00 PM, Michal Hocko wrote:
> On Fri 27-07-18 17:24:55, Wei Wang wrote:
>> The OOM notifier is getting deprecated to use for the reasons mentioned
>> here by Michal Hocko: https://lkml.org/lkml/2018/7/12/314
>>
>> This patch replaces the virtio-balloon oom notifier with a shrinker
>> to release balloon pages on memory pressure.
> It would be great to document the replacement. This is not a small
> change...

OK. I plan to document the following to the commit log:

   The OOM notifier is getting deprecated to use for the reasons:
     - As a callout from the oom context, it is too subtle and easy to
       generate bugs and corner cases which are hard to track;
     - It is called too late (after the reclaiming has been performed).
       Drivers with large amuont of reclaimable memory is expected to be
       released them at an early age of memory pressure;
     - The notifier callback isn't aware of the oom contrains;
     Link: https://lkml.org/lkml/2018/7/12/314

     This patch replaces the virtio-balloon oom notifier with a shrinker
     to release balloon pages on memory pressure. Users can set the 
amount of
     memory pages to release each time a shrinker_scan is called via the
     module parameter balloon_pages_to_shrink, and the default amount is 256
     pages. Historically, the feature VIRTIO_BALLOON_F_DEFLATE_ON_OOM has
     been used to release balloon pages on OOM. We continue to use this
     feature bit for the shrinker, so the shrinker is only registered when
     this feature bit has been negotiated with host.

     In addition, the bug in the replaced virtballoon_oom_notify that only
     VIRTIO_BALLOON_ARRAY_PFNS_MAX (i.e 256) balloon pages can be freed
     though the user has specified more than that number is fixed in the
     shrinker_scan function.


Best,
Wei

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7776B0253
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 21:38:39 -0400 (EDT)
Received: by pawu10 with SMTP id u10so75802323paw.1
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 18:38:38 -0700 (PDT)
Received: from mgwym04.jp.fujitsu.com (mgwym04.jp.fujitsu.com. [211.128.242.43])
        by mx.google.com with ESMTPS id wi5si14608909pbc.159.2015.08.06.18.38.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 18:38:38 -0700 (PDT)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by yt-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 067EDAC0385
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 10:38:34 +0900 (JST)
Subject: Re: [PATCH 0/3] Make workingset detection logic memcg aware
References: <cover.1438599199.git.vdavydov@parallels.com>
 <55C16842.9040505@jp.fujitsu.com> <20150806085911.GL11971@esperanza>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <55C40C08.8010706@jp.fujitsu.com>
Date: Fri, 7 Aug 2015 10:38:16 +0900
MIME-Version: 1.0
In-Reply-To: <20150806085911.GL11971@esperanza>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2015/08/06 17:59, Vladimir Davydov wrote:
> On Wed, Aug 05, 2015 at 10:34:58AM +0900, Kamezawa Hiroyuki wrote:
>
>> Reading discussion, I feel storing more data is difficult, too.
>
> Yep, even with the current 16-bit memcg id. Things would get even worse
> if we wanted to extend it one day (will we?)
>
>>
>> I wonder, rather than collecting more data, rough calculation can help the situation.
>> for example,
>>
>>     (refault_disatance calculated in zone) * memcg_reclaim_ratio < memcg's active list
>>
>> If one of per-zone calc or per-memcg calc returns true, refault should be true.
>>
>> memcg_reclaim_ratio is the percentage of scan in a memcg against in a zone.
>
> This particular formula wouldn't work I'm afraid. If there are two
> isolated cgroups issuing local reclaim on the same zone, the refault
> distance needed for activation would be reduced by half for no apparent
> reason.

Hmm, you mean activation in memcg means activation in global LRU, and it's not a
valid reason. Current implementation does have the same issue, right ?

i.e. when a container has been hitting its limit for a while, and then, a file cache is
pushed out but came back soon, it can be easily activated.

I'd like to confirm what you want to do.

  1) avoid activating a file cache when it was kicked out because of memcg's local limit.
  2) maintain acitve/inactive ratio in memcg properly as global LRU does.
  3) reclaim shadow entry at proper timing.

All ? hmm. It seems that mixture of record of global memory pressure and of local memory
pressure is just wrong.

Now, the record is
a??a??a??a??
a??a??a??a??eviction | node | zone | 2bit.

How about changing this as

         0 |eviction | node | zone | 2bit
         1 |eviction |  memcgid    | 2bit

Assume each memcg has an eviction counter, which ignoring node/zone.
i.e. memcg local reclaim happens against memcg not against zone.

At page-in,
         if (the 1st bit is 0)
                 compare eviction counter with zone's counter and activate the page if needed.
         else if (the 1st bit is 1)
                 compare eviction counter with the memcg (if exists)
                 if (current memcg == recorded memcg && eviction distance is okay)
                      activate page.
                 else
                      inactivate
       
At page-out
         if (global memory pressure)
                 record eviction id with using zone's counter.
         else if (memcg local memory pressure)
                 record eviction id with memcg's counter.

By this,
    1) locally reclaimed pages cannot be activated unless it's refaulted in the same memcg.
       In this case, activating in the memcg has some meaning.

    2) At global memory pressure, distance is properly calculated based on global system status.
       global memory pressure can ignore memcg's behavior.

about shadow entries, kmemcg should take care of it....


Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id B475E6B0032
	for <linux-mm@kvack.org>; Sat, 20 Dec 2014 04:25:20 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id p10so2732036pdj.13
        for <linux-mm@kvack.org>; Sat, 20 Dec 2014 01:25:20 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id m2si17255367pdr.187.2014.12.20.01.25.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Dec 2014 01:25:19 -0800 (PST)
Date: Sat, 20 Dec 2014 12:24:54 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 1/2] mm, vmscan: prevent kswapd livelock due to
 pfmemalloc-throttled process being killed
Message-ID: <20141220092454.GL18274@esperanza>
References: <1418994116-23665-1-git-send-email-vbabka@suse.cz>
 <20141219155747.GA31756@dhcp22.suse.cz>
 <20141219182815.GK18274@esperanza>
 <5494AF56.9070001@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <5494AF56.9070001@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, stable@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Sat, Dec 20, 2014 at 12:05:58AM +0100, Vlastimil Babka wrote:
> On 19.12.2014 19:28, Vladimir Davydov wrote:
> >So AFAIU the problem does exist. However, I think it could be fixed by
> >simply waking up all processes waiting on pfmemalloc_wait before putting
> >kswapd to sleep:
> 
> Hm I don't see how it helps? If any of the waiting processes were killed
> and wants to run on kswapd's CPU to remove itself from the waitqueue,
> it will still remain on the waitqueue, no?

Yes, but do we really want all waiting processes to be removed from the
wait queue? AFAIU we just want them to be awake before putting kswapd to
sleep. If there's a process killed (and therefore woken) by the OOM
killer left on the wait queue after we called wake_up_all, it will see
pgdat_balanced=true as soon as it gets scheduled and pass away quickly.
All we have to do is drop the waitqueue_active check from kswapd.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

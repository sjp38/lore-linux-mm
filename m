Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6C4CF6B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 06:43:20 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r136so11499722wmf.4
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 03:43:20 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id g7si3674459edj.126.2017.09.26.03.43.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 03:43:19 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 25BFA1C2771
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 11:43:17 +0100 (IST)
Date: Tue, 26 Sep 2017 11:43:16 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC 0/2] Use HighAtomic against long-term fragmentation
Message-ID: <20170926104316.r2mjcrakykqfehga@techsingularity.net>
References: <1506415604-4310-1-git-send-email-zhuhui@xiaomi.com>
 <20170926095127.p5ocg44et2g62gku@techsingularity.net>
 <CANFwon3Mf3AUfUPtSAUQus0yohMzKEirDcNqfnwPDwFWD04z-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CANFwon3Mf3AUfUPtSAUQus0yohMzKEirDcNqfnwPDwFWD04z-w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <teawater@gmail.com>
Cc: Hui Zhu <zhuhui@xiaomi.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, hillf.zj@alibaba-inc.com, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Sep 26, 2017 at 06:04:04PM +0800, Hui Zhu wrote:
> 2017-09-26 17:51 GMT+08:00 Mel Gorman <mgorman@techsingularity.net>:
> > On Tue, Sep 26, 2017 at 04:46:42PM +0800, Hui Zhu wrote:
> >> Current HighAtomic just to handle the high atomic page alloc.
> >> But I found that use it handle the normal unmovable continuous page
> >> alloc will help to against long-term fragmentation.
> >>
> >
> > This is not wise. High-order atomic allocations do not always have a
> > smooth recovery path such as network drivers with large MTUs that have no
> > choice but to drop the traffic and hope for a retransmit. That's why they
> > have the highatomic reserve. If the reserve is used for normal unmovable
> > allocations then allocation requests that could have waited for reclaim
> > may cause high-order atomic allocations to fail. Changing it may allow
> > improve latencies in some limited cases while causing functional failures
> > in others.  If there is a special case where there are a large number of
> > other high-order allocations then I would suggest increasing min_free_kbytes
> > instead as a workaround.
> 
> I think let 0 order unmovable page alloc and other order unmovable pages
> alloc use different migrate types will help against long-term
> fragmentation.
> 

That can already happen through the migratetype fallback lists.

> Do you think kernel can add a special migrate type for big than 0 order
> unmovable pages alloc?
> 

Technically, yes but the barrier to entry will be high as you'll have to
explain carefully why it is necessary including information on why order-0
pages cannot be used, back it up with data showing what is improved as a
result and justify why potentially forcing normal workloads to reclaim due
to being unable to use the high-order reserve is ok. If it's a limitation
of a specific driver then it'll be asked why that driver does not have a
dedicated pool (which is functionally similar to having a dedicated reserve).

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

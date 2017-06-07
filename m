Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E36E66B0311
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 23:01:08 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s12so389329pgc.2
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 20:01:08 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 1si401748plz.248.2017.06.06.20.01.07
        for <linux-mm@kvack.org>;
        Tue, 06 Jun 2017 20:01:07 -0700 (PDT)
Date: Wed, 7 Jun 2017 11:53:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: vmscan: do not pass reclaimed slab to vmpressure
Message-ID: <20170607025324.GB18007@bbox>
References: <1485344318-6418-1-git-send-email-vinmenon@codeaurora.org>
 <20170125232713.GB20811@bbox>
 <CAOaiJ-mk=SmNR4oK+udhJNxHzmobf28wSu+nf449c=1cHMBDAg@mail.gmail.com>
 <20170126141836.GA3584@bbox>
 <CAOaiJ-m=X=8GpLCW-7wVkBmT=Gq9V9ocXtcXbmNNALffLepWeg@mail.gmail.com>
 <20170130234028.GA7942@bbox>
 <5936A787.4050002@huawei.com>
MIME-Version: 1.0
In-Reply-To: <5936A787.4050002@huawei.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: vinayak menon <vinayakm.list@gmail.com>, Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, Shiraz Hashim <shiraz.hashim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

Hi,

On Tue, Jun 06, 2017 at 09:00:55PM +0800, zhong jiang wrote:
> On 2017/1/31 7:40, Minchan Kim wrote:
> > Hi Vinayak,
> > Sorry for late response. It was Lunar New Year holidays.
> >
> > On Fri, Jan 27, 2017 at 01:43:23PM +0530, vinayak menon wrote:
> >>> Thanks for the explain. However, such case can happen with THP page
> >>> as well as slab. In case of THP page, nr_scanned is 1 but nr_reclaimed
> >>> could be 512 so I think vmpressure should have a logic to prevent undeflow
> >>> regardless of slab shrinking.
> >>>
> >> I see. Going to send a vmpressure fix. But, wouldn't the THP case
> >> result in incorrect
> >> vmpressure reporting even if we fix the vmpressure underflow problem ?
> > If a THP page is reclaimed, it reports lower pressure due to bigger
> > reclaim ratio(ie, reclaimed/scanned) compared to normal pages but
> > it's not a problem, is it? Because VM reclaimed more memory than
> > expected so memory pressure isn't severe now.
>   Hi, Minchan
> 
>   THP lru page is reclaimed, reclaim ratio bigger make sense. but I read the code, I found
>   THP is split to normal pages and loop again.  reclaimed pages should not be bigger
>    than nr_scan.  because of each loop will increase nr_scan counter.
>  
>    It is likely  I miss something.  you can point out the point please.

You are absolutely right.

I got confused by nr_scanned from isolate_lru_pages and sc->nr_scanned
from shrink_page_list.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

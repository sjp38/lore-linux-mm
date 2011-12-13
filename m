Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 0B6B76B0268
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 09:40:34 -0500 (EST)
Message-ID: <4EE763D0.9060003@tao.ma>
Date: Tue, 13 Dec 2011 22:40:16 +0800
From: Tao Ma <tm@tao.ma>
MIME-Version: 1.0
Subject: Re: [PATCH V2] vmscan/trace: Add 'active' and 'file' info to trace_mm_vmscan_lru_isolate.
References: <1323614784-2924-1-git-send-email-tm@tao.ma> <CAEwNFnCXJuH53ks=qPdHkm_hrcm+Nsh7f5APQx6BgQEQBKC_yQ@mail.gmail.com> <20111212112738.GA3277@csn.ul.ie>
In-Reply-To: <20111212112738.GA3277@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

Hi Mel,
On 12/12/2011 07:27 PM, Mel Gorman wrote:
> On Mon, Dec 12, 2011 at 09:59:20AM +0900, Minchan Kim wrote:
>>> <SNIP>
>>> @@ -1237,7 +1237,7 @@ static unsigned long isolate_pages_global(unsigned long nr,
>>>        if (file)
>>>                lru += LRU_FILE;
>>>        return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanned, order,
>>> -                                                               mode, file);
>>> +                                                       mode, active, file);
>>
>> I guess you want to count exact scanning number of which lru list.
>> But It's impossible now since we do lumpy reclaim so that trace's
>> result is mixed by active/inactive list scanning.
>> And I don't like adding new argument for just trace although it's trivial.
>>
> 
> FWIW, lumpy reclaim is why the trace point does not report the active
> or file information. Seeing active==1 does not imply that only active
> pages were isolated and mode is already there as Minchan points out.
OK, thanks for the info.
> 
> Similarly, seeing file==1 does not imply that only file-backed
> pages were isolated. Any processing script that depends on just this
> information would be misleading.  If more information on how much
> each LRU was scanned is required, the mm_vmscan_lru_shrink_inactive
> tracepoint already reports the number of pages scanned, reclaimed
> and whether the pages isolated were anon, file or both so ordinarily
> I would suggest using just that.
So how can I tell the isolation list status when we do shrink_active_list?
> 
> That said, I see that trace_shrink_flags() is currently misleading as
> it should be used sc->order instead of sc->reclaim_mode to determine
> if it was file, anon or a mix of both that was isolated. That should
> be fixed.
sure, I will see how to work it out.
> 
> If isolate_lru_pages really needs to export the file information,
> then it would be preferable to fix trace_shrink_flags() and use it to
> indicate if it was file, anon or a mix of both that was isolated. The
> information needed to trace this is not available in isolate_lru_pages
> so it would need to be passed down. Even with that, I would also
> like to see trace/postprocess/trace-vmscan-postprocess.pl updated to
> illustrate how this new information can be used to debug a problem
> or at least describe what sort of problem it can debug.
Sorry, I don't ever know the existence of this script. And I will update
this script in the next try.
> 
> 
>> I think 'mode' is more proper rather than  specific 'active'.
>> The 'mode' can achieve your goal without passing new argument "active".
>>
> 
> True.
> 
>> In addition to, current mmotm has various modes.
>> So sometime we can get more specific result rather than vauge 'active'.
>>
> 
> Which also means that trace/postprocess/trace-vmscan-postprocess.pl
> is not using mm_vmscan_lru_isolate properly as it does not understand
> ISOLATE_CLEAN and ISOLATE_UNMAPPED. The impact for the script is that
> the scan count it reports will deviate from what /proc/vmstat reports
> which is irritating.
Let me see whether I can fix it or not.

Thanks
Tao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

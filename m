Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8E03E8D0003
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:43:02 -0400 (EDT)
Received: by pwi1 with SMTP id 1so323167pwi.14
        for <linux-mm@kvack.org>; Wed, 03 Nov 2010 08:42:58 -0700 (PDT)
Date: Thu, 4 Nov 2010 00:42:49 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for
 protecting the working set
Message-ID: <20101103154249.GA1779@barrios-desktop>
References: <20101028191523.GA14972@google.com>
 <20101101012322.605C.A69D9226@jp.fujitsu.com>
 <20101101182416.GB31189@google.com>
 <4CCF0BE3.2090700@redhat.com>
 <AANLkTi=src1L0gAFsogzCmejGOgg5uh=9O4Uw+ZmfBg4@mail.gmail.com>
 <4CCF8151.3010202@redhat.com>
 <AANLkTi=JJ-0ae+QybtR+e=4_4mpQghh61c4=TZYAw8uF@mail.gmail.com>
 <4CD0C22B.2000905@redhat.com>
 <AANLkTik8y=bh3dBJe0bFmjAUvc7y8yBpjP4DKuKU+Z2j@mail.gmail.com>
 <4CD14A6F.4010109@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CD14A6F.4010109@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Mandeep Singh Baines <msb@chromium.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 03, 2010 at 07:41:35AM -0400, Rik van Riel wrote:
> On 11/02/2010 11:03 PM, Minchan Kim wrote:
> 
> >It could.
> >But time based approach would be same, IMHO.
> >First of all, I don't want long latency of direct reclaim process.
> >It could affect response of foreground process directly.
> >
> >If VM limits the number of pages reclaimed per second, direct reclaim
> >process's latency will be affected. so we should avoid throttling in
> >direct reclaim path. Agree?
> 
> The idea would be to not throttle the processes trying to
> reclaim page cache pages, but to only reclaim anonymous
> pages when the page cache pages are low (and occasionally
> a few page cache pages, say 128 a second).

Fair enough. Only anon reclaim is better than thrashing of code pages. 

> 
> If too many reclaimers come in when the page cache is
> low and no swap is available, we will OOM kill instead
> of stalling.

I understand why you use (file < pages_min).
We can keep the threshold small value. Otherwise, 
we can see the many OOM question. "Why OOM happens although my system have enough 
file LRU pages?"

> 
> After all, the entire point of this patch would be to
> avoid minutes-long latencies in triggering the OOM
> killer.

I got your point. The patch's goal is not protect working set fully, but prevent
page cache thrashing in low file LRU. 
It could make minutes-long latencies by reaching the OOM. 

Okay. I will look into this idea.
Thanks for the good suggestion, Rik. 

> 
> -- 
> All rights reversed

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

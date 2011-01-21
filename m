Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6B2818D0069
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 19:18:23 -0500 (EST)
Message-ID: <4D38D070.2050802@redhat.com>
Date: Thu, 20 Jan 2011 19:16:48 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/2] Tunable watermark
References: <65795E11DBF1E645A09CEC7EAEE94B9C3A30A295@USINDEVS02.corp.hds.com>
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9C3A30A295@USINDEVS02.corp.hds.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Satoru Moriya <satoru.moriya@hds.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "rdunlap@xenotime.net" <rdunlap@xenotime.net>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>
List-ID: <linux-mm.kvack.org>

On 01/07/2011 05:03 PM, Satoru Moriya wrote:

> The result is following.
>
>                    | default |  case 1   |  case 2 |
> ----------------------------------------------------------
> wmark_min_kbytes  |  5752   |    5752   |   5752  |
> wmark_low_kbytes  |  7190   |   16384   |  32768  | (KB)
> wmark_high_kbytes |  8628   |   20480   |  40960  |
> ----------------------------------------------------------
> real              |   503   |    364    |    337  |
> user              |     3   |      5    |      4  | (msec)
> sys               |   153   |    149    |    146  |
> ----------------------------------------------------------
> page fault        |  32768  |  32768    |  32768  |
> kswapd_wakeup     |   1809  |    335    |    228  | (times)
> direct reclaim    |      5  |      0    |      0  |
>
> As you can see, direct reclaim was performed 5 times and
> its exec time was 503 msec in the default case. On the other
> hand, in case 1 (large delta case ) no direct reclaim was
> performed and its exec time was 364 msec.

Saving 1.5 seconds on a one-off workload is probably not
worth the complexity of giving a system administrator
yet another set of tunables to mess with.

However, I suspect it may be a good idea if the kernel
could adjust these watermarks automatically, since direct
reclaim could lead to quite a big performance penalty.

I do not know which events should be used to increase and
decrease the watermarks, but I have some ideas:
- direct reclaim (increase)
- kswapd has trouble freeing pages (increase)
- kswapd frees enough memory at DEF_PRIORITY (decrease)
- next to no direct reclaim events in the last N (1000?)
   reclaim events (decrease)

I guess we will also need to be sure that the watermarks
are never raised above some sane upper threshold.  Maybe
4x or 5x the default?


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F35606B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 19:59:19 -0400 (EDT)
Received: by wyf19 with SMTP id 19so2281027wyf.14
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 16:59:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DB8AAE3.20806@redhat.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
	<51e7412097fa62f86656c77c1934e3eb96d5eef6.1303833417.git.minchan.kim@gmail.com>
	<4DB8AAE3.20806@redhat.com>
Date: Thu, 28 Apr 2011 08:59:17 +0900
Message-ID: <BANLkTimPAU-uc=FCV9Z-LKmQm-GGusHfiw@mail.gmail.com>
Subject: Re: [RFC 6/8] In order putback lru core
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>

Hi Rik,

On Thu, Apr 28, 2011 at 8:46 AM, Rik van Riel <riel@redhat.com> wrote:
> On 04/26/2011 12:25 PM, Minchan Kim wrote:
>
>> But this approach has a problem on contiguous pages.
>> In this case, my idea can not work since friend pages are isolated, too.
>> It means prev_page->next == next_page always is false and both pages are
>> not
>> LRU any more at that time. It's pointed out by Rik at LSF/MM summit.
>> So for solving the problem, I can change the idea.
>> I think we don't need both friend(prev, next) pages relation but
>> just consider either prev or next page that it is still same LRU.
>
>> Any comment?
>
> If the friend pages are isolated too, then your condition
> "either prev or next page that it is still same LRU" is
> likely to be false, no?

H - P1 - P2 - P3 - P4 - P5 - P6 - P7 - P8 - P9 - P10 - T

assume : we isolate pages P3~P7 and we consider only next pointer.

H - P1 - P2 - P8 - P9 - P10 - T

If we start to putback P7 as starting point, next P8 is valid so,

H - P1 - P2 - P7 - P8 - P9 - P10 - T
Then, if we consider P6, next P7 is valid, too. So,

H - P1 - P2 - P6 - P7 - P8 - P9 - P10 - T

continue until P3.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

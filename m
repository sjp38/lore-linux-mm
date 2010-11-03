Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 47F356B0095
	for <linux-mm@kvack.org>; Tue,  2 Nov 2010 22:00:55 -0400 (EDT)
Message-ID: <4CD0C22B.2000905@redhat.com>
Date: Tue, 02 Nov 2010 22:00:11 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for protecting
 the working set
References: <20101028191523.GA14972@google.com>	<20101101012322.605C.A69D9226@jp.fujitsu.com>	<20101101182416.GB31189@google.com>	<4CCF0BE3.2090700@redhat.com>	<AANLkTi=src1L0gAFsogzCmejGOgg5uh=9O4Uw+ZmfBg4@mail.gmail.com>	<4CCF8151.3010202@redhat.com> <AANLkTi=JJ-0ae+QybtR+e=4_4mpQghh61c4=TZYAw8uF@mail.gmail.com>
In-Reply-To: <AANLkTi=JJ-0ae+QybtR+e=4_4mpQghh61c4=TZYAw8uF@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mandeep Singh Baines <msb@chromium.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

On 11/02/2010 08:48 PM, Minchan Kim wrote:

>> I wonder if a possible solution would be to limit how fast
>> file pages get reclaimed, when the page cache is very small.
>> Say, inactive_file * active_file<  2 * zone->pages_high ?
>
> Why do you multiply inactive_file and active_file?
> What's meaning?

That was a stupid typo, it should have been a + :)

> I think it's very difficult to fix _a_ threshold.
> At least, user have to set it with proper value to use the feature.
> Anyway, we need default value. It needs some experiments in desktop
> and embedded.

Yes, setting a threshold will be difficult.  However,
if the behaviour below that threshold is harmless to
pretty much any workload, it doesn't matter a whole
lot where we set it...

>> At that point, maybe we could slow down the reclaiming of
>> page cache pages to be significantly slower than they can
>> be refilled by the disk.  Maybe 100 pages a second - that
>> can be refilled even by an actual spinning metal disk
>> without even the use of readahead.
>>
>> That can be rounded up to one batch of SWAP_CLUSTER_MAX
>> file pages every 1/4 second, when the number of page cache
>> pages is very low.
>
> How about reducing scanning window size?
> I think it could approximate the idea.

A good idea in principle, but if it results in the VM
simply calling the pageout code more often, I suspect
it will not have any effect.

Your patch looks like it would have that effect.

I suspect we will need a time-based approach to really
protect the last bits of page cache in a near-OOM
situation.

>> Would there be any downsides to this approach?
>
> At first feeling, I have a concern unbalance aging of anon/file.
> But I think it's no problem. It a result user want. User want to
> protect file-backed page(ex, code page) so many anon swapout is
> natural result to go on the system. If the system has no swap, we have
> no choice except OOM.

We already have an unbalance in aging anon and file
pages, several of which are introduced on purpose.

In this proposal, there would only be an imbalance
if the number of file pages is really low.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

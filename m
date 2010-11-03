Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 470C66B00B2
	for <linux-mm@kvack.org>; Tue,  2 Nov 2010 23:03:20 -0400 (EDT)
Received: by iwn9 with SMTP id 9so39356iwn.14
        for <linux-mm@kvack.org>; Tue, 02 Nov 2010 20:03:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4CD0C22B.2000905@redhat.com>
References: <20101028191523.GA14972@google.com>
	<20101101012322.605C.A69D9226@jp.fujitsu.com>
	<20101101182416.GB31189@google.com>
	<4CCF0BE3.2090700@redhat.com>
	<AANLkTi=src1L0gAFsogzCmejGOgg5uh=9O4Uw+ZmfBg4@mail.gmail.com>
	<4CCF8151.3010202@redhat.com>
	<AANLkTi=JJ-0ae+QybtR+e=4_4mpQghh61c4=TZYAw8uF@mail.gmail.com>
	<4CD0C22B.2000905@redhat.com>
Date: Wed, 3 Nov 2010 12:03:18 +0900
Message-ID: <AANLkTik8y=bh3dBJe0bFmjAUvc7y8yBpjP4DKuKU+Z2j@mail.gmail.com>
Subject: Re: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for
 protecting the working set
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Mandeep Singh Baines <msb@chromium.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 3, 2010 at 11:00 AM, Rik van Riel <riel@redhat.com> wrote:
> On 11/02/2010 08:48 PM, Minchan Kim wrote:
>
>>> I wonder if a possible solution would be to limit how fast
>>> file pages get reclaimed, when the page cache is very small.
>>> Say, inactive_file * active_file< =A02 * zone->pages_high ?
>>
>> Why do you multiply inactive_file and active_file?
>> What's meaning?
>
> That was a stupid typo, it should have been a + :)
>
>> I think it's very difficult to fix _a_ threshold.
>> At least, user have to set it with proper value to use the feature.
>> Anyway, we need default value. It needs some experiments in desktop
>> and embedded.
>
> Yes, setting a threshold will be difficult. =A0However,
> if the behaviour below that threshold is harmless to
> pretty much any workload, it doesn't matter a whole
> lot where we set it...

Okay. But I doubt we could make the default value with effective when
we really need the function.
Maybe whenever user uses the feature, he have to tweak the knob.

>
>>> At that point, maybe we could slow down the reclaiming of
>>> page cache pages to be significantly slower than they can
>>> be refilled by the disk. =A0Maybe 100 pages a second - that
>>> can be refilled even by an actual spinning metal disk
>>> without even the use of readahead.
>>>
>>> That can be rounded up to one batch of SWAP_CLUSTER_MAX
>>> file pages every 1/4 second, when the number of page cache
>>> pages is very low.
>>
>> How about reducing scanning window size?
>> I think it could approximate the idea.
>
> A good idea in principle, but if it results in the VM
> simply calling the pageout code more often, I suspect
> it will not have any effect.
>
> Your patch looks like it would have that effect.


It could.
But time based approach would be same, IMHO.
First of all, I don't want long latency of direct reclaim process.
It could affect response of foreground process directly.

If VM limits the number of pages reclaimed per second, direct reclaim
process's latency will be affected. so we should avoid throttling in
direct reclaim path. Agree?

So, for slow down reclaim pages in kswapd, there will be processes
enter direct relcaim. So it results in the VM simply calling the
pageout code more often.

If I misunderstood way to implement your idea, please let me know it.

>
> I suspect we will need a time-based approach to really
> protect the last bits of page cache in a near-OOM
> situation.
>
>>> Would there be any downsides to this approach?
>>
>> At first feeling, I have a concern unbalance aging of anon/file.
>> But I think it's no problem. It a result user want. User want to
>> protect file-backed page(ex, code page) so many anon swapout is
>> natural result to go on the system. If the system has no swap, we have
>> no choice except OOM.
>
> We already have an unbalance in aging anon and file
> pages, several of which are introduced on purpose.
>
> In this proposal, there would only be an imbalance
> if the number of file pages is really low.

Right.

>
> --
> All rights reversed
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

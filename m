Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0FA848D0015
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 19:28:24 -0400 (EDT)
Received: by iwn38 with SMTP id 38so1972220iwn.14
        for <linux-mm@kvack.org>; Thu, 28 Oct 2010 16:28:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101028220331.GZ26494@google.com>
References: <20101028191523.GA14972@google.com>
	<20101028131029.ee0aadc0.akpm@linux-foundation.org>
	<20101028220331.GZ26494@google.com>
Date: Fri, 29 Oct 2010 08:28:23 +0900
Message-ID: <AANLkTi=VnTkuyYht8D+2MPO1d4mXR1ah-0aQeAjZsTaq@mail.gmail.com>
Subject: Re: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for
 protecting the working set
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mandeep Singh Baines <msb@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 29, 2010 at 7:03 AM, Mandeep Singh Baines <msb@chromium.org> wr=
ote:
> Andrew Morton (akpm@linux-foundation.org) wrote:
>> On Thu, 28 Oct 2010 12:15:23 -0700
>> Mandeep Singh Baines <msb@chromium.org> wrote:
>>
>> > On ChromiumOS, we do not use swap.
>>
>> Well that's bad. =A0Why not?
>>
>
> We're using SSDs. We're still in the "make it work" phase so wanted
> avoid swap unless/until we learn how to use it effectively with
> an SSD.
>
> You'll want to tune swap differently if you're using an SSD. Not sure
> if swappiness is the answer. Maybe a new tunable to control how aggressiv=
e
> swap is unless such a thing already exits?
>
>> > When memory is low, the only way to
>> > free memory is to reclaim pages from the file list. This results in a
>> > lot of thrashing under low memory conditions. We see the system become
>> > unresponsive for minutes before it eventually OOMs. We also see very
>> > slow browser tab switching under low memory. Instead of an unresponsiv=
e
>> > system, we'd really like the kernel to OOM as soon as it starts to
>> > thrash. If it can't keep the working set in memory, then OOM.
>> > Losing one of many tabs is a better behaviour for the user than an
>> > unresponsive system.
>> >
>> > This patch create a new sysctl, min_filelist_kbytes, which disables re=
claim
>> > of file-backed pages when when there are less than min_filelist_bytes =
worth
>> > of such pages in the cache. This tunable is handy for low memory syste=
ms
>> > using solid-state storage where interactive response is more important
>> > than not OOMing.
>> >
>> > With this patch and min_filelist_kbytes set to 50000, I see very littl=
e
>> > block layer activity during low memory. The system stays responsive un=
der
>> > low memory and browser tab switching is fast. Eventually, a process a =
gets
>> > killed by OOM. Without this patch, the system gets wedged for minutes
>> > before it eventually OOMs. Below is the vmstat output from my test run=
s.
>> >
>> > BEFORE (notice the high bi and wa, also how long it takes to OOM):
>>
>> That's an interesting result.
>>
>> Having the machine "wedged for minutes" thrashing away paging
>> executable text is pretty bad behaviour. =A0I wonder how to fix it.
>> Perhaps simply declaring oom at an earlier stage.
>>
>> Your patch is certainly simple enough but a bit sad. =A0It says "the VM
>> gets this wrong, so lets just disable it all". =A0And thereby reduces th=
e
>> motivation to fix it for real.
>>
>
> Yeah, I used the RFC label because we're thinking this is just a temporar=
y
> bandaid until something better comes along.
>
> Couple of other nits I have with our patch:
> * Not really sure what to do for the cgroup case. We do something
> =A0reasonable for now.
> * One of my colleagues also brought up the point that we might want to do
> =A0something different if swap was enabled.
>
>> But the patch definitely improves the situation in real-world
>> situations and there's a case to be made that it should be available at
>> least as an interim thing until the VM gets fixed for real. =A0Which
>> means that the /proc tunable might disappear again (or become a no-op)
>> some time in the future.

I think this feature that "System response time doesn't allow but OOM allow=
".
While we can control process to not killed by OOM using
/oom_score_adj, we can't control response time directly.
But in mobile system, we have to control response time. One of cause
to avoid swap is due to response time.

How about using memcg?
Isolate processes related to system response(ex, rendering engine, IPC
engine and so no)  to another group.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 94C066B00D0
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 20:28:36 -0400 (EDT)
Received: by iwn38 with SMTP id 38so2046497iwn.14
        for <linux-mm@kvack.org>; Thu, 28 Oct 2010 17:28:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101029090449.a79452a2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101028191523.GA14972@google.com>
	<20101028131029.ee0aadc0.akpm@linux-foundation.org>
	<20101028220331.GZ26494@google.com>
	<AANLkTi=VnTkuyYht8D+2MPO1d4mXR1ah-0aQeAjZsTaq@mail.gmail.com>
	<20101029090449.a79452a2.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 29 Oct 2010 09:28:33 +0900
Message-ID: <AANLkTin4C=yt+CZm_QTOMUOh0wevCauET2Fnmh7hJZap@mail.gmail.com>
Subject: Re: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for
 protecting the working set
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mandeep Singh Baines <msb@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 29, 2010 at 9:04 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 29 Oct 2010 08:28:23 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Fri, Oct 29, 2010 at 7:03 AM, Mandeep Singh Baines <msb@chromium.org>=
 wrote:
>> > Andrew Morton (akpm@linux-foundation.org) wrote:
>> >> On Thu, 28 Oct 2010 12:15:23 -0700
>> >> Mandeep Singh Baines <msb@chromium.org> wrote:
>> >>
>> >> > On ChromiumOS, we do not use swap.
>> >>
>> >> Well that's bad. =A0Why not?
>> >>
>> >
>> > We're using SSDs. We're still in the "make it work" phase so wanted
>> > avoid swap unless/until we learn how to use it effectively with
>> > an SSD.
>> >
>> > You'll want to tune swap differently if you're using an SSD. Not sure
>> > if swappiness is the answer. Maybe a new tunable to control how aggres=
sive
>> > swap is unless such a thing already exits?
>> >
>> >> > When memory is low, the only way to
>> >> > free memory is to reclaim pages from the file list. This results in=
 a
>> >> > lot of thrashing under low memory conditions. We see the system bec=
ome
>> >> > unresponsive for minutes before it eventually OOMs. We also see ver=
y
>> >> > slow browser tab switching under low memory. Instead of an unrespon=
sive
>> >> > system, we'd really like the kernel to OOM as soon as it starts to
>> >> > thrash. If it can't keep the working set in memory, then OOM.
>> >> > Losing one of many tabs is a better behaviour for the user than an
>> >> > unresponsive system.
>> >> >
>> >> > This patch create a new sysctl, min_filelist_kbytes, which disables=
 reclaim
>> >> > of file-backed pages when when there are less than min_filelist_byt=
es worth
>> >> > of such pages in the cache. This tunable is handy for low memory sy=
stems
>> >> > using solid-state storage where interactive response is more import=
ant
>> >> > than not OOMing.
>> >> >
>> >> > With this patch and min_filelist_kbytes set to 50000, I see very li=
ttle
>> >> > block layer activity during low memory. The system stays responsive=
 under
>> >> > low memory and browser tab switching is fast. Eventually, a process=
 a gets
>> >> > killed by OOM. Without this patch, the system gets wedged for minut=
es
>> >> > before it eventually OOMs. Below is the vmstat output from my test =
runs.
>> >> >
>> >> > BEFORE (notice the high bi and wa, also how long it takes to OOM):
>> >>
>> >> That's an interesting result.
>> >>
>> >> Having the machine "wedged for minutes" thrashing away paging
>> >> executable text is pretty bad behaviour. =A0I wonder how to fix it.
>> >> Perhaps simply declaring oom at an earlier stage.
>> >>
>> >> Your patch is certainly simple enough but a bit sad. =A0It says "the =
VM
>> >> gets this wrong, so lets just disable it all". =A0And thereby reduces=
 the
>> >> motivation to fix it for real.
>> >>
>> >
>> > Yeah, I used the RFC label because we're thinking this is just a tempo=
rary
>> > bandaid until something better comes along.
>> >
>> > Couple of other nits I have with our patch:
>> > * Not really sure what to do for the cgroup case. We do something
>> > =A0reasonable for now.
>> > * One of my colleagues also brought up the point that we might want to=
 do
>> > =A0something different if swap was enabled.
>> >
>> >> But the patch definitely improves the situation in real-world
>> >> situations and there's a case to be made that it should be available =
at
>> >> least as an interim thing until the VM gets fixed for real. =A0Which
>> >> means that the /proc tunable might disappear again (or become a no-op=
)
>> >> some time in the future.
>>
>> I think this feature that "System response time doesn't allow but OOM al=
low".
>> While we can control process to not killed by OOM using
>> /oom_score_adj, we can't control response time directly.
>> But in mobile system, we have to control response time. One of cause
>> to avoid swap is due to response time.
>>
>> How about using memcg?
>> Isolate processes related to system response(ex, rendering engine, IPC
>> engine and so no) =A0to another group.
>>
> Yes, this seems interesting topic on memcg.
>
> maybe configure cgroups as..
>
> /system =A0 =A0 =A0 ....... limit to X % of the system.
> /application =A0....... limit to 100-X % of the system.
>
> and put management software to /system. Then, the system software can che=
ck
> behavior of applicatoin and measure cpu time and I/O performance in /appl=
icaiton.
> (And yes, it can watch memory usage.)
>
> Here, memory cgroup has oom-notifier, you may able to do something other =
than
> oom-killer by the system. If this patch is applied to global VM, I'll che=
ck
> memcg can support it or not.
> Hmm....checking anon/file rate in /application may be enough ?

I think anon/file/mapped_file is enough to do that.

>
> Or, as a google guy proosed, we may have to add "file-cache-only" memcg.
> For example, configure system as
>
> /system
> /application-anon
> /application-file-cache
>
> (But balancing file/anon must be done by user....this is difficult.)

Yes. I believe such fine-grained control can make system admin more annoyin=
g.

>
> BTW, can we know that "recently paged out file cache comes back immediate=
ly!"
> score ?

Not easy. If we can get it easily, we can enhance victim selection algorith=
m.
AFAIR, Rik tried it.
http://lwn.net/Articles/147879/


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

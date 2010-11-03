Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BB0136B00BF
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 19:49:26 -0400 (EDT)
Received: by iwn9 with SMTP id 9so1244195iwn.14
        for <linux-mm@kvack.org>; Wed, 03 Nov 2010 16:49:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101103224055.GC19646@google.com>
References: <20101028191523.GA14972@google.com>
	<20101101012322.605C.A69D9226@jp.fujitsu.com>
	<20101101182416.GB31189@google.com>
	<4CCF0BE3.2090700@redhat.com>
	<AANLkTi=src1L0gAFsogzCmejGOgg5uh=9O4Uw+ZmfBg4@mail.gmail.com>
	<4CCF8151.3010202@redhat.com>
	<20101103224055.GC19646@google.com>
Date: Thu, 4 Nov 2010 08:49:25 +0900
Message-ID: <AANLkTikkSVJ36OViEBWAMaM10jqkA3mLbSA06zAx38R_@mail.gmail.com>
Subject: Re: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for
 protecting the working set
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mandeep Singh Baines <msb@chromium.org>
Cc: Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

Hello.

On Thu, Nov 4, 2010 at 7:40 AM, Mandeep Singh Baines <msb@chromium.org> wro=
te:
> Rik van Riel (riel@redhat.com) wrote:
>> On 11/01/2010 03:43 PM, Mandeep Singh Baines wrote:
>>
>> >Yes, this prevents you from reclaiming the active list all at once. But=
 if the
>> >memory pressure doesn't go away, you'll start to reclaim the active lis=
t
>> >little by little. First you'll empty the inactive list, and then
>> >you'll start scanning
>> >the active list and pulling pages from inactive to active. The problem =
is that
>> >there is no minimum time limit to how long a page will sit in the inact=
ive list
>> >before it is reclaimed. Just depends on scan rate which does not depend
>> >on time.
>> >
>> >In my experiments, I saw the active list get smaller and smaller
>> >over time until eventually it was only a few MB at which point the syst=
em came
>> >grinding to a halt due to thrashing.
>>
>> I believe that changing the active/inactive ratio has other
>> potential thrashing issues. =A0Specifically, when the inactive
>> list is too small, pages may not stick around long enough to
>> be accessed multiple times and get promoted to the active
>> list, even when they are in active use.
>>
>> I prefer a more flexible solution, that automatically does
>> the right thing.
>>
>> The problem you see is that the file list gets reclaimed
>> very quickly, even when it is already very small.
>>
>> I wonder if a possible solution would be to limit how fast
>> file pages get reclaimed, when the page cache is very small.
>> Say, inactive_file * active_file < 2 * zone->pages_high ?
>>
>> At that point, maybe we could slow down the reclaiming of
>> page cache pages to be significantly slower than they can
>> be refilled by the disk. =A0Maybe 100 pages a second - that
>> can be refilled even by an actual spinning metal disk
>> without even the use of readahead.
>>
>> That can be rounded up to one batch of SWAP_CLUSTER_MAX
>> file pages every 1/4 second, when the number of page cache
>> pages is very low.
>>
>> This way HPC and virtual machine hosting nodes can still
>> get rid of totally unused page cache, but on any system
>> that actually uses page cache, some minimal amount of
>> cache will be protected under heavy memory pressure.
>>
>> Does this sound like a reasonable approach?
>>
>> I realize the threshold may have to be tweaked...
>>
>> The big question is, how do we integrate this with the
>> OOM killer? =A0Do we pretend we are out of memory when
>> we've hit our file cache eviction quota and kill something?
>>
>> Would there be any downsides to this approach?
>>
>> Are there any volunteers for implementing this idea?
>> (Maybe someone who needs the feature?)
>>
>
> I've created a patch which takes a slightly different approach.
> Instead of limiting how fast pages get reclaimed, the patch limits
> how fast the active list gets scanned. This should result in the
> active list being a better measure of the working set. I've seen
> fairly good results with this patch and a scan inteval of 1
> centisecond. I see no thrashing when the scan interval is non-zero.
>
> I've made it a tunable because I don't know what to set the scan
> interval. The final patch could set the value based on HZ and some
> other system parameters. Maybe relate it to sched_period?
>
> ---
>
> [PATCH] vmscan: add a configurable scan interval
>
> On ChromiumOS, we see a lot of thrashing under low memory. We do not
> use swap, so the mm system can only free file-backed pages. Eventually,
> we are left with little file back pages remaining (a few MB) and the
> system becomes unresponsive due to thrashing.
>
> Our preference is for the system to OOM instead of becoming unresponsive.
>
> This patch create a tunable, vmscan_interval_centisecs, for controlling
> the minimum interval between active list scans. At 0, I see the same
> thrashing. At 1, I see no thrashing. The mm system does a good job
> of protecting the working set. If a page has been referenced in the
> last vmscan_interval_centisecs it is kept in memory.
>
> Signed-off-by: Mandeep Singh Baines <msb@chromium.org>

vmscan already have used HZ/10 to calm down congestion of writeback or
something.
(But I don't know why VM used the value and who determined it by any
rationale. It might be a value determined by some experiments.)
If there isn't any good math, we will depend on experiment in this time, to=
o.

Anyway If interval is long, It could make inactive list's size very
shortly in many reclaim workload and then unnecessary OOM kill.
So I hope if inactive list size is very small compared to active list
size, quit the check and refiill the inactive list.

Anyway, the approach makes sense to me.
But need other guy's opinion.

Nitpick :
I expect you will include description of knob in
Documentation/sysctl/vm.txt in your formal patch.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

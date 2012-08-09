Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 3D56C6B002B
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 18:38:49 -0400 (EDT)
Message-ID: <50243BE0.9060007@sandia.gov>
Date: Thu, 9 Aug 2012 16:38:24 -0600
From: "Jim Schutt" <jaschut@sandia.gov>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/5] Improve hugepage allocation success rates
 under load V3
References: <1344520165-24419-1-git-send-email-mgorman@suse.de>
 <5023FE83.4090200@sandia.gov> <20120809204630.GJ12690@suse.de>
In-Reply-To: <20120809204630.GJ12690@suse.de>
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 08/09/2012 02:46 PM, Mel Gorman wrote:
> On Thu, Aug 09, 2012 at 12:16:35PM -0600, Jim Schutt wrote:
>> On 08/09/2012 07:49 AM, Mel Gorman wrote:
>>> Changelog since V2
>>> o Capture !MIGRATE_MOVABLE pages where possible
>>> o Document the treatment of MIGRATE_MOVABLE pages while capturing
>>> o Expand changelogs
>>>
>>> Changelog since V1
>>> o Dropped kswapd related patch, basically a no-op and regresses if fixed (minchan)
>>> o Expanded changelogs a little
>>>
>>> Allocation success rates have been far lower since 3.4 due to commit
>>> [fe2c2a10: vmscan: reclaim at order 0 when compaction is enabled]. This
>>> commit was introduced for good reasons and it was known in advance that
>>> the success rates would suffer but it was justified on the grounds that
>>> the high allocation success rates were achieved by aggressive reclaim.
>>> Success rates are expected to suffer even more in 3.6 due to commit
>>> [7db8889a: mm: have order>   0 compaction start off where it left] which
>>> testing has shown to severely reduce allocation success rates under load -
>>> to 0% in one case.  There is a proposed change to that patch in this series
>>> and it would be ideal if Jim Schutt could retest the workload that led to
>>> commit [7db8889a: mm: have order>   0 compaction start off where it left].
>>
>> On my first test of this patch series on top of 3.5, I ran into an
>> instance of what I think is the sort of thing that patch 4/5 was
>> fixing.  Here's what vmstat had to say during that period:
>>
>> <SNIP>
>
> My conclusion looking at the vmstat data is that everything is looking ok
> until system CPU usage goes through the roof. I'm assuming that's what we
> are all still looking at.

I'm concerned about both the high CPU usage as well as the
reduction in write-out rate, but I've been assuming the latter
is caused by the former.

<snip>

>
> Ok, this is an untested hack and I expect it would drop allocation success
> rates again under load (but not as much). Can you test again and see what
> effect, if any, it has please?
>
> ---8<---
> mm: compaction: back out if contended
>
> ---

<snip>

Initial testing with this patch looks very good from
my perspective; CPU utilization stays reasonable,
write-out rate stays high, no signs of stress.
Here's an example after ~10 minutes under my test load:

2012-08-09 16:26:07.550-06:00
vmstat -w 4 16
procs -------------------memory------------------ ---swap-- -----io---- --system-- -----cpu-------
  r  b       swpd       free       buff      cache   si   so    bi    bo   in   cs  us sy  id wa st
21 19          0     351628        576   37835440    0    0    17 44394 1241  653   6 20  64  9  0
11 11          0     365520        576   37893060    0    0   124 2121508 203450 170957  12 46  25 17  0
13 16          0     359888        576   37954456    0    0    98 2185033 209473 171571  13 44  25 18  0
17 15          0     353728        576   38010536    0    0    89 2170971 208052 167988  13 43  26 18  0
17 16          0     349732        576   38048284    0    0   135 2217752 218754 174170  13 49  21 16  0
43 13          0     343280        576   38046500    0    0   153 2207135 217872 179519  13 47  23 18  0
26 13          0     350968        576   37937184    0    0   147 2189822 214276 176697  13 47  23 17  0
  4 12          0     350080        576   37958364    0    0   226 2145212 207077 172163  12 44  24 20  0
15 13          0     353124        576   37921040    0    0   145 2078422 197231 166381  12 41  30 17  0
14 15          0     348964        576   37949588    0    0   107 2020853 188192 164064  12 39  30 20  0
21  9          0     354784        576   37951228    0    0   117 2148090 204307 165609  13 48  22 18  0
36 16          0     347368        576   37989824    0    0   166 2208681 216392 178114  13 47  24 16  0
28 15          0     300656        576   38060912    0    0   164 2181681 214618 175132  13 45  24 18  0
  9 16          0     295484        576   38092184    0    0   153 2156909 218993 180289  13 43  27 17  0
17 16          0     346760        576   37979008    0    0   165 2124168 198730 173455  12 44  27 18  0
14 17          0     360988        576   37957136    0    0   142 2092248 197430 168199  12 42  29 17  0

I'll continue testing tomorrow to be sure nothing
shows up after continued testing.

If this passes your allocation success rate testing,
I'm happy with this performance for 3.6 - if not, I'll
be happy to test any further patches.

I really appreciate getting the chance to test out
your patchset.

Thanks -- Jim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

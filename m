Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B9EA16B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 04:05:47 -0500 (EST)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id oAU95i3Z030743
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 01:05:44 -0800
Received: from qwi2 (qwi2.prod.google.com [10.241.195.2])
	by wpaz37.hot.corp.google.com with ESMTP id oAU95gku002707
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 01:05:43 -0800
Received: by qwi2 with SMTP id 2so11572qwi.21
        for <linux-mm@kvack.org>; Tue, 30 Nov 2010 01:05:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101130160000.ac7b0b76.kamezawa.hiroyu@jp.fujitsu.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<20101130160000.ac7b0b76.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 30 Nov 2010 01:05:42 -0800
Message-ID: <AANLkTi=rDcjREYStNJ=Nk8A_2DH=t2cocxpwa_rj6W3r@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/4] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 29, 2010 at 11:00 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 29 Nov 2010 22:49:41 -0800
> Ying Han <yinghan@google.com> wrote:
>
>> The current implementation of memcg only supports direct reclaim and thi=
s
>> patchset adds the support for background reclaim. Per cgroup background
>> reclaim is needed which spreads out the memory pressure over longer peri=
od
>> of time and smoothes out the system performance.
>>
>> The current implementation is not a stable version, and it crashes somet=
imes
>> on my NUMA machine. Before going further for debugging, I would like to =
start
>> the discussion and hear the feedbacks of the initial design.
>>
>
> It's welcome but please wait until merge of dirty-ratio.
> And please post after you don't see crash ....
Yeah, I will look into the crash and fix it. Besides, it runs fine so
far on my single node
system.

>
> Description of design is appreciated.
> Where the cost for "kswapd" is charged agaist if cpu cgroup is used at th=
e same time ?
There is no special treatment for that in the current implementation.
Ideally it would be nice to charge the kswapd time to the
corresponding cgroup. As a starting point, all the kswapd threads
cputime could be charged to root.

>> Current status:
>> I run through some simple tests which reads/writes a large file and make=
s sure
>> it triggers per cgroup kswapd on the low_wmark. Also, I compared at
>> pg_steal/pg_scan ratio w/o background reclaim.
>>
>>
>
> =A0Step1: Create a cgroup with 500M memory_limit and set the min_free_kby=
tes to 1024.
>> $ mount -t cgroup -o cpuset,memory cpuset /dev/cgroup
>> $ mkdir /dev/cgroup/A
>> $ echo 0 >/dev/cgroup/A/cpuset.cpus
>> $ echo 0 >/dev/cgroup/A/cpuset.mems
>> $ echo 500m >/dev/cgroup/A/memory.limit_in_bytes
>> $ echo 1024 >/dev/cgroup/A/memory.min_free_kbytes
>> $ echo $$ >/dev/cgroup/A/tasks
>>
>> Step2: Check the wmarks.
>> $ cat /dev/cgroup/A/memory.reclaim_wmarks
>> memcg_low_wmark 98304000
>> memcg_high_wmark 81920000
>>
>> Step3: Dirty the pages by creating a 20g file on hard drive.
>> $ ddtest -D /export/hdc3/dd -b 1024 -n 20971520 -t 1
>>
>> Checked the memory.stat w/o background reclaim. It used to be all the pa=
ges are
>> reclaimed from direct reclaim, and now about half of them are reclaimed =
at
>> background. (note: writing '0' to min_free_kbytes disables per cgroup ks=
wapd)
>>
>> Only direct reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0With background reclaim:
>> kswapd_steal 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_steal 2751822
>> pg_pgsteal 5100401 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pg_pgsteal 2476676
>> kswapd_pgscan 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kswapd_pgscan 6019373
>> pg_scan 5542464 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pg_scan 3851281
>> pgrefill 304505 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgrefill 348077
>> pgoutrun 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgoutrun 44568
>> allocstall 159278 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0allocstall 75669
>>
>> Step4: Cleanup
>> $ echo $$ >/dev/cgroup/tasks
>> $ echo 0 > /dev/cgroup/A/memory.force_empty
>>
>> Step5: Read the 20g file into the pagecache.
>> $ cat /export/hdc3/dd/tf0 > /dev/zero;
>>
>> Checked the memory.stat w/o background reclaim. All the clean pages are =
reclaimed at
>> background instead of direct reclaim.
>>
>> Only direct reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0With background reclaim
>> kswapd_steal 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kswapd_steal 3512424
>> pg_pgsteal 3461280 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pg_pgsteal 0
>> kswapd_pgscan 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kswapd_pgscan 3512440
>> pg_scan 3461280 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pg_scan 0
>> pgrefill 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgrefill=
 0
>> pgoutrun 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgoutrun 74973
>> allocstall 108165 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0allocstall 0
>>
>
> What is the trigger for starting background reclaim ?

The background reclaim is triggered when the usage_in_bytes above the
watermark in mem_cgroup_do_charge.

--Ying
>
> Thanks,
> -Kame
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

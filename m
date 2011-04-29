Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 67160900001
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 23:29:03 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p3T3T1mX003792
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 20:29:01 -0700
Received: from qwc23 (qwc23.prod.google.com [10.241.193.151])
	by kpbe14.cbf.corp.google.com with ESMTP id p3T3StDQ018524
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 20:28:59 -0700
Received: by qwc23 with SMTP id 23so2333905qwc.17
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 20:28:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTimum+TkOxGcqQYfaYEVN+U5oLQqhA@mail.gmail.com>
References: <1304030226-19332-1-git-send-email-yinghan@google.com>
	<1304030226-19332-3-git-send-email-yinghan@google.com>
	<BANLkTimP_0-ErmnGUnJPVjYRG=fcRN8eOA@mail.gmail.com>
	<BANLkTimum+TkOxGcqQYfaYEVN+U5oLQqhA@mail.gmail.com>
Date: Thu, 28 Apr 2011 20:28:54 -0700
Message-ID: <BANLkTik-kyPO_UFoMu=WcjRoBvA0NiCikg@mail.gmail.com>
Subject: Re: [PATCH 2/2] Add stats to monitor soft_limit reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, Apr 28, 2011 at 4:51 PM, Hiroyuki Kamezawa
<kamezawa.hiroyuki@gmail.com> wrote:
> 2011/4/29 Ying Han <yinghan@google.com>:
>> On Thu, Apr 28, 2011 at 3:37 PM, Ying Han <yinghan@google.com> wrote:
>>> This patch extend the soft_limit reclaim stats to both global backgroun=
d
>>> reclaim and global direct reclaim.
>>>
>>> We have a thread discussing the naming of some of the stats. Both
>>> KAMEZAWA and Johannes posted the proposals. The following stats are bas=
ed
>>> on what i had before that thread. I will make the corresponding change =
on
>>> the next post when we make decision.
>>>
>>> $cat /dev/cgroup/memory/A/memory.stat
>>> kswapd_soft_steal 1053626
>>> kswapd_soft_scan 1053693
>>> direct_soft_steal 1481810
>>> direct_soft_scan 1481996
>>>
>>> Signed-off-by: Ying Han <yinghan@google.com>
>>> ---
>>> =A0Documentation/cgroups/memory.txt | =A0 10 ++++-
>>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 68 ++++++++=
++++++++++++++++++++----------
>>> =A02 files changed, 58 insertions(+), 20 deletions(-)
>>>
>>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/m=
emory.txt
>>> index 0c40dab..fedc107 100644
>>> --- a/Documentation/cgroups/memory.txt
>>> +++ b/Documentation/cgroups/memory.txt
>>> @@ -387,8 +387,14 @@ pgpgout =A0 =A0 =A0 =A0 =A0 =A0- # of pages paged =
out (equivalent to # of uncharging events).
>>> =A0swap =A0 =A0 =A0 =A0 =A0 - # of bytes of swap usage
>>> =A0pgfault =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- # of page faults.
>>> =A0pgmajfault =A0 =A0 - # of major page faults.
>>> -soft_steal =A0 =A0 - # of pages reclaimed from global hierarchical rec=
laim
>>> -soft_scan =A0 =A0 =A0- # of pages scanned from global hierarchical rec=
laim
>>> +soft_kswapd_steal- # of pages reclaimed in global hierarchical reclaim=
 from
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 background reclaim
>>> +soft_kswapd_scan - # of pages scanned in global hierarchical reclaim f=
rom
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 background reclaim
>>> +soft_direct_steal- # of pages reclaimed in global hierarchical reclaim=
 from
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 direct reclaim
>>> +soft_direct_scan- # of pages scanned in global hierarchical reclaim fr=
om
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 direct reclaim
>
> Thank you for CC.
>
> I don't have strong opinion but once we add interfaces to mainline,
> it's hard to rename them. So, it's better to make a list of what name
> we'll need in future.
>
> Now, your naming has a format as [Reason]-[Who reclaim]-[What count?]
> soft_kswapd_steal
> soft_kswapd_scan
> soft_direct_steal
> soft_direct_scan
>
> Ok, we can make a name for wmark and limit reclaim as
>
> limit_direct_steal/scan
> wmark_bg_steal/scan
>
> Then, assume we finally do round-robin scan of memcg regardless of softli=
mit by
> removing global LRU, what name do we have ? Hmm,
>
> kernel_kswapd_scan/steal
> kernel_direct_scan/steal
>
> ?

Johannes has the proposal to separate out reclaims on the memcg
internally and externally. And then apply the format
[Reason]-[Who reclaim]-[What count?], also i added the 4th item .

1. when the memcg hits its hard_limit
> limit_direct_steal
> limit_direct_scan

2. when the memcg hits its wmark
> wmark_kswapd_steal
> wmark_kswapd_scan

3. the global direct reclaim triggers soft_limit pushback
> soft_direct_steal
> soft_direct_scan

4. hierarchy-triggered direct reclaim
> limit_hierarchy_steal
> limit_hierarchy_scan

5. the global bg reclaim triggers soft_limit pushback
> soft_kswapd_steal
> soft_kswapd_scan

For both soft_limit reclaim and per-memcg bg reclaim, we don't have
hierarchical reclaim. Only hitting the hard_limit of parent will
trigger direct reclaim hierarchically on the children.


> BTW, your changelog has different name of counters. please fix.

sure, will fix that.

>
> And I'm sorry I'll not be very active for a while.
np.

--Ying

>
> Thanks,
> -Kame
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

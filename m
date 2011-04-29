Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B6D6E900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 15:12:44 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p3TJCfBK025968
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 12:12:41 -0700
Received: from qyj19 (qyj19.prod.google.com [10.241.83.83])
	by hpaq11.eem.corp.google.com with ESMTP id p3TJCYex009990
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 12:12:40 -0700
Received: by qyj19 with SMTP id 19so414486qyj.9
        for <linux-mm@kvack.org>; Fri, 29 Apr 2011 12:12:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110429103038.GL6547@balbir.in.ibm.com>
References: <1304030226-19332-1-git-send-email-yinghan@google.com>
	<1304030226-19332-3-git-send-email-yinghan@google.com>
	<BANLkTimP_0-ErmnGUnJPVjYRG=fcRN8eOA@mail.gmail.com>
	<BANLkTimum+TkOxGcqQYfaYEVN+U5oLQqhA@mail.gmail.com>
	<BANLkTik-kyPO_UFoMu=WcjRoBvA0NiCikg@mail.gmail.com>
	<20110429103038.GL6547@balbir.in.ibm.com>
Date: Fri, 29 Apr 2011 12:12:33 -0700
Message-ID: <BANLkTinbBfE+1dDrti1b-K9_=mM_6OTS-w@mail.gmail.com>
Subject: Re: [PATCH 2/2] Add stats to monitor soft_limit reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Fri, Apr 29, 2011 at 3:30 AM, Balbir Singh <balbir@linux.vnet.ibm.com> w=
rote:
> * Ying Han <yinghan@google.com> [2011-04-28 20:28:54]:
>
>> On Thu, Apr 28, 2011 at 4:51 PM, Hiroyuki Kamezawa
>> <kamezawa.hiroyuki@gmail.com> wrote:
>> > 2011/4/29 Ying Han <yinghan@google.com>:
>> >> On Thu, Apr 28, 2011 at 3:37 PM, Ying Han <yinghan@google.com> wrote:
>> >>> This patch extend the soft_limit reclaim stats to both global backgr=
ound
>> >>> reclaim and global direct reclaim.
>> >>>
>> >>> We have a thread discussing the naming of some of the stats. Both
>> >>> KAMEZAWA and Johannes posted the proposals. The following stats are =
based
>> >>> on what i had before that thread. I will make the corresponding chan=
ge on
>> >>> the next post when we make decision.
>> >>>
>> >>> $cat /dev/cgroup/memory/A/memory.stat
>> >>> kswapd_soft_steal 1053626
>> >>> kswapd_soft_scan 1053693
>> >>> direct_soft_steal 1481810
>> >>> direct_soft_scan 1481996
>> >>>
>> >>> Signed-off-by: Ying Han <yinghan@google.com>
>> >>> ---
>> >>> =A0Documentation/cgroups/memory.txt | =A0 10 ++++-
>> >>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 68 +++++=
+++++++++++++++++++++++----------
>> >>> =A02 files changed, 58 insertions(+), 20 deletions(-)
>> >>>
>> >>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroup=
s/memory.txt
>> >>> index 0c40dab..fedc107 100644
>> >>> --- a/Documentation/cgroups/memory.txt
>> >>> +++ b/Documentation/cgroups/memory.txt
>> >>> @@ -387,8 +387,14 @@ pgpgout =A0 =A0 =A0 =A0 =A0 =A0- # of pages pag=
ed out (equivalent to # of uncharging events).
>> >>> =A0swap =A0 =A0 =A0 =A0 =A0 - # of bytes of swap usage
>> >>> =A0pgfault =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- # of page faults.
>> >>> =A0pgmajfault =A0 =A0 - # of major page faults.
>> >>> -soft_steal =A0 =A0 - # of pages reclaimed from global hierarchical =
reclaim
>> >>> -soft_scan =A0 =A0 =A0- # of pages scanned from global hierarchical =
reclaim
>> >>> +soft_kswapd_steal- # of pages reclaimed in global hierarchical recl=
aim from
>> >>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 background reclaim
>> >>> +soft_kswapd_scan - # of pages scanned in global hierarchical reclai=
m from
>> >>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 background reclaim
>> >>> +soft_direct_steal- # of pages reclaimed in global hierarchical recl=
aim from
>> >>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 direct reclaim
>> >>> +soft_direct_scan- # of pages scanned in global hierarchical reclaim=
 from
>> >>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 direct reclaim
>> >
>> > Thank you for CC.
>> >
>> > I don't have strong opinion but once we add interfaces to mainline,
>> > it's hard to rename them. So, it's better to make a list of what name
>> > we'll need in future.
>> >
>> > Now, your naming has a format as [Reason]-[Who reclaim]-[What count?]
>> > soft_kswapd_steal
>> > soft_kswapd_scan
>> > soft_direct_steal
>> > soft_direct_scan
>> >
>> > Ok, we can make a name for wmark and limit reclaim as
>> >
>> > limit_direct_steal/scan
>> > wmark_bg_steal/scan
>> >
>> > Then, assume we finally do round-robin scan of memcg regardless of sof=
tlimit by
>> > removing global LRU, what name do we have ? Hmm,
>> >
>> > kernel_kswapd_scan/steal
>> > kernel_direct_scan/steal
>> >
>> > ?
>>
>> Johannes has the proposal to separate out reclaims on the memcg
>> internally and externally. And then apply the format
>> [Reason]-[Who reclaim]-[What count?], also i added the 4th item .
>>
>> 1. when the memcg hits its hard_limit
>> > limit_direct_steal
>> > limit_direct_scan
>>
>> 2. when the memcg hits its wmark
>> > wmark_kswapd_steal
>> > wmark_kswapd_scan
>>
>> 3. the global direct reclaim triggers soft_limit pushback
>> > soft_direct_steal
>> > soft_direct_scan
>>
>> 4. hierarchy-triggered direct reclaim
>> > limit_hierarchy_steal
>> > limit_hierarchy_scan
>>
>> 5. the global bg reclaim triggers soft_limit pushback
>> > soft_kswapd_steal
>> > soft_kswapd_scan
>>
>
> I like these names, but these are more developer friendly than end
> user friendly.

Thank you for reviewing. One thing that I can think of to help is
better documentation. :)

--Ying

Thank you
>
> --
> =A0 =A0 =A0 =A0Three Cheers,
> =A0 =A0 =A0 =A0Balbir
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

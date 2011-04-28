Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BAC456B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 00:24:35 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p3S4OWTF002384
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 21:24:32 -0700
Received: from qyl38 (qyl38.prod.google.com [10.241.83.230])
	by kpbe13.cbf.corp.google.com with ESMTP id p3S4NqNv006598
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 21:24:30 -0700
Received: by qyl38 with SMTP id 38so1967776qyl.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 21:24:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110428125739.15e252a7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110428121643.b3cbf420.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimywCF06gfKWFcbAsWtFUbs73rZrQ@mail.gmail.com>
	<20110428125739.15e252a7.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 27 Apr 2011 21:24:30 -0700
Message-ID: <BANLkTikgJWYJ8_rAkuNtD0vTehCG7vPpow@mail.gmail.com>
Subject: Re: Fw: [PATCH] memcg: add reclaim statistics accounting
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Apr 27, 2011 at 8:57 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 27 Apr 2011 20:43:58 -0700
> Ying Han <yinghan@google.com> wrote:
>
>> On Wed, Apr 27, 2011 at 8:16 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > sorry, I had wrong TO:...
>> >
>> > Begin forwarded message:
>> >
>> > Date: Thu, 28 Apr 2011 12:02:34 +0900
>> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > To: linux-mm@vger.kernel.org
>> > Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ni=
shimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vne=
t.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, "akp=
m@linux-foundation.org" <akpm@linux-foundation.org>
>> > Subject: [PATCH] memcg: add reclaim statistics accounting
>> >
>> >
>> >
>> > Now, memory cgroup provides poor reclaim statistics per memcg. This
>> > patch adds statistics for direct/soft reclaim as the number of
>> > pages scans, the number of page freed by reclaim, the nanoseconds of
>> > latency at reclaim.
>> >
>> > It's good to add statistics before we modify memcg/global reclaim, lar=
gely.
>> > This patch refactors current soft limit status and add an unified upda=
te logic.
>> >
>> > For example, After #cat 195Mfile > /dev/null under 100M limit.
>> > =A0 =A0 =A0 =A0# cat /cgroup/memory/A/memory.stat
>> > =A0 =A0 =A0 =A0....
>> > =A0 =A0 =A0 =A0limit_freed 24592
>>
>> why not "limit_steal" ?
>>
>
> It's not "stealed". Freed by itself.
> pages reclaimed by soft-limit is stealed because of global memory pressur=
e.
> I don't like the name "steal" but I can't change it because of API breaka=
ge.
>
>
>> > =A0 =A0 =A0 =A0soft_steal 0
>> > =A0 =A0 =A0 =A0limit_scan 43974
>> > =A0 =A0 =A0 =A0soft_scan 0
>> > =A0 =A0 =A0 =A0limit_latency 133837417
>> >
>> > nearly 96M caches are freed. scanned twice. used 133ms.
>>
>> Does it make sense to split up the soft_steal/scan for bg reclaim and
>> direct reclaim?
>
> Please clarify what you're talking about before asking. Maybe you want to=
 say
> "I'm now working for supporting softlimit in direct reclaim path. So, doe=
s
> =A0it make sense to account direct/kswapd works in statistics ?"
>
> I think bg/direct reclaim is not required to be splitted.

Ok, thanks for the clarification. The patch i am working now to be
more specific is to add the
soft_limit hierarchical reclaim on the global direct reclaim.

I am adding similar stats to monitor the soft_steal, but i split-off
the soft_steal from global direct reclaim and
global background reclaim. I am wondering isn't that give us more
visibility of the reclaim path?

>
>> The same for the limit_steal/scan.
>
> limit has only direct reclaim, now. And this is independent from any
> soft limit works.

agree.

>
>> I am now testing
>> the patch to add the soft_limit reclaim on global ttfp, and i already
>> have the patch to add the following:
>>
>> kswapd_soft_steal 0
>> kswapd_soft_scan 0
>
> please don't change the name of _used_ statisitcs.

good point. thanks

>
>
>> direct_soft_steal 0
>> direct_soft_scan 0
>
> Maybe these are new ones added by your work. But should be merged to
> soft_steal/soft_scan.
the same question above, why we don't want to have better visibility
of where we triggered
the soft_limit reclaim and how much has been done on behalf of each.

>
>> kswapd_steal 0
>> pg_pgsteal 0
>> kswapd_pgscan 0
>> pg_scan 0
>>
>
> Maybe this indicates reclaimed-by-other-tasks-than-this-memcg. Right ?
> Maybe good for checking isolation of memcg, hmm, can these be accounted
> in scalable way ?

you can ignore those four stats. They are part of the per-memcg-kswapd
patchset, and i guess you might
have similar patch for that purpose.

>
> BTW, my office will be closed for a week because of holidays. So, I'll no=
t make
> responce tomorrow. please CC kamezawa.hiroyuki@gmail.com if you need.
> I may read e-mails.

Thanks for the heads up ~

--Ying

>
> Thanks,
> -Kame
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

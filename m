Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 68A996B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 00:40:12 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p3S4e8Gv032495
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 21:40:10 -0700
Received: from qwf7 (qwf7.prod.google.com [10.241.194.71])
	by hpaq2.eem.corp.google.com with ESMTP id p3S4dfxk029980
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 21:40:07 -0700
Received: by qwf7 with SMTP id 7so1248564qwf.38
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 21:40:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110428132757.130b4206.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110428121643.b3cbf420.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimywCF06gfKWFcbAsWtFUbs73rZrQ@mail.gmail.com>
	<20110428125739.15e252a7.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikgJWYJ8_rAkuNtD0vTehCG7vPpow@mail.gmail.com>
	<20110428132757.130b4206.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 27 Apr 2011 21:40:06 -0700
Message-ID: <BANLkTinicqanpcVHtAWsgQxu1gkbzVpXdg@mail.gmail.com>
Subject: Re: Fw: [PATCH] memcg: add reclaim statistics accounting
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Apr 27, 2011 at 9:27 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 27 Apr 2011 21:24:30 -0700
> Ying Han <yinghan@google.com> wrote:
>
>> On Wed, Apr 27, 2011 at 8:57 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Wed, 27 Apr 2011 20:43:58 -0700
>> > Ying Han <yinghan@google.com> wrote:
>> >
>>
>> >> Does it make sense to split up the soft_steal/scan for bg reclaim and
>> >> direct reclaim?
>> >
>> > Please clarify what you're talking about before asking. Maybe you want=
 to say
>> > "I'm now working for supporting softlimit in direct reclaim path. So, =
does
>> > =A0it make sense to account direct/kswapd works in statistics ?"
>> >
>> > I think bg/direct reclaim is not required to be splitted.
>>
>> Ok, thanks for the clarification. The patch i am working now to be
>> more specific is to add the
>> soft_limit hierarchical reclaim on the global direct reclaim.
>>
>> I am adding similar stats to monitor the soft_steal, but i split-off
>> the soft_steal from global direct reclaim and
>> global background reclaim. I am wondering isn't that give us more
>> visibility of the reclaim path?
>>
>
> Hmm, if kswapd and direc-reclaim uses the same logic, I don't care which
> steals memory. But i'm not sure you implementation before seeing patch.
> So, please let me postphone answering this. But, considering again,
> /proc/vmstat has
> =3D=3D
> pgscan_kswapd_dma 0
> pgscan_kswapd_dma32 0
> pgscan_kswapd_normal 0
> pgscan_kswapd_movable 0
> pgscan_direct_dma 0
> pgscan_direct_dma32 0
> pgscan_direct_normal 0
> pgscan_direct_movable 0
> =3D=3D
>
> maybe it's ok to have split stats.
>
>
> BTW, ff I add more statistics, I'll add per-node statistics.
> Hmm, memory.node_stat is required ?

Yes and this will be useful. One of the stats I would like add now is
the number of pages allocated on behalf of the memcg per numa node.
This is a piece of useful information to evaluate the numa locality
correlated to the application
performance.

I was wondering where to add the stats and memory.stat seems not to be
the best fit. If we have memory.node_stat, that would be a good place
for those kind of info?

--Ying

>
>
>> >
>> >
>> >> direct_soft_steal 0
>> >> direct_soft_scan 0
>> >
>> > Maybe these are new ones added by your work. But should be merged to
>> > soft_steal/soft_scan.
>> the same question above, why we don't want to have better visibility
>> of where we triggered
>> the soft_limit reclaim and how much has been done on behalf of each.
>>
> Maybe I answerd this.
>
>
>
>> >
>> >> kswapd_steal 0
>> >> pg_pgsteal 0
>> >> kswapd_pgscan 0
>> >> pg_scan 0
>> >>
>> >
>> > Maybe this indicates reclaimed-by-other-tasks-than-this-memcg. Right ?
>> > Maybe good for checking isolation of memcg, hmm, can these be accounte=
d
>> > in scalable way ?
>>
>> you can ignore those four stats. They are part of the per-memcg-kswapd
>> patchset, and i guess you might
>> have similar patch for that purpose.
>>
> Ah, I named them as wmark_scan/wmark_steal for avoiding confusion.
>
>
> Thanks,
> -Kame
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

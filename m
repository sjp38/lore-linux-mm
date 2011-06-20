Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E13816B007E
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 02:59:17 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p5K6xFWB014419
	for <linux-mm@kvack.org>; Sun, 19 Jun 2011 23:59:15 -0700
Received: from qyk9 (qyk9.prod.google.com [10.241.83.137])
	by kpbe15.cbf.corp.google.com with ESMTP id p5K6xDnY032636
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 19 Jun 2011 23:59:13 -0700
Received: by qyk9 with SMTP id 9so1053361qyk.3
        for <linux-mm@kvack.org>; Sun, 19 Jun 2011 23:59:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110620130227.6202e8f6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110616125314.4f78b1e0.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimYEr9k3Sk5JoaRrrQH4mGoTmL1Wf5gadYVGDuNpxofHw@mail.gmail.com>
	<20110620084123.c63d3e12.kamezawa.hiroyu@jp.fujitsu.com>
	<20110620130227.6202e8f6.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sun, 19 Jun 2011 23:59:13 -0700
Message-ID: <BANLkTi=LH_wgwFMVqp_zEAvdrsBWHoY7-g@mail.gmail.com>
Subject: Re: [PATCH 3/7] memcg: add memory.scan_stat
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Andrew Bresticker <abrestic@google.com>

On Sunday, June 19, 2011, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 20 Jun 2011 08:41:23 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> On Fri, 17 Jun 2011 15:04:18 -0700
>> Ying Han <yinghan@google.com> wrote:
>>
>> > On Wed, Jun 15, 2011 at 8:53 PM, KAMEZAWA Hiroyuki
>> > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > > From e08990dd9ada13cf236bec1ef44b207436434b8e Mon Sep 17 00:00:00 20=
01
>> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > > Date: Wed, 15 Jun 2011 14:11:01 +0900
>> > > Subject: [PATCH 3/7] memcg: add memory.scan_stat
>> > >
>> > > commit log of commit 0ae5e89 " memcg: count the soft_limit reclaim i=
n..."
>> > > says it adds scanning stats to memory.stat file. But it doesn't beca=
use
>> > > we considered we needed to make a concensus for such new APIs.
>> > >
>> > > This patch is a trial to add memory.scan_stat. This shows
>> > > =A0- the number of scanned pages
>> > > =A0- the number of recleimed pages
>> > > =A0- the number of elaplsed time (including sleep/pause time)
>> > > =A0for both of direct/soft reclaim and shrinking caused by changing =
limit
>> > > =A0or force_empty.
>> > >
>> > > The biggest difference with oringinal Ying's one is that this file
>> > > can be reset by some write, as
>> > >
>> > > =A0# echo 0 ...../memory.scan_stat
>> > >
>> > > [kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.scan_stat
>> > > scanned_pages_by_limit 358470
>> > > freed_pages_by_limit 180795
>> > > elapsed_ns_by_limit 21629927
>> > > scanned_pages_by_system 0
>> > > freed_pages_by_system 0
>> > > elapsed_ns_by_system 0
>> > > scanned_pages_by_shrink 76646
>> > > freed_pages_by_shrink 38355
>> > > elappsed_ns_by_shrink 31990670
>> > > total_scanned_pages_by_limit 358470
>> > > total_freed_pages_by_limit 180795
>> > > total_elapsed_ns_by_hierarchical 216299275
>> > > total_scanned_pages_by_system 0
>> > > total_freed_pages_by_system 0
>> > > total_elapsed_ns_by_system 0
>> > > total_scanned_pages_by_shrink 76646
>> > > total_freed_pages_by_shrink 38355
>> > > total_elapsed_ns_by_shrink 31990670
>> > >
>> > > total_xxxx is for hierarchy management.
>> > >
>> > > This will be useful for further memcg developments and need to be
>> > > developped before we do some complicated rework on LRU/softlimit
>> > > management.
>> >
>> > Agreed. Actually we are also looking into adding a per-memcg API for
>> > adding visibility of
>> > page reclaim path. It would be helpful for us to settle w/ the API fir=
st.
>> >
>> > I am not a fan of names, but how about
>> > "/dev/cgroup/memory/memory.reclaim_stat" ?
>> >
>>
>> Hm, ok, I have no favorite.
>>
>>
>
> If I rename, I'll just rename file name as "reclaim_stat" but doesn't
> rename internal structures because there is already "struct reclaim_stat"=
.
>
> Hm, to be honest, I don't like the name "reclaim_stat".
> (Because in most case, the pages are not freed for reclaim, but for
> =A0hitting limit.)
>
> memory.vmscan_info ?

No objection on the name. I will look into the other part of the patch

Thanks

--ying
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

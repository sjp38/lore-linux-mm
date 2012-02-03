Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id B17F06B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 15:16:00 -0500 (EST)
Received: by qcsd16 with SMTP id d16so2741265qcs.14
        for <linux-mm@kvack.org>; Fri, 03 Feb 2012 12:15:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120203161140.GC13461@tiehlicka.suse.cz>
References: <1328233033-14246-1-git-send-email-yinghan@google.com>
	<20120203161140.GC13461@tiehlicka.suse.cz>
Date: Fri, 3 Feb 2012 12:15:59 -0800
Message-ID: <CALWz4iz48O2TcGOFaGw1_FyhzJ_7njgZ_p8cELcpDJuuKa=Gxg@mail.gmail.com>
Subject: Re: [PATCH] memcg: fix up documentation on global LRU.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Fri, Feb 3, 2012 at 8:11 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Thu 02-02-12 17:37:13, Ying Han wrote:
>> In v3.3-rc1, the global LRU has been removed with commit
>> "mm: make per-memcg LRU lists exclusive". The patch fixes up the memcg d=
ocs.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>
> For the global LRU removal
> Acked-by: Michal Hocko <mhocko@suse.cz>
>
> see the comment about the swap extension bellow.
>
> Thanks
>
>> ---
>> =A0Documentation/cgroups/memory.txt | =A0 25 ++++++++++++-------------
>> =A01 files changed, 12 insertions(+), 13 deletions(-)
>>
>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/me=
mory.txt
>> index 4c95c00..847a2a4 100644
>> --- a/Documentation/cgroups/memory.txt
>> +++ b/Documentation/cgroups/memory.txt
> [...]
>> @@ -209,19 +208,19 @@ In this case, setting memsw.limit_in_bytes=3D3G wi=
ll prevent bad use of swap.
>> =A0By using memsw limit, you can avoid system OOM which can be caused by=
 swap
>> =A0shortage.
>>
>> -* why 'memory+swap' rather than swap.
>> -The global LRU(kswapd) can swap out arbitrary pages. Swap-out means
>> -to move account from memory to swap...there is no change in usage of
>> -memory+swap. In other words, when we want to limit the usage of swap wi=
thout
>> -affecting global LRU, memory+swap limit is better than just limiting sw=
ap from
>> -OS point of view.
>> -
>> =A0* What happens when a cgroup hits memory.memsw.limit_in_bytes
>> =A0When a cgroup hits memory.memsw.limit_in_bytes, it's useless to do sw=
ap-out
>> =A0in this cgroup. Then, swap-out will not be done by cgroup routine and=
 file
>> -caches are dropped. But as mentioned above, global LRU can do swapout m=
emory
>> -from it for sanity of the system's memory management state. You can't f=
orbid
>> -it by cgroup.
>> +caches are dropped.
>> +
>> +TODO:
>> +* use 'memory+swap' rather than swap was due to existence of global LRU=
.

I wasn't sure about the initial comment while making the patch. Since
it mentions something about global LRU, which i figured we need to
revisit it anyway.

> Not really. It also helped inter-cgroup behavior. Consider an (anon) mem
> hog which goes wild. You could end up with a full swap until it gets
> killed which might be quite some time. With the swap extension, on the
> other hand, you are able to stop it before it does too much damage.

First of all, let me understand what are we comparing here. Is this
comment about to compare 'memory+swap' vs 'memory' + 'swap', the later
one is setting swap as separate limit ?

If so, here was my interpretation of the initial comment: due to the
existence of global LRU, random pages will be shoot down to swap from
any memcg, which in turn change the 'memory' and 'swap' at the same
time. While keeping 'memory+swap' per-memcg remains no change while
that happens.

Am I understanding it correctly? btw: I was warned that putting
separate limit on swap doesn't make much sense.

Thank you

--Ying






>
>
> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

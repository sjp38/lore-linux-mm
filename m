Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id AC8566B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 15:03:39 -0500 (EST)
Received: by qauh8 with SMTP id h8so2844621qau.14
        for <linux-mm@kvack.org>; Fri, 03 Feb 2012 12:03:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120203113822.19cf6fd2.kamezawa.hiroyu@jp.fujitsu.com>
References: <1328233033-14246-1-git-send-email-yinghan@google.com>
	<20120203113822.19cf6fd2.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 3 Feb 2012 12:03:38 -0800
Message-ID: <CALWz4ixtGPwDxsd8vnW=ErSh7zaVgO6m=6C7wxk2xmK69QnURQ@mail.gmail.com>
Subject: Re: [PATCH] memcg: fix up documentation on global LRU.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Thu, Feb 2, 2012 at 6:38 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, =A02 Feb 2012 17:37:13 -0800
> Ying Han <yinghan@google.com> wrote:
>
>> In v3.3-rc1, the global LRU has been removed with commit
>> "mm: make per-memcg LRU lists exclusive". The patch fixes up the memcg d=
ocs.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>> =A0Documentation/cgroups/memory.txt | =A0 25 ++++++++++++-------------
>> =A01 files changed, 12 insertions(+), 13 deletions(-)
>>
>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/me=
mory.txt
>> index 4c95c00..847a2a4 100644
>> --- a/Documentation/cgroups/memory.txt
>> +++ b/Documentation/cgroups/memory.txt
>> @@ -34,8 +34,7 @@ Current Status: linux-2.6.34-mmotm(development version=
 of 2010/April)
>>
>> =A0Features:
>> =A0 - accounting anonymous pages, file caches, swap caches usage and lim=
iting them.
>> - - private LRU and reclaim routine. (system's global LRU and private LR=
U
>> - =A0 work independently from each other)
>> + - pages are linked to per-memcg LRU exclusively, and there is no globa=
l LRU.
>> =A0 - optionally, memory+swap usage can be accounted and limited.
>> =A0 - hierarchical accounting
>> =A0 - soft limit
>> @@ -154,7 +153,7 @@ updated. page_cgroup has its own LRU on cgroup.
>> =A02.2.1 Accounting details
>>
>> =A0All mapped anon pages (RSS) and cache pages (Page Cache) are accounte=
d.
>> -Some pages which are never reclaimable and will not be on the global LR=
U
>> +Some pages which are never reclaimable and will not be on the LRU
>> =A0are not accounted. We just account pages under usual VM management.
>>
>> =A0RSS pages are accounted at page_fault unless they've already been acc=
ounted
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
. It can
>> +swap out arbitrary pages. Swap-out means to move account from memory to=
 swap...
>> +there is no change in usage of memory+swap. In other words, when we wan=
t to
>> +limit the usage of swap without affecting global LRU, memory+swap limit=
 is
>> +better than just limiting swap from OS point of view. However, the glob=
al LRU
>> +has been removed now and all pages are linked in private LRU. We might =
want to
>> +revisit this in the future.
>>
>
> Could you devide this memory+swap discussion to otehr patch ?

yes, will do that.

>
> Do you want to do memory locking by setting swap_limit=3D0 ?

hmm, not sure what do you mean here?

--Ying
>
> Thanks,
> -Kame
>
>
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

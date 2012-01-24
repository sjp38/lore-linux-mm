Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 7AEE56B004D
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 18:22:10 -0500 (EST)
Received: by qcsg1 with SMTP id g1so1652585qcs.14
        for <linux-mm@kvack.org>; Tue, 24 Jan 2012 15:22:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBC+y3pVAsbCNP+mBm6Lfcx5XpTcg6D-us5J1E+W+_JcAQ@mail.gmail.com>
References: <CAJd=RBBG5X8=vkdRTCZ1bvTaVxPAVun9O+yiX0SM6yDzrxDGDQ@mail.gmail.com>
	<CALWz4iyB0oSMBsfLJYD+xrB7ua9bRg5FD=cw4Sc-EdG1iLynow@mail.gmail.com>
	<CAJd=RBC+y3pVAsbCNP+mBm6Lfcx5XpTcg6D-us5J1E+W+_JcAQ@mail.gmail.com>
Date: Tue, 24 Jan 2012 15:22:09 -0800
Message-ID: <CALWz4iznfeLX1u00bWWf_ziThCrJNAJUQVBRu8Rv9yDsdMmKsQ@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: check mem cgroup over reclaimed
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jan 23, 2012 at 7:45 PM, Hillf Danton <dhillf@gmail.com> wrote:
> Hi all
>
> On Tue, Jan 24, 2012 at 3:04 AM, Ying Han <yinghan@google.com> wrote:
>> On Sun, Jan 22, 2012 at 5:55 PM, Hillf Danton <dhillf@gmail.com> wrote:
>>> To avoid reduction in performance of reclaimee, checking overreclaim is=
 added
>>> after shrinking lru list, when pages are reclaimed from mem cgroup.
>>>
>>> If over reclaim occurs, shrinking remaining lru lists is skipped, and n=
o more
>>> reclaim for reclaim/compaction.
>>>
>>> Signed-off-by: Hillf Danton <dhillf@gmail.com>
>>> ---
>>>
>>> --- a/mm/vmscan.c =A0 =A0 =A0 Mon Jan 23 00:23:10 2012
>>> +++ b/mm/vmscan.c =A0 =A0 =A0 Mon Jan 23 09:57:20 2012
>>> @@ -2086,6 +2086,7 @@ static void shrink_mem_cgroup_zone(int p
>>> =A0 =A0 =A0 =A0unsigned long nr_reclaimed, nr_scanned;
>>> =A0 =A0 =A0 =A0unsigned long nr_to_reclaim =3D sc->nr_to_reclaim;
>>> =A0 =A0 =A0 =A0struct blk_plug plug;
>>> + =A0 =A0 =A0 bool memcg_over_reclaimed =3D false;
>>>
>>> =A0restart:
>>> =A0 =A0 =A0 =A0nr_reclaimed =3D 0;
>>> @@ -2103,6 +2104,11 @@ restart:
>>>
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_recla=
imed +=3D shrink_list(lru, nr_to_scan,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mz, sc, priority);
>>> +
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg_ove=
r_reclaimed =3D !scanning_global_lru(mz)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 && (nr_reclaimed >=3D nr_to_reclaim);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (memcg=
_over_reclaimed)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 goto out;
>>
>> Why we need the change here? Do we have number to demonstrate?
>
> See below please 8-)
>
>>
>>
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
>>> @@ -2116,6 +2122,7 @@ restart:
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (nr_reclaimed >=3D nr_to_reclaim && p=
riority < DEF_PRIORITY)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>>> =A0 =A0 =A0 =A0}
>>> +out:
>>> =A0 =A0 =A0 =A0blk_finish_plug(&plug);
>>> =A0 =A0 =A0 =A0sc->nr_reclaimed +=3D nr_reclaimed;
>>>
>>> @@ -2127,7 +2134,8 @@ restart:
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_active_list(SWAP_CLUSTER_MAX, mz,=
 sc, priority, 0);
>>>
>>> =A0 =A0 =A0 =A0/* reclaim/compaction might need reclaim to continue */
>>> - =A0 =A0 =A0 if (should_continue_reclaim(mz, nr_reclaimed,
>>> + =A0 =A0 =A0 if (!memcg_over_reclaimed &&
>>> + =A0 =A0 =A0 =A0 =A0 should_continue_reclaim(mz, nr_reclaimed,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0sc->nr_scanned - nr_scanned, sc))
>>
>> This changes the existing logic. What if the nr_reclaimed is greater
>> than nr_to_reclaim, but smaller than pages_for_compaction? The
>> existing logic is to continue reclaiming.
>>
> With soft limit available, what if nr_to_reclaim set to be the number of
> pages exceeding soft limit? With over reclaim abused, what are the target=
s
> of soft limit?

The nr_to_reclaim is set to SWAP_CLUSTER_MAX (32) for direct reclaim
and ULONG_MAX for background reclaim. Not sure we can set it, but it
is possible the res_counter_soft_limit_excess equal to that target
value. The current soft limit mechanism provides a clue of WHERE to
reclaim pages when there is memory pressure, it doesn't change the
reclaim target as it was before.

Overreclaim a cgroup under its softlimit is bad, but we should be
careful not introducing side effect before providing the guarantee.
Here, the should_continue_reclaim() has logic of freeing a bit more
order-0 pages for compaction. The logic got changed after this.

--Ying


> Thanks
> Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

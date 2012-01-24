Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 1C6AE6B004F
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 22:45:54 -0500 (EST)
Received: by wera13 with SMTP id a13so1318939wer.14
        for <linux-mm@kvack.org>; Mon, 23 Jan 2012 19:45:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALWz4iyB0oSMBsfLJYD+xrB7ua9bRg5FD=cw4Sc-EdG1iLynow@mail.gmail.com>
References: <CAJd=RBBG5X8=vkdRTCZ1bvTaVxPAVun9O+yiX0SM6yDzrxDGDQ@mail.gmail.com>
	<CALWz4iyB0oSMBsfLJYD+xrB7ua9bRg5FD=cw4Sc-EdG1iLynow@mail.gmail.com>
Date: Tue, 24 Jan 2012 11:45:52 +0800
Message-ID: <CAJd=RBC+y3pVAsbCNP+mBm6Lfcx5XpTcg6D-us5J1E+W+_JcAQ@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: check mem cgroup over reclaimed
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi all

On Tue, Jan 24, 2012 at 3:04 AM, Ying Han <yinghan@google.com> wrote:
> On Sun, Jan 22, 2012 at 5:55 PM, Hillf Danton <dhillf@gmail.com> wrote:
>> To avoid reduction in performance of reclaimee, checking overreclaim is =
added
>> after shrinking lru list, when pages are reclaimed from mem cgroup.
>>
>> If over reclaim occurs, shrinking remaining lru lists is skipped, and no=
 more
>> reclaim for reclaim/compaction.
>>
>> Signed-off-by: Hillf Danton <dhillf@gmail.com>
>> ---
>>
>> --- a/mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 Mon Jan 23 00:23:10 2012
>> +++ b/mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 Mon Jan 23 09:57:20 2012
>> @@ -2086,6 +2086,7 @@ static void shrink_mem_cgroup_zone(int p
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_reclaimed, nr_scanned;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_to_reclaim =3D sc->nr_to_rec=
laim;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct blk_plug plug;
>> + =C2=A0 =C2=A0 =C2=A0 bool memcg_over_reclaimed =3D false;
>>
>> =C2=A0restart:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0nr_reclaimed =3D 0;
>> @@ -2103,6 +2104,11 @@ restart:
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nr_reclaimed +=3D shrink_list(lru,=
 nr_to_scan,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mz, sc, p=
riority);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg_over_reclaimed =3D !scanning_globa=
l_lru(mz)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 && (nr_recla=
imed >=3D nr_to_reclaim);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (memcg_over_reclaimed)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
>
> Why we need the change here? Do we have number to demonstrate?

See below please 8-)

>
>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0}
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
>> @@ -2116,6 +2122,7 @@ restart:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (nr_reclaimed =
>=3D nr_to_reclaim && priority < DEF_PRIORITY)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0break;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> +out:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0blk_finish_plug(&plug);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0sc->nr_reclaimed +=3D nr_reclaimed;
>>
>> @@ -2127,7 +2134,8 @@ restart:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0shrink_active_lis=
t(SWAP_CLUSTER_MAX, mz, sc, priority, 0);
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* reclaim/compaction might need reclaim to c=
ontinue */
>> - =C2=A0 =C2=A0 =C2=A0 if (should_continue_reclaim(mz, nr_reclaimed,
>> + =C2=A0 =C2=A0 =C2=A0 if (!memcg_over_reclaimed &&
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 should_continue_reclaim(mz, nr_recl=
aimed,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sc->nr=
_scanned - nr_scanned, sc))
>
> This changes the existing logic. What if the nr_reclaimed is greater
> than nr_to_reclaim, but smaller than pages_for_compaction? The
> existing logic is to continue reclaiming.
>
With soft limit available, what if nr_to_reclaim set to be the number of
pages exceeding soft limit? With over reclaim abused, what are the targets
of soft limit?

Thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

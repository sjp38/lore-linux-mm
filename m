Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CF7D36B0023
	for <linux-mm@kvack.org>; Tue, 24 May 2011 07:24:36 -0400 (EDT)
Received: by pwi12 with SMTP id 12so3882638pwi.14
        for <linux-mm@kvack.org>; Tue, 24 May 2011 04:24:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTimw23VP4yyuDed-KrLEcnfLMMA-fQ@mail.gmail.com>
References: <BANLkTi=NTLn4Lx7EkybuA8-diTVOvMDxBw@mail.gmail.com>
 <BANLkTinEDXHuRUYpYN0d95+fz4+F7ccL4w@mail.gmail.com> <4DD5DC06.6010204@jp.fujitsu.com>
 <BANLkTik=7C5qFZTsPQG4JYY-MEWDTHdc6A@mail.gmail.com> <BANLkTins7qxWVh0bEwtk1Vx+m98N=oYVtw@mail.gmail.com>
 <20110520140856.fdf4d1c8.kamezawa.hiroyu@jp.fujitsu.com> <20110520101120.GC11729@random.random>
 <BANLkTikAFMvpgHR2dopd+Nvjfyw_XT5=LA@mail.gmail.com> <20110520153346.GA1843@barrios-desktop>
 <BANLkTi=X+=Wh1MLs7Fc-v-OMtxAHbcPmxA@mail.gmail.com> <20110520161934.GA2386@barrios-desktop>
 <BANLkTi=4C5YAxwAFWC6dsAPMR3xv6LP1hw@mail.gmail.com> <BANLkTimThVw7-PN6ypBBarqXJa1xxYA_Ow@mail.gmail.com>
 <BANLkTint+Qs+cO+wKUJGytnVY3X1bp+8rQ@mail.gmail.com> <BANLkTinx+oPJFQye7T+RMMGzg9E7m28A=Q@mail.gmail.com>
 <BANLkTik29nkn-DN9ui6XV4sy5Wo2jmeS9w@mail.gmail.com> <BANLkTikQd34QZnQVSn_9f_Mxc8wtJMHY0w@mail.gmail.com>
 <BANLkTi=wVOPSv1BA_mZq9=r14Vu3kUh3_w@mail.gmail.com> <BANLkTimw23VP4yyuDed-KrLEcnfLMMA-fQ@mail.gmail.com>
From: Andrew Lutomirski <luto@mit.edu>
Date: Tue, 24 May 2011 07:24:15 -0400
Message-ID: <BANLkTi=PffB2AmQ4m1XymxhnDUWsEXTwQA@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com

On Mon, May 23, 2011 at 9:34 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Tue, May 24, 2011 at 10:19 AM, Andrew Lutomirski <luto@mit.edu> wrote:
>> On Sun, May 22, 2011 at 7:12 PM, Minchan Kim <minchan.kim@gmail.com> wro=
te:
>>> Could you test below patch based on vanilla 2.6.38.6?
>>> The expect result is that system hang never should happen.
>>> I hope this is last test about hang.
>>>
>>> Thanks.
>>>
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index 292582c..1663d24 100644
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -231,8 +231,11 @@ unsigned long shrink_slab(struct shrink_control *s=
hrink,
>>> =A0 =A0 =A0 if (scanned =3D=3D 0)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 scanned =3D SWAP_CLUSTER_MAX;
>>>
>>> - =A0 =A0 =A0 if (!down_read_trylock(&shrinker_rwsem))
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1; =A0 =A0 =A0 /* Assume we'll be =
able to shrink next time */
>>> + =A0 =A0 =A0 if (!down_read_trylock(&shrinker_rwsem)) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Assume we'll be able to shrink next ti=
me */
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D 1;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>>> + =A0 =A0 =A0 }
>>>
>>> =A0 =A0 =A0 list_for_each_entry(shrinker, &shrinker_list, list) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long long delta;
>>> @@ -286,6 +289,8 @@ unsigned long shrink_slab(struct shrink_control *sh=
rink,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrinker->nr +=3D total_scan;
>>> =A0 =A0 =A0 }
>>> =A0 =A0 =A0 up_read(&shrinker_rwsem);
>>> +out:
>>> + =A0 =A0 =A0 cond_resched();
>>> =A0 =A0 =A0 return ret;
>>> =A0}
>>>
>>> @@ -2331,7 +2336,7 @@ static bool sleeping_prematurely(pg_data_t
>>> *pgdat, int order, long remaining,
>>> =A0 =A0 =A0 =A0* must be balanced
>>> =A0 =A0 =A0 =A0*/
>>> =A0 =A0 =A0 if (order)
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return pgdat_balanced(pgdat, balanced, cl=
asszone_idx);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return !pgdat_balanced(pgdat, balanced, c=
lasszone_idx);
>>> =A0 =A0 =A0 else
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return !all_zones_ok;
>>> =A0}
>>
>> So far with this patch I can't reproduce the hang or the bogus OOM.
>>
>> To be completely clear, I have COMPACTION, MIGRATION, and THP off, I'm
>> running 2.6.38.6, and I have exactly two patches applied. =A0One is the
>> attached patch and the other is a the fpu.ko/aesni_intel.ko merger
>> which I need to get dracut to boot my box.
>>
>> For fun, I also upgraded to 8GB of RAM and it still works.
>>
>
> Hmm. Could you test it with enable thp and 2G RAM?
> Isn't it a original test environment?
> Please don't change test environment. :)

The test that passed last night was an environment (hardware and
config) that I had confirmed earlier as failing without the patch.

I just re-tested my original config (from a backup -- migration,
compaction, and thp "always" are enabled).  I get bogus OOMs but not a
hang.  (I'm running with mem=3D2G right now -- I'll swap the DIMMs back
out later on if you want.)

I attached the bogus OOM (actually several that happened in sequence).
 They look readahead-related.  There was plenty of free swap space.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

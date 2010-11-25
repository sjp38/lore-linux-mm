Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 562C06B0087
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 05:51:12 -0500 (EST)
Received: by iwn4 with SMTP id 4so87665iwn.14
        for <linux-mm@kvack.org>; Thu, 25 Nov 2010 02:51:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101125100428.24920cd3.kamezawa.hiroyu@jp.fujitsu.com>
References: <AANLkTingzd3Pqrip1izfkLm+HCE9jRQL777nu9s3RnLv@mail.gmail.com>
	<20101124094736.3c4ba760.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTimSRJ6GC3=bddNMfnVE3LmMx-9xSY2GX_XNvzCA@mail.gmail.com>
	<20101125100428.24920cd3.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 25 Nov 2010 13:51:06 +0300
Message-ID: <AANLkTinQ_sqpEc=-vcCQvpp98ny5HSDVvqD_R6_YE3-C@mail.gmail.com>
Subject: Re: Question about cgroup hierarchy and reducing memory limit
From: Evgeniy Ivanov <lolkaantimat@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thank you very much for very detailed explanation.

On Thu, Nov 25, 2010 at 4:04 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Thanks.
>
> On Wed, 24 Nov 2010 15:17:38 +0300
> Evgeniy Ivanov <lolkaantimat@gmail.com> wrote:
>> > What kinds of error ? Do you have swap ? What is the kerenel version ?
>>
>> Kernel is 2.6.31-5 from SLES-SP1 (my build, but without extra patches).
>> I have 2 Gb swap and just 40 Mb used. Machine has 3 Gb RAM and no load
>> (neither mem or CPU).
>>
> Hmm, maybe I should see 2.6.32.

Oh, yes. You're right, I took a wrong version, but still my 2.6.31-5
is from Novell. I can use 2.6.32 as well (I see it in packages).

>> Error is "-bash: echo: write error: Device or resource busy", when I
>> write to memory.limit_in_bytes.
>>
> Ok.
>
>> > It's designed to allow "shrink at once" but that means release memory
>> > and do forced-writeback. To release memory, it may have to write back
>> > to swap. If tasks in "A" and "B" are too busy and tocuhes tons of memo=
ry
>> > while shrinking, it may fail.
>>
>> Well, in test I have a process which uses 30M of memory and in loop
>> dirties all pages (just single byte) then sleeps 5 seconds before next
>> iteration.
>>
>> > It may be a regression. Kernel version is important.
>> >
>> > Could you show memory.stat file when you shrink "A" and "B" ?
>> > And what happnes
>> > # sync
>> > # sync
>> > # sync
>> > # reduce memory A
>> > # reduce memory B
>>
>> Sync doesn't help. Here is log just for memory.stat for group I tried to=
 shrink:
>>
>> ivanoe:/cgroups/root# cat C/memory.stat
>> cache 0
>> rss 90222592
>
> Hmm, memcg is filled with 86MB of anon pages....So, all "pageout" in this
> will go swap.
>
>> mapped_file 0
>> pgpgin 1212770
>> pgpgout 1190743
>> inactive_anon 45338624
>> active_anon 44883968
>
> (Off topic) IIUC, this active/inactive ratio has been modified in recent =
kernel.
> =A0 =A0 =A0 =A0 =A0 =A0So, new swapout may do different behavior.
>
>> inactive_file 0
>> active_file 0
>> unevictable 0
>> hierarchical_memory_limit 94371840
>> hierarchical_memsw_limit 9223372036854775807
>> total_cache 0
>> total_rss 90222592
>> total_mapped_file 0
>> total_pgpgin 1212770
>> total_pgpgout 1190743
>> total_inactive_anon 45338624
>> total_active_anon 44883968
>> total_inactive_file 0
>> total_active_file 0
>> total_unevictable 0
>> ivanoe:/cgroups/root# echo 30M > C/memory.limit_in_bytes
>> -bash: echo: write error: Device or resource busy
>> ivanoe:/cgroups/root# echo 30M > C/memory.limit_in_bytes
>> -bash: echo: write error: Device or resource busy
>> ivanoe:/cgroups/root# echo 30M > C/memory.limit_in_bytes
>> -bash: echo: write error: Device or resource busy
>> ivanoe:/cgroups/root# echo 30M > C/memory.limit_in_bytes
>
>
> So, this means reducing limit from 90M->30M and
> failure of 50MB swapout.
>
>> ivanoe:/cgroups/root# cat memory.limit_in_bytes
>> 125829120
>> ivanoe:/cgroups/root# cat B/memory.limit_in_bytes
>> 62914560
>> ivanoe:/cgroups/root# cat A/memory.limit_in_bytes
>> 20971520
>>
>
> Ah....I have to explain this.
>
> =A0(root) limited to 120MB
> =A0(A) =A0 =A0limited to 60MB and this is children of (root)
> =A0(B) =A0 =A0limited to 20MB and this is children of (root)
> =A0(C) =A0 =A0limited to 90MB(now) and this is children of (root)
>
> And now, you want to set limit of (C) to 30MB.
>
> At first, memory cgroup has 2 mode. Do you know memory.use_hierarchy file=
 ?
>
> If memory.use_hierarchy =3D=3D 0, all cgroups under the cgroup are flat.
> In above, if root/memory.use_hierarhy =3D=3D 0, A and B and C and (root) =
are
> all independent from each other.
>
> If memory.use_hierarchy =3D=3D 1, all cgroups under the cgroup are in tre=
e.
> In above, if root/memory.use_hierarchy =3D=3D 1, A and B and C works as c=
hildren
> of (root) and usage of A+B+C is limited by (root).
>
> If you use root/memory.use_hierarchy=3D=3D0, changing limit of C doesn't =
affect to
> (root) and (root/A) and (root/B). All works will be done in C and you can=
 set
> arbitrary limit.
>
> Even if you use root/memory.use_hierarchy=3D=3D1, changing limit of C wil=
l not
> affect to (root) and (root/A) and (root/B). All pageout will be done in C
> but you can't set limit larger than (root).

Thank you for explanation. I use memory.use_hierarchy=3D1, I don't want
all pageout done in C, that's why originally I was trying to change
limits of A and B before adding C (same problem as with changing
limits for C).

>
> (Off topic)If you use root/memory.use_hierarchy=3D=3D1, changing limit of=
 (root)
> will affect (A) and (B) and (C). Then memory are reclaimed from (A) and (=
B)
> and (C) because (root) is parent of (A) and (B) and (C).
>
>
>
> So, in this case, only "C" is the problem.

Kind of, A and B are not good too. I guess it's related to decreasing
memory limit of any group.

> And, at swapout, it may be problem how swap is slow.
>
> The logic of pageout(swapout) at shrinking is:
>
> 0. retry_count=3D5
> 1. usage =3D current_usage
> 2. limit =3D new limit.
> 3. if (usage < limit) =3D> goto end(success)
> 4. try to reclaim memory.
> 5. new_usage =3D current_usage
> 6. if (new_usage >=3D usage) retry_count--
> 7. if (retry_count < 0) goto end(-EBUSY)
>
> So, It depends on workload(swapin) and speed of swapout whether it will s=
uccess.
> It seems pagein in "C" is faster than swapout of shrinking itelation.
>
> So, why you succeed to reduce limit by 1MB is maybe because pagein is blo=
cked
> by hitting memory limit. So, shrink usage can success.

I see, that makes sense.

> To make success rate higher, it seems
> =A01) memory cgroup should do harder retry
> =A0 =A0Difficulty with this is that we have no guarantee.
> or
> =A02) memory cgroup should block pagein.
> =A0 =A0Difficulty with this is tasks may stop too long. (if new limit is =
bad.)

> I may not be able to give you good advise about SLES.
> I'll think about some and write a patch. Thank you for reporting.
> I hope my patch may be able to be backported.

That would be great, thanks!
For now we decided either to use decreasing limits in script with
timeout or controlling the limit just by root group.


--=20
Evgeniy Ivanov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

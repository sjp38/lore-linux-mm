Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C2F096B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 23:02:45 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id j13so14278738iod.6
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 20:02:45 -0800 (PST)
Received: from nm6-vm4.bullet.mail.ne1.yahoo.com (nm6-vm4.bullet.mail.ne1.yahoo.com. [98.138.91.166])
        by mx.google.com with ESMTPS id z69si6932690ioz.60.2017.01.11.20.02.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 20:02:45 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: shrink_inactive_list() failed to reclaim pages
From: Pintu Kumar <pintu_agarwal@yahoo.com>
In-Reply-To: <20170111173802.GK16365@dhcp22.suse.cz>
Date: Thu, 12 Jan 2017 09:32:35 +0530
Content-Transfer-Encoding: quoted-printable
Message-Id: <443501E9-8994-4CA3-ABE9-CA2A6C7B5288@yahoo.com>
References: <CAPJVTTimt2CeiiX868+EY2HbbWmKsG05u7QOBbuTb74f-ZrpPQ@mail.gmail.com> <20170111173802.GK16365@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Cheng-yu Lee <cylee@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Luigi Semenzato <semenzato@google.com>, Ben Cheng <bccheng@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, "minchan@kernel.org" <minchan@kernel.org>, Pintu Kumar <pintu_agarwal@yahoo.com>, Pintu Kumar <pintu.k@samsung.com>

Adding my self

> On 11-Jan-2017, at 11:08 PM, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> [CC Minchan and Sergey for the zram part]
>=20
> On Thu 12-01-17 01:16:11, Cheng-yu Lee wrote:
>> Hi community,
>>=20
>> I have a x86_64 Chromebook running 3.14 kernel with 8G of memory. =
Using
>=20
> Do you see the same with the current Linus tree?
>=20
>> zram with swap size set to ~12GB. When in low memory, kswapd is =
awaken to
>> reclaim pages, but under some circumstances the kernel can not find =
pages
>> to reclaim while I'm sure there're still plenty of memory which could =
be
>> reclaimed from background processes (For example, I run some C =
programs
>> which just malloc() lots of memory and get suspended in the =
background.
>> There's no reason they could't be swapped). The consequence is that =
most of
>> CPU time is spent on page reclamation. The system hangs or becomes =
very
>> laggy for a long period. Sometimes it even triggers a kernel panic by =
the
>> hung task detector like:
>> <0>[46246.676366] Kernel panic - not syncing: hung_task: blocked =
tasks
>>=20
>> I've added kernel message to trace the problem. I found =
shrink_inactive_list()
>> can barely find any page to reclaim. More precisely, when the problem
>> happens, lots of page have _count > 2 in __remove_mapping(). So the
>> condition at line 662 of vmscan.c holds:
>> http://lxr.free-electrons.com/source/mm/vmscan.c#L662
>> Thus the kernel fails to reclaim those pages at line 1209
>> http://lxr.free-electrons.com/source/mm/vmscan.c#L1209
>=20
> I assume that you are talking about the anonymous LRU
>=20
>> It's weird that the inactive anonymous list is huge (several GB), but
>> nothing can really be freed. So I did some hack to see if moving more =
pages
>> from the active list helps. I commented out the =
"inactive_list_is_low()"
>> checking at line 2420
>> in shrink_node_memcg() so shrink_active_list() is always called.
>> http://lxr.free-electrons.com/source/mm/vmscan.c#L2420
>> It turns out that the hack helps. If moving more pages from the =
active
>> list, kswapd works smoothly. The whole 12G zram can be used up before
>> system enters OOM condition.
>>=20
>> Any idea why the whole inactive anonymous LRU is occupied by pages =
which
>> can not be freed for la long time (several minutes before system =
dies) ?
>> Are there any parameters I can tune to help the situation ? I've =
tried
>> swappiness but it doesn't help.
>>=20
>> An alternative is to patch the kernel to call shrink_active_list() =
more
>> frequently when it finds there's nothing that can be reclaimed . But =
I am
>> not sure if it's the right direction. Also it's not so trivial to =
figure
>> out where to add the call.
>>=20
>> Thanks,
>> Cheng-Yu
>=20
> --=20
> Michal Hocko
> SUSE Labs
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

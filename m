Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1A3916B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 14:04:54 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id e2so67097396ybi.0
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 11:04:54 -0700 (PDT)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id r4si16069072qkd.42.2016.09.13.11.04.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 11:04:53 -0700 (PDT)
Received: by mail-qt0-x241.google.com with SMTP id 11so7240788qtc.3
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 11:04:53 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [RFC] scripts: Include postprocessing script for memory allocation tracing
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
In-Reply-To: <20160912121635.GL14524@dhcp22.suse.cz>
Date: Tue, 13 Sep 2016 14:04:49 -0400
Content-Transfer-Encoding: quoted-printable
Message-Id: <0ACE5927-A6E5-4B49-891D-F990527A9F50@gmail.com>
References: <20160911222411.GA2854@janani-Inspiron-3521> <20160912121635.GL14524@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Janani Ravichandran <janani.rvchndrn@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, rostedt@goodmis.org


> On Sep 12, 2016, at 8:16 AM, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> Hi,

Hello Michal,

> I am sorry I didn't follow up on the previous submission.

That=E2=80=99s alright :)

> I find this
> _really_ helpful. It is great that you could build on top of existing
> tracepoints but one thing is not entirely clear to me. Without a begin
> marker in __alloc_pages_nodemask we cannot really tell how long the
> whole allocation took, which would be extremely useful. Or do you use
> any graph tracer tricks to deduce that?

I=E2=80=99m using the function graph tracer to see how long =
__alloc_pages_nodemask()
took.


> There is a note in your
> changelog but I cannot seem to find that in the changelog. And FWIW I
> would be open to adding a tracepoint like that. It would make our life
> so much easier=E2=80=A6

The line
echo __alloc_pages_nodemask > set_ftrace_filter in setup_alloc_trace.sh
sets __alloc_pages_nodemask as a function graph filter and this should =
help
us observe how long the function took.

>=20
> On Sun 11-09-16 18:24:12, Janani Ravichandran wrote:
> [...]
>> allocation_postprocess.py is a script which reads from trace_pipe. It
>> does the following to filter out info from tracepoints that may not
>> be important:
>>=20
>> 1. Displays mm_vmscan_direct_reclaim_begin and
>> mm_vmscan_direct_reclaim_end only when try_to_free_pages has
>> exceeded the threshold.
>> 2. Displays mm_compaction_begin and mm_compaction_end only when
>> compact_zone has exceeded the threshold.
>> 3. Displays mm_compaction_try_to_compat_pages only when
>> try_to_compact_pages has exceeded the threshold.
>> 4. Displays mm_shrink_slab_start and mm_shrink_slab_end only when
>> the time elapsed between them exceeds the threshold.
>> 5. Displays mm_vmscan_lru_shrink_inactive only when =
shrink_inactive_list
>> has exceeded the threshold.
>>=20
>> When CTRL+C is pressed, the script shows the times taken by the
>> shrinkers. However, currently it is not possible to differentiate =
among
>> the
>> superblock shrinkers.
>>=20
>> Sample output:
>> ^Ci915_gem_shrinker_scan : total time =3D 8.731000 ms, max latency =3D
>> 0.278000 ms
>> ext4_es_scan : total time =3D 0.970000 ms, max latency =3D 0.129000 =
ms
>> scan_shadow_nodes : total time =3D 1.150000 ms, max latency =3D =
0.175000 ms
>> super_cache_scan : total time =3D 8.455000 ms, max latency =3D =
0.466000 ms
>> deferred_split_scan : total time =3D 25.767000 ms, max latency =3D =
25.485000
>> ms
>=20
> Would it be possible to group those per the context?

Absolutely!
> I mean a single
> allocation/per-process drop down values rather than mixing all those
> values together? For example if I see that a process is talling due to
> direct reclaim I would love to see what is the worst case allocation
> stall and what is the most probable source of that stall. Mixing =
kswapd
> traces would be misleading here.
>=20

True. I=E2=80=99ll do that and send a v2. Thanks for the suggestions!

Janani
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

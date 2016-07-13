Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id E119C6B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 02:17:04 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l89so25284851lfi.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 23:17:04 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id r123si25975927wmb.115.2016.07.12.23.17.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 23:17:03 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id q128so71335wma.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 23:17:03 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH 3/3] Add name fields in shrinker tracepoint definitions
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
In-Reply-To: <ed4c8fa0-d727-c014-58c5-efe3a191f2ec@suse.de>
Date: Wed, 13 Jul 2016 11:46:51 +0530
Content-Transfer-Encoding: quoted-printable
Message-Id: <010E7991-C436-414A-8F5A-602705E5A47B@gmail.com>
References: <cover.1468051277.git.janani.rvchndrn@gmail.com> <6114f72a15d5e52984ea546ba977737221351636.1468051282.git.janani.rvchndrn@gmail.com> <447d8214-3c3d-cc4a-2eff-a47923fbe45f@suse.cz> <ed4c8fa0-d727-c014-58c5-efe3a191f2ec@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Jones <tonyj@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com


> On Jul 13, 2016, at 6:05 AM, Tony Jones <tonyj@suse.de> wrote:
>=20
> On 07/11/2016 07:18 AM, Vlastimil Babka wrote:
>> On 07/09/2016 11:05 AM, Janani Ravichandran wrote:
>>>=20
>>> 	TP_fast_assign(
>>> +		__entry->name =3D shr->name;
>>> 		__entry->shr =3D shr;
>>> 		__entry->shrink =3D shr->scan_objects;
>>> 		__entry->nid =3D sc->nid;
>>> @@ -214,7 +216,8 @@ TRACE_EVENT(mm_shrink_slab_start,
>>> 		__entry->total_scan =3D total_scan;
>>> 	),
>>>=20
>>> -	TP_printk("%pF %p: nid: %d objects to shrink %ld gfp_flags %s =
pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
>>> +	TP_printk("name: %s %pF %p: nid: %d objects to shrink %ld =
gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld =
total_scan %ld",
>>> +		__entry->name,
>>=20
>> Is this legal to do when printing is not done via the /sys ... file=20=

>> itself, but raw data is collected and then printed by e.g. trace-cmd?=20=

>> How can it possibly interpret the "char *" kernel pointer?
>=20
> I actually had a similar patch set to this,  I was going to post it =
but Janani beat me to it ;-)
>=20
> Vlastimil is correct,  I'll attach my patch below so you can see the =
difference.  Otherwise you won't get correct behavior passing through =
perf.

Thanks for that! I will have a look at it.
>  =20
>=20
> I also have a patch which adds a similar latency script (python) but =
interfaces it into the perf script setup.

I=92m looking for pointers for writing latency scripts using tracepoints =
as I=92m new to it. Can I have a look at yours, please?

Thanks :)

Janani.
>=20
> Tony
>=20
> ---
>=20
> Pass shrinker name in shrink slab tracepoints
>=20
> Signed-off-by: Tony Jones <tonyj@suse.de>
> ---
> include/trace/events/vmscan.h | 12 ++++++++++--
> 1 file changed, 10 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/trace/events/vmscan.h =
b/include/trace/events/vmscan.h
> index 0101ef3..0a15948 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -16,6 +16,8 @@
> #define RECLAIM_WB_SYNC		0x0004u /* Unused, all reclaim =
async */
> #define RECLAIM_WB_ASYNC	0x0008u
>=20
> +#define SHRINKER_NAME_LEN 	(size_t)32
> +
> #define show_reclaim_flags(flags)				\
> 	(flags) ? __print_flags(flags, "|",			\
> 		{RECLAIM_WB_ANON,	"RECLAIM_WB_ANON"},	\
> @@ -190,6 +192,7 @@ TRACE_EVENT(mm_shrink_slab_start,
>=20
> 	TP_STRUCT__entry(
> 		__field(struct shrinker *, shr)
> +		__array(char, name, SHRINKER_NAME_LEN)
> 		__field(void *, shrink)
> 		__field(int, nid)
> 		__field(long, nr_objects_to_shrink)
> @@ -203,6 +206,7 @@ TRACE_EVENT(mm_shrink_slab_start,
>=20
> 	TP_fast_assign(
> 		__entry->shr =3D shr;
> +		strlcpy(__entry->name, shr->name, SHRINKER_NAME_LEN);
> 		__entry->shrink =3D shr->scan_objects;
> 		__entry->nid =3D sc->nid;
> 		__entry->nr_objects_to_shrink =3D nr_objects_to_shrink;
> @@ -214,9 +218,10 @@ TRACE_EVENT(mm_shrink_slab_start,
> 		__entry->total_scan =3D total_scan;
> 	),
>=20
> -	TP_printk("%pF %p: nid: %d objects to shrink %ld gfp_flags %s =
pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
> +	TP_printk("%pF %p(%s): nid: %d objects to shrink %ld gfp_flags =
%s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan =
%ld",
> 		__entry->shrink,
> 		__entry->shr,
> +		__entry->name,
> 		__entry->nid,
> 		__entry->nr_objects_to_shrink,
> 		show_gfp_flags(__entry->gfp_flags),
> @@ -236,6 +241,7 @@ TRACE_EVENT(mm_shrink_slab_end,
>=20
> 	TP_STRUCT__entry(
> 		__field(struct shrinker *, shr)
> +		__array(char, name, SHRINKER_NAME_LEN)
> 		__field(int, nid)
> 		__field(void *, shrink)
> 		__field(long, unused_scan)
> @@ -246,6 +252,7 @@ TRACE_EVENT(mm_shrink_slab_end,
>=20
> 	TP_fast_assign(
> 		__entry->shr =3D shr;
> +		strlcpy(__entry->name, shr->name, SHRINKER_NAME_LEN);
> 		__entry->nid =3D nid;
> 		__entry->shrink =3D shr->scan_objects;
> 		__entry->unused_scan =3D unused_scan_cnt;
> @@ -254,9 +261,10 @@ TRACE_EVENT(mm_shrink_slab_end,
> 		__entry->total_scan =3D total_scan;
> 	),
>=20
> -	TP_printk("%pF %p: nid: %d unused scan count %ld new scan count =
%ld total_scan %ld last shrinker return val %d",
> +	TP_printk("%pF %p(%s): nid: %d unused scan count %ld new scan =
count %ld total_scan %ld last shrinker return val %d",
> 		__entry->shrink,
> 		__entry->shr,
> +		__entry->name,
> 		__entry->nid,
> 		__entry->unused_scan,
> 		__entry->new_scan,
>=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

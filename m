Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 534866B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 04:15:44 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ag5so423517691pad.2
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 01:15:44 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z1si27261192pab.287.2016.09.06.01.15.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Sep 2016 01:15:43 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u868CTfX144089
	for <linux-mm@kvack.org>; Tue, 6 Sep 2016 04:15:42 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 259r1mxdsf-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 06 Sep 2016 04:15:42 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zhong@linux.vnet.ibm.com>;
	Tue, 6 Sep 2016 04:15:41 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] mem-hotplug: Don't clear the only node in new_node_page()
From: Li Zhong <zhong@linux.vnet.ibm.com>
In-Reply-To: <d7393a3e-73a7-7923-bc32-d4dcbc6523f9@suse.cz>
Date: Tue, 6 Sep 2016 16:13:24 +0800
Content-Transfer-Encoding: quoted-printable
References: <1473044391.4250.19.camel@TP420> <d7393a3e-73a7-7923-bc32-d4dcbc6523f9@suse.cz>
Message-Id: <B1E0D42A-2F9D-4511-927B-962BC2FD13B3@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm <linux-mm@kvack.org>, John Allen <jallen@linux.vnet.ibm.com>, qiuxishi@huawei.com, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, rientjes@google.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>


> On Sep 5, 2016, at 22:18, Vlastimil Babka <vbabka@suse.cz> wrote:
>=20
> On 09/05/2016 04:59 AM, Li Zhong wrote:
>> Commit 394e31d2c introduced new_node_page() for memory hotplug.
>>=20
>> In new_node_page(), the nid is cleared before calling =
__alloc_pages_nodemask().
>> But if it is the only node of the system,
>=20
> So the use case is that we are partially offlining the only online =
node?

Yes.
>=20
>> and the first round allocation fails,
>> it will not be able to get memory from an empty nodemask, and trigger =
oom.
>=20
> Hmm triggering OOM due to empty nodemask sounds like a wrong thing to =
do. CCing some OOM experts for insight. Also OOM is skipped for =
__GFP_THISNODE allocations, so we might also consider the same for =
nodemask-constrained allocations?
>=20
>> The patch checks whether it is the last node on the system, and if it =
is, then
>> don't clear the nid in the nodemask.
>=20
> I'd rather see the allocation not OOM, and rely on the fallback in =
new_node_page() that doesn't have nodemask. But I suspect it might also =
make sense to treat empty nodemask as something unexpected and put some =
WARN_ON (instead of OOM) in the allocator.

I think it would be much easier to understand these kind of empty =
nodemask allocation failure with this WARN_ON(), how about something =
like this?

=3D=3D=3D
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a2214c6..57edf18 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3629,6 +3629,11 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned =
int order,
                .migratetype =3D gfpflags_to_migratetype(gfp_mask),
        };
=20
+       if (nodemask && nodes_empty(*nodemask)) {
+               WARN_ON(1);
+               return NULL;
+       }
+
        if (cpusets_enabled()) {
                alloc_mask |=3D __GFP_HARDWALL;
                alloc_flags |=3D ALLOC_CPUSET;
=3D=3D=3D

If that=E2=80=99s ok, maybe I can send a separate patch for this?=20

Thanks, Zhong

>=20
>> Reported-by: John Allen <jallen@linux.vnet.ibm.com>
>> Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
>=20
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Fixes: 394e31d2ceb4 ("mem-hotplug: alloc new page from a nearest =
neighbor node when mem-offline")
>=20
>> ---
>> mm/memory_hotplug.c | 4 +++-
>> 1 file changed, 3 insertions(+), 1 deletion(-)
>>=20
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 41266dc..b58906b 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1567,7 +1567,9 @@ static struct page *new_node_page(struct page =
*page, unsigned long private,
>> 		return =
alloc_huge_page_node(page_hstate(compound_head(page)),
>> 					next_node_in(nid, nmask));
>>=20
>> -	node_clear(nid, nmask);
>> +	if (nid !=3D next_node_in(nid, nmask))
>> +		node_clear(nid, nmask);
>> +
>> 	if (PageHighMem(page)
>> 	    || (zone_idx(page_zone(page)) =3D=3D ZONE_MOVABLE))
>> 		gfp_mask |=3D __GFP_HIGHMEM;
>>=20
>>=20
>>=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

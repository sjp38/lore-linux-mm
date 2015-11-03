Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id C350982F64
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 11:13:59 -0500 (EST)
Received: by qgem9 with SMTP id m9so16846498qge.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 08:13:59 -0800 (PST)
Received: from mail-qk0-x22c.google.com (mail-qk0-x22c.google.com. [2607:f8b0:400d:c09::22c])
        by mx.google.com with ESMTPS id 19si22822557qhq.94.2015.11.03.08.13.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 08:13:58 -0800 (PST)
Received: by qkcn129 with SMTP id n129so8525966qkc.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 08:13:58 -0800 (PST)
Message-ID: <5638dd45.4aed8c0a.b4962.ffffe94a@mx.google.com>
Date: Tue, 03 Nov 2015 08:13:57 -0800 (PST)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH V5] mm: memory hot-add: memory can not be added to
 movable zone defaultly
In-Reply-To: <1442303398-45536-1-git-send-email-liuchangsheng@inspur.com>
References: <9e3e1a14aae1a1d86cbe0ac245fa7356@s.corp-email.com>
	<1442303398-45536-1-git-send-email-liuchangsheng@inspur.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Changsheng Liu <liuchangsheng@inspur.com>
Cc: akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wunan@inspur.com, yanxiaofeng@inspur.com, fandd@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>

Hi Changsheng,

According to the following thread, Tang has no objection to change kernel
behavior since udev cannot online memory as movable.

https://lkml.org/lkml/2015/10/21/159

So how about reposting the v5 patch?
I have a comment about the patch. Please see below.

On Tue, 15 Sep 2015 03:49:58 -0400
Changsheng Liu <liuchangsheng@inspur.com> wrote:

> From: Changsheng Liu <liuchangcheng@inspur.com>
>=20
> =08After the user config CONFIG_MOVABLE_NODE and movable_node kernel opti=
on,
> When the memory is hot added, should_add_memory_movable() return 0
> because all zones including movable zone are empty,
> so the memory that was hot added will be added  to the normal zone
> and the normal zone will be created firstly.
> But we want the whole node to be added to movable zone defaultly.
>=20
> So we change should_add_memory_movable(): if the user config
> CONFIG_MOVABLE_NODE and movable_node kernel option
> it will always return 1 and all zones is empty at the same time,
> so that the movable zone will be created firstly
> and then the whole node will be added to movable zone defaultly.
> If we want the node to be added to normal zone,
> we can do it as follows:
> "echo online_kernel > /sys/devices/system/memory/memoryXXX/state"
>=20
> Signed-off-by: Xiaofeng Yan <yanxiaofeng@inspur.com>
> Signed-off-by: Changsheng Liu <liuchangcheng@inspur.com>
> Tested-by: Dongdong Fan <fandd@inspur.com>
> ---
>  mm/memory_hotplug.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
>=20
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 26fbba7..d39dbb0 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1190,6 +1190,9 @@ static int check_hotplug_memory_range(u64 start, u6=
4 size)
>  /*
>   * If movable zone has already been setup, newly added memory should be =
check.
>   * If its address is higher than movable zone, it should be added as mov=
able.
> + * And if system boots up with movable_node and config CONFIG_MOVABLE_NO=
D and
> + * added memory does not overlap the zone before MOVABLE_ZONE,
> + * the memory is added as movable
>   * Without this check, movable zone may overlap with other zone.
>   */
>  static int should_add_memory_movable(int nid, u64 start, u64 size)
> @@ -1197,6 +1200,11 @@ static int should_add_memory_movable(int nid, u64 =
start, u64 size)
>  	unsigned long start_pfn =3D start >> PAGE_SHIFT;
>  	pg_data_t *pgdat =3D NODE_DATA(nid);
>  	struct zone *movable_zone =3D pgdat->node_zones + ZONE_MOVABLE;
> +	struct zone *pre_zone =3D pgdat->node_zones + (ZONE_MOVABLE - 1);
> +

> +	if (movable_node_is_enabled()
> +	&& zone_end_pfn(pre_zone) <=3D start_pfn)
> +		return 1;

	if (movable_node_is_enabled() && (zone_end_pfn(pre_zone) <=3D start_pfn))

Thanks,
Yasuaki Ishimatsu

> =20
>  	if (zone_is_empty(movable_zone))
>  		return 0;
> --=20
> 1.7.1
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8AE886B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 11:13:00 -0500 (EST)
Received: by qkcl124 with SMTP id l124so21716128qkc.3
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 08:13:00 -0800 (PST)
Received: from mail-qg0-x231.google.com (mail-qg0-x231.google.com. [2607:f8b0:400d:c04::231])
        by mx.google.com with ESMTPS id p102si1155067qkp.116.2015.11.04.08.12.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 08:12:59 -0800 (PST)
Received: by qgem9 with SMTP id m9so44027096qge.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 08:12:59 -0800 (PST)
Message-ID: <563a2e8b.128e8c0a.5ba8e.336b@mx.google.com>
Date: Wed, 04 Nov 2015 08:12:59 -0800 (PST)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH V8] mm: memory hot-add: hot-added memory can not be
 added to movable zone by default
In-Reply-To: <5639DBDE.6000306@huawei.com>
References: <1446625415-11941-1-git-send-email-liuchangsheng@inspur.com>
	<5639DBDE.6000306@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: liuchangsheng <liuchangsheng@inspur.com>, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wunan@inspur.com, yanxiaofeng@inspur.com, fandd@inspur.com, Wang Nan <wangnan0@huawei.com>, Dave Hansen <dave.hansen@intel.com>, Yinghai Lu <yinghai@kernel.org>, Tang Chen <tangchen@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>


On Wed, 4 Nov 2015 18:20:14 +0800
Xishi Qiu <qiuxishi@huawei.com> wrote:

> On 2015/11/4 16:23, liuchangsheng wrote:
> 
> > After the user config CONFIG_MOVABLE_NODE,
> > When the memory is hot added, should_add_memory_movable() return 0
> > because all zones including ZONE_MOVABLE are empty,
> > so the memory that was hot added will be assigned to ZONE_NORMAL,
> > and we need using the udev rules to online the memory automatically:
> > SUBSYSTEM=="memory", ACTION=="add", ATTR{state}=="offline",
> > ATTR{state}="online_movable"
> > The memory block onlined by udev must be adjacent to ZONE_MOVABLE.
> > The events of memory section are notified to udev asynchronously,
> 
> Hi Yasuaki,
> 

> If udev onlines memory in descending order, like 3->2->1->0, it will
> success, but we notifiy to udev in ascending order, like 0->1->2->3,
> so the udev rules cannot online memory as movable, right?

right.

> 
> > so it can not ensure that the memory block onlined by udev is
> > adjacent to ZONE_MOVABLE.So it can't ensure memory online always success.
> > But we want the whole node to be added to ZONE_MOVABLE by default.
> > 
> > So we change should_add_memory_movable(): if the user config
> > CONFIG_MOVABLE_NODE and movable_node kernel option
> > and the ZONE_NORMAL is empty or the pfn of the hot-added memory
> > is after the end of the ZONE_NORMAL it will always return 1
> > and then the whole node will be added to ZONE_MOVABLE by default.
> > If we want the node to be assigned to ZONE_NORMAL,
> > we can do it as follows:
> > "echo online_kernel > /sys/devices/system/memory/memoryXXX/state"
> > 
> 

> The order should like 0->1->2->3, right? 3->2->1->0 will be failed.

right.

Thanks,
Yasuaki Ishimatsu

> 
> > Signed-off-by: liuchangsheng <liuchangsheng@inspur.com>
> > Signed-off-by: Xiaofeng Yan <yanxiaofeng@inspur.com>
> > Tested-by: Dongdong Fan <fandd@inspur.com>
> > Reviewed-by: <yasu.isimatu@gmail.com>
> > Cc: Wang Nan <wangnan0@huawei.com>
> > Cc: Dave Hansen <dave.hansen@intel.com>
> > Cc: Yinghai Lu <yinghai@kernel.org>
> > Cc: Tang Chen <tangchen@cn.fujitsu.com>
> > Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> > Cc: Toshi Kani <toshi.kani@hp.com>
> > Cc: Xishi Qiu <qiuxishi@huawei.com>
> > ---
> >  mm/memory_hotplug.c | 7 +++++++
> >  1 file changed, 7 insertions(+)
> > 
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index aa992e2..8617b9f 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -1201,6 +1201,9 @@ static int check_hotplug_memory_range(u64 start, u64 size)
> >  /*
> >   * If movable zone has already been setup, newly added memory should be check.
> >   * If its address is higher than movable zone, it should be added as movable.
> > + * And if system boots up with movable_node and config CONFIG_MOVABLE_NOD and
> > + * added memory does not overlap the zone before MOVABLE_ZONE,
> > + * the memory is added as movable.
> >   * Without this check, movable zone may overlap with other zone.
> >   */
> >  static int should_add_memory_movable(int nid, u64 start, u64 size)
> > @@ -1208,6 +1211,10 @@ static int should_add_memory_movable(int nid, u64 start, u64 size)
> >  	unsigned long start_pfn = start >> PAGE_SHIFT;
> >  	pg_data_t *pgdat = NODE_DATA(nid);
> >  	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
> > +	struct zone *pre_zone = pgdat->node_zones + (ZONE_MOVABLE - 1);
> > +
> > +	if (movable_node_is_enabled() && (zone_end_pfn(pre_zone) <= start_pfn))
> > +		return 1;
> >  
> 
> Looks good to me.
> 
> How about add some comment in mm/Kconfig?
> 
> Thanks,
> Xishi Qiu
> 
> >  	if (zone_is_empty(movable_zone))
> >  		return 0;
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id C2D076B0038
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 15:42:18 -0400 (EDT)
Received: by qgt47 with SMTP id 47so71428080qgt.2
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 12:42:18 -0700 (PDT)
Received: from mail-qg0-x22c.google.com (mail-qg0-x22c.google.com. [2607:f8b0:400d:c04::22c])
        by mx.google.com with ESMTPS id f185si1649565qhc.2.2015.09.11.12.42.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Sep 2015 12:42:17 -0700 (PDT)
Received: by qgev79 with SMTP id v79so71392654qge.0
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 12:42:17 -0700 (PDT)
Message-ID: <55f32e98.5a18370a.25e16.4c64@mx.google.com>
Date: Fri, 11 Sep 2015 12:42:16 -0700 (PDT)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH V4] mm: memory hot-add: memory can not be added to
 movable zone defaultly
In-Reply-To: <55EBFA66.5040106@inspur.com>
References: <0bc3aaab6cea54112f1c444880f9b832@s.corp-email.com>
	<1441000720-28506-1-git-send-email-liuchangsheng@inspur.com>
	<55e5c643.04c0370a.45f82.58bb@mx.google.com>
	<55EBFA66.5040106@inspur.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Changsheng Liu <liuchangsheng@inspur.com>
Cc: akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wunan@inspur.com, yanxiaofeng@inspur.com, fandd@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>

Hi Changsheng,

Thank you for your comments.
I'm on vacation. So After that, I'll repost the patch.

Thanks,
Yasuaki Ishimatsu
On Sun, 6 Sep 2015 16:33:42 +0800
Changsheng Liu <liuchangsheng@inspur.com> wrote:

> 
> 
> On 9/1/2015 23:37, Yasuaki Ishimatsu wrote:
> > On Mon, 31 Aug 2015 01:58:40 -0400
> > Changsheng Liu <liuchangsheng@inspur.com> wrote:
> >
> >> From: Changsheng Liu <liuchangcheng@inspur.com>
> >>
> >> After the user config CONFIG_MOVABLE_NODE and movable_node kernel option,
> >> When the memory is hot added, should_add_memory_movable() return 0
> >> because all zones including movable zone are empty,
> >> so the memory that was hot added will be added  to the normal zone
> >> and the normal zone will be created firstly.
> >> But we want the whole node to be added to movable zone defaultly.
> >>
> >> So we change should_add_memory_movable(): if the user config
> >> CONFIG_MOVABLE_NODE and movable_node kernel option
> >> it will always return 1 and all zones is empty at the same time,
> >> so that the movable zone will be created firstly
> >> and then the whole node will be added to movable zone defaultly.
> >> If we want the node to be added to normal zone,
> >> we can do it as follows:
> >> "echo online_kernel > /sys/devices/system/memory/memoryXXX/state"
> >>
> >> If the memory is added to movable zone defaultly,
> >> the user can offline it and add it to other zone again.
> >> But if the memory is added to normal zone defaultly,
> >> the user will not offline the memory used by kernel.
> >>
> >> Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
> >> Reviewed-by: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
> >> Reviewed-by: Vlastimil Babka <vbabka@suse.cz>
> >> Reviewed-by: Xiaofeng Yan <yanxiaofeng@inspur.com>
> >> Signed-off-by: Changsheng Liu <liuchangcheng@inspur.com>
> >> Tested-by: Dongdong Fan <fandd@inspur.com>
> >> ---
> >>   mm/memory_hotplug.c |    5 +++++
> >>   1 files changed, 5 insertions(+), 0 deletions(-)
> >>
> >> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> >> index 26fbba7..d1149ff 100644
> >> --- a/mm/memory_hotplug.c
> >> +++ b/mm/memory_hotplug.c
> >> @@ -1197,6 +1197,11 @@ static int should_add_memory_movable(int nid, u64 start, u64 size)
> >>   	unsigned long start_pfn = start >> PAGE_SHIFT;
> >>   	pg_data_t *pgdat = NODE_DATA(nid);
> >>   	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
> >> +	struct zone *normal_zone = pgdat->node_zones + ZONE_NORMAL;
> >> +
> >> +	if (movable_node_is_enabled()
> >> +	&& (zone_end_pfn(normal_zone) <= start_pfn))
> >> +		return 1;
> > If system boots up without movable_node, kernel behavior is changed by the patch.
> > And you syould consider other zone.
> >
> > How about it. The patch is no build and test.
> >
> >
> > ---
> >   mm/memory_hotplug.c |   36 ++++++++++++++++++++++++++++++++----
> >   1 files changed, 32 insertions(+), 4 deletions(-)
> >
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index 6da82bc..321595d 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -1198,6 +1198,8 @@ static int check_hotplug_memory_range(u64 start, u64 size)
> >   /*
> >    * If movable zone has already been setup, newly added memory should be check.
> >    * If its address is higher than movable zone, it should be added as movable.
> > + * And if system boots up with movable_zone and added memory does not overlap
> > + * other zone except for movable zone, the memory is added as movable.
> >    * Without this check, movable zone may overlap with other zone.
> >    */
> >   static int should_add_memory_movable(int nid, u64 start, u64 size)
> > @@ -1205,14 +1207,40 @@ static int should_add_memory_movable(int nid, u64 start, u64 size)
> >   	unsigned long start_pfn = start >> PAGE_SHIFT;
> >   	pg_data_t *pgdat = NODE_DATA(nid);
> >   	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
> > +	struct zone *zone;
> > +	enum zone_type zt = ZONE_MOVABLE - 1;
> > +
> > +	/*
> > +	 * If memory is added after ZONE_MOVALBE, the memory is managed as
> > +	 * movable.
> > +	 */
> > +	if (!zone_is_empty(movable_zone) &&
> > +	    (movable_zone->zone_start_pfn <= start_pfn))
> > +		return 1;
> >   
> > -	if (zone_is_empty(movable_zone))
> > +	if (!movable_node_is_enabled())
> >   		return 0;
> >   
> > -	if (movable_zone->zone_start_pfn <= start_pfn)
> > -		return 1;
> > +	/*
> > +	 * Find enabled zone and check the added memory.
> > +	 * If the memory is added after the enabled zone, the memory is
> > +	 * managed as movable.
> > +	 *
> > +	 * If all zones are empty, the memory is also managed as movable.
> > +	 */
> > +	for (; zt >= ZONE_DMA; zt--) {
> > +		zone = pgdat->node_zones + zt;
> >   
> > -	return 0;
> > +		if (zone_is_empty(zone))
> > +			continue;
> > +
> > +		if (zone_end_pfn(zone) <= start_pfn)
> > +			return 1;
> > +		else
> > +			return 0;
> > +	}
> > +
> > +	return 1;
> >   }
> >   
>      The function zone_for_memory()  adds the memory to 
> ZONE_NORMAL(x86_64)/ZONE_HIGH(x86_32) defaultly, So I think the system 
> just  need check the added-memory is whether after the ZONE_NORMAL/ZONE_HIGH
> >   int zone_for_memory(int nid, u64 start, u64 size, int zone_default)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

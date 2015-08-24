Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 051F56B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 15:15:59 -0400 (EDT)
Received: by qgeh99 with SMTP id h99so33512581qge.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 12:15:58 -0700 (PDT)
Received: from mail-qg0-x232.google.com (mail-qg0-x232.google.com. [2607:f8b0:400d:c04::232])
        by mx.google.com with ESMTPS id k18si18002275qkl.20.2015.08.24.12.15.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 12:15:58 -0700 (PDT)
Received: by qgeh99 with SMTP id h99so33512271qge.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 12:15:57 -0700 (PDT)
Message-ID: <55db6d6d.82d1370a.dd0ff.6055@mx.google.com>
Date: Mon, 24 Aug 2015 12:15:57 -0700 (PDT)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH] Memory hot added,The memory can not been added to
 movable zone
In-Reply-To: <55D57071.1080901@inspur.com>
References: <1439972306-50845-1-git-send-email-liuchangsheng@inspur.com>
	<20150819165029.665b89d7ab3228185460172c@linux-foundation.org>
	<55D57071.1080901@inspur.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Changsheng Liu <liuchangsheng@inspur.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, isimatu.yasuaki@jp.fujitsu.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yanxiaofeng@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>

Hi 
On Thu, 20 Aug 2015 14:15:13 +0800
Changsheng Liu <liuchangsheng@inspur.com> wrote:

> Hi Andrew Morton:
> First, thanks very much for your review, I will update codes according 
> to  your suggestio
> 
> a?? 2015/8/20 7:50, Andrew Morton a??e??:
> > On Wed, 19 Aug 2015 04:18:26 -0400 Changsheng Liu <liuchangsheng@inspur.com> wrote:
> >
> >> From: Changsheng Liu <liuchangcheng@inspur.com>
> >>
> >> When memory hot added, the function should_add_memory_movable
> >> always return 0,because the movable zone is empty,
> >> so the memory that hot added will add to normal zone even if
> >> we want to remove the memory.
> >> So we change the function should_add_memory_movable,if the user
> >> config CONFIG_MOVABLE_NODE it will return 1 when
> >> movable zone is empty
> > I cleaned this up a bit:
> >
> > : Subject: mm: memory hot-add: memory can not been added to movable zone
> > :
> > : When memory is hot added, should_add_memory_movable() always returns 0
> > : because the movable zone is empty, so the memory that was hot added will
> > : add to the normal zone even if we want to remove the memory.
> > :
> > : So we change should_add_memory_movable(): if the user config
> > : CONFIG_MOVABLE_NODE it will return 1 when the movable zone is empty.
> >
> > But I don't understand the "even if we want to remove the memory".
> > This is hot-add, not hot-remove.  What do you mean here?
>      After the system startup, we hot added one memory. After some time 
> we wanted to hot remove the memroy that was hot added,
>      but we could not offline some memory blocks successfully because 
> the memory was added to normal zone defaultly and the value of the file 
>      named removable under some memory blocks is 0.

For this, we prepared online_movable. When memory is onlined by online_movable,
the memory move from ZONE_NORMAL to ZONE_MOVABLE.

Ex.
# echo online_movable > /sys/devices/system/memory/memoryXXX/state

Thanks,
Yasuaki Ishimatsu

>      we checked the value of the file under some memory blocks as follows:
>      "cat /sys/devices/system/memory/ memory***/removable"
>      When memory being hot added we let the memory be added to movable 
> zone,
>      so we will be able to hot remove the memory that have been hot added
> >> --- a/mm/memory_hotplug.c
> >> +++ b/mm/memory_hotplug.c
> >> @@ -1198,9 +1198,13 @@ static int should_add_memory_movable(int nid, u64 start, u64 size)
> >>   	pg_data_t *pgdat = NODE_DATA(nid);
> >>   	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
> >>   
> >> -	if (zone_is_empty(movable_zone))
> >> +	if (zone_is_empty(movable_zone)) {
> >> +	#ifdef CONFIG_MOVABLE_NODE
> >> +		return 1;
> >> +	#else
> >>   		return 0;
> >> -
> >> +	#endif
> >> +	}
> >>   	if (movable_zone->zone_start_pfn <= start_pfn)
> >>   		return 1;
> > Cleaner:
> >
> > --- a/mm/memory_hotplug.c~memory-hot-addedthe-memory-can-not-been-added-to-movable-zone-fix
> > +++ a/mm/memory_hotplug.c
> > @@ -1181,13 +1181,9 @@ static int should_add_memory_movable(int
> >   	pg_data_t *pgdat = NODE_DATA(nid);
> >   	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
> >   
> > -	if (zone_is_empty(movable_zone)) {
> > -	#ifdef CONFIG_MOVABLE_NODE
> > -		return 1;
> > -	#else
> > -		return 0;
> > -	#endif
> > -	}
> > +	if (zone_is_empty(movable_zone))
> > +		return IS_ENABLED(CONFIG_MOVABLE_NODE);
> > +
> >   	if (movable_zone->zone_start_pfn <= start_pfn)
> >   		return 1;
> >   
> > _
> >
> > .
> >
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

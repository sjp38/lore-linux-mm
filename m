Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1665C2806D2
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 05:06:12 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v6so4924431wrc.21
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 02:06:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l125si8566898wmg.143.2017.04.20.02.06.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Apr 2017 02:06:10 -0700 (PDT)
Date: Thu, 20 Apr 2017 11:06:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 6/9] mm, memory_hotplug: do not associate hotadded
 memory to zones until online
Message-ID: <20170420090605.GD15781@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410110351.12215-7-mhocko@kernel.org>
 <20170410162547.GM4618@dhcp22.suse.cz>
 <49b6c3e2-0e68-b77e-31d6-f589d3b4822e@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49b6c3e2-0e68-b77e-31d6-f589d3b4822e@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu 20-04-17 10:25:27, Vlastimil Babka wrote:
> On 04/10/2017 06:25 PM, Michal Hocko wrote:
[...]
> > Let's simulate memory hot online manually
> > Normal Movable
> > 
> > /sys/devices/system/memory/memory32/valid_zones:Normal
> > /sys/devices/system/memory/memory33/valid_zones:Normal Movable
> > 
> > /sys/devices/system/memory/memory32/valid_zones:Normal
> > /sys/devices/system/memory/memory33/valid_zones:Normal
> > /sys/devices/system/memory/memory34/valid_zones:Normal Movable
> > 
> > /sys/devices/system/memory/memory32/valid_zones:Normal
> > /sys/devices/system/memory/memory33/valid_zones:Normal Movable
> > /sys/devices/system/memory/memory34/valid_zones:Movable Normal
> 
> Commands seem to be missing above?

Yes. git commit just dropped everything starting with # which happened
to be the bash prompt for my commands. I have changed that to $ and it
looks as follows
    $ echo 0x100000000 > /sys/devices/system/memory/probe
    $ grep . /sys/devices/system/memory/memory32/valid_zones
    Normal Movable
    
    $ echo $((0x100000000+(128<<20))) > /sys/devices/system/memory/probe
    $ grep . /sys/devices/system/memory/memory3?/valid_zones
    /sys/devices/system/memory/memory32/valid_zones:Normal
    /sys/devices/system/memory/memory33/valid_zones:Normal Movable
    
    $ echo $((0x100000000+2*(128<<20))) > /sys/devices/system/memory/probe
    $ grep . /sys/devices/system/memory/memory3?/valid_zones
    /sys/devices/system/memory/memory32/valid_zones:Normal
    /sys/devices/system/memory/memory33/valid_zones:Normal
    /sys/devices/system/memory/memory34/valid_zones:Normal Movable
    
    $ echo online_movable > /sys/devices/system/memory/memory34/state
    $ grep . /sys/devices/system/memory/memory3?/valid_zones
    /sys/devices/system/memory/memory32/valid_zones:Normal
    /sys/devices/system/memory/memory33/valid_zones:Normal Movable
    /sys/devices/system/memory/memory34/valid_zones:Movable Normal

[...]
> > This means that the same physical online steps as above will lead to the
> > following state:
> > Normal Movable
> > 
> > /sys/devices/system/memory/memory32/valid_zones:Normal Movable
> > /sys/devices/system/memory/memory33/valid_zones:Normal Movable
> > 
> > /sys/devices/system/memory/memory32/valid_zones:Normal Movable
> > /sys/devices/system/memory/memory33/valid_zones:Normal Movable
> > /sys/devices/system/memory/memory34/valid_zones:Normal Movable
> > 
> > /sys/devices/system/memory/memory32/valid_zones:Normal Movable
> > /sys/devices/system/memory/memory33/valid_zones:Normal Movable
> > /sys/devices/system/memory/memory34/valid_zones:Movable
> 
> Ditto.

This just copies the above so I didn't add those commands. I can if that
is preferable.
 
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -533,6 +533,20 @@ static inline bool zone_is_empty(struct zone *zone)
> >  }
> >  
> >  /*
> > + * Return true if [start_pfn, start_pfn + nr_pages) range has a non-mpty
> 
> 
> 							       non-empty

fixed

> > + * intersection with the given zone
> > + */
> > +static inline bool zone_intersects(struct zone *zone,
> > +		unsigned long start_pfn, unsigned long nr_pages)
> > +{
> 
> I'm looking at your current mmotm tree branch, which looks like this:
> 
> + * Return true if [start_pfn, start_pfn + nr_pages) range has a non-mpty
> + * intersection with the given zone
> + */
> +static inline bool zone_intersects(struct zone *zone,
> +               unsigned long start_pfn, unsigned long nr_pages)
> +{
> +       if (zone_is_empty(zone))
> +               return false;
> +       if (zone->zone_start_pfn <= start_pfn && start_pfn < zone_end_pfn(zone))
> +               return true;
> +       if (start_pfn + nr_pages > zone->zone_start_pfn)
> +               return true;
> 
> A false positive is possible here, when start_pfn >= zone_end_pfn(zone)?

Ohh, right. Looks better?

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index eae6da28646e..611ff869fa4d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -541,10 +541,14 @@ static inline bool zone_intersects(struct zone *zone,
 {
 	if (zone_is_empty(zone))
 		return false;
-	if (zone->zone_start_pfn <= start_pfn && start_pfn < zone_end_pfn(zone))
+	if (start_pfn >= zone_end_pfn(zone))
+		return false;
+
+	if (zone->zone_start_pfn <= start_pfn)
 		return true;
 	if (start_pfn + nr_pages > zone->zone_start_pfn)
 		return true;
+
 	return false;
 }
 
> > @@ -1029,39 +1018,114 @@ static void node_states_set_node(int node, struct memory_notify *arg)
> >  	node_set_state(node, N_MEMORY);
> >  }
> >  
> > -bool zone_can_shift(unsigned long pfn, unsigned long nr_pages,
> > -		   enum zone_type target, int *zone_shift)
> > +bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_pages, int online_type)
> >  {
> > -	struct zone *zone = page_zone(pfn_to_page(pfn));
> > -	enum zone_type idx = zone_idx(zone);
> > -	int i;
> > +	struct pglist_data *pgdat = NODE_DATA(nid);
> > +	struct zone *movable_zone = &pgdat->node_zones[ZONE_MOVABLE];
> > +	struct zone *normal_zone =  &pgdat->node_zones[ZONE_NORMAL];
> >  
> > -	*zone_shift = 0;
> > +	/*
> > +	 * TODO there shouldn't be any inherent reason to have ZONE_NORMAL
> > +	 * physically before ZONE_MOVABLE. All we need is they do not
> > +	 * overlap. Historically we didn't allow ZONE_NORMAL after ZONE_MOVABLE
> > +	 * though so let's stick with it for simplicity for now.
> > +	 * TODO make sure we do not overlap with ZONE_DEVICE
> 
> Is this last TODO a blocker, unlike the others?

I think it is not but my knowledge of the zone device is very limited. I
was hoping for Dan's feedback here. From what I understand Zone device
occupies the high end of the address space so we shouldn't overlap here.
Is this correct Dan?

[...]
> > +	if (online_type == MMOP_ONLINE_MOVABLE && !can_online_high_movable(nid))
> > +		return -EINVAL;
> >  
> > -	zone = move_pfn_range(zone_shift, pfn, pfn + nr_pages);
> > +	/* associate pfn range with the zone */
> > +	zone = move_pfn_range(online_type, nid, pfn, nr_pages);
> >  	if (!zone)
> >  		return -EINVAL;
> 
> Nit: This !zone currently cannot happen.

fixed

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

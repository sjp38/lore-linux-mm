Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3BDA66B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 10:55:12 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p62so7025803wrc.13
        for <linux-mm@kvack.org>; Tue, 30 May 2017 07:55:12 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z142si14995340wmc.38.2017.05.30.07.55.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 07:55:09 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4UErZwF025428
	for <linux-mm@kvack.org>; Tue, 30 May 2017 10:55:08 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2as03rtkh0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 May 2017 10:55:07 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 30 May 2017 15:55:06 +0100
Date: Tue, 30 May 2017 16:55:01 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [-next] memory hotplug regression
References: <20170524082022.GC5427@osiris>
 <20170524083956.GC14733@dhcp22.suse.cz>
 <20170526122509.GB14849@osiris>
 <20170530121806.GD7969@dhcp22.suse.cz>
 <20170530123724.GC4874@osiris>
 <20170530143246.GJ7969@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170530143246.GJ7969@dhcp22.suse.cz>
Message-Id: <20170530145501.GD4874@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, May 30, 2017 at 04:32:47PM +0200, Michal Hocko wrote:
> On Tue 30-05-17 14:37:24, Heiko Carstens wrote:
> > On Tue, May 30, 2017 at 02:18:06PM +0200, Michal Hocko wrote:
> > > > So ZONE_DMA ends within ZONE_NORMAL. This shouldn't be possible, unless
> > > > this restriction is gone?
> > > 
> > > The patch below should help.
> > 
> > It does fix this specific problem, but introduces a new one:
> > 
> > # echo online_movable > /sys/devices/system/memory/memory16/state
> > # cat /sys/devices/system/memory/memory16/valid_zones
> > Movable
> > # echo offline > /sys/devices/system/memory/memory16/state
> > # cat /sys/devices/system/memory/memory16/valid_zones
> >           <--- no output
> > 
> > Memory block 16 is the only one I onlined and offlineto ZONE_MOVABLE.
> 
> Could you test the this on top please?
> ---
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 792c098e0e5f..a26f9f8e6365 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -937,13 +937,18 @@ void __ref move_pfn_range_to_zone(struct zone *zone,
>  	set_zone_contiguous(zone);
>  }
> 
> +/*
> + * Returns a default kernel memory zone for the given pfn range.
> + * If no kernel zone covers this pfn range it will automatically go
> + * to the ZONE_NORMAL.
> + */
>  struct zone *default_zone_for_pfn(int nid, unsigned long start_pfn,
>  		unsigned long nr_pages)
>  {
>  	struct pglist_data *pgdat = NODE_DATA(nid);
>  	int zid;
> 
> -	for (zid = 0; zid < MAX_NR_ZONES; zid++) {
> +	for (zid = 0; zid <= ZONE_NORMAL; zid++) {
>  		struct zone *zone = &pgdat->node_zones[zid];
> 
>  		if (zone_intersects(zone, start_pfn, nr_pages))

Still broken, but in different way(s):

# cat /sys/devices/system/memory/memory16/valid_zones
Normal Movable
# echo online_movable > /sys/devices/system/memory/memory16/state
# cat /sys/devices/system/memory/memory16/valid_zones
Movable
# cat /sys/devices/system/memory/memory18/valid_zones
Movable
# echo online > /sys/devices/system/memory/memory18/state
# cat /sys/devices/system/memory/memory18/valid_zones
Normal    <--- should be Movable
# cat /sys/devices/system/memory/memory17/valid_zones
          <--- no output

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

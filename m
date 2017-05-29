Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 243E06B0292
	for <linux-mm@kvack.org>; Mon, 29 May 2017 04:52:34 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r203so12159943wmb.2
        for <linux-mm@kvack.org>; Mon, 29 May 2017 01:52:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x27si9631246eda.67.2017.05.29.01.52.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 May 2017 01:52:32 -0700 (PDT)
Date: Mon, 29 May 2017 10:52:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [-next] memory hotplug regression
Message-ID: <20170529085231.GE19725@dhcp22.suse.cz>
References: <20170524082022.GC5427@osiris>
 <20170524083956.GC14733@dhcp22.suse.cz>
 <20170526122509.GB14849@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170526122509.GB14849@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 26-05-17 14:25:09, Heiko Carstens wrote:
> On Wed, May 24, 2017 at 10:39:57AM +0200, Michal Hocko wrote:
> > On Wed 24-05-17 10:20:22, Heiko Carstens wrote:
> > > Having the ZONE_MOVABLE default was actually the only point why s390's
> > > arch_add_memory() was rather complex compared to other architectures.
> > > 
> > > We always had this behaviour, since we always wanted to be able to offline
> > > memory after it was brought online. Given that back then "online_movable"
> > > did not exist, the initial s390 memory hotplug support simply added all
> > > additional memory to ZONE_MOVABLE.
> > > 
> > > Keeping the default the same would be quite important.
> > 
> > Hmm, that is really unfortunate because I would _really_ like to get rid
> > of the previous semantic which was really awkward. The whole point of
> > the rework is to get rid of the nasty zone shifting.
> > 
> > Is it an option to use `online_movable' rather than `online' in your setup?
> > Btw. my long term plan is to remove the zone range constrains altogether
> > so you could online each memblock to the type you want. Would that be
> > sufficient for you in general?
> 
> Why is it a problem to change the default for 'online'? As far as I can see
> that doesn't have too much to do with the order of zones, no?

`online' (aka MMOP_ONLINE_KEEP) should always inherit its current zone.
The previous implementation made an exception to allow to shift to
another zone if it is on the border of two zones. This is what I wanted
to get rid of because it is just too ugly to live.

But now I am not really sure what is the usecase here. I assume you know
how to online the memoery. That's why you had to play tricks with the
zones previously. All you need now is to use the proper MMOP_ONLINE*

> By the way: we played around a bit with the changes wrt memory
> hotplug. There are a two odd things:
> 
> 1) With the new code I can generate overlapping zones for ZONE_DMA and
> ZONE_NORMAL:
> 
> --- new code:
> 
> DMA      [mem 0x0000000000000000-0x000000007fffffff]
> Normal   [mem 0x0000000080000000-0x000000017fffffff]
> 
> # cat /sys/devices/system/memory/block_size_bytes
> 10000000
> # cat /sys/devices/system/memory/memory5/valid_zones
> DMA
> # echo 0 > /sys/devices/system/memory/memory5/online
> # cat /sys/devices/system/memory/memory5/valid_zones
> Normal
> # echo 1 > /sys/devices/system/memory/memory5/online
> Normal

OK, interesting. I will double check the code.

> # cat /proc/zoneinfo
> Node 0, zone      DMA
> spanned  524288        <-----
> present  458752
> managed  455078
> start_pfn:           0 <-----
> 
> Node 0, zone   Normal
> spanned  720896
> present  589824
> managed  571648
> start_pfn:           327680 <-----
> 
> So ZONE_DMA ends within ZONE_NORMAL. This shouldn't be possible, unless
> this restriction is gone?
>
> --- old code:
> 
> # echo 0 > /sys/devices/system/memory/memory5/online
> # cat /sys/devices/system/memory/memory5/valid_zones
> DMA
> # echo online_movable > /sys/devices/system/memory/memory5/state
> -bash: echo: write error: Invalid argument
> # echo online_kernel > /sys/devices/system/memory/memory5/state
> -bash: echo: write error: Invalid argument
> # echo online > /sys/devices/system/memory/memory5/state
> # cat /sys/devices/system/memory/memory5/valid_zones
> DMA
> 
> 
> 2) Another oddity is that after a memory block was brought online it's
> association to ZONE_NORMAL or ZONE_MOVABLE seems to be fixed. Even if it
> is brought offline afterwards:

This is intended behavior because I got rid of the tricky&ugly zone
shifting code. Ultimately I would like to allow for overlapping zones
so the explicit online_{movable,kernel} will _always_ work.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

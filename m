Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DFB996B02C3
	for <linux-mm@kvack.org>; Tue, 30 May 2017 08:18:09 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g13so19384996wmd.9
        for <linux-mm@kvack.org>; Tue, 30 May 2017 05:18:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z3si13587489eda.205.2017.05.30.05.18.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 May 2017 05:18:08 -0700 (PDT)
Date: Tue, 30 May 2017 14:18:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [-next] memory hotplug regression
Message-ID: <20170530121806.GD7969@dhcp22.suse.cz>
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
[...]
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
> 
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

The patch below should help.

> --- old code:
> 
> # echo 0 > /sys/devices/system/memory/memory5/online
> # cat /sys/devices/system/memory/memory5/valid_zones
> DMA
> # echo online_movable > /sys/devices/system/memory/memory5/state
> -bash: echo: write error: Invalid argument
> # echo online_kernel > /sys/devices/system/memory/memory5/state
> -bash: echo: write error: Invalid argument

this error doesn't make any sense. Because we we want to online kernel
memory and DMA is pretty much the kernel memory

> # echo online > /sys/devices/system/memory/memory5/state
> # cat /sys/devices/system/memory/memory5/valid_zones
> DMA

--- 

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 89EFA6B0292
	for <linux-mm@kvack.org>; Fri, 26 May 2017 08:25:19 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b28so226522wrb.2
        for <linux-mm@kvack.org>; Fri, 26 May 2017 05:25:19 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 60si710522wri.313.2017.05.26.05.25.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 May 2017 05:25:18 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4QCNxcr129305
	for <linux-mm@kvack.org>; Fri, 26 May 2017 08:25:16 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2apk7ybbpf-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 26 May 2017 08:25:16 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Fri, 26 May 2017 13:25:14 +0100
Date: Fri, 26 May 2017 14:25:09 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [-next] memory hotplug regression
References: <20170524082022.GC5427@osiris>
 <20170524083956.GC14733@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170524083956.GC14733@dhcp22.suse.cz>
Message-Id: <20170526122509.GB14849@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, May 24, 2017 at 10:39:57AM +0200, Michal Hocko wrote:
> On Wed 24-05-17 10:20:22, Heiko Carstens wrote:
> > Having the ZONE_MOVABLE default was actually the only point why s390's
> > arch_add_memory() was rather complex compared to other architectures.
> > 
> > We always had this behaviour, since we always wanted to be able to offline
> > memory after it was brought online. Given that back then "online_movable"
> > did not exist, the initial s390 memory hotplug support simply added all
> > additional memory to ZONE_MOVABLE.
> > 
> > Keeping the default the same would be quite important.
> 
> Hmm, that is really unfortunate because I would _really_ like to get rid
> of the previous semantic which was really awkward. The whole point of
> the rework is to get rid of the nasty zone shifting.
> 
> Is it an option to use `online_movable' rather than `online' in your setup?
> Btw. my long term plan is to remove the zone range constrains altogether
> so you could online each memblock to the type you want. Would that be
> sufficient for you in general?

Why is it a problem to change the default for 'online'? As far as I can see
that doesn't have too much to do with the order of zones, no?

By the way: we played around a bit with the changes wrt memory
hotplug. There are a two odd things:

1) With the new code I can generate overlapping zones for ZONE_DMA and
ZONE_NORMAL:

--- new code:

DMA      [mem 0x0000000000000000-0x000000007fffffff]
Normal   [mem 0x0000000080000000-0x000000017fffffff]

# cat /sys/devices/system/memory/block_size_bytes
10000000
# cat /sys/devices/system/memory/memory5/valid_zones
DMA
# echo 0 > /sys/devices/system/memory/memory5/online
# cat /sys/devices/system/memory/memory5/valid_zones
Normal
# echo 1 > /sys/devices/system/memory/memory5/online
Normal

# cat /proc/zoneinfo
Node 0, zone      DMA
spanned  524288        <-----
present  458752
managed  455078
start_pfn:           0 <-----

Node 0, zone   Normal
spanned  720896
present  589824
managed  571648
start_pfn:           327680 <-----

So ZONE_DMA ends within ZONE_NORMAL. This shouldn't be possible, unless
this restriction is gone?

--- old code:

# echo 0 > /sys/devices/system/memory/memory5/online
# cat /sys/devices/system/memory/memory5/valid_zones
DMA
# echo online_movable > /sys/devices/system/memory/memory5/state
-bash: echo: write error: Invalid argument
# echo online_kernel > /sys/devices/system/memory/memory5/state
-bash: echo: write error: Invalid argument
# echo online > /sys/devices/system/memory/memory5/state
# cat /sys/devices/system/memory/memory5/valid_zones
DMA


2) Another oddity is that after a memory block was brought online it's
association to ZONE_NORMAL or ZONE_MOVABLE seems to be fixed. Even if it
is brought offline afterwards:

# cat /sys/devices/system/memory/memory16/valid_zones
Normal Movable
# echo online_movable > /sys/devices/system/memory/memory16/state
# echo offline > /sys/devices/system/memory/memory16/state
# cat /sys/devices/system/memory/memory16/valid_zones
Movable  <---- should be "Normal Movable"

I assume this happens because start_pfn and spanned pages of the zones
aren't updated if a memory block at the beginning or end of a zone is
brought offline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C1B1E6B03A5
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 11:22:32 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 18so2989447wrz.4
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 08:22:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 140si3712085wmb.110.2017.04.10.08.22.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 08:22:31 -0700 (PDT)
Date: Mon, 10 Apr 2017 17:22:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -v2 0/9] mm: make movable onlining suck less
Message-ID: <20170410152228.GF4618@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410162749.7d7f31c1@nial.brq.redhat.com>
 <20170410145639.GE4618@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170410145639.GE4618@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tobias Regnery <tobias.regnery@gmail.com>

[dropping Lai Jiangshan whose email bounces]

On Mon 10-04-17 16:56:39, Michal Hocko wrote:
> On Mon 10-04-17 16:27:49, Igor Mammedov wrote:
> [...]
> > Hi Michal,
> > 
> > I've given series some dumb testing, see below for unexpected changes I've noticed.
> > 
> > Using the same CLI as above plus hotpluggable dimms present at startup
> > (it still uses hotplug path as dimms aren't reported in e820)
> > 
> > -object memory-backend-ram,id=mem1,size=256M -object memory-backend-ram,id=mem0,size=256M \
> > -device pc-dimm,id=dimm1,memdev=mem1,slot=1,node=0 -device pc-dimm,id=dimm0,memdev=mem0,slot=0,node=0
> > 
> > so dimm1 => memory3[23] and dimm0 => memory3[45]
> > 
> > #issue1:
> > unable to online memblock as NORMAL adjacent to onlined MOVABLE
> > 
> > 1: after boot
> > memory32:offline removable: 0  zones: Normal Movable
> > memory33:offline removable: 0  zones: Normal Movable
> > memory34:offline removable: 0  zones: Normal Movable
> > memory35:offline removable: 0  zones: Normal Movable
> > 
> > 2: online as movable 1st dimm
> > 
> > #echo online_movable > memory32/state
> > #echo online_movable > memory33/state
> > 
> > everything is as expected:
> > memory32:online removable: 1  zones: Movable
> > memory33:online removable: 1  zones: Movable
> > memory34:offline removable: 0  zones: Movable
> > memory35:offline removable: 0  zones: Movable
> > 
> > 3: try to offline memory32 and online as NORMAL
> > 
> > #echo offline > memory32/state
> > memory32:offline removable: 1  zones: Normal Movable
> > memory33:online removable: 1  zones: Movable
> > memory34:offline removable: 0  zones: Movable
> > memory35:offline removable: 0  zones: Movable
> 
> OK, this is not expected. We are not shifting zones anymore so the range
> which was online_movable will not become available to the zone Normal.
> So this must be something broken down the show_valid_zones path. I will
> investigate.

Heh, this one is embarrassing
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 1c6fdacbccd3..9677b6b711b0 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -402,7 +402,7 @@ static ssize_t show_valid_zones(struct device *dev,
 		return sprintf(buf, "none\n");
 
 	start_pfn = valid_start_pfn;
-	nr_pages = valid_end_pfn - valid_end_pfn;
+	nr_pages = valid_end_pfn - start_pfn;
 
 	/*
 	 * Check the existing zone. Make sure that we do that only on the
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

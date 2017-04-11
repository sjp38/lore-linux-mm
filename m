Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9DA436B039F
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 04:02:00 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id y38so18908088qtb.23
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 01:02:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x76si3976671qkb.117.2017.04.11.01.01.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 01:01:59 -0700 (PDT)
Date: Tue, 11 Apr 2017 10:01:52 +0200
From: Igor Mammedov <imammedo@redhat.com>
Subject: Re: [PATCH -v2 0/9] mm: make movable onlining suck less
Message-ID: <20170411100152.6b4be896@nial.brq.redhat.com>
In-Reply-To: <20170410145639.GE4618@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
	<20170410162749.7d7f31c1@nial.brq.redhat.com>
	<20170410145639.GE4618@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tobias Regnery <tobias.regnery@gmail.com>

On Mon, 10 Apr 2017 16:56:39 +0200
Michal Hocko <mhocko@kernel.org> wrote:

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
> 
> > 
> > #echo online_kernel > memory32/state
> > write error: Invalid argument
> > // that's not what's expected  
> 
> this is proper behavior with the current implementation. Does anything
> depend on the zone reusing?
if we didn't have zone imbalance issue in design,
the it wouldn't matter but as it stands it's not
minore issue.

Consider following,
one hotplugs some memory and onlines it as movable,
then one needs to hotplug some more but to do so 
one one needs more memory from zone NORMAL and to keep
zone balance some memory in MOVABLE should be reonlined
as NORMAL


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

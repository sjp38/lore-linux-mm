Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 020DF6B03A1
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 10:56:45 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l44so5429905wrc.11
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 07:56:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j20si12591512wrb.275.2017.04.10.07.56.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 07:56:43 -0700 (PDT)
Date: Mon, 10 Apr 2017 16:56:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -v2 0/9] mm: make movable onlining suck less
Message-ID: <20170410145639.GE4618@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410162749.7d7f31c1@nial.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170410162749.7d7f31c1@nial.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tobias Regnery <tobias.regnery@gmail.com>

On Mon 10-04-17 16:27:49, Igor Mammedov wrote:
[...]
> Hi Michal,
> 
> I've given series some dumb testing, see below for unexpected changes I've noticed.
> 
> Using the same CLI as above plus hotpluggable dimms present at startup
> (it still uses hotplug path as dimms aren't reported in e820)
> 
> -object memory-backend-ram,id=mem1,size=256M -object memory-backend-ram,id=mem0,size=256M \
> -device pc-dimm,id=dimm1,memdev=mem1,slot=1,node=0 -device pc-dimm,id=dimm0,memdev=mem0,slot=0,node=0
> 
> so dimm1 => memory3[23] and dimm0 => memory3[45]
> 
> #issue1:
> unable to online memblock as NORMAL adjacent to onlined MOVABLE
> 
> 1: after boot
> memory32:offline removable: 0  zones: Normal Movable
> memory33:offline removable: 0  zones: Normal Movable
> memory34:offline removable: 0  zones: Normal Movable
> memory35:offline removable: 0  zones: Normal Movable
> 
> 2: online as movable 1st dimm
> 
> #echo online_movable > memory32/state
> #echo online_movable > memory33/state
> 
> everything is as expected:
> memory32:online removable: 1  zones: Movable
> memory33:online removable: 1  zones: Movable
> memory34:offline removable: 0  zones: Movable
> memory35:offline removable: 0  zones: Movable
> 
> 3: try to offline memory32 and online as NORMAL
> 
> #echo offline > memory32/state
> memory32:offline removable: 1  zones: Normal Movable
> memory33:online removable: 1  zones: Movable
> memory34:offline removable: 0  zones: Movable
> memory35:offline removable: 0  zones: Movable

OK, this is not expected. We are not shifting zones anymore so the range
which was online_movable will not become available to the zone Normal.
So this must be something broken down the show_valid_zones path. I will
investigate.

> 
> #echo online_kernel > memory32/state
> write error: Invalid argument
> // that's not what's expected

this is proper behavior with the current implementation. Does anything
depend on the zone reusing?

> memory32:offline removable: 1  zones: Normal Movable
> memory33:online removable: 1  zones: Movable
> memory34:offline removable: 0  zones: Movable
> memory35:offline removable: 0  zones: Movable
> 
> 
> ======
> #issue2: dimm1 assigned to node 1 on qemu CLI
> memblock is onlined as movable by default
> 
> // after boot
> memory32:offline removable: 1  zones: Normal
> memory33:offline removable: 1  zones: Normal Movable
> memory34:offline removable: 1  zones: Normal
> memory35:offline removable: 1  zones: Normal Movable
> // not related to this issue but notice not all blocks are
> // "Normal Movable" when compared when both dimms on node 0 /#issue1/

yes they should be

> #echo online_movable > memory33/state
> #echo online > memory32/state
> 
> memory32:online removable: 1  zones: Movable
> memory33:online removable: 1  zones: Movable
> 
> before series memory32 goes to zone NORMAL as expected
> memory32:online removable: 0  zones: Normal Movable
> memory33:online removable: 1  zones: Movable Normal

OK, I will double check.
 
> ======
> #issue3:
> removable flag flipped to non-removable state
> 
> // before series at commit ef0b577b6:
> memory32:offline removable: 0  zones: Normal Movable
> memory33:offline removable: 0  zones: Normal Movable
> memory34:offline removable: 0  zones: Normal Movable
> memory35:offline removable: 0  zones: Normal Movable
> 
> // after series at commit 6a010434
> memory32:offline removable: 1  zones: Normal
> memory33:offline removable: 1  zones: Normal
> memory34:offline removable: 1  zones: Normal
> memory35:offline removable: 1  zones: Normal Movable
> 
> also looking at #issue1 removable flag state doesn't
> seem to be consistent between state changes but maybe that's
> been broken before

OK, will have a look.

Thanks for your testing!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

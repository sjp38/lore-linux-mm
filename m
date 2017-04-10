Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 892F16B039F
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 12:02:34 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b78so3067865wrd.18
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 09:02:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y33si16709033wrd.301.2017.04.10.09.02.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 09:02:33 -0700 (PDT)
Date: Mon, 10 Apr 2017 18:02:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -v2 0/9] mm: make movable onlining suck less
Message-ID: <20170410160228.GI4618@dhcp22.suse.cz>
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
> #issue3:
> removable flag flipped to non-removable state
> 
> // before series at commit ef0b577b6:
> memory32:offline removable: 0  zones: Normal Movable
> memory33:offline removable: 0  zones: Normal Movable
> memory34:offline removable: 0  zones: Normal Movable
> memory35:offline removable: 0  zones: Normal Movable

did you mean _after_ the series because the bellow looks like
the original behavior (at least valid_zones).
 
> // after series at commit 6a010434
> memory32:offline removable: 1  zones: Normal
> memory33:offline removable: 1  zones: Normal
> memory34:offline removable: 1  zones: Normal
> memory35:offline removable: 1  zones: Normal Movable
> 
> also looking at #issue1 removable flag state doesn't
> seem to be consistent between state changes but maybe that's
> been broken before

Well, the file has a very questionable semantic. It doesn't provide
a stable information. Anyway put that aside.
is_pageblock_removable_nolock relies on having zone association
which we do not have yet if the memblock is offline. So we need
the following. I will queue this as a preparatory patch.
---

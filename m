Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 291F3831F4
	for <linux-mm@kvack.org>; Thu,  4 May 2017 09:39:11 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id n198so1592238wmg.9
        for <linux-mm@kvack.org>; Thu, 04 May 2017 06:39:11 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id v62si1522828wmb.41.2017.05.04.06.39.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 May 2017 06:39:08 -0700 (PDT)
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
 <20170504112159.GC31540@dhcp22.suse.cz>
 <83d4556c-b21c-7ae5-6e83-4621a74f9fd5@huawei.com>
 <20170504131131.GI31540@dhcp22.suse.cz>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <df1b34fb-f90b-da9e-6723-49e8f1cb1757@huawei.com>
Date: Thu, 4 May 2017 16:37:55 +0300
MIME-Version: 1.0
In-Reply-To: <20170504131131.GI31540@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>

On 04/05/17 16:11, Michal Hocko wrote:
> On Thu 04-05-17 15:14:10, Igor Stoppa wrote:

> I believe that this is a fundamental question. Sealing sounds useful
> for after-boot usecases as well and it would change the approach
> considerably. Coming up with an ad-hoc solution for the boot only way
> seems like a wrong way to me. And as you've said SELinux which is your
> target already does the thing after the early boot.

I didn't spend too many thoughts on this so far, because the zone-based
approach seemed almost doomed, so I wanted to wait for the evolution of
the discussion :-)

The main question here is granularity, I think.

At least, as first cut, the simpler approach would be to have a master
toggle: when some legitimate operation needs to happen, the seal is
lifted across the entire range, then it is put back in place, once the
operation has concluded.

Simplicity is the main advantage.

The disadvantage is that anything can happen, undetected, while the seal
is lifted.
OTOH the amount of code that could backfire should be fairly limited, so
it doesn't seem a huge issue to me.

The alternative would be to somehow know what a write will change and
make only the appropriate page(s) writable. But it seems overkill to me.
Especially because in some cases, with huge pages, everything would fit
anyway in one page.

One more option that comes to mind - but I do not know how realistic it
would be - is to have multiple slabs, to be used for different purposes.
Ex: one for the monolithic kernel and one for modules.
It wouldn't help for livepatch, though, as it can modify both, so both
would have to be unprotected.

But live-patching is potentially a far less frequent event than module
loading/unloading (thinking about USB gadgets, for example).

[...]

> Slab pages are not migrateable currently. Even if they start being
> migrateable it would be an opt-in because that requires pointers tracking
> to make sure they are updated properly.

ok

[...]

> I haven't researched that too deeply. In principle both SLAB and SLUB
> maintain slab pages in a similar way so I do not see any fundamental
> problems.


good, then I could proceed with the prototype, if there are no further
objections/questions and we agree that, implementation aside, there are
no obvious fundamental problems preventing the merge


---
thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

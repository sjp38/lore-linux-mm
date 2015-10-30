Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id DDB5F82F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 15:42:20 -0400 (EDT)
Received: by padhy1 with SMTP id hy1so76809531pad.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 12:42:20 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id td8si13112276pac.42.2015.10.30.12.42.19
        for <linux-mm@kvack.org>;
        Fri, 30 Oct 2015 12:42:20 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH] mm: Introduce kernelcore=reliable option
Date: Fri, 30 Oct 2015 19:42:17 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32B64312@ORSMSX114.amr.corp.intel.com>
References: <1444915942-15281-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <3908561D78D1C84285E8C5FCA982C28F32B5A060@ORSMSX114.amr.corp.intel.com>
 <5628B427.3050403@jp.fujitsu.com>
 <3908561D78D1C84285E8C5FCA982C28F32B5C7AE@ORSMSX114.amr.corp.intel.com>
 <E86EADE93E2D054CBCD4E708C38D364A54280C26@G01JPEXMBYT01>
 <322B7BFA-08FE-4A8F-B54C-86901BDB7CBD@intel.com>
 <56330C0A.3060901@jp.fujitsu.com>
In-Reply-To: <56330C0A.3060901@jp.fujitsu.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

> If each memory controller has the same distance/latency, you (your firmwa=
re) don't need
> to allocate reliable memory per each memory controller.
> If distance is problem, another node should be allocated.
>
> ...is the behavior(splitting zone) really required ?

It's useful from a memory bandwidth perspective to have allocations
spread across both memory controllers. Keeping a whole bunch of
Xeon cores fed needs all the bandwidth you can get.

Socket0 is also a problem.  We want to mirror <4GB addresses because
there is a bunch of critical stuff there (entire kernel text+data). But we
can currently only mirror one block per memory controller, so we end up
with just 2GB mirrored (the 2GB-4GB range is MMIO).  This isn't enough
for even a small machine (I have 128GB on node0 ... but that is really the
bare minimum configuration ... 2GB is only enough to cover the "struct
page" allocations for node0).  I really have to allocate some more mirror
from the other memory controller.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

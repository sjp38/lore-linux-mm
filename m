Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 08CE26B0279
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 16:19:37 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b13so185462025pgn.4
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 13:19:37 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id f68si9866362pfe.95.2017.06.21.13.19.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 13:19:36 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH] mm/hwpoison: Clear PRESENT bit for kernel 1:1 mappings
 of poison pages
Date: Wed, 21 Jun 2017 20:19:34 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F612DCC2E@ORSMSX114.amr.corp.intel.com>
References: <20170616190200.6210-1-tony.luck@intel.com>
 <20170619180147.qolal6mz2wlrjbxk@pd.tnic>
 <20170621174740.npbtg2e4o65tyrss@intel.com>
 <AT5PR84MB0082333B55A6823A73C28989ABDA0@AT5PR84MB0082.NAMPRD84.PROD.OUTLOOK.COM>
In-Reply-To: <AT5PR84MB0082333B55A6823A73C28989ABDA0@AT5PR84MB0082.NAMPRD84.PROD.OUTLOOK.COM>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>, Borislav Petkov <bp@suse.de>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Yazen Ghannam <yazen.ghannam@amd.com>, "Williams, Dan J" <dan.j.williams@intel.com>, "Kani, Toshimitsu" <toshi.kani@hpe.com>, "Vaden, Tom (HPE Server OS Architecture)" <tom.vaden@hpe.com>

>> +if (set_memory_np(decoy_addr, 1))
>> +pr_warn("Could not invalidate pfn=3D0x%lx from 1:1 map \n", pfn);
>
> Does this patch handle breaking up 512 GiB, 1 GiB or 2 MiB page mappings
> if it's just trying to mark a 4 KiB page as bad?

Yes.  The 1:1 mappings start out using the largest supported page size.  Th=
is
call will break up huge/large pages so that only 4KB is mapped out.
[This will affect performance because of the extra levels of TLB walks]

> Although the kernel doesn't use MTRRs itself anymore, what if the system
> BIOS still uses them for some memory regions, and the bad address falls i=
n
> an MTRR region?

This code is called after mm/memory-failure.c:memory_failure() has already
checked that the page is one managed by the kernel.  In general machine che=
cks
from other regions are going to be called out as fatal before we get here.

-Tony




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

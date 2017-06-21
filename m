Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C3F2B6B02B4
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 16:30:48 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r70so168932138pfb.7
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 13:30:48 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id s8si14361301pgr.167.2017.06.21.13.30.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 13:30:48 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH] mm/hwpoison: Clear PRESENT bit for kernel 1:1 mappings
 of poison pages
Date: Wed, 21 Jun 2017 20:30:46 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F612DCCAF@ORSMSX114.amr.corp.intel.com>
References: <20170616190200.6210-1-tony.luck@intel.com>
 <20170621021226.GA18024@hori1.linux.bs1.fc.nec.co.jp>
 <20170621175403.n5kssz32e2oizl7k@intel.com>
 <AT5PR84MB0082AF4EDEB05999494CA62FABDA0@AT5PR84MB0082.NAMPRD84.PROD.OUTLOOK.COM>
In-Reply-To: <AT5PR84MB0082AF4EDEB05999494CA62FABDA0@AT5PR84MB0082.NAMPRD84.PROD.OUTLOOK.COM>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Borislav Petkov <bp@suse.de>, "Hansen, Dave" <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "Kani, Toshimitsu" <toshi.kani@hpe.com>, "Vaden,
 Tom (HPE Server OS Architecture)" <tom.vaden@hpe.com>

> Persistent memory does have unpoisoning and would require this inverse
> operation - see drivers/nvdimm/pmem.c pmem_clear_poison() and core.c
> nvdimm_clear_poison().

Nice.  Well this code will need to cooperate with that ... in particular if=
 the page
is in an area that can be unpoisoned ... then we should do that *instead* o=
f marking
the page not present (which breaks up huge/large pages and so affects perfo=
rmance).

Instead of calling it "arch_unmap_pfn" it could be called something like ar=
ch_handle_poison()
and do something like:

void arch_handle_poison(unsigned long pfn)
{
	if this is a pmem page && pmem_clear_poison(pfn)
		return
	if this is a nvdimm page && nvdimm_clear_poison(pfn)
		return
	/* can't clear, map out from 1:1 region */
	... code from my patch ...
}

I'm just not sure how those first two "if" bits work ... particularly in te=
rms of CONFIG dependencies and system
capabilities.  Perhaps each of pmem and nvdimm could register their unpoiso=
n functions and this code could
just call each in turn?

-Tony


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

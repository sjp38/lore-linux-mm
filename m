Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 626546B02FD
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 18:05:02 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e3so38365843pfc.4
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 15:05:02 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 88si277297plb.131.2017.06.27.15.05.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 15:05:00 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH] mm/hwpoison: Clear PRESENT bit for kernel 1:1 mappings
 of poison pages
Date: Tue, 27 Jun 2017 22:04:58 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F612E4285@ORSMSX114.amr.corp.intel.com>
References: <20170616190200.6210-1-tony.luck@intel.com>
 <20170619180147.qolal6mz2wlrjbxk@pd.tnic>
 <20170621174740.npbtg2e4o65tyrss@intel.com>
 <AT5PR84MB00823EB30BD7BF0EA3DAFF0BABD80@AT5PR84MB0082.NAMPRD84.PROD.OUTLOOK.COM>
In-Reply-To: <AT5PR84MB00823EB30BD7BF0EA3DAFF0BABD80@AT5PR84MB0082.NAMPRD84.PROD.OUTLOOK.COM>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>, Borislav Petkov <bp@suse.de>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Yazen Ghannam <yazen.ghannam@amd.com>, "Kani, Toshimitsu" <toshi.kani@hpe.com>, "Williams, Dan J" <dan.j.williams@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

> > > > +if (set_memory_np(decoy_addr, 1))
> > > > +pr_warn("Could not invalidate pfn=3D0x%lx from 1:1 map \n",
>
> Another concept to consider is mapping the page as UC rather than
> completely unmapping it.

UC would also avoid the speculative prefetch issue.  The Vol 3, Section 11.=
3 SDM says:

Strong Uncacheable (UC) -System memory locations are not cached. All reads =
and writes
appear on the system bus and are executed in program order without reorderi=
ng. No speculative
memory accesses, pagetable walks, or prefetches of speculated branch target=
s are made.
This type of cache-control is useful for memory-mapped I/O devices. When us=
ed with normal
RAM, it greatly reduces processor performance.

But then I went and read the code for set_memory_uc() ... which calls "rese=
rve_memtyep()"
which does all kinds of things to avoid issues with MTRRs and other stuff. =
 Which all looks
really more complex that we need just here.

> The uncorrectable error scope could be smaller than a page size, like:
> * memory ECC width (e.g., 8 bytes)
> * cache line size (e.g., 64 bytes)
> * block device logical block size (e.g., 512 bytes, for persistent memory=
)
>
> UC preserves the ability to access adjacent data within the page that
> hasn't gone bad, and is particularly useful for persistent memory.

If you want to dig into the non-poisoned pieces of the page later it might =
be
better to set up a new scratch UC mapping to do that.

My takeaway from Dan's comments on unpoisoning is that this isn't the conte=
xt
that he wants to do that.  He'd rather wait until he has somebody overwriti=
ng the
page with fresh data.

So I think I'd like to keep the patch as-is.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

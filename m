Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 38AB96B0292
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 18:20:56 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id g7so55351924pgr.3
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 15:20:56 -0700 (PDT)
Received: from g2t2352.austin.hpe.com (g2t2352.austin.hpe.com. [15.233.44.25])
        by mx.google.com with ESMTPS id 71si3554946pfo.179.2017.06.23.15.20.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 15:20:55 -0700 (PDT)
From: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Subject: RE: [PATCH] mm/hwpoison: Clear PRESENT bit for kernel 1:1 mappings of
 poison pages
Date: Fri, 23 Jun 2017 22:19:35 +0000
Message-ID: <AT5PR84MB00823EB30BD7BF0EA3DAFF0BABD80@AT5PR84MB0082.NAMPRD84.PROD.OUTLOOK.COM>
References: <20170616190200.6210-1-tony.luck@intel.com>
 <20170619180147.qolal6mz2wlrjbxk@pd.tnic>
 <20170621174740.npbtg2e4o65tyrss@intel.com>
In-Reply-To: <20170621174740.npbtg2e4o65tyrss@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Borislav Petkov <bp@suse.de>
Cc: Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Yazen Ghannam <yazen.ghannam@amd.com>, "Kani,
 Toshimitsu" <toshi.kani@hpe.com>, "'dan.j.williams@intel.com'" <dan.j.williams@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

> > > +	if (set_memory_np(decoy_addr, 1))
> > > +		pr_warn("Could not invalidate pfn=3D0x%lx from 1:1 map \n",

Another concept to consider is mapping the page as UC rather than
completely unmapping it.

The uncorrectable error scope could be smaller than a page size, like:
* memory ECC width (e.g., 8 bytes)
* cache line size (e.g., 64 bytes)
* block device logical block size (e.g., 512 bytes, for persistent memory)

UC preserves the ability to access adjacent data within the page that
hasn't gone bad, and is particularly useful for persistent memory.

---
Robert Elliott, HPE Persistent Memory


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

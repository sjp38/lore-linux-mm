Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC1A96B0279
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:07:19 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id z48so24166210otz.6
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 22:07:19 -0700 (PDT)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id n55si1271875otd.0.2017.06.22.22.07.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 22:07:18 -0700 (PDT)
Received: by mail-oi0-x230.google.com with SMTP id b6so19971481oia.1
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 22:07:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F612DCCAF@ORSMSX114.amr.corp.intel.com>
References: <20170616190200.6210-1-tony.luck@intel.com> <20170621021226.GA18024@hori1.linux.bs1.fc.nec.co.jp>
 <20170621175403.n5kssz32e2oizl7k@intel.com> <AT5PR84MB0082AF4EDEB05999494CA62FABDA0@AT5PR84MB0082.NAMPRD84.PROD.OUTLOOK.COM>
 <3908561D78D1C84285E8C5FCA982C28F612DCCAF@ORSMSX114.amr.corp.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 22 Jun 2017 22:07:18 -0700
Message-ID: <CAPcyv4igNoRZ1EJxeD01xwq5AU_hhEs4LoXs-8XA2mFbWDr5eA@mail.gmail.com>
Subject: Re: [PATCH] mm/hwpoison: Clear PRESENT bit for kernel 1:1 mappings of
 poison pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Borislav Petkov <bp@suse.de>, "Hansen, Dave" <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "Kani, Toshimitsu" <toshi.kani@hpe.com>, "Vaden, Tom (HPE Server OS Architecture)" <tom.vaden@hpe.com>

On Wed, Jun 21, 2017 at 1:30 PM, Luck, Tony <tony.luck@intel.com> wrote:
>> Persistent memory does have unpoisoning and would require this inverse
>> operation - see drivers/nvdimm/pmem.c pmem_clear_poison() and core.c
>> nvdimm_clear_poison().
>
> Nice.  Well this code will need to cooperate with that ... in particular if the page
> is in an area that can be unpoisoned ... then we should do that *instead* of marking
> the page not present (which breaks up huge/large pages and so affects performance).
>
> Instead of calling it "arch_unmap_pfn" it could be called something like arch_handle_poison()
> and do something like:
>
> void arch_handle_poison(unsigned long pfn)
> {
>         if this is a pmem page && pmem_clear_poison(pfn)
>                 return
>         if this is a nvdimm page && nvdimm_clear_poison(pfn)
>                 return
>         /* can't clear, map out from 1:1 region */
>         ... code from my patch ...
> }
>
> I'm just not sure how those first two "if" bits work ... particularly in terms of CONFIG dependencies and system
> capabilities.  Perhaps each of pmem and nvdimm could register their unpoison functions and this code could
> just call each in turn?

We don't unpoison pmem without new data to write in it's place. What
context is arch_handle_poison() called? Ideally we only "clear" poison
when we know we are trying to write zero over the poisoned range.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

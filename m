Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 523016B0315
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 18:09:23 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id r65so17162961qki.8
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 15:09:23 -0700 (PDT)
Received: from mail-qt0-x236.google.com (mail-qt0-x236.google.com. [2607:f8b0:400d:c0d::236])
        by mx.google.com with ESMTPS id c28si448062qtg.85.2017.06.27.15.09.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 15:09:22 -0700 (PDT)
Received: by mail-qt0-x236.google.com with SMTP id f92so36248901qtb.2
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 15:09:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F612E4285@ORSMSX114.amr.corp.intel.com>
References: <20170616190200.6210-1-tony.luck@intel.com> <20170619180147.qolal6mz2wlrjbxk@pd.tnic>
 <20170621174740.npbtg2e4o65tyrss@intel.com> <AT5PR84MB00823EB30BD7BF0EA3DAFF0BABD80@AT5PR84MB0082.NAMPRD84.PROD.OUTLOOK.COM>
 <3908561D78D1C84285E8C5FCA982C28F612E4285@ORSMSX114.amr.corp.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 27 Jun 2017 15:09:21 -0700
Message-ID: <CAPcyv4gC_6TpwVSjuOzxrz3OdVZCVWD0QVWhBzAuOxUNHJHRMQ@mail.gmail.com>
Subject: Re: [PATCH] mm/hwpoison: Clear PRESENT bit for kernel 1:1 mappings of
 poison pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>, Borislav Petkov <bp@suse.de>, "Hansen, Dave" <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Yazen Ghannam <yazen.ghannam@amd.com>, "Kani, Toshimitsu" <toshi.kani@hpe.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Tue, Jun 27, 2017 at 3:04 PM, Luck, Tony <tony.luck@intel.com> wrote:
>> > > > +if (set_memory_np(decoy_addr, 1))
>> > > > +pr_warn("Could not invalidate pfn=0x%lx from 1:1 map \n",
>>
>> Another concept to consider is mapping the page as UC rather than
>> completely unmapping it.
>
> UC would also avoid the speculative prefetch issue.  The Vol 3, Section 11.3 SDM says:
>
> Strong Uncacheable (UC) -System memory locations are not cached. All reads and writes
> appear on the system bus and are executed in program order without reordering. No speculative
> memory accesses, pagetable walks, or prefetches of speculated branch targets are made.
> This type of cache-control is useful for memory-mapped I/O devices. When used with normal
> RAM, it greatly reduces processor performance.
>
> But then I went and read the code for set_memory_uc() ... which calls "reserve_memtyep()"
> which does all kinds of things to avoid issues with MTRRs and other stuff.  Which all looks
> really more complex that we need just here.
>
>> The uncorrectable error scope could be smaller than a page size, like:
>> * memory ECC width (e.g., 8 bytes)
>> * cache line size (e.g., 64 bytes)
>> * block device logical block size (e.g., 512 bytes, for persistent memory)
>>
>> UC preserves the ability to access adjacent data within the page that
>> hasn't gone bad, and is particularly useful for persistent memory.
>
> If you want to dig into the non-poisoned pieces of the page later it might be
> better to set up a new scratch UC mapping to do that.
>
> My takeaway from Dan's comments on unpoisoning is that this isn't the context
> that he wants to do that.  He'd rather wait until he has somebody overwriting the
> page with fresh data.
>
> So I think I'd like to keep the patch as-is.

Yes, the persistent-memory poison interactions should be handled
separately and not hold up this patch for the normal system-memory
case. We might dove-tail support for this into stray write protection
where we unmap all of pmem while nothing in the kernel is actively
accessing it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

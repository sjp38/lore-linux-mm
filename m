Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 91CA78E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 15:42:17 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id g12so8892879pll.22
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 12:42:17 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id d12si75273740pgf.470.2019.01.11.12.42.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 12:42:16 -0800 (PST)
Subject: Re: [RFC PATCH v7 00/16] Add support for eXclusive Page Frame
 Ownership
References: <cover.1547153058.git.khalid.aziz@oracle.com>
 <31fe7522-0a59-94c8-663e-049e9ad2bff6@intel.com>
 <7e3b2c4b-51ff-2027-3a53-8c798c2ca588@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <8ffc77a9-6eae-7287-0ea3-56bfb61758cd@intel.com>
Date: Fri, 11 Jan 2019 12:42:14 -0800
MIME-Version: 1.0
In-Reply-To: <7e3b2c4b-51ff-2027-3a53-8c798c2ca588@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>

>> The second process could easily have the page's old TLB entry.  It could
>> abuse that entry as long as that CPU doesn't context switch
>> (switch_mm_irqs_off()) or otherwise flush the TLB entry.
> 
> That is an interesting scenario. Working through this scenario, physmap
> TLB entry for a page is flushed on the local processor when the page is
> allocated to userspace, in xpfo_alloc_pages(). When the userspace passes
> page back into kernel, that page is mapped into kernel space using a va
> from kmap pool in xpfo_kmap() which can be different for each new
> mapping of the same page. The physical page is unmapped from kernel on
> the way back from kernel to userspace by xpfo_kunmap(). So two processes
> on different CPUs sharing same physical page might not be seeing the
> same virtual address for that page while they are in the kernel, as long
> as it is an address from kmap pool. ret2dir attack relies upon being
> able to craft a predictable virtual address in the kernel physmap for a
> physical page and redirect execution to that address. Does that sound right?

All processes share one set of kernel page tables.  Or, did your patches
change that somehow that I missed?

Since they share the page tables, they implicitly share kmap*()
mappings.  kmap_atomic() is not *used* by more than one CPU, but the
mapping is accessible and at least exists for all processors.

I'm basically assuming that any entry mapped in a shared page table is
exploitable on any CPU regardless of where we logically *want* it to be
used.

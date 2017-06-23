Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3016B0292
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 16:59:47 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id m82so19636696pfk.0
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 13:59:47 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id l83si3990358pfk.80.2017.06.23.13.59.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 13:59:46 -0700 (PDT)
Date: Fri, 23 Jun 2017 13:59:45 -0700
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH] mm/hwpoison: Clear PRESENT bit for kernel 1:1 mappings
 of poison pages
Message-ID: <20170623205945.ovhfyymzfkevazpd@intel.com>
References: <20170616190200.6210-1-tony.luck@intel.com>
 <20170621021226.GA18024@hori1.linux.bs1.fc.nec.co.jp>
 <20170621175403.n5kssz32e2oizl7k@intel.com>
 <AT5PR84MB0082AF4EDEB05999494CA62FABDA0@AT5PR84MB0082.NAMPRD84.PROD.OUTLOOK.COM>
 <3908561D78D1C84285E8C5FCA982C28F612DCCAF@ORSMSX114.amr.corp.intel.com>
 <CAPcyv4igNoRZ1EJxeD01xwq5AU_hhEs4LoXs-8XA2mFbWDr5eA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4igNoRZ1EJxeD01xwq5AU_hhEs4LoXs-8XA2mFbWDr5eA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Borislav Petkov <bp@suse.de>, "Hansen, Dave" <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "Kani, Toshimitsu" <toshi.kani@hpe.com>, "Vaden, Tom (HPE Server OS Architecture)" <tom.vaden@hpe.com>

On Thu, Jun 22, 2017 at 10:07:18PM -0700, Dan Williams wrote:
> On Wed, Jun 21, 2017 at 1:30 PM, Luck, Tony <tony.luck@intel.com> wrote:
> >> Persistent memory does have unpoisoning and would require this inverse
> >> operation - see drivers/nvdimm/pmem.c pmem_clear_poison() and core.c
> >> nvdimm_clear_poison().
> >
> > Nice.  Well this code will need to cooperate with that ... in particular if the page
> > is in an area that can be unpoisoned ... then we should do that *instead* of marking
> > the page not present (which breaks up huge/large pages and so affects performance).
> >
> > Instead of calling it "arch_unmap_pfn" it could be called something like arch_handle_poison()
> > and do something like:
> >
> > void arch_handle_poison(unsigned long pfn)
> > {
> >         if this is a pmem page && pmem_clear_poison(pfn)
> >                 return
> >         if this is a nvdimm page && nvdimm_clear_poison(pfn)
> >                 return
> >         /* can't clear, map out from 1:1 region */
> >         ... code from my patch ...
> > }
> >
> > I'm just not sure how those first two "if" bits work ... particularly in terms of CONFIG dependencies and system
> > capabilities.  Perhaps each of pmem and nvdimm could register their unpoison functions and this code could
> > just call each in turn?
> 
> We don't unpoison pmem without new data to write in it's place. What
> context is arch_handle_poison() called? Ideally we only "clear" poison
> when we know we are trying to write zero over the poisoned range.

Context is that of the process that did the access (but we've moved
off the machine check stack and are now in normal kernel context).
We are about to unmap this page from all applications that are
using it.  But they may be running ... so now it a bad time to
clear the poison. They might access the page and not get a signal.

If I move this code to after all the users PTEs have been cleared
and TLBs flushed, then it would be safe to try to unpoison the page
and not invalidate from the 1:1 mapping.

But I'm not sure what happens next. For a normal DDR4 page I could
put it back on the free list and allow it to be re-used. But for
PMEM you have some other cleanup that you need to do to mark the
block as lost from your file system.

Is this too early for you to be able to do that?

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

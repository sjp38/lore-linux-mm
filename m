Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 18CF66B000A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 00:44:47 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w185-v6so27223981oig.19
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 21:44:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n76-v6sor16849576oig.126.2018.07.12.21.44.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Jul 2018 21:44:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <153074042316.27838.17319837331947007626.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153074042316.27838.17319837331947007626.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 12 Jul 2018 21:44:44 -0700
Message-ID: <CAPcyv4gxt3iT_Y11WVHXZfctcf_i2MWpe=jc0WB2JrsVcOk7MQ@mail.gmail.com>
Subject: Re: [PATCH v5 00/11] mm: Teach memory_failure() about ZONE_DEVICE pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm <linux-nvdimm@lists.01.org>
Cc: linux-edac@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@alien8.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Hellwig <hch@lst.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Souptick Joarder <jrdr.linux@gmail.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>

On Wed, Jul 4, 2018 at 2:40 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> Changes since v4 [1]:
> * Rework dax_lock_page() to reuse get_unlocked_mapping_entry() (Jan)
>
> * Change the calling convention to take a 'struct page *' and return
>   success / failure instead of performing the pfn_to_page() internal to
>   the api (Jan, Ross).
>
> * Rename dax_lock_page() to dax_lock_mapping_entry() (Jan)
>
> * Account for the case that a given pfn can be fsdax mapped with
>   different sizes in different vmas (Jan)
>
> * Update collect_procs() to determine the mapping size of the pfn for
>   each page given it can be variable in the dax case.
>
> [1]: https://lists.01.org/pipermail/linux-nvdimm/2018-June/016279.html
>
> ---
>
> As it stands, memory_failure() gets thoroughly confused by dev_pagemap
> backed mappings. The recovery code has specific enabling for several
> possible page states and needs new enabling to handle poison in dax
> mappings.
>
> In order to support reliable reverse mapping of user space addresses:
>
> 1/ Add new locking in the memory_failure() rmap path to prevent races
> that would typically be handled by the page lock.
>
> 2/ Since dev_pagemap pages are hidden from the page allocator and the
> "compound page" accounting machinery, add a mechanism to determine the
> size of the mapping that encompasses a given poisoned pfn.
>
> 3/ Given pmem errors can be repaired, change the speculatively accessed
> poison protection, mce_unmap_kpfn(), to be reversible and otherwise
> allow ongoing access from the kernel.
>
> A side effect of this enabling is that MADV_HWPOISON becomes usable for
> dax mappings, however the primary motivation is to allow the system to
> survive userspace consumption of hardware-poison via dax. Specifically
> the current behavior is:
>
>     mce: Uncorrected hardware memory error in user-access at af34214200
>     {1}[Hardware Error]: It has been corrected by h/w and requires no further action
>     mce: [Hardware Error]: Machine check events logged
>     {1}[Hardware Error]: event severity: corrected
>     Memory failure: 0xaf34214: reserved kernel page still referenced by 1 users
>     [..]
>     Memory failure: 0xaf34214: recovery action for reserved kernel page: Failed
>     mce: Memory error not recovered
>     <reboot>
>
> ...and with these changes:
>
>     Injecting memory failure for pfn 0x20cb00 at process virtual address 0x7f763dd00000
>     Memory failure: 0x20cb00: Killing dax-pmd:5421 due to hardware memory corruption
>     Memory failure: 0x20cb00: recovery action for dax page: Recovered
>
> Given all the cross dependencies I propose taking this through
> nvdimm.git with acks from Naoya, x86/core, x86/RAS, and of course dax
> folks.
>

Hi,

Any comments on this series? Matthew is patiently waiting to rebase
some of his Xarray work until the dax_lock_mapping_entry() changes hit
-next.

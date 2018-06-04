Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 339466B0005
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 10:31:29 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s84-v6so17793101oig.17
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 07:31:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b9-v6sor20297653oia.135.2018.06.04.07.31.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Jun 2018 07:31:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180604124031.GP19202@dhcp22.suse.cz>
References: <152800336321.17112.3300876636370683279.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180604124031.GP19202@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 4 Jun 2018 07:31:25 -0700
Message-ID: <CAPcyv4gLxz7Ke6ApXoATDN31PSGwTgNRLTX-u1dtT3d+6jmzjw@mail.gmail.com>
Subject: Re: [PATCH v2 00/11] mm: Teach memory_failure() about ZONE_DEVICE pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, linux-edac@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@alien8.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Hellwig <hch@lst.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ingo Molnar <mingo@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Souptick Joarder <jrdr.linux@gmail.com>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Mon, Jun 4, 2018 at 5:40 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Sat 02-06-18 22:22:43, Dan Williams wrote:
>> Changes since v1 [1]:
>> * Rework the locking to not use lock_page() instead use a combination of
>>   rcu_read_lock(), xa_lock_irq(&mapping->pages), and igrab() to validate
>>   that dax pages are still associated with the given mapping, and to
>>   prevent the address_space from being freed while memory_failure() is
>>   busy. (Jan)
>>
>> * Fix use of MF_COUNT_INCREASED in madvise_inject_error() to account for
>>   the case where the injected error is a dax mapping and the pinned
>>   reference needs to be dropped. (Naoya)
>>
>> * Clarify with a comment that VM_FAULT_NOPAGE may not always indicate a
>>   mapping of the storage capacity, it could also indicate the zero page.
>>   (Jan)
>>
>> [1]: https://lists.01.org/pipermail/linux-nvdimm/2018-May/015932.html
>>
>> ---
>>
>> As it stands, memory_failure() gets thoroughly confused by dev_pagemap
>> backed mappings. The recovery code has specific enabling for several
>> possible page states and needs new enabling to handle poison in dax
>> mappings.
>>
>> In order to support reliable reverse mapping of user space addresses:
>>
>> 1/ Add new locking in the memory_failure() rmap path to prevent races
>> that would typically be handled by the page lock.
>>
>> 2/ Since dev_pagemap pages are hidden from the page allocator and the
>> "compound page" accounting machinery, add a mechanism to determine the
>> size of the mapping that encompasses a given poisoned pfn.
>>
>> 3/ Given pmem errors can be repaired, change the speculatively accessed
>> poison protection, mce_unmap_kpfn(), to be reversible and otherwise
>> allow ongoing access from the kernel.
>
> This doesn't really describe the problem you are trying to solve and why
> do you believe that HWPoison is the best way to handle it. As things
> stand HWPoison is rather ad-hoc and I am not sure adding more to it is
> really great without some deep reconsidering how the whole thing is done
> right now IMHO. Are you actually trying to solve some real world problem
> or you merely want to make soft offlining work properly?

I'm trying to solve this real world problem when real poison is
consumed through a dax mapping:

        mce: Uncorrected hardware memory error in user-access at af34214200
        {1}[Hardware Error]: It has been corrected by h/w and requires
no further action
        mce: [Hardware Error]: Machine check events logged
        {1}[Hardware Error]: event severity: corrected
        Memory failure: 0xaf34214: reserved kernel page still
referenced by 1 users
        [..]
        Memory failure: 0xaf34214: recovery action for reserved kernel
page: Failed
        mce: Memory error not recovered

...i.e. currently all poison consumed through dax mappings is
needlessly system fatal.

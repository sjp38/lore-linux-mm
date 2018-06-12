Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id C0F886B0005
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 19:38:04 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id n40-v6so428762ote.13
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 16:38:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p8-v6sor532283oig.95.2018.06.12.16.38.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Jun 2018 16:38:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180612201420.GA12706@linux.intel.com>
References: <152850182079.38390.8280340535691965744.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152850187949.38390.1012249765651998342.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180612201420.GA12706@linux.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 12 Jun 2018 16:38:02 -0700
Message-ID: <CAPcyv4htXbtUieMJH2bSgNoVqkUikFES6b7nL=a+FVs0Syg+wg@mail.gmail.com>
Subject: Re: [PATCH v4 11/12] mm, memory_failure: Teach memory_failure() about
 dev_pagemap pages
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue, Jun 12, 2018 at 1:14 PM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> On Fri, Jun 08, 2018 at 04:51:19PM -0700, Dan Williams wrote:
>>     mce: Uncorrected hardware memory error in user-access at af34214200
>>     {1}[Hardware Error]: It has been corrected by h/w and requires no fu=
rther action
>>     mce: [Hardware Error]: Machine check events logged
>>     {1}[Hardware Error]: event severity: corrected
>>     Memory failure: 0xaf34214: reserved kernel page still referenced by =
1 users
>>     [..]
>>     Memory failure: 0xaf34214: recovery action for reserved kernel page:=
 Failed
>>     mce: Memory error not recovered
>>
>> In contrast to typical memory, dev_pagemap pages may be dax mapped. With
>> dax there is no possibility to map in another page dynamically since dax
>> establishes 1:1 physical address to file offset associations. Also
>> dev_pagemap pages associated with NVDIMM / persistent memory devices can
>> internal remap/repair addresses with poison. While memory_failure()
>> assumes that it can discard typical poisoned pages and keep them
>> unmapped indefinitely, dev_pagemap pages may be returned to service
>> after the error is cleared.
>>
>> Teach memory_failure() to detect and handle MEMORY_DEVICE_HOST
>> dev_pagemap pages that have poison consumed by userspace. Mark the
>> memory as UC instead of unmapping it completely to allow ongoing access
>> via the device driver (nd_pmem). Later, nd_pmem will grow support for
>> marking the page back to WB when the error is cleared.
>>
>> Cc: Jan Kara <jack@suse.cz>
>> Cc: Christoph Hellwig <hch@lst.de>
>> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>> Cc: Matthew Wilcox <mawilcox@microsoft.com>
>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> ---
> <>
>> +static int memory_failure_dev_pagemap(unsigned long pfn, int flags,
>> +             struct dev_pagemap *pgmap)
>> +{
>> +     const bool unmap_success =3D true;
>> +     unsigned long size;
>> +     struct page *page;
>> +     LIST_HEAD(tokill);
>> +     int rc =3D -EBUSY;
>> +     loff_t start;
>> +
>> +     /*
>> +      * Prevent the inode from being freed while we are interrogating
>> +      * the address_space, typically this would be handled by
>> +      * lock_page(), but dax pages do not use the page lock.
>> +      */
>> +     page =3D dax_lock_page(pfn);
>> +     if (!page)
>> +             goto out;
>> +
>> +     if (hwpoison_filter(page)) {
>> +             rc =3D 0;
>> +             goto unlock;
>> +     }
>> +
>> +     switch (pgmap->type) {
>> +     case MEMORY_DEVICE_PRIVATE:
>> +     case MEMORY_DEVICE_PUBLIC:
>> +             /*
>> +              * TODO: Handle HMM pages which may need coordination
>> +              * with device-side memory.
>> +              */
>> +             goto unlock;
>> +     default:
>> +             break;
>> +     }
>> +
>> +     /*
>> +      * If the page is not mapped in userspace then report it as
>> +      * unhandled.
>> +      */
>> +     size =3D dax_mapping_size(page);
>> +     if (!size) {
>> +             pr_err("Memory failure: %#lx: failed to unmap page\n", pfn=
);
>> +             goto unlock;
>> +     }
>> +
>> +     SetPageHWPoison(page);
>> +
>> +     /*
>> +      * Unlike System-RAM there is no possibility to swap in a
>> +      * different physical page at a given virtual address, so all
>> +      * userspace consumption of ZONE_DEVICE memory necessitates
>> +      * SIGBUS (i.e. MF_MUST_KILL)
>> +      */
>> +     flags |=3D MF_ACTION_REQUIRED | MF_MUST_KILL;
>> +     collect_procs(page, &tokill, flags & MF_ACTION_REQUIRED);
>
> You know "flags & MF_ACTION_REQUIRED" will always be true, so you can jus=
t
> pass in MF_ACTION_REQUIRED or even just "true".
>
>> +
>> +     start =3D (page->index << PAGE_SHIFT) & ~(size - 1);
>> +     unmap_mapping_range(page->mapping, start, start + size, 0);
>> +
>> +     kill_procs(&tokill, flags & MF_MUST_KILL, !unmap_success, ilog2(si=
ze),
>
> You know "flags & MF_MUST_KILL" will always be true, so you can just pass=
 in
> MF_MUST_KILL or even just "true".
>
> Also, you can get rid of the constant "unmap_success" if you want and jus=
t
> pass in false as the 3rd argument.

I don't like reading "true" and "false" as arguments to functions,
because the immediate next question is "what does true mean"? I could
just pass MF_MUST_KILL and MF_ACTION_REQUIRED directly, but was trying
to keep some consistency with other callers in that file.

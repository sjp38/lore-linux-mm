Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id CE70E6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 10:33:19 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id l95-v6so1712199otl.17
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 07:33:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h3-v6sor21968884ote.269.2018.06.05.07.33.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Jun 2018 07:33:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180605141104.GF19202@dhcp22.suse.cz>
References: <152800336321.17112.3300876636370683279.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180604124031.GP19202@dhcp22.suse.cz> <CAPcyv4gLxz7Ke6ApXoATDN31PSGwTgNRLTX-u1dtT3d+6jmzjw@mail.gmail.com>
 <20180605141104.GF19202@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 5 Jun 2018 07:33:17 -0700
Message-ID: <CAPcyv4iGd56kc2NG5GDYMqW740RNr7NZr9DRft==fPxPyieq7Q@mail.gmail.com>
Subject: Re: [PATCH v2 00/11] mm: Teach memory_failure() about ZONE_DEVICE pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, linux-edac@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@alien8.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Hellwig <hch@lst.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ingo Molnar <mingo@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Souptick Joarder <jrdr.linux@gmail.com>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue, Jun 5, 2018 at 7:11 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 04-06-18 07:31:25, Dan Williams wrote:
> [...]
>> I'm trying to solve this real world problem when real poison is
>> consumed through a dax mapping:
>>
>>         mce: Uncorrected hardware memory error in user-access at af34214200
>>         {1}[Hardware Error]: It has been corrected by h/w and requires
>> no further action
>>         mce: [Hardware Error]: Machine check events logged
>>         {1}[Hardware Error]: event severity: corrected
>>         Memory failure: 0xaf34214: reserved kernel page still
>> referenced by 1 users
>>         [..]
>>         Memory failure: 0xaf34214: recovery action for reserved kernel
>> page: Failed
>>         mce: Memory error not recovered
>>
>> ...i.e. currently all poison consumed through dax mappings is
>> needlessly system fatal.
>
> Thanks. That should be a part of the changelog.

...added for v3:
https://lists.01.org/pipermail/linux-nvdimm/2018-June/016153.html

> It would be great to
> describe why this cannot be simply handled by hwpoison code without any
> ZONE_DEVICE specific hacks? The error is recoverable so why does
> hwpoison code even care?
>

Up until we started testing hardware poison recovery for persistent
memory I assumed that the kernel did not need any new enabling to get
basic support for recovering userspace consumed poison.

However, the recovery code has a dedicated path for many different
page states (see: action_page_types). Without any changes it
incorrectly assumes that a dax mapped page is a page cache page
undergoing dma, or some other pinned operation. It also assumes that
the page must be offlined which is not correct / possible for dax
mapped pages. There is a possibility to repair poison to dax mapped
persistent memory pages, and the pages can't otherwise be offlined
because they 1:1 correspond with a physical storage block, i.e.
offlining pmem would be equivalent to punching a hole in the physical
address space.

There's also the entanglement of device-dax which guarantees a given
mapping size (4K, 2M, 1G). This requires determining the size of the
mapping encompassing a given pfn to know how much to unmap. Since dax
mapped pfns don't come from the page allocator we need to read the
page size from the page tables, not compound_order(page).

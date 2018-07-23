Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 64AB16B0006
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 06:05:04 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 70-v6so63389plc.1
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 03:05:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r7-v6sor2578370ple.150.2018.07.23.03.05.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 03:05:03 -0700 (PDT)
Date: Mon, 23 Jul 2018 13:04:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 17/19] x86/mm: Implement sync_direct_mapping()
Message-ID: <20180723100458.3oifgqyfavb6c45j@kshutemo-mobl1>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-18-kirill.shutemov@linux.intel.com>
 <4a99e079-7bd0-a611-571a-d730815b4b2a@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4a99e079-7bd0-a611-571a-d730815b4b2a@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 18, 2018 at 05:01:37PM -0700, Dave Hansen wrote:
> On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
> >  arch/x86/include/asm/mktme.h |   8 +
> >  arch/x86/mm/init_64.c        |  10 +
> >  arch/x86/mm/mktme.c          | 437 +++++++++++++++++++++++++++++++++++
> >  3 files changed, 455 insertions(+)
> 
> I'm not the maintainer.  But, NAK from me on this on the diffstat alone.
> 
> There is simply too much technical debt here.  There is no way this code
> is not riddled with bugs and I would bet lots of beer on the fact that
> this has received little to know testing with all the combinations that
> matter, like memory hotplug.  I'd love to be proven wrong, so I eagerly
> await to be dazzled with the test results that have so far escaped
> mention in the changelog.
> 
> Please make an effort to refactor this to reuse the code that we already
> have to manage the direct mapping.  We can't afford 455 new lines of
> page table manipulation that nobody tests or runs.

I'll look in this once again. But I'm not sure that there's any better
solution.

The problem boils down to page allocation issue. We are not be able to
allocate enough page tables in early boot for all direct mappings. At that
stage we have very limited pool of pages that can be used for page tables.
The pool is allocated at compile-time and it's not enough to handle MKTME.

Syncing approach appeared to be the simplest to me.

Other possibility I see is to write down a journal of operations on direct
mappings to be replayed once we have proper page allocator around.

> How _was_ this tested?

Besides normal boot with MTKME enabled and access pages via new direct
mappings, I also test memory hotplug and hotremove with QEMU.

Ideally we wound need some self-test for this. But I don't see a way to
simulate hotplug and hotremove. Soft offlining doesn't cut it. We
actually need to see the ACPI event to trigger the code.

-- 
 Kirill A. Shutemov

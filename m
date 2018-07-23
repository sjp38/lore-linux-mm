Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 18B886B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 08:25:40 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 132-v6so236208pga.18
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 05:25:40 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id l184-v6si8510576pge.257.2018.07.23.05.25.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 05:25:38 -0700 (PDT)
Subject: Re: [PATCHv5 17/19] x86/mm: Implement sync_direct_mapping()
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-18-kirill.shutemov@linux.intel.com>
 <4a99e079-7bd0-a611-571a-d730815b4b2a@intel.com>
 <20180723100458.3oifgqyfavb6c45j@kshutemo-mobl1>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <ac7b7cbb-67d2-5a1e-fc2a-ffb6b522224b@intel.com>
Date: Mon, 23 Jul 2018 05:25:27 -0700
MIME-Version: 1.0
In-Reply-To: <20180723100458.3oifgqyfavb6c45j@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/23/2018 03:04 AM, Kirill A. Shutemov wrote:
> On Wed, Jul 18, 2018 at 05:01:37PM -0700, Dave Hansen wrote:>> Please make an effort to refactor this to reuse the code that we already
>> have to manage the direct mapping.  We can't afford 455 new lines of
>> page table manipulation that nobody tests or runs.
> 
> I'll look in this once again. But I'm not sure that there's any better
> solution.
> 
> The problem boils down to page allocation issue. We are not be able to
> allocate enough page tables in early boot for all direct mappings. At that
> stage we have very limited pool of pages that can be used for page tables.
> The pool is allocated at compile-time and it's not enough to handle MKTME.
> 
> Syncing approach appeared to be the simplest to me.

If that is, indeed, the primary motivation for this design, then please
call that out in the changelog.  It's exceedingly difficult to review
without this information.

We also need data and facts, please.

Which pool are we talking about?  How large is it now?  How large would
it need to be to accommodate MKTME?  How much memory do we need to map
before we run into issues?

>> How _was_ this tested?
> 
> Besides normal boot with MTKME enabled and access pages via new direct
> mappings, I also test memory hotplug and hotremove with QEMU.

... also great changelog fodder.

> Ideally we wound need some self-test for this. But I don't see a way to
> simulate hotplug and hotremove. Soft offlining doesn't cut it. We
> actually need to see the ACPI event to trigger the code.

That's something that we have to go fix.  For the online side, we always
have the "probe" file.  I guess nobody ever bothered to make an
equivalent for the remove side.  But, that doesn't seem like an
insurmountable problem to me.

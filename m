Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2AA8D6B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 13:39:51 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id 9-v6so5212181oin.12
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 10:39:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p80-v6sor2906656ota.278.2018.06.04.10.39.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Jun 2018 10:39:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180604170801.GA17234@agluck-desk>
References: <152800336321.17112.3300876636370683279.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152800340082.17112.1154560126059273408.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180604170801.GA17234@agluck-desk>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 4 Jun 2018 10:39:48 -0700
Message-ID: <CAPcyv4g76nv=D2NXrpFLS-aWQR=N0T2n01WhrVY2_KPavkvLCA@mail.gmail.com>
Subject: Re: [PATCH v2 07/11] x86, memory_failure: Introduce {set, clear}_mce_nospec()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, linux-edac@vger.kernel.org, X86 ML <x86@kernel.org>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>

On Mon, Jun 4, 2018 at 10:08 AM, Luck, Tony <tony.luck@intel.com> wrote:
> On Sat, Jun 02, 2018 at 10:23:20PM -0700, Dan Williams wrote:
>> +static inline int set_mce_nospec(unsigned long pfn)
>> +{
>> +     int rc;
>> +
>> +     rc = set_memory_uc((unsigned long) __va(PFN_PHYS(pfn)), 1);
>
> You should really do the decoy_addr thing here that I had in mce_unmap_kpfn().
> Putting the virtual address of the page you mustn't accidentally prefetch
> from into a register is a pretty good way to make sure that the processor
> does do a prefetch.

Maybe I'm misreading, but doesn't that make the page completely
inaccessible? We still want to read pmem through the driver and the
linear mapping with memcpy_mcsafe(). Alternatively I could just drop
this patch and setup a private / alias mapping for the pmem driver to
use. It seems aliased mappings would be the safer option, but I want
to make sure I've comprehended your suggestion correctly?

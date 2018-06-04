Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D521A6B000D
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 14:08:47 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z9-v6so1789228pfe.23
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 11:08:47 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id b70-v6si47522230pfe.265.2018.06.04.11.08.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 11:08:46 -0700 (PDT)
Date: Mon, 4 Jun 2018 11:08:45 -0700
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH v2 07/11] x86, memory_failure: Introduce {set,
 clear}_mce_nospec()
Message-ID: <20180604180845.GA17942@agluck-desk>
References: <152800336321.17112.3300876636370683279.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152800340082.17112.1154560126059273408.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180604170801.GA17234@agluck-desk>
 <CAPcyv4g76nv=D2NXrpFLS-aWQR=N0T2n01WhrVY2_KPavkvLCA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4g76nv=D2NXrpFLS-aWQR=N0T2n01WhrVY2_KPavkvLCA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, linux-edac@vger.kernel.org, X86 ML <x86@kernel.org>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>

On Mon, Jun 04, 2018 at 10:39:48AM -0700, Dan Williams wrote:
> On Mon, Jun 4, 2018 at 10:08 AM, Luck, Tony <tony.luck@intel.com> wrote:
> > On Sat, Jun 02, 2018 at 10:23:20PM -0700, Dan Williams wrote:
> >> +static inline int set_mce_nospec(unsigned long pfn)
> >> +{
> >> +     int rc;
> >> +
> >> +     rc = set_memory_uc((unsigned long) __va(PFN_PHYS(pfn)), 1);
> >
> > You should really do the decoy_addr thing here that I had in mce_unmap_kpfn().
> > Putting the virtual address of the page you mustn't accidentally prefetch
> > from into a register is a pretty good way to make sure that the processor
> > does do a prefetch.
> 
> Maybe I'm misreading, but doesn't that make the page completely
> inaccessible? We still want to read pmem through the driver and the
> linear mapping with memcpy_mcsafe(). Alternatively I could just drop
> this patch and setup a private / alias mapping for the pmem driver to
> use. It seems aliased mappings would be the safer option, but I want
> to make sure I've comprehended your suggestion correctly?

I'm OK with the call to set_memory_uc() to make this uncacheable
instead of set_memory_np() to make it inaccessible.

The problem is how to achieve that.

The result of __va(PFN_PHYS(pfn) is the virtual address where the poison
page is currently mapped into the kernel. That value gets put into
register %rdi to make the call to set_memory_uc() (which goes on to
call a bunch of other functions passing the virtual address along
the way).

Now imagine an impatient super-speculative processor is waiting for
some result to decide where to jump next, and picks a path that isn't
going to be taken ... out in the weeds somewhere it runs into:

	movzbl	(%rdi), %eax

Oops ... now you just read from the address you were trying to
avoid. So we log an error. Eventually the speculation gets sorted
out and the processor knows not to signal a machine check. But the
log is sitting in a machine check bank waiting to cause an overflow
if we try to log a second error.

The decoy_addr trick in mce_unmap_kpfn() throws in the high bit
to the address passed.  The set_memory_np() code (and I assume the
set_memory_uc()) code ignores it, but it means any stray speculative
access won't point at the poison page.

-Tony

Note: this is *mostly* a problem if the poison is in the first
cache line of the page.  But you could hit other lines if the
instruction you speculatively ran into had the right offset. E.g.
to hit the third line:

	movzbl	128(%rdi), %eax

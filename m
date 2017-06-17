Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3BF6F6B02FA
	for <linux-mm@kvack.org>; Sat, 17 Jun 2017 00:09:30 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 33so34554238pgx.14
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 21:09:30 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id a3si3716800plc.494.2017.06.16.21.09.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 21:09:28 -0700 (PDT)
Date: Fri, 16 Jun 2017 22:09:26 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 1/3] mm: add vm_insert_mixed_mkwrite()
Message-ID: <20170617040926.GA26554@linux.intel.com>
References: <20170614172211.19820-1-ross.zwisler@linux.intel.com>
 <20170614172211.19820-2-ross.zwisler@linux.intel.com>
 <20170615144204.GN1764@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170615144204.GN1764@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Thu, Jun 15, 2017 at 04:42:04PM +0200, Jan Kara wrote:
> On Wed 14-06-17 11:22:09, Ross Zwisler wrote:
> > To be able to use the common 4k zero page in DAX we need to have our PTE
> > fault path look more like our PMD fault path where a PTE entry can be
> > marked as dirty and writeable as it is first inserted, rather than waiting
> > for a follow-up dax_pfn_mkwrite() => finish_mkwrite_fault() call.
> > 
> > Right now we can rely on having a dax_pfn_mkwrite() call because we can
> > distinguish between these two cases in do_wp_page():
> > 
> > 	case 1: 4k zero page => writable DAX storage
> > 	case 2: read-only DAX storage => writeable DAX storage
> > 
> > This distinction is made by via vm_normal_page().  vm_normal_page() returns
> > false for the common 4k zero page, though, just as it does for DAX ptes.
> > Instead of special casing the DAX + 4k zero page case, we will simplify our
> > DAX PTE page fault sequence so that it matches our DAX PMD sequence, and
> > get rid of dax_pfn_mkwrite() completely.
> > 
> > This means that insert_pfn() needs to follow the lead of insert_pfn_pmd()
> > and allow us to pass in a 'mkwrite' flag.  If 'mkwrite' is set insert_pfn()
> > will do the work that was previously done by wp_page_reuse() as part of the
> > dax_pfn_mkwrite() call path.
> > 
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> 
> So I agree that getting rid of dax_pfn_mkwrite() and using fault handler in
> that case is a way to go. However I somewhat dislike the
> vm_insert_mixed_mkwrite() thing - it looks like a hack - and I'm aware that
> we have a similar thing for PMD which is ugly as well. Besides being ugly
> I'm also concerned that when 'mkwrite' is set, we just silently overwrite
> whatever PTE was installed at that position. Not that I'd see how that
> could screw us for DAX but still a concern that e.g. some PTE flag could
> get discarded by this is there... In fact, for !HAVE_PTE_SPECIAL
> architectures, you will leak zero page references by just overwriting the
> PTE - for those archs you really need to unmap zero page before replacing
> PTE (and the same for PMD I suppose).
> 
> So how about some vmf_insert_pfn(vmf, pe_size, pfn) helper that would
> properly detect PTE / PMD case, read / write case etc., check that PTE did
> not change from orig_pte, and handle all the nasty details instead of
> messing with insert_pfn?

I played around with this some today, and I wasn't super happy with the
results.  Here were some issues I encountered:

1) The pte_mkyoung(), maybe_mkwrite() and pte_mkdirty() calls need to happen
with the PTE locked, and I'm currently able to piggy-back on the locking done
in insert_pfn().  If I keep those steps out of insert_pfn() I either have to
essentially duplicate all the work done by insert_pfn() into another function
so I can do everything I need under one lock, or I have to insert the PFN via
insert_pfn() (which as you point out, will just leave the pfn alone if it's
already present), then for writes I have to re-grab the PTE lock and set do
the mkwrite steps.

Either of these work, but they both also seem kind of gross...

2) Combining the PTE and PMD cases into a common function will require
mm/memory.c to call vmf_insert_pfn_pmd(), which depends on
CONFIG_TRANSPARENT_HUGEPAGE being defined.  This works, it just means some
more #ifdef CONFIG_TRANSPARENT_HUGEPAGE hackery in mm/memory.c.

I agree that unconditionally overwriting the PTE when mkwrite is set is
undesireable, and should be fixed.  My implementation of the wrapper just
didn't seem that natural, which usually tells me I'm headed down the wrong
path.  Maybe I'm just not fully understanding what you intended?

In any case, my current favorite soultion for this issue is still what I had
in v1:

https://patchwork.kernel.org/patch/9772809/

with perhaps the removal of the new vm_insert_mixed_mkwrite() symbol, and just
adding a 'write' flag to vm_insert_mixed() and updating all the call sites,
and fixing the flow where mkwrite unconditionally overwrites the PTE?

If not, can you help me understand what you think is ugly about the 'write'
flag to vm_insert_mixed() and vmf_insert_pfn_pmd()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

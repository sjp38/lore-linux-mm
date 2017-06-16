Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4DCA34404A3
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 15:44:40 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id o62so50941181pga.0
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 12:44:40 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id q127si2615562pga.353.2017.06.16.12.44.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 12:44:39 -0700 (PDT)
Date: Fri, 16 Jun 2017 13:44:37 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 1/3] mm: add vm_insert_mixed_mkwrite()
Message-ID: <20170616194437.GA20742@linux.intel.com>
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
> 
> 								Honza

Sounds good, I'll figure this out for v3.

Thanks for the review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

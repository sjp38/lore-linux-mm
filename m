Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8A73F6B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 10:28:43 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s4so35760359pgr.3
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 07:28:43 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id s64si1632209pfi.620.2017.07.20.07.28.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 07:28:42 -0700 (PDT)
Date: Thu, 20 Jul 2017 08:28:40 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v3 3/5] dax: use common 4k zero page for dax mmap reads
Message-ID: <20170720142840.GB20414@linux.intel.com>
References: <20170628220152.28161-1-ross.zwisler@linux.intel.com>
 <20170628220152.28161-4-ross.zwisler@linux.intel.com>
 <20170719153314.GC15908@quack2.suse.cz>
 <20170719162645.GA26445@linux.intel.com>
 <20170720102723.GB17689@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170720102723.GB17689@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Thu, Jul 20, 2017 at 12:27:23PM +0200, Jan Kara wrote:
> On Wed 19-07-17 10:26:45, Ross Zwisler wrote:
> > On Wed, Jul 19, 2017 at 05:33:14PM +0200, Jan Kara wrote:
> > > On Wed 28-06-17 16:01:50, Ross Zwisler wrote:
> > > > Another major change is that we remove dax_pfn_mkwrite() from our fault
> > > > flow, and instead rely on the page fault itself to make the PTE dirty and
> > > > writeable.  The following description from the patch adding the
> > > > vm_insert_mixed_mkwrite() call explains this a little more:
> > > > 
> > > > ***
> > > >   To be able to use the common 4k zero page in DAX we need to have our PTE
> > > >   fault path look more like our PMD fault path where a PTE entry can be
> > > >   marked as dirty and writeable as it is first inserted, rather than
> > > >   waiting for a follow-up dax_pfn_mkwrite() => finish_mkwrite_fault() call.
> > > > 
> > > >   Right now we can rely on having a dax_pfn_mkwrite() call because we can
> > > >   distinguish between these two cases in do_wp_page():
> > > > 
> > > >   	case 1: 4k zero page => writable DAX storage
> > > >   	case 2: read-only DAX storage => writeable DAX storage
> > > > 
> > > >   This distinction is made by via vm_normal_page().  vm_normal_page()
> > > >   returns false for the common 4k zero page, though, just as it does for
> > > >   DAX ptes.  Instead of special casing the DAX + 4k zero page case, we will
> > > >   simplify our DAX PTE page fault sequence so that it matches our DAX PMD
> > > >   sequence, and get rid of dax_pfn_mkwrite() completely.
> > > > 
> > > >   This means that insert_pfn() needs to follow the lead of insert_pfn_pmd()
> > > >   and allow us to pass in a 'mkwrite' flag.  If 'mkwrite' is set
> > > >   insert_pfn() will do the work that was previously done by wp_page_reuse()
> > > >   as part of the dax_pfn_mkwrite() call path.
> > > > ***
> > > 
> > > Hum, thinking about this in context of this patch... So what if we have
> > > allocated storage, a process faults it read-only, we map it to page tables
> > > writeprotected. Then the process writes through mmap to the area - the code
> > > in handle_pte_fault() ends up in do_wp_page() if I'm reading it right.
> > 
> > Yep.
> > 
> > > Then, since we are missing ->pfn_mkwrite() handlers, the PTE will be marked
> > > writeable but radix tree entry stays clean - bug. Am I missing something?
> > 
> > I don't think we ever end up with a writeable PTE but with a clean radix tree
> > entry.  When we get the write fault we do a full fault through
> > dax_iomap_pte_fault() and dax_insert_mapping().
> >
> > dax_insert_mapping() sets up the dirty radix tree entry via
> > dax_insert_mapping_entry() before it does anything with the page tables via
> > vm_insert_mixed_mkwrite().
> > 
> > So, this mkwrite fault path is exactly the path we would have taken if the
> > initial read to real storage hadn't happened, and we end up in the same end
> > state - with a dirty DAX radix tree entry and a writeable PTE.
> 
> Ah sorry, I have missed that it is not that you would not have
> ->pfn_mkwrite() handler - you still have it but it is the same as standard
> fault handler now. So maybe can you rephrase the changelog a bit saying
> that: "We get rid of dax_pfn_mkwrite() helper and use dax_iomap_fault() to
> handle write-protection faults instead." Thanks!

Ah, sure, will do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

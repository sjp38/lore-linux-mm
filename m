Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 34FEF831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 15:44:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e7so132723558pfk.9
        for <linux-mm@kvack.org>; Mon, 22 May 2017 12:44:57 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f15si18178092plm.174.2017.05.22.12.44.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 12:44:56 -0700 (PDT)
Date: Mon, 22 May 2017 13:44:55 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 2/2] dax: Fix race between colliding PMD & PTE entries
Message-ID: <20170522194455.GB27118@linux.intel.com>
References: <20170517171639.14501-1-ross.zwisler@linux.intel.com>
 <20170517171639.14501-2-ross.zwisler@linux.intel.com>
 <20170518075037.GA9084@quack2.suse.cz>
 <20170518212939.GA28029@linux.intel.com>
 <20170522143748.GC25118@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170522143748.GC25118@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pawel Lebioda <pawel.lebioda@intel.com>, Dave Jiang <dave.jiang@intel.com>, Xiong Zhou <xzhou@redhat.com>, Eryu Guan <eguan@redhat.com>, stable@vger.kernel.org

On Mon, May 22, 2017 at 04:37:48PM +0200, Jan Kara wrote:
> On Thu 18-05-17 15:29:39, Ross Zwisler wrote:
> > On Thu, May 18, 2017 at 09:50:37AM +0200, Jan Kara wrote:
> > > On Wed 17-05-17 11:16:39, Ross Zwisler wrote:
<>
> > > The first scenario seems to be possible. dax_iomap_pmd_fault() will create
> > > PMD entry in the radix tree. Then dax_iomap_pte_fault() will come, do
> > > grab_mapping_entry(), there it sees entry is PMD but we are doing PTE fault
> > > so I'd think that pmd_downgrade = true... But actually the condition there
> > > doesn't trigger in this case. And that's a catch that although we asked
> > > grab_mapping_entry() for PTE, we've got PMD back and that screws us later.
> > 
> > Yep, it was a concious decision when implementing the PMD support to allow one
> > thread to use PMDs and another to use PTEs in the same range, as long as the
> > thread faulting in PMDs is the first to insert into the radix tree.  A PMD
> > radix tree entry will be inserted and used for locking and dirty tracking, and
> > each thread or process can fault in either PTEs or PMDs into its own address
> > space as needed.
> 
> Well, for *threads* it doesn't really make good sense to mix PMDs and PTEs
> as they share page tables. However for *processes* it makes some sense to
> allow one process to use PTEs and another process to use PMDs. And I
> remember we were discussing this in the past.

Ugh, I was super sloppy with my use of "thread" and "process" in my previous
email.  Sorry, and thanks for the clarifications.  I think we're on the same
page, even if I had trouble articulating it. :)

> So normal fault path uses alloc_set_pte() for installing new PTE. And that
> uses pte_alloc_one_map() which checks whether PMD is still suitable for
> inserting a PTE. If not, we return VM_FAULT_NOPAGE. Probably it would be
> cleanest to factor our common parts of PTE and PMD insertion so that we can
> use these functions both from DAX and generic fault paths.

Makes sense, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

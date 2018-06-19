Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3972C6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 13:16:43 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p16-v6so161717pfn.7
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 10:16:43 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f4-v6si156254pgs.244.2018.06.19.10.16.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Jun 2018 10:16:41 -0700 (PDT)
Date: Tue, 19 Jun 2018 10:16:38 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v14 00/74] Convert page cache to XArray
Message-ID: <20180619171638.GE1438@bombadil.infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
 <20180619031257.GA12527@linux.intel.com>
 <20180619092230.GA1438@bombadil.infradead.org>
 <20180619164037.GA6679@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180619164037.GA6679@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

On Tue, Jun 19, 2018 at 10:40:37AM -0600, Ross Zwisler wrote:
> On Tue, Jun 19, 2018 at 02:22:30AM -0700, Matthew Wilcox wrote:
> > On Mon, Jun 18, 2018 at 09:12:57PM -0600, Ross Zwisler wrote:
> > > Hit another deadlock.  This one reproduces 100% of the time in my setup with
> > > XFS + DAX + generic/340.  It doesn't reproduce for me at all with
> > > next-20180615.  Here's the output from "echo w > /proc/sysrq-trigger":
> > 
> > *sigh*.  I wonder what the differences are between our setups ...
> > 
> > > [   92.849119] sysrq: SysRq : Show Blocked State
> > > [   92.850506]   task                        PC stack   pid father
> > > [   92.852299] holetest        D    0  1651   1466 0x00000000
> > > [   92.853912] Call Trace:
> > > [   92.854610]  __schedule+0x2c5/0xad0
> > > [   92.855612]  schedule+0x36/0x90
> > > [   92.856602]  get_unlocked_entry+0xce/0x120
> > > [   92.857756]  ? dax_insert_entry+0x2b0/0x2b0
> > > [   92.858931]  grab_mapping_entry+0x19e/0x250
> > > [   92.860119]  dax_iomap_pte_fault+0x115/0x1140
> > > [   92.860836]  dax_iomap_fault+0x37/0x40
> > ...
> > > This looks very similar to the one I reported last week with generic/269.
> > 
> > Yeah, another missing wakeup, no doubt.  Can you bisect this?  That was
> > how I found the last one; bisected it to a single patch and stared very
> > hard at the patch until I saw it.  I'm not going to be in a position to
> > tinker with my DAX setup until the first week of July.
> 
> It bisected to this commit:
> 
> b4b4daa7e8fb0ad0fee35d3e28d00e97c849a6cb is the first bad commit
> commit b4b4daa7e8fb0ad0fee35d3e28d00e97c849a6cb
> Author: Matthew Wilcox <willy@infradead.org>
> Date:   Thu Mar 29 22:58:27 2018 -0400
> 
>     dax: Convert page fault handlers to XArray
> 
>     This is the last part of DAX to be converted to the XArray so
>     remove all the old helper functions.
> 
>     Signed-off-by: Matthew Wilcox <willy@infradead.org>

I think I see a bug.  No idea if it's the one you're hitting ;-)

I had been intending to not use the 'entry' to decide whether we were
waiting on a 2MB or 4kB page, but rather the xas.  I shelved that idea,
but not before dropping the DAX_PMD flag being passed from the PMD
pagefault caller.  So if I put that back ...


diff --git a/fs/dax.c b/fs/dax.c
index 9919b6b545fb..75cc160d2f0b 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -367,13 +367,13 @@ static struct page *dax_busy_page(void *entry)
  * a VM_FAULT code, encoded as an xarray internal entry.  The ERR_PTR values
  * overlap with xarray value entries.
  */
-static
-void *grab_mapping_entry(struct xa_state *xas, struct address_space *mapping)
+static void *grab_mapping_entry(struct xa_state *xas,
+		struct address_space *mapping, unsigned long size)
 {
 	bool pmd_downgrade = false; /* splitting 2MiB entry into 4k entries? */
 	void *locked = dax_make_entry(pfn_to_pfn_t(0),
-						DAX_EMPTY | DAX_LOCKED);
-	void *unlocked = dax_make_entry(pfn_to_pfn_t(0), DAX_EMPTY);
+						size | DAX_EMPTY | DAX_LOCKED);
+	void *unlocked = dax_make_entry(pfn_to_pfn_t(0), size | DAX_EMPTY);
 	void *entry;
 
 retry:
@@ -1163,7 +1163,7 @@ static vm_fault_t dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	if (write && !vmf->cow_page)
 		flags |= IOMAP_WRITE;
 
-	entry = grab_mapping_entry(&xas, mapping);
+	entry = grab_mapping_entry(&xas, mapping, 0);
 	if (xa_is_internal(entry)) {
 		ret = xa_to_internal(entry);
 		goto out;
@@ -1396,7 +1396,7 @@ static vm_fault_t dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	 * page is already in the tree, for instance), it will return
 	 * VM_FAULT_FALLBACK.
 	 */
-	entry = grab_mapping_entry(&xas, mapping);
+	entry = grab_mapping_entry(&xas, mapping, DAX_PMD);
 	if (xa_is_internal(entry)) {
 		result = xa_to_internal(entry);
 		goto fallback;

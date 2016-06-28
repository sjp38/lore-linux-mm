Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8079A6B0253
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 17:42:15 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g62so61135808pfb.3
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 14:42:15 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id d3si423220pay.44.2016.06.28.14.42.14
        for <linux-mm@kvack.org>;
        Tue, 28 Jun 2016 14:42:14 -0700 (PDT)
Date: Tue, 28 Jun 2016 15:41:59 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 0/3 v1] dax: Clear dirty bits after flushing caches
Message-ID: <20160628214159.GB15457@linux.intel.com>
References: <1466523915-14644-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466523915-14644-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, Jun 21, 2016 at 05:45:12PM +0200, Jan Kara wrote:
> Hello,
> 
> currently we never clear dirty bits in the radix tree of a DAX inode. Thus
> fsync(2) or even periodical writeback flush all the dirty pfns again and
> again. This patches implement clearing of the dirty tag in the radix tree
> so that we issue flush only when needed.
> 
> The difficulty with clearing the dirty tag is that we have to protect against
> a concurrent page fault setting the dirty tag and writing new data into the
> page. So we need a lock serializing page fault and clearing of the dirty tag
> and write-protecting PTEs (so that we get another pagefault when pfn is written
> to again and we have to set the dirty tag again).
> 
> The effect of the patch set is easily visible:
> 
> Writing 1 GB of data via mmap, then fsync twice.
> 
> Before this patch set both fsyncs take ~205 ms on my test machine, after the
> patch set the first fsync takes ~283 ms (the additional cost of walking PTEs,
> clearing dirty bits etc. is very noticeable), the second fsync takes below
> 1 us.
> 
> As a bonus, these patches make filesystem freezing for DAX filesystems
> reliable because mappings are now properly writeprotected while freezing the
> fs.
> 
> Patches have passed xfstests for both xfs and ext4.
> 
> So far the patches don't work with PMD pages - that's next on my todo list.

Regarding the PMD work, I had a go at this a while ago.  You may (or may not)
find these patches useful:

mm: add follow_pte_pmd()
	https://patchwork.kernel.org/patch/7616241/
mm: add pmd_mkclean()
	https://patchwork.kernel.org/patch/7616261/
mm: add pgoff_mkclean()
	https://patchwork.kernel.org/patch/7616221/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

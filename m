Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 704EA828DF
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 09:11:58 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id q63so44211559pfb.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 06:11:58 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id bm5si9818791pad.107.2016.01.22.06.11.57
        for <linux-mm@kvack.org>;
        Fri, 22 Jan 2016 06:11:57 -0800 (PST)
Date: Fri, 22 Jan 2016 09:11:40 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v3 0/8] Support for transparent PUD pages for DAX files
Message-ID: <20160122141140.GD2948@linux.intel.com>
References: <1452282592-27290-1-git-send-email-matthew.r.wilcox@intel.com>
 <56A1605A.20807@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56A1605A.20807@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingming cao <mingming.cao@oracle.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On Thu, Jan 21, 2016 at 02:48:58PM -0800, mingming cao wrote:
> On 01/08/2016 11:49 AM, Matthew Wilcox wrote:
> > Filesystems still need work to allocate 1GB pages.  With ext4, I can
> > only get 16MB of contiguous space, although it is aligned.  With XFS,
> > I can get 80MB less than 1GB, and it's not aligned.  The XFS problem
> > may be due to the small amount of RAM in my test machine.
> 
> I dont think ext4 can do 1G at this time due to extent length bits
> (15 for unwritten) and block group size bundary (well, with flex bg we
> may able to relax this ). I have seen about 125M of contiguous space
> allocated on my fresh new ext4 filesystem. I do remember mballoc in ext4
> used to normalize the allocation request up to 8 or 16M, but it appears
> not that small any more.

I agree that the on-disk ext4 format can't represent a single 1GB
extent (ext4_extent's ee_len is 16 bits), but the in-memory extent tree
(extent_status's es_len) uses a 32-bit block count field, which can
represent an 8TB length extent with 4kB blocks.

It seems that at the moment, something is constraining allocations to be
at most 16MB, so that we can convert one extent_status to one ext4_extent.
What I'd like to see is code to convert one extent_status into multiple
ext4_extents on disc, and recombine multiple ext4_extents into a single
extent_status when the inode is read back in later.

Then we can start looking at places where ext4 puts metadata in the
middle of 1GB regions, preventing them from being used ... that'll be
a separate bag of issues, no doubt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

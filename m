Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 737326B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 07:15:47 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so5080376pad.9
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 04:15:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20130924165848.4f3ba25b4de236fa746fb7ee@linux-foundation.org>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20130924163740.4bc7db61e3e520798220dc4c@linux-foundation.org>
 <20130924234950.GC2018@tassilo.jf.intel.com>
 <20130924165848.4f3ba25b4de236fa746fb7ee@linux-foundation.org>
Subject: Re: [PATCHv6 00/22] Transparent huge page cache: phase 1, everything
 but mmap()
Content-Transfer-Encoding: 7bit
Message-Id: <20130925111538.CCE16E0090@blue.fi.intel.com>
Date: Wed, 25 Sep 2013 14:15:38 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Andrew Morton wrote:
> On Tue, 24 Sep 2013 16:49:50 -0700 Andi Kleen <ak@linux.intel.com> wrote:
> 
> > > At the very least we should get this done for a real filesystem to see
> > > how intrusive the changes are and to evaluate the performance changes.
> > 
> > That would give even larger patches, and people already complain
> > the patchkit is too large.
> 
> The thing is that merging an implementation for ramfs commits us to
> doing it for the major real filesystems.  Before making that commitment
> we should at least have a pretty good understanding of what those
> changes will look like.
> 
> Plus I don't see how we can realistically performance-test it without
> having real physical backing store in the picture?

My plan for real filesystem is to get it first beneficial for read-mostly
files:
 - allocate huge pages on read (or collapse small pages) only if nobody
   has the inode opened on write;
 - split huge page on write to avoid dealing with write back patch at
   first and dirty only 4k pages;

This will will get most of elf executables and libraries mapped with huge
pages (it may require dynamic linker change to align length to huge page
boundary) which is not bad for start.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

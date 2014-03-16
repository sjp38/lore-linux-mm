Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 16F0F6B0035
	for <linux-mm@kvack.org>; Sat, 15 Mar 2014 22:46:18 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so4275133pad.17
        for <linux-mm@kvack.org>; Sat, 15 Mar 2014 19:46:17 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id sh5si10195481pbc.140.2014.03.15.19.46.16
        for <linux-mm@kvack.org>;
        Sat, 15 Mar 2014 19:46:17 -0700 (PDT)
Date: Sat, 15 Mar 2014 22:46:13 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [RFC PATCH] Support map_pages() for DAX
Message-ID: <20140316024613.GF6091@linux.intel.com>
References: <1394838199-29102-1-git-send-email-toshi.kani@hp.com>
 <20140314233233.GA8310@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140314233233.GA8310@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Toshi Kani <toshi.kani@hp.com>, kirill.shutemov@linux.intel.com, david@fromorbit.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Mar 15, 2014 at 01:32:33AM +0200, Kirill A. Shutemov wrote:
> Side note: I'm sceptical about whole idea to use i_mmap_mutux to protect
> against truncate. It will not scale good enough comparing lock_page()
> with its granularity.

I'm actually working on this now.  The basic idea is to put an entry in
the radix tree for each page.  For zero pages, that's a pagecache page.
For pages that map to the media, it's an exceptional entry.  Radix tree
exceptional entries take two bits, leaving us with 30 or 62 bits depending
on sizeof(void *).  We can then take two more bits for Dirty and Lock,
leaving 28 or 60 bits that we can use to cache the PFN on the page,
meaning that we won't have to call the filesystem's get_block as often.

This means that shmem_find_get_pages_and_swap() moves from the shmem code
to filemap and gets renamed to find_get_rtes().  Next step is making
the truncate code use it so that the truncate code locks against DAX
code paths as well as pagecache codepaths.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

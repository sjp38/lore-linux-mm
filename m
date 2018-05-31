Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0630C6B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 17:46:18 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id i1-v6so13977618pld.11
        for <linux-mm@kvack.org>; Thu, 31 May 2018 14:46:17 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a65-v6si10595320pfa.148.2018.05.31.14.46.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 31 May 2018 14:46:16 -0700 (PDT)
Date: Thu, 31 May 2018 14:46:12 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v11 00/63] Convert page cache to XArray
Message-ID: <20180531214612.GA12216@bombadil.infradead.org>
References: <20180414141316.7167-1-willy@infradead.org>
 <20180416160133.GA12434@linux.intel.com>
 <20180531213643.GD28256@linux.intel.com>
 <20180531213742.GE28256@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180531213742.GE28256@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Thu, May 31, 2018 at 03:37:42PM -0600, Ross Zwisler wrote:
> Never mind, just saw your mail from a few weeks ago.  :-/  I'll retest on my
> end.

Don't strain too hard; I found (and fixed) some bugs in the DAX
conversion.  I keep finding new bugs though -- the latest was that
xas_store(xas, NULL); doesn't work properly if xas is multiindex and some
of the covered entries are not NULL.  And in fixing that, I noticed that
xas_store(xas, not-null) doesn't handle tagged entries correctly.

I'd offer to push out the current version for testing but I've pulled
everything apart and nothing works right now ;-)  I always think "it'll
be ready tomorrow", but I don't want to make a promise I can't keep.

Here's my current changelog (may have forgotten a few things; need to
compare a diff once I've put together a decent patch series)

 - Reordered two DAX bugfixes to the head of the queue to allow them to
   be merged independently.
 - Converted apparmor secid to IDR
 - Fixed bug in page cache lookup conversion which could lead to returning
   pages which had been released from the page cache.
 - Fixed several bugs in DAX conversion
 - Re-added conversion of dax_layout_busy_page
 - At Ross's request, renamed dax_mk_foo() to dax_make_foo().
 - Split out the radix tree test suite addition of ubsan.
 - Split out radix tree code deletion.
 - Removed __radix_tree_create from the public API
 - Fixed up a couple of comments in DAX
 - Renamed shmem_xa_replace() to shmem_replace_entry()
 * Undid change of xas_load() behaviour with multislot xa_state
 - Added xas_store_for_each() and use it in DAX
 - Corrected some typos in the XArray kerneldoc.
 - Fixed multi-index xas_store(xas, NULL)
 - Fixed tag handling in multi-index xas_store(xas, not-null)

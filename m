Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD076B0069
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 08:07:41 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n24so158168829pfb.0
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 05:07:41 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 80si11672231pfv.253.2016.09.16.05.07.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Sep 2016 05:07:40 -0700 (PDT)
Date: Fri, 16 Sep 2016 15:07:32 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 07/41] mm, shmem: swich huge tmpfs to multi-order
 radix-tree entries
Message-ID: <20160916120732.GA72667@black.fi.intel.com>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-8-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160915115523.29737-8-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu, Sep 15, 2016 at 02:54:49PM +0300, Kirill A. Shutemov wrote:
> We would need to use multi-order radix-tree entires for ext4 and other
> filesystems to have coherent view on tags (dirty/towrite) in the tree.
> 
> This patch converts huge tmpfs implementation to multi-order entries, so
> we will be able to use the same code patch for all filesystems.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

0-DAY reported this:

reproduce: make htmldocs

All warnings (new ones prefixed by >>):

   lib/crc32.c:148: warning: No description found for parameter 'tab)[256]'
   lib/crc32.c:148: warning: Excess function parameter 'tab' description in 'crc32_le_generic'
   lib/crc32.c:293: warning: No description found for parameter 'tab)[256]'
   lib/crc32.c:293: warning: Excess function parameter 'tab' description in 'crc32_be_generic'
   lib/crc32.c:1: warning: no structured comments found
>> mm/filemap.c:1434: warning: No description found for parameter 'start'
>> mm/filemap.c:1434: warning: Excess function parameter 'index' description in 'find_get_pages_contig'
>> mm/filemap.c:1525: warning: No description found for parameter 'indexp'
>> mm/filemap.c:1525: warning: Excess function parameter 'index' description in 'find_get_pages_tag'

The fixup:

diff --git a/mm/filemap.c b/mm/filemap.c
index c69b1204744a..1ef20dd45b6b 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1548,7 +1548,7 @@ repeat:
 /**
  * find_get_pages_contig - gang contiguous pagecache lookup
  * @mapping:	The address_space to search
- * @index:	The starting page index
+ * @start:	The starting page index
  * @nr_pages:	The maximum number of pages
  * @pages:	Where the resulting pages are placed
  *
@@ -1641,7 +1641,7 @@ EXPORT_SYMBOL(find_get_pages_contig);
 /**
  * find_get_pages_tag - find and return pages that match @tag
  * @mapping:	the address_space to search
- * @index:	the starting page index
+ * @indexp:	the starting page index
  * @tag:	the tag index
  * @nr_pages:	the maximum number of pages
  * @pages:	where the resulting pages are placed
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

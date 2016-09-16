Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5AC4D6B0069
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 08:10:40 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id mi5so148268887pab.2
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 05:10:40 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id s127si45171904pfb.4.2016.09.16.05.10.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Sep 2016 05:10:39 -0700 (PDT)
Date: Fri, 16 Sep 2016 15:10:34 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 29/41] ext4: make ext4_mpage_readpages() hugepage-aware
Message-ID: <20160916121034.GC72667@black.fi.intel.com>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-30-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160915115523.29737-30-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu, Sep 15, 2016 at 02:55:11PM +0300, Kirill A. Shutemov wrote:
> This patch modifies ext4_mpage_readpages() to deal with huge pages.
> 
> We read out 2M at once, so we have to alloc (HPAGE_PMD_NR *
> blocks_per_page) sector_t for that. I'm not entirely happy with kmalloc
> in this codepath, but don't see any other option.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

0-DAY reported this:

compiler: powerpc64-linux-gnu-gcc (Debian 5.4.0-6) 5.4.0 20160609
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cro
+ss
        chmod +x ~/bin/make.cross
        git checkout d8bfe8f327288810a9a099b15f3c89a834d419a4
        # save the attached .config to linux build tree
        make.cross ARCH=powerpc

All errors (new ones prefixed by >>):

   In file included from include/linux/linkage.h:4:0,
                    from include/linux/kernel.h:6,
                    from fs/ext4/readpage.c:30:
   fs/ext4/readpage.c: In function 'ext4_mpage_readpages':
>> include/linux/compiler.h:491:38: error: call to '__compiletime_assert_144' declared with attribute error:
+BUILD_BUG_ON failed: BIO_MAX_PAGES < HPAGE_PMD_NR
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                         ^
   include/linux/compiler.h:474:4: note: in definition of macro '__compiletime_assert'
       prefix ## suffix();    \                                                       
       ^                       
   include/linux/compiler.h:491:2: note: in expansion of macro '_compiletime_assert'
     _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)           
     ^                                                                   
   include/linux/bug.h:51:37: note: in expansion of macro 'compiletime_assert'
    #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)      
                                        ^
   include/linux/bug.h:75:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
     BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)       
     ^                                                              
   fs/ext4/readpage.c:144:4: note: in expansion of macro 'BUILD_BUG_ON'
       BUILD_BUG_ON(BIO_MAX_PAGES < HPAGE_PMD_NR);                     
       ^                                          

The fixup:

diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index 6d7cbddceeb2..75b2a7700c9a 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -140,7 +140,8 @@ int ext4_mpage_readpages(struct address_space *mapping,
 
 		block_in_file = (sector_t)page->index << (PAGE_SHIFT - blkbits);
 
-		if (PageTransHuge(page)) {
+		if (PageTransHuge(page) &&
+				IS_ENABLED(TRANSPARENT_HUGE_PAGECACHE)) {
 			BUILD_BUG_ON(BIO_MAX_PAGES < HPAGE_PMD_NR);
 			nr = HPAGE_PMD_NR * blocks_per_page;
 			/* XXX: need a better solution ? */
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

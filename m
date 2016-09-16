Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 493966B0253
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 08:09:09 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fu12so150025559pac.1
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 05:09:09 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id xt5si10042924pab.68.2016.09.16.05.09.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Sep 2016 05:09:08 -0700 (PDT)
Date: Fri, 16 Sep 2016 15:09:03 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 19/41] block: define BIO_MAX_PAGES to HPAGE_PMD_NR if
 huge page cache enabled
Message-ID: <20160916120903.GB72667@black.fi.intel.com>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-20-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160915115523.29737-20-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu, Sep 15, 2016 at 02:55:01PM +0300, Kirill A. Shutemov wrote:
> We are going to do IO a huge page a time. So we need BIO_MAX_PAGES to be
> at least HPAGE_PMD_NR. For x86-64, it's 512 pages.

0-DAY reported this:

[    2.555776] PCI: Using configuration type 1 for base access
[    2.870504] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    2.885252] ------------[ cut here ]------------
[    2.887501] WARNING: CPU: 0 PID: 1 at mm/slab_common.c:98 kmem_cache_create+0xbc/0x18b
[    2.891987] Modules linked in:
[    2.893538] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.8.0-rc6-00021-gd96a38d #421
[    2.897164]  00000000 00200246 cef0decc c141aa9e 00000000 c11279b6 cef0dee4 c104990a
[    2.908396]  00000062 c1a820f0 c1b752f4 c1999b09 cef0def8 c104999c 00000009 00000000
[    2.912555]  00000000 cef0df1c c11279b6 00000000 c1999afe 00001800 6bc01ac0 c1b3d0bc
[    2.916733] Call Trace:
[    2.930981]  [<c141aa9e>] dump_stack+0x74/0xa7
[    2.933128]  [<c11279b6>] ? kmem_cache_create+0xbc/0x18b
[    2.935630]  [<c104990a>] __warn+0xbc/0xd3
[    2.937586]  [<c1b752f4>] ? x509_key_init+0xf/0xf
[    2.939837]  [<c104999c>] warn_slowpath_null+0x16/0x1b
[    2.942279]  [<c11279b6>] kmem_cache_create+0xbc/0x18b
[    2.957745]  [<c1b752f4>] ? x509_key_init+0xf/0xf
[    2.960010]  [<c1b7534c>] init_bio+0x58/0x94
[    2.962048]  [<c10004a8>] do_one_initcall+0x83/0x103
[    2.964428]  [<c1061d24>] ? parse_args+0x1c9/0x29c
[    2.966725]  [<c1b41cc0>] ? kernel_init_freeable+0x16f/0x20c
[    2.969400]  [<c1b41ce0>] kernel_init_freeable+0x18f/0x20c
[    2.994076]  [<c1731e6a>] kernel_init+0xd/0xd5
[    2.996185]  [<c17385ae>] ret_from_kernel_thread+0xe/0x30
[    2.998748]  [<c1731e5d>] ? rest_init+0xa6/0xa6
[    3.000968] ---[ end trace 197bc755366f9a86 ]---
[    3.021244] ACPI: Added _OSI(Module Device)

Fix up:

diff --git a/block/bio.c b/block/bio.c
index aa7354088008..a06bf174cddf 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -44,7 +44,8 @@
  */
 #define BV(x) { .nr_vecs = x, .name = "biovec-"__stringify(x) }
 static struct biovec_slab bvec_slabs[BVEC_POOL_NR] __read_mostly = {
-	BV(1), BV(4), BV(16), BV(64), BV(128), BV(BIO_MAX_PAGES),
+	BV(1), BV(4), BV(16), BV(64), BV(128),
+	{ .nr_vecs = BIO_MAX_PAGES, .name ="biovec-max_pages" },
 };
 #undef BV
 
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C9E6C6B0003
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 23:52:11 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id c2-v6so13700197plo.21
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 20:52:11 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n20si4957242pgc.508.2018.04.04.20.52.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 04 Apr 2018 20:52:09 -0700 (PDT)
Date: Wed, 4 Apr 2018 20:52:00 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v10 00/62] Convert page cache to XArray
Message-ID: <20180405035200.GE9301@bombadil.infradead.org>
References: <20180330034245.10462-1-willy@infradead.org>
 <ff6a317f-920b-62c7-9a7a-9bf235371d41@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ff6a317f-920b-62c7-9a7a-9bf235371d41@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>

On Wed, Apr 04, 2018 at 09:35:46AM -0700, Mike Kravetz wrote:
> Running with this XArray series on top of next-20180329 consistently 'hangs'
> on shutdown looping (?forever?) in tag_pages_for_writeback/xas_for_each_tag.
> All I have to do is make sure there is some activity on the ext4 fs before
> shutdown.  Not sure if this is a 'next-20180329' issue or XArray issue.
> But the fact that we are looping in xas_for_each_tag looks suspicious.

Thanks for your help debugging this!  Particularly collecting the xa_dump.
I got bit by the undefined behaviour of shifting by BITS_PER_LONG,
but of course it was subtle.

The userspace testing framework wasn't catching this for a couple of
reasons; I'll work on making sure it catches this kind of thing in
the future.

I'll fold this in and post a v11 later this week or early next week.

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index eac04922eba2..f5b7e507a86f 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -904,9 +929,12 @@ static inline unsigned int xas_find_chunk(struct xa_state *xas, bool advance,
 	if (advance)
 		offset++;
 	if (XA_CHUNK_SIZE == BITS_PER_LONG) {
-		unsigned long data = *addr & (~0UL << offset);
-		if (data)
-			return __ffs(data);
+		if (offset < XA_CHUNK_SIZE) {
+			unsigned long data = *addr & (~0UL << offset);
+
+			if (data)
+				return __ffs(data);
+		}
 		return XA_CHUNK_SIZE;
 	}
 

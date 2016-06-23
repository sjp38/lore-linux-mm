Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 88381828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 07:00:14 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ts6so4058576pac.1
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 04:00:14 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id t125si6322712pfb.123.2016.06.23.04.00.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 04:00:13 -0700 (PDT)
Date: Thu, 23 Jun 2016 04:00:11 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 10/12] NFS: Do not serialise O_DIRECT reads and writes
Message-ID: <20160623110011.GA6247@infradead.org>
References: <1466544893-12058-3-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-4-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-5-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-6-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-7-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-8-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-9-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-10-git-send-email-trond.myklebust@primarydata.com>
 <20160622164715.GB16823@infradead.org>
 <97494C37-23D3-44FA-A9B8-1887E17429D9@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <97494C37-23D3-44FA-A9B8-1887E17429D9@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 22, 2016 at 05:24:50PM +0000, Trond Myklebust wrote:
> If we?re going to worry about write atomicity in the buffered I/O case,
> then we really should also make sure that O_DIRECT writes are atomic
> w.r.t. page cache updates too.  With this locking model, a buffered
> read() can race with the O_DIRECT write() and get a mixture of old
> data and new.

The difference between buffered I/O and direct I/O is that the former
is covered by standards, and the latter is a Linux extension with very
lose semantics.  But I'm perfectly fine with removing the buffered
reader shared lock for now - for the purposes of direct I/O
synchronization it's not nessecary.


Yes.

> > +	if (mapping->nrpages) {
> > +		inode_lock(inode);
> 
> This is unnecessary now that we have a rw_semaphore. You don?t need to
> take an exclusive lock in order to serialise w.r.t. new writes, and by
> doing so you end up serialising all reads if there happens to be pages
> in the page cache. This is true whether or not those pages are dirty.

Traditionally we needed the exclusive lock around
invalidate_inode_pages2 and unmap_mapping_range, and from a quick look
that's what the existing callers all have.  I don't actually see that
requirement documented anywhere, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

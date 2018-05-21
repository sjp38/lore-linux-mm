Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id CC8866B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 06:25:28 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f10-v6so9785307pln.21
        for <linux-mm@kvack.org>; Mon, 21 May 2018 03:25:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b97-v6si14092383plb.135.2018.05.21.03.25.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 21 May 2018 03:25:27 -0700 (PDT)
Date: Mon, 21 May 2018 03:25:24 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v11 54/63] dax: Hash on XArray instead of mapping
Message-ID: <20180521102524.GB20878@bombadil.infradead.org>
References: <20180414141316.7167-1-willy@infradead.org>
 <20180414141316.7167-55-willy@infradead.org>
 <20180521044756.GD27043@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180521044756.GD27043@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Sun, May 20, 2018 at 10:47:56PM -0600, Ross Zwisler wrote:
> On Sat, Apr 14, 2018 at 07:13:07AM -0700, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > Since the XArray is embedded in the struct address_space, this contains
> > exactly as much entropy as the address of the mapping.
> 
> I agree that they both have the same amount of entropy, but what's the
> benefit?  It doesn't seem like this changes any behavior, fixes any bugs or
> makes things any simpler?

This is a preparatory patch for some of the changes later in the series.
It has no benefit in and of itself; the benefit comes later when we
switch from dax_wake_mapping_entry() to dax_wake_entry():

static void dax_wake_entry(struct xa_state *xas, bool wake_all)

This switch could be left until the end; I can introduce dax_wake_entry()
without this change:

+static void dax_wake_entry(struct xa_state *xas, bool wake_all)
+{
+	struct address_space *mapping = container_of(xas->xa,
+			struct address_space, i_pages);
+       return dax_wake_mapping_entry_waiter(mapping, xas->xa_index, NULL,
+			wake_all);
+}

and then cut everybody over in the final step.

Or I can just explain in the changelog that it's a preparatory step.

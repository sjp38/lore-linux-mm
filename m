Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4826B0266
	for <linux-mm@kvack.org>; Tue, 22 May 2018 17:38:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w7-v6so11948769pfd.9
        for <linux-mm@kvack.org>; Tue, 22 May 2018 14:38:25 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id c2-v6si16814706plr.454.2018.05.22.14.38.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 14:38:24 -0700 (PDT)
Date: Tue, 22 May 2018 15:38:22 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v11 54/63] dax: Hash on XArray instead of mapping
Message-ID: <20180522213822.GA12733@linux.intel.com>
References: <20180414141316.7167-1-willy@infradead.org>
 <20180414141316.7167-55-willy@infradead.org>
 <20180521044756.GD27043@linux.intel.com>
 <20180521102524.GB20878@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180521102524.GB20878@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Mon, May 21, 2018 at 03:25:24AM -0700, Matthew Wilcox wrote:
> On Sun, May 20, 2018 at 10:47:56PM -0600, Ross Zwisler wrote:
> > On Sat, Apr 14, 2018 at 07:13:07AM -0700, Matthew Wilcox wrote:
> > > From: Matthew Wilcox <mawilcox@microsoft.com>
> > > 
> > > Since the XArray is embedded in the struct address_space, this contains
> > > exactly as much entropy as the address of the mapping.
> > 
> > I agree that they both have the same amount of entropy, but what's the
> > benefit?  It doesn't seem like this changes any behavior, fixes any bugs or
> > makes things any simpler?
> 
> This is a preparatory patch for some of the changes later in the series.
> It has no benefit in and of itself; the benefit comes later when we
> switch from dax_wake_mapping_entry() to dax_wake_entry():
> 
> static void dax_wake_entry(struct xa_state *xas, bool wake_all)
> 
> This switch could be left until the end; I can introduce dax_wake_entry()
> without this change:
> 
> +static void dax_wake_entry(struct xa_state *xas, bool wake_all)
> +{
> +	struct address_space *mapping = container_of(xas->xa,
> +			struct address_space, i_pages);
> +       return dax_wake_mapping_entry_waiter(mapping, xas->xa_index, NULL,
> +			wake_all);
> +}
> 
> and then cut everybody over in the final step.
> 
> Or I can just explain in the changelog that it's a preparatory step.

Sure, just a note in the changelog saying that it's a preparatory step would
be good enough for me.

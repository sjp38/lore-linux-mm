Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id E513E6B02A1
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 10:36:22 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id y143so39826245oie.3
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 07:36:22 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id uy16si236696pab.300.2016.11.02.07.36.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 07:36:22 -0700 (PDT)
Date: Wed, 2 Nov 2016 07:36:12 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCHv3 15/41] filemap: handle huge pages in
 do_generic_file_read()
Message-ID: <20161102143612.GA4790@infradead.org>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-16-kirill.shutemov@linux.intel.com>
 <20161013093313.GB26241@quack2.suse.cz>
 <20161031181035.GA7007@node.shutemov.name>
 <20161101163940.GA5459@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161101163940.GA5459@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Tue, Nov 01, 2016 at 05:39:40PM +0100, Jan Kara wrote:
> I'd also note that having PMD-sized pages has some obvious disadvantages as
> well:
> 
> 1) I'm not sure buffer head handling code will quite scale to 512 or even
> 2048 buffer_heads on a linked list referenced from a page. It may work but
> I suspect the performance will suck. 

buffer_head handling always sucks.  For the iomap based bufferd write
path I plan to support a buffer_head-less mode for the block size ==
PAGE_SIZE case in 4.11 latest, but if I get enough other things of my
plate in time even for 4.10.  I think that's the right way to go for
THP, especially if we require the fs to allocate the whole huge page
as a single extent, similar to the DAX PMD mapping case.

> 2) PMD-sized pages result in increased space & memory usage.

How so?

> 3) In ext4 we have to estimate how much metadata we may need to modify when
> allocating blocks underlying a page in the worst case (you don't seem to
> update this estimate in your patch set). With 2048 blocks underlying a page,
> each possibly in a different block group, it is a lot of metadata forcing
> us to reserve a large transaction (not sure if you'll be able to even
> reserve such large transaction with the default journal size), which again
> makes things slower.

As said above I think we should only use huge page mappings if there is
a single underlying extent, same as in DAX to keep the complexity down.

> 4) As you have noted some places like write_begin() still depend on 4k
> pages which creates a strange mix of places that use subpages and that use
> head pages.

Just use the iomap bufferd I/O code and all these issues will go away.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

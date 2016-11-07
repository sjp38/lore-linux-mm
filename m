Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA566B0253
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 06:32:07 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id y16so58647764wmd.6
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 03:32:07 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id j132si9951083wmf.13.2016.11.07.03.32.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 03:32:05 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id u144so15937821wmu.0
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 03:32:05 -0800 (PST)
Date: Mon, 7 Nov 2016 14:13:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 15/41] filemap: handle huge pages in
 do_generic_file_read()
Message-ID: <20161107111305.GB13280@node.shutemov.name>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-16-kirill.shutemov@linux.intel.com>
 <20161013093313.GB26241@quack2.suse.cz>
 <20161031181035.GA7007@node.shutemov.name>
 <20161101163940.GA5459@quack2.suse.cz>
 <20161102143612.GA4790@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161102143612.GA4790@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Wed, Nov 02, 2016 at 07:36:12AM -0700, Christoph Hellwig wrote:
> On Tue, Nov 01, 2016 at 05:39:40PM +0100, Jan Kara wrote:
> > I'd also note that having PMD-sized pages has some obvious disadvantages as
> > well:
> > 
> > 1) I'm not sure buffer head handling code will quite scale to 512 or even
> > 2048 buffer_heads on a linked list referenced from a page. It may work but
> > I suspect the performance will suck. 
> 
> buffer_head handling always sucks.  For the iomap based bufferd write
> path I plan to support a buffer_head-less mode for the block size ==
> PAGE_SIZE case in 4.11 latest, but if I get enough other things of my
> plate in time even for 4.10.  I think that's the right way to go for
> THP, especially if we require the fs to allocate the whole huge page
> as a single extent, similar to the DAX PMD mapping case.
> 
> > 2) PMD-sized pages result in increased space & memory usage.
> 
> How so?
> 
> > 3) In ext4 we have to estimate how much metadata we may need to modify when
> > allocating blocks underlying a page in the worst case (you don't seem to
> > update this estimate in your patch set). With 2048 blocks underlying a page,
> > each possibly in a different block group, it is a lot of metadata forcing
> > us to reserve a large transaction (not sure if you'll be able to even
> > reserve such large transaction with the default journal size), which again
> > makes things slower.
> 
> As said above I think we should only use huge page mappings if there is
> a single underlying extent, same as in DAX to keep the complexity down.

It looks like a huge limitation to me.

> > 4) As you have noted some places like write_begin() still depend on 4k
> > pages which creates a strange mix of places that use subpages and that use
> > head pages.
> 
> Just use the iomap bufferd I/O code and all these issues will go away.

Not really.

I'm looking onto iomap_write_actor(): we still calculate 'offset' and
'bytes' based on PAGE_SIZE before we even get the page.
This way we limit outself to PAGE_SIZE per-iteration.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

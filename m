Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 984FC280250
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 13:56:11 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n67so538342wme.7
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 10:56:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vt7si10209658wjb.282.2016.11.03.10.56.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Nov 2016 10:56:10 -0700 (PDT)
Date: Thu, 3 Nov 2016 18:56:02 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCHv3 15/41] filemap: handle huge pages in
 do_generic_file_read()
Message-ID: <20161103175602.GB24234@quack2.suse.cz>
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
Cc: Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Wed 02-11-16 07:36:12, Christoph Hellwig wrote:
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

Yeah, if we require whole THP to be backed by a single extent, things get
simpler. But still there's the issue that ext4 cannot easily use iomap code
for buffered writes because of the data exposure issue we already talked
about - well, ext4 could actually work (it supports unwritten extents) but
old compatibility modes won't work and I'd strongly prefer not to have two
independent write paths in ext4... But I'll put more thought into this, I
have some idea how we could hack around the problem even for on-disk formats
that don't support unwritten extents. The trick we could use is that we'd
just mark the range of file as unwritten in memory in extent cache we have,
that should protect us against exposing uninitialized pages in racing
faults.

> > 2) PMD-sized pages result in increased space & memory usage.
> 
> How so?

Well, memory usage is clear I guess - if the files are smaller than THP
size, or if you don't use all the 4k pages that are forming THP you are
wasting memory. Sure it can be somewhat controlled by the heuristics
deciding when to use THP in pagecache and when to fall back to 4k pages.

Regarding space usage - it is mostly the case for sparse mmaped IO where
you always have to allocate (and write out) all the blocks underlying a THP
that gets written to, even though you may only need 4K from that area...

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
> 
> > 4) As you have noted some places like write_begin() still depend on 4k
> > pages which creates a strange mix of places that use subpages and that use
> > head pages.
> 
> Just use the iomap bufferd I/O code and all these issues will go away.

Yep, the above two things would make things somewhat less ugly I agree.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

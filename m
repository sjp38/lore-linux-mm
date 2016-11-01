Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5FA2E6B02A1
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 12:39:47 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 68so64294814wmz.5
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 09:39:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 64si31947898wmq.74.2016.11.01.09.39.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Nov 2016 09:39:45 -0700 (PDT)
Date: Tue, 1 Nov 2016 17:39:40 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCHv3 15/41] filemap: handle huge pages in
 do_generic_file_read()
Message-ID: <20161101163940.GA5459@quack2.suse.cz>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-16-kirill.shutemov@linux.intel.com>
 <20161013093313.GB26241@quack2.suse.cz>
 <20161031181035.GA7007@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161031181035.GA7007@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Mon 31-10-16 21:10:35, Kirill A. Shutemov wrote:
> [ My mail system got broken and original reply didn't get to through. Resent. ]

OK, this answers some of my questions from previous email so disregard that
one.

> On Thu, Oct 13, 2016 at 11:33:13AM +0200, Jan Kara wrote:
> > On Thu 15-09-16 14:54:57, Kirill A. Shutemov wrote:
> > > Most of work happans on head page. Only when we need to do copy data to
> > > userspace we find relevant subpage.
> > > 
> > > We are still limited by PAGE_SIZE per iteration. Lifting this limitation
> > > would require some more work.
> >
> > Hum, I'm kind of lost.
> 
> The limitation here comes from how copy_page_to_iter() and
> copy_page_from_iter() work wrt. highmem: it can only handle one small
> page a time.
> 
> On write side, we also have problem with assuming small page: write length
> and offset within page calculated before we know if small or huge page is
> allocated. It's not easy to fix. Looks like it would require change in
> ->write_begin() interface to accept len > PAGE_SIZE.
>
> > Can you point me to some design document / email that would explain some
> > high level ideas how are huge pages in page cache supposed to work?
> 
> I'll elaborate more in cover letter to next revision.
> 
> > When are we supposed to operate on the head page and when on subpage?
> 
> It's case-by-case. See above explanation why we're limited to PAGE_SIZE
> here.
> 
> > What is protected by the page lock of the head page?
> 
> Whole huge page. As with anon pages.
> 
> > Do page locks of subpages play any role?
> 
> lock_page() on any subpage would lock whole huge page.
> 
> > If understand right, e.g.  pagecache_get_page() will return subpages but
> > is it generally safe to operate on subpages individually or do we have
> > to be aware that they are part of a huge page?
> 
> I tried to make it as transparent as possible: page flag operations will
> be redirected to head page, if necessary. Things like page_mapping() and
> page_to_pgoff() know about huge pages.
> 
> Direct access to struct page fields must be avoided for tail pages as most
> of them doesn't have meaning you would expect for small pages.

OK, good to know.

> > If I understand the motivation right, it is mostly about being able to mmap
> > PMD-sized chunks to userspace. So my naive idea would be that we could just
> > implement it by allocating PMD sized chunks of pages when adding pages to
> > page cache, we don't even have to read them all unless we come from PMD
> > fault path.
> 
> Well, no. We have one PG_{uptodate,dirty,writeback,mappedtodisk,etc}
> per-hugepage, one common list of buffer heads...
> 
> PG_dirty and PG_uptodate behaviour inhered from anon-THP (where handling
> it otherwise doesn't make sense) and handling it differently for file-THP
> is nightmare from maintenance POV.

But the complexity of two different page sizes for page cache and *each*
filesystem that wants to support it does not make the maintenance easy
either. So I'm not convinced that using the same rules for anon-THP and
file-THP is a clear win. And if we have these two options neither of which
has negligible maintenance cost, I'd also like to see more justification
for why it is a good idea to have file-THP for normal filesystems. Do you
have any performance numbers that show it is a win under some realistic
workload?

I'd also note that having PMD-sized pages has some obvious disadvantages as
well:

1) I'm not sure buffer head handling code will quite scale to 512 or even
2048 buffer_heads on a linked list referenced from a page. It may work but
I suspect the performance will suck. 

2) PMD-sized pages result in increased space & memory usage.

3) In ext4 we have to estimate how much metadata we may need to modify when
allocating blocks underlying a page in the worst case (you don't seem to
update this estimate in your patch set). With 2048 blocks underlying a page,
each possibly in a different block group, it is a lot of metadata forcing
us to reserve a large transaction (not sure if you'll be able to even
reserve such large transaction with the default journal size), which again
makes things slower.

4) As you have noted some places like write_begin() still depend on 4k
pages which creates a strange mix of places that use subpages and that use
head pages.

All this would be a non-issue (well, except 2 I guess) if we just didn't
expose filesystems to the fact that something like file-THP exists.

> > Reclaim may need to be aware not to split pages unnecessarily
> > but that's about it. So I'd like to understand what's wrong with this
> > naive idea and why do filesystems need to be aware that someone wants to
> > map in PMD sized chunks...
> 
> In addition to flags, THP uses some space in struct page of tail pages to
> encode additional information. See compound_{mapcount,head,dtor,order},
> page_deferred_list().

Thanks, I'll check that.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

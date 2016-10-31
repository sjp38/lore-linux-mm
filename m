Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 227706B0290
	for <linux-mm@kvack.org>; Mon, 31 Oct 2016 14:10:40 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id b81so5212829lfe.1
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 11:10:40 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id o75si3960437lff.70.2016.10.31.11.10.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Oct 2016 11:10:38 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id i187so7521040lfe.1
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 11:10:38 -0700 (PDT)
Date: Mon, 31 Oct 2016 21:10:35 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 15/41] filemap: handle huge pages in
 do_generic_file_read()
Message-ID: <20161031181035.GA7007@node.shutemov.name>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-16-kirill.shutemov@linux.intel.com>
 <20161013093313.GB26241@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161013093313.GB26241@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

[ My mail system got broken and original reply didn't get to through. Resent. ]

On Thu, Oct 13, 2016 at 11:33:13AM +0200, Jan Kara wrote:
> On Thu 15-09-16 14:54:57, Kirill A. Shutemov wrote:
> > Most of work happans on head page. Only when we need to do copy data to
> > userspace we find relevant subpage.
> > 
> > We are still limited by PAGE_SIZE per iteration. Lifting this limitation
> > would require some more work.
>
> Hum, I'm kind of lost.

The limitation here comes from how copy_page_to_iter() and
copy_page_from_iter() work wrt. highmem: it can only handle one small
page a time.

On write side, we also have problem with assuming small page: write length
and offset within page calculated before we know if small or huge page is
allocated. It's not easy to fix. Looks like it would require change in
->write_begin() interface to accept len > PAGE_SIZE.

> Can you point me to some design document / email that would explain some
> high level ideas how are huge pages in page cache supposed to work?

I'll elaborate more in cover letter to next revision.

> When are we supposed to operate on the head page and when on subpage?

It's case-by-case. See above explanation why we're limited to PAGE_SIZE
here.

> What is protected by the page lock of the head page?

Whole huge page. As with anon pages.

> Do page locks of subpages play any role?

lock_page() on any subpage would lock whole huge page.

> If understand right, e.g.  pagecache_get_page() will return subpages but
> is it generally safe to operate on subpages individually or do we have
> to be aware that they are part of a huge page?

I tried to make it as transparent as possible: page flag operations will
be redirected to head page, if necessary. Things like page_mapping() and
page_to_pgoff() know about huge pages.

Direct access to struct page fields must be avoided for tail pages as most
of them doesn't have meaning you would expect for small pages.

> If I understand the motivation right, it is mostly about being able to mmap
> PMD-sized chunks to userspace. So my naive idea would be that we could just
> implement it by allocating PMD sized chunks of pages when adding pages to
> page cache, we don't even have to read them all unless we come from PMD
> fault path.

Well, no. We have one PG_{uptodate,dirty,writeback,mappedtodisk,etc}
per-hugepage, one common list of buffer heads...

PG_dirty and PG_uptodate behaviour inhered from anon-THP (where handling
it otherwise doesn't make sense) and handling it differently for file-THP
is nightmare from maintenance POV.

> Reclaim may need to be aware not to split pages unnecessarily
> but that's about it. So I'd like to understand what's wrong with this
> naive idea and why do filesystems need to be aware that someone wants to
> map in PMD sized chunks...

In addition to flags, THP uses some space in struct page of tail pages to
encode additional information. See compound_{mapcount,head,dtor,order},
page_deferred_list().

--
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

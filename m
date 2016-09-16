Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1BFC16B0069
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 08:17:45 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id u14so72424057lfd.0
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 05:17:45 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id e199si5626379lfe.148.2016.09.16.05.17.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Sep 2016 05:17:43 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id l131so4892505lfl.0
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 05:17:43 -0700 (PDT)
Date: Fri, 16 Sep 2016 15:17:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 29/41] ext4: make ext4_mpage_readpages() hugepage-aware
Message-ID: <20160916121740.GA18021@node.shutemov.name>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-30-kirill.shutemov@linux.intel.com>
 <56332284-449B-4998-AA99-245361CEE6D9@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56332284-449B-4998-AA99-245361CEE6D9@dilger.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-block@vger.kernel.org

On Thu, Sep 15, 2016 at 06:27:10AM -0600, Andreas Dilger wrote:
> On Sep 15, 2016, at 5:55 AM, Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> > 
> > This patch modifies ext4_mpage_readpages() to deal with huge pages.
> > 
> > We read out 2M at once, so we have to alloc (HPAGE_PMD_NR *
> > blocks_per_page) sector_t for that. I'm not entirely happy with kmalloc
> > in this codepath, but don't see any other option.
> 
> If you're reading 2MB from disk (possibly from disjoint blocks with seeks
> in between) I don't think that the kmalloc() is going to be the limiting
> performance factor.  If you are concerned about the size of the kmalloc()
> causing failures when pages are fragmented (it can be 16KB for 1KB blocks
> with 4KB pages), then using ext4_kvmalloc() to fall back to vmalloc() in
> case kmalloc() fails.  It shouldn't fail often for 16KB allocations,
> but it could in theory.

Good point. Will use ext4_kvmalloc().

> I also notice that ext4_kvmalloc() should probably use unlikely() for
> the failure case, so that the uncommon vmalloc() fallback is out-of-line
> in this more important codepath.  The only other callers are during mount,
> so a branch misprediction is not critical.

I agree. But it's out-of-scope for the patchset.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

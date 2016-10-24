Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 763646B028C
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 18:29:53 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id i187so29849877lfe.4
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 15:29:53 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id p193si11702924lfd.308.2016.10.25.15.29.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 15:29:52 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id x79so13052700lff.2
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 15:29:51 -0700 (PDT)
Date: Mon, 24 Oct 2016 14:36:25 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 17/41] filemap: handle huge pages in
 filemap_fdatawait_range()
Message-ID: <20161024113625.GC2849@node.shutemov.name>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-18-kirill.shutemov@linux.intel.com>
 <20161013094441.GC26241@quack2.suse.cz>
 <20161013120844.GA2906@node>
 <20161013131802.GC27186@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161013131802.GC27186@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu, Oct 13, 2016 at 03:18:02PM +0200, Jan Kara wrote:
> On Thu 13-10-16 15:08:44, Kirill A. Shutemov wrote:
> > On Thu, Oct 13, 2016 at 11:44:41AM +0200, Jan Kara wrote:
> > > On Thu 15-09-16 14:54:59, Kirill A. Shutemov wrote:
> > > > We writeback whole huge page a time.
> > > 
> > > This is one of the things I don't understand. Firstly I didn't see where
> > > changes of writeback like this would happen (maybe they come later).
> > > Secondly I'm not sure why e.g. writeback should behave atomically wrt huge
> > > pages. Is this because radix-tree multiorder entry tracks dirtiness for us
> > > at that granularity?
> > 
> > We track dirty/writeback on per-compound pages: meaning we have one
> > dirty/writeback flag for whole compound page, not on every individual
> > 4k subpage. The same story for radix-tree tags.
> > 
> > > BTW, can you also explain why do we need multiorder entries? What do
> > > they solve for us?
> > 
> > It helps us having coherent view on tags in radix-tree: no matter which
> > index we refer from the range huge page covers we will get the same
> > answer on which tags set.
> 
> OK, understand that. But why do we need a coherent view? For which purposes
> exactly do we care that it is not just a bunch of 4k pages that happen to
> be physically contiguous and thus can be mapped in one PMD?

My understanding is that things like PageDirty() should be handled on the
same granularity as PAGECACHE_TAG_DIRTY, otherwise things can go horribly
wrong...

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 86B806B0290
	for <linux-mm@kvack.org>; Mon, 31 Oct 2016 12:06:18 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 68so45455101wmz.5
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 09:06:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b65si25124685wmf.115.2016.10.31.09.06.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 31 Oct 2016 09:06:16 -0700 (PDT)
Date: Sun, 30 Oct 2016 18:31:35 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCHv3 17/41] filemap: handle huge pages in
 filemap_fdatawait_range()
Message-ID: <20161030173135.GC17039@quack2.suse.cz>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-18-kirill.shutemov@linux.intel.com>
 <20161013094441.GC26241@quack2.suse.cz>
 <20161013120844.GA2906@node>
 <20161013131802.GC27186@quack2.suse.cz>
 <20161024113625.GC2849@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161024113625.GC2849@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Mon 24-10-16 14:36:25, Kirill A. Shutemov wrote:
> On Thu, Oct 13, 2016 at 03:18:02PM +0200, Jan Kara wrote:
> > On Thu 13-10-16 15:08:44, Kirill A. Shutemov wrote:
> > > On Thu, Oct 13, 2016 at 11:44:41AM +0200, Jan Kara wrote:
> > > > On Thu 15-09-16 14:54:59, Kirill A. Shutemov wrote:
> > > > > We writeback whole huge page a time.
> > > > 
> > > > This is one of the things I don't understand. Firstly I didn't see where
> > > > changes of writeback like this would happen (maybe they come later).
> > > > Secondly I'm not sure why e.g. writeback should behave atomically wrt huge
> > > > pages. Is this because radix-tree multiorder entry tracks dirtiness for us
> > > > at that granularity?
> > > 
> > > We track dirty/writeback on per-compound pages: meaning we have one
> > > dirty/writeback flag for whole compound page, not on every individual
> > > 4k subpage. The same story for radix-tree tags.
> > > 
> > > > BTW, can you also explain why do we need multiorder entries? What do
> > > > they solve for us?
> > > 
> > > It helps us having coherent view on tags in radix-tree: no matter which
> > > index we refer from the range huge page covers we will get the same
> > > answer on which tags set.
> > 
> > OK, understand that. But why do we need a coherent view? For which purposes
> > exactly do we care that it is not just a bunch of 4k pages that happen to
> > be physically contiguous and thus can be mapped in one PMD?
> 
> My understanding is that things like PageDirty() should be handled on the
> same granularity as PAGECACHE_TAG_DIRTY, otherwise things can go horribly
> wrong...

Yeah, I agree with that. My question was rather aiming in the direction:
Why don't we keep PageDirty and PAGECACHE_TAG_DIRTY on a page granularity?
Why do we push all this to happen only in the head page?

In your coverletter of the latest version (BTW thanks for expanding
explanations there) you write:
  - head page (the first subpage) on LRU represents whole huge page;
  - head page's flags represent state of whole huge page (with few
    exceptions);
  - mm can't migrate subpages of the compound page individually;

So the fact that flags of a head page represent flags of each individual
page is the decision that I'm questioning, at least for PageDirty and
PageWriteback flags. I'm asking because frankly, I don't like the series
much. IMHO too many places need to know about huge pages and things will
get broken frequently. And from filesystem POV I don't really see why a
filesystem should care about huge pages *at all*. Sure functions allocating
pages into page cache need to care, sure functions mapping pages into page
tables need to care. But nobody else should need to be aware we are playing
some huge page games... At least that is my idea how things ought to work
;)

Your solution seems to go more towards the direction where we have two
different sizes of pages in the system and everyone has to cope with it.
But I'd also note that you go only half way there - e.g. page lookup
functions still work with subpages, some places still use PAGE_SIZE &
page->index, ... - so the result is a strange mix.

So what are the reasons for having pages forming a huge page bound so
tightly?


								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

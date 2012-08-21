Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 5DBCD6B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 15:00:23 -0400 (EDT)
Received: by yhr47 with SMTP id 47so165715yhr.14
        for <linux-mm@kvack.org>; Tue, 21 Aug 2012 12:00:22 -0700 (PDT)
Date: Tue, 21 Aug 2012 11:59:42 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 01/15] mm: add invalidatepage_range address space
 operation
In-Reply-To: <5033a999.0f403a0a.19c3.ffff95deSMTPIN_ADDED@mx.google.com>
Message-ID: <alpine.LSU.2.00.1208211144550.2178@eggly.anvils>
References: <1343376074-28034-1-git-send-email-lczerner@redhat.com> <1343376074-28034-2-git-send-email-lczerner@redhat.com> <alpine.LSU.2.00.1208192153020.2390@eggly.anvils> <5033a999.0f403a0a.19c3.ffff95deSMTPIN_ADDED@mx.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Czerner <lczerner@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, 21 Aug 2012, Lukas Czerner wrote:
> On Sun, 19 Aug 2012, Hugh Dickins wrote:
> > > --- a/include/linux/fs.h
> > > +++ b/include/linux/fs.h
> > > @@ -620,6 +620,8 @@ struct address_space_operations {
> > >  	/* Unfortunately this kludge is needed for FIBMAP. Don't use it */
> > >  	sector_t (*bmap)(struct address_space *, sector_t);
> > >  	void (*invalidatepage) (struct page *, unsigned long);
> > > +	void (*invalidatepage_range) (struct page *, unsigned long,
> > > +				      unsigned long);
> > 
> > It may turn out to be bad advice, given how invalidatepage() already
> > takes an unsigned long, but I'd be tempted to make both of these args
> > unsigned int, since that helps to make it clearer that they're intended
> > to be offsets within a page, in the range 0..PAGE_CACHE_SIZE.
> > 
> > (partial_start, partial_end and top in truncate_inode_pages_range()
> > are all unsigned int.)
> 
> Hmm, this does not seem right. I can see that PAGE_CACHE_SIZE
> (PAGE_SIZE) can be defined as unsigned long, or am I missing
> something ?

They would be defined as unsigned long so that they can be used in
masks like ~(PAGE_SIZE - 1), and behave as expected on addresses,
without needing casts to be added all over.

We do not (currently!) expect PAGE_SIZE or PAGE_CACHE_SIZE to grow
beyond an unsigned int - but indeed they can be larger than what's
held in an unsigned short (look no further than ia64 or ppc64).

For more reassurance, see include/linux/highmem.h, which declares
zero_user_segments() and others: unsigned int (well, unsigned with
the int implicit) for offsets within a page.

Hugh

> > 
> > Andrew is very keen on naming arguments in prototypes,
> > and I think there is an especially strong case for it here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 70ACD6B006C
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 13:44:31 -0400 (EDT)
Date: Tue, 4 Sep 2012 13:44:26 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 02/15 v2] jbd2: implement
 jbd2_journal_invalidatepage_range
Message-ID: <20120904174426.GA28370@fieldses.org>
References: <1346451711-1931-1-git-send-email-lczerner@redhat.com>
 <1346451711-1931-3-git-send-email-lczerner@redhat.com>
 <20120904145213.GA26656@fieldses.org>
 <alpine.LFD.2.00.1209041127230.18459@new-host-2>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.LFD.2.00.1209041127230.18459@new-host-2>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?THVrw6HFoQ==?= Czerner <lczerner@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, tytso@mit.edu, hughd@google.com, linux-mm@kvack.org

On Tue, Sep 04, 2012 at 11:37:13AM -0400, LukA!A! Czerner wrote:
> On Tue, 4 Sep 2012, J. Bruce Fields wrote:
> 
> > Date: Tue, 4 Sep 2012 10:52:13 -0400
> > From: J. Bruce Fields <bfields@fieldses.org>
> > To: Lukas Czerner <lczerner@redhat.com>
> > Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, tytso@mit.edu,
> >     hughd@google.com, linux-mm@kvack.org
> > Subject: Re: [PATCH 02/15 v2] jbd2: implement
> >     jbd2_journal_invalidatepage_range
> > 
> > On Fri, Aug 31, 2012 at 06:21:38PM -0400, Lukas Czerner wrote:
> > > mm now supports invalidatepage_range address space operation and there
> > > are two file system using jbd2 also implementing punch hole feature
> > > which can benefit from this. We need to implement the same thing for
> > > jbd2 layer in order to allow those file system take benefit of this
> > > functionality.
> > > 
> > > With new function jbd2_journal_invalidatepage_range() we can now specify
> > > length to invalidate, rather than assuming invalidate to the end of the
> > > page.
> > > 
> > > Signed-off-by: Lukas Czerner <lczerner@redhat.com>
> > > ---
> > >  fs/jbd2/journal.c     |    1 +
> > >  fs/jbd2/transaction.c |   19 +++++++++++++++++--
> > >  include/linux/jbd2.h  |    2 ++
> > >  3 files changed, 20 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/fs/jbd2/journal.c b/fs/jbd2/journal.c
> > > index e149b99..e4618e9 100644
> > > --- a/fs/jbd2/journal.c
> > > +++ b/fs/jbd2/journal.c
> > > @@ -86,6 +86,7 @@ EXPORT_SYMBOL(jbd2_journal_force_commit_nested);
> > >  EXPORT_SYMBOL(jbd2_journal_wipe);
> > >  EXPORT_SYMBOL(jbd2_journal_blocks_per_page);
> > >  EXPORT_SYMBOL(jbd2_journal_invalidatepage);
> > > +EXPORT_SYMBOL(jbd2_journal_invalidatepage_range);
> > >  EXPORT_SYMBOL(jbd2_journal_try_to_free_buffers);
> > >  EXPORT_SYMBOL(jbd2_journal_force_commit);
> > >  EXPORT_SYMBOL(jbd2_journal_file_inode);
> > > diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
> > > index fb1ab953..65c1374 100644
> > > --- a/fs/jbd2/transaction.c
> > > +++ b/fs/jbd2/transaction.c
> > > @@ -1993,10 +1993,20 @@ zap_buffer_unlocked:
> > >   *
> > >   */
> > >  void jbd2_journal_invalidatepage(journal_t *journal,
> > > -		      struct page *page,
> > > -		      unsigned long offset)
> > > +				 struct page *page,
> > > +				 unsigned long offset)
> > > +{
> > > +	jbd2_journal_invalidatepage_range(journal, page, offset,
> > > +					  PAGE_CACHE_SIZE - offset);
> > > +}
> > > +
> > > +void jbd2_journal_invalidatepage_range(journal_t *journal,
> > > +				       struct page *page,
> > > +				       unsigned int offset,
> > > +				       unsigned int length)
> > >  {
> > >  	struct buffer_head *head, *bh, *next;
> > > +	unsigned int stop = offset + length;
> > >  	unsigned int curr_off = 0;
> > >  	int may_free = 1;
> > >  
> > > @@ -2005,6 +2015,8 @@ void jbd2_journal_invalidatepage(journal_t *journal,
> > >  	if (!page_has_buffers(page))
> > >  		return;
> > >  
> > > +	BUG_ON(stop > PAGE_CACHE_SIZE || stop < length);
> > 
> > This misses e.g. length == (unsigned int)(-1), offset = 1.  Could make
> > it obvious with:
> 
> Hmm.. So if length = -1 (e.g. UINT_MAX) and offset = 1 then:
> 
> offset + length = 0
> 
> so 
> 
> length is bigger than (offset + length) right ? Speaking in numbers:
> 
> length = 4294967295
> offset = 1
> stop = length + offset = 0
> 
> so (0 < 4294967295) is true and we'll BUG() on this, right ?
> 
> Am I missing something ?

Gah, no, I just wasn't thinking straight: the only way offset or length
could individually be greater than PAGE_CACHE_SIZE while their sum is
less would be if their sum overflows, in which case the second condition
(stop < length) would trigger.  So the two conditions are enough.

--b.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

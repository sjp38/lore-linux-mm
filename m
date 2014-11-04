Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 52DFA6B0075
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 10:33:49 -0500 (EST)
Received: by mail-lb0-f182.google.com with SMTP id f15so12282473lbj.41
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 07:33:48 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ky4si1390541lbc.28.2014.11.04.07.33.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 07:33:47 -0800 (PST)
Date: Tue, 4 Nov 2014 16:33:43 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Improve comment before pagecache_isize_extended()
Message-ID: <20141104153343.GA21902@quack.suse.cz>
References: <1415101390-18301-1-git-send-email-jack@suse.cz>
 <5458D29A0200007800044C76@mail.emea.novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5458D29A0200007800044C76@mail.emea.novell.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Beulich <JBeulich@suse.com>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org

On Tue 04-11-14 12:20:26, Jan Beulich wrote:
> >>> On 04.11.14 at 12:43, <"jack@suse.cz".non-mime.internet> wrote:
> > --- a/mm/truncate.c
> > +++ b/mm/truncate.c
> > @@ -743,10 +743,13 @@ EXPORT_SYMBOL(truncate_setsize);
> >   * changed.
> >   *
> >   * The function must be called after i_size is updated so that page fault
> > - * coming after we unlock the page will already see the new i_size.
> > - * The function must be called while we still hold i_mutex - this not only
> > - * makes sure i_size is stable but also that userspace cannot observe new
> > - * i_size value before we are prepared to store mmap writes at new inode size.
> > + * coming after we unlock the page will already see the new i_size.  The caller
> > + * must make sure (generally by holding i_mutex but e.g. XFS uses its private
> > + * lock) i_size cannot change from the new value while we are called. It must
> > + * also make sure userspace cannot observe new i_size value before we are
> > + * prepared to store mmap writes upto new inode size (otherwise userspace could
> > + * think it stored data via mmap within i_size but they would get zeroed due to
> > + * writeback & reclaim because they have no backing blocks).
> >   */
> >  void pagecache_isize_extended(struct inode *inode, loff_t from, loff_t to)
> >  {
> 
> May I suggest that the comment preceding truncate_setsize() also be
> updated/removed?
  But that comment is actually still true AFAICT because VFS takes i_mutex
before calling into ->setattr(). So we hold i_mutex in truncate_setsize()
even for XFS.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

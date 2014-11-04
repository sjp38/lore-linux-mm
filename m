Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1DA7B6B00A8
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 14:37:16 -0500 (EST)
Received: by mail-la0-f42.google.com with SMTP id gq15so1529120lab.15
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 11:37:15 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lm8si2467215lac.7.2014.11.04.11.37.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 11:37:14 -0800 (PST)
Date: Tue, 4 Nov 2014 20:37:07 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Improve comment before pagecache_isize_extended()
Message-ID: <20141104193707.GE21902@quack.suse.cz>
References: <1415101390-18301-1-git-send-email-jack@suse.cz>
 <5458D29A0200007800044C76@mail.emea.novell.com>
 <20141104153343.GA21902@quack.suse.cz>
 <54590AC80200007800044E95@mail.emea.novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54590AC80200007800044E95@mail.emea.novell.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Beulich <JBeulich@suse.com>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org

On Tue 04-11-14 16:20:08, Jan Beulich wrote:
> >>> On 04.11.14 at 16:33, <jack@suse.cz> wrote:
> > On Tue 04-11-14 12:20:26, Jan Beulich wrote:
> >> >>> On 04.11.14 at 12:43, <"jack@suse.cz".non-mime.internet> wrote:
> >> > --- a/mm/truncate.c
> >> > +++ b/mm/truncate.c
> >> > @@ -743,10 +743,13 @@ EXPORT_SYMBOL(truncate_setsize);
> >> >   * changed.
> >> >   *
> >> >   * The function must be called after i_size is updated so that page fault
> >> > - * coming after we unlock the page will already see the new i_size.
> >> > - * The function must be called while we still hold i_mutex - this not only
> >> > - * makes sure i_size is stable but also that userspace cannot observe new
> >> > - * i_size value before we are prepared to store mmap writes at new inode 
> > size.
> >> > + * coming after we unlock the page will already see the new i_size.  The 
> > caller
> >> > + * must make sure (generally by holding i_mutex but e.g. XFS uses its 
> > private
> >> > + * lock) i_size cannot change from the new value while we are called. It 
> > must
> >> > + * also make sure userspace cannot observe new i_size value before we are
> >> > + * prepared to store mmap writes upto new inode size (otherwise userspace 
> > could
> >> > + * think it stored data via mmap within i_size but they would get zeroed 
> > due to
> >> > + * writeback & reclaim because they have no backing blocks).
> >> >   */
> >> >  void pagecache_isize_extended(struct inode *inode, loff_t from, loff_t to)
> >> >  {
> >> 
> >> May I suggest that the comment preceding truncate_setsize() also be
> >> updated/removed?
> >   But that comment is actually still true AFAICT because VFS takes i_mutex
> > before calling into ->setattr(). So we hold i_mutex in truncate_setsize()
> > even for XFS.
> 
> I doubt that, especially in the light of the WARN_ON() that
> prompted all this:
> 
> [<ffffffff810053fa>] dump_trace+0x7a/0x350
> [<ffffffff810050de>] show_stack_log_lvl+0xee/0x150
> [<ffffffff810064fc>] show_stack+0x1c/0x50
> [<ffffffff8138e4e3>] dump_stack+0x68/0x7d
> [<ffffffff81042c82>] warn_slowpath_common+0x82/0xb0
> [<ffffffff810d3831>] pagecache_isize_extended+0x121/0x130
> [<ffffffff810d4689>] truncate_setsize+0x29/0x50
> [<ffffffffa056705f>] xfs_setattr_size+0x12f/0x440 [xfs]
> [<ffffffffa055cbf7>] xfs_file_fallocate+0x297/0x310 [xfs]
> [<ffffffff81111b59>] do_fallocate+0x169/0x190
> [<ffffffff8111206e>] SyS_fallocate+0x4e/0x90
> [<ffffffff81392712>] system_call_fastpath+0x12/0x17
> [<00007f0e6bdddf45>] 0x7f0e6bdddf45
> 
> I.e. truncate_setsize() is being called here without the mutex
> held (or else the WARN_ON() wouldn't have got triggered in
> the first place).
  Ah, OK, I was thinking about standard truncate path and didn't notice
that xfs_setattr_size() can get called also from the fallocate code.
I'll fix that comment as well.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

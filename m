Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 8D7206B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 18:40:28 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id g10so1084624pdj.34
        for <linux-mm@kvack.org>; Thu, 11 Apr 2013 15:40:27 -0700 (PDT)
Date: Thu, 11 Apr 2013 15:40:21 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 10/18] mm: teach truncate_inode_pages_range() to handle
 non page aligned ranges
In-Reply-To: <20130411211851.GD9379@quack.suse.cz>
Message-ID: <alpine.LNX.2.00.1304111528400.820@eggly.anvils>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com> <1365498867-27782-11-git-send-email-lczerner@redhat.com> <20130411211851.GD9379@quack.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Lukas Czerner <lczerner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, 11 Apr 2013, Jan Kara wrote:
> On Tue 09-04-13 11:14:19, Lukas Czerner wrote:
> > This commit changes truncate_inode_pages_range() so it can handle non
> > page aligned regions of the truncate. Currently we can hit BUG_ON when
> > the end of the range is not page aligned, but we can handle unaligned
> > start of the range.
> > 
> > Being able to handle non page aligned regions of the page can help file
> > system punch_hole implementations and save some work, because once we're
> > holding the page we might as well deal with it right away.
> > 
> > In previous commits we've changed ->invalidatepage() prototype to accept
> > 'length' argument to be able to specify range to invalidate. No we can
> > use that new ability in truncate_inode_pages_range().
> > 
> > Signed-off-by: Lukas Czerner <lczerner@redhat.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Hugh Dickins <hughd@google.com>
> > ---
> >  mm/truncate.c |  104 ++++++++++++++++++++++++++++++++++++++++-----------------
> >  1 files changed, 73 insertions(+), 31 deletions(-)
> > 
> > diff --git a/mm/truncate.c b/mm/truncate.c
> > index fdba083..e2e8a8a 100644
> > --- a/mm/truncate.c
> > +++ b/mm/truncate.c
...
> >  
> >  	pagevec_init(&pvec, 0);
> >  	index = start;
> > -	while (index <= end && pagevec_lookup(&pvec, mapping, index,
> > -			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
> > +	while (index < end && pagevec_lookup(&pvec, mapping, index,
> > +			min(end - index, (pgoff_t)PAGEVEC_SIZE))) {
>   So does this really work when end == -1 and file has ULONG_MAX pages?
> Previously it did but now you seem of skip the last page... Otherwise the
> patch looks good to me.

Recalling earlier discussion of truncate.c (which is indeed schizophrenic
about it), I believe that MAX_LFS_FILESIZE (and in particular that "-1")
prevents a file from having more than LONG_MAX pages on any architecture:

#if BITS_PER_LONG==32
#define MAX_LFS_FILESIZE	(((loff_t)PAGE_CACHE_SIZE << (BITS_PER_LONG-1))-1) 
#elif BITS_PER_LONG==64
#define MAX_LFS_FILESIZE 	((loff_t)0x7fffffffffffffffLL)
#endif

(And if we ever extend that 32-bit range, I would recommend avoiding
the final wrap-around page, which could easily cause trouble elsewhere.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

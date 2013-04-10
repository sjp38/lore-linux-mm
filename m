Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id EF1BF6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 05:52:02 -0400 (EDT)
Date: Wed, 10 Apr 2013 11:51:54 +0200 (CEST)
From: =?ISO-8859-15?Q?Luk=E1=A8_Czerner?= <lczerner@redhat.com>
Subject: Re: [PATCH v3 09/18] reiserfs: use ->invalidatepage() length
 argument
In-Reply-To: <20130409132756.GE13672@quack.suse.cz>
Message-ID: <alpine.LFD.2.00.1304101151130.10609@dhcp-1-230.brq.redhat.com>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com> <1365498867-27782-10-git-send-email-lczerner@redhat.com> <20130409132756.GE13672@quack.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Lukas Czerner <lczerner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, reiserfs-devel@vger.kernel.org

On Tue, 9 Apr 2013, Jan Kara wrote:

> Date: Tue, 9 Apr 2013 15:27:56 +0200
> From: Jan Kara <jack@suse.cz>
> To: Lukas Czerner <lczerner@redhat.com>
> Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
>     linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
>     reiserfs-devel@vger.kernel.org
> Subject: Re: [PATCH v3 09/18] reiserfs: use ->invalidatepage() length argument
> 
> On Tue 09-04-13 11:14:18, Lukas Czerner wrote:
> > ->invalidatepage() aop now accepts range to invalidate so we can make
> > use of it in reiserfs_invalidatepage()
>   Hum, reiserfs is probably never going to support punch hole. So shouldn't
> we rather WARN and return without doing anything if stop !=
> PAGE_CACHE_SIZE?
> 
> 								Honza

Hi,

I can not even think of the case when this would happen since it
could not happen before either. However in the case it happens the
code will do what's expected. So I do not have any strong preference
about this one, but I do not think it's necessary to WARN here. If
you still insist on the WARN, let me know and I'll resend the patch.

Thanks for the reviews!
-Lukas

> > 
> > Signed-off-by: Lukas Czerner <lczerner@redhat.com>
> > Cc: reiserfs-devel@vger.kernel.org
> > ---
> >  fs/reiserfs/inode.c |    9 +++++++--
> >  1 files changed, 7 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/reiserfs/inode.c b/fs/reiserfs/inode.c
> > index 808e02e..e963164 100644
> > --- a/fs/reiserfs/inode.c
> > +++ b/fs/reiserfs/inode.c
> > @@ -2975,11 +2975,13 @@ static void reiserfs_invalidatepage(struct page *page, unsigned int offset,
> >  	struct buffer_head *head, *bh, *next;
> >  	struct inode *inode = page->mapping->host;
> >  	unsigned int curr_off = 0;
> > +	unsigned int stop = offset + length;
> > +	int partial_page = (offset || length < PAGE_CACHE_SIZE);
> >  	int ret = 1;
> >  
> >  	BUG_ON(!PageLocked(page));
> >  
> > -	if (offset == 0)
> > +	if (!partial_page)
> >  		ClearPageChecked(page);
> >  
> >  	if (!page_has_buffers(page))
> > @@ -2991,6 +2993,9 @@ static void reiserfs_invalidatepage(struct page *page, unsigned int offset,
> >  		unsigned int next_off = curr_off + bh->b_size;
> >  		next = bh->b_this_page;
> >  
> > +		if (next_off > stop)
> > +			goto out;
> > +
> >  		/*
> >  		 * is this block fully invalidated?
> >  		 */
> > @@ -3009,7 +3014,7 @@ static void reiserfs_invalidatepage(struct page *page, unsigned int offset,
> >  	 * The get_block cached value has been unconditionally invalidated,
> >  	 * so real IO is not possible anymore.
> >  	 */
> > -	if (!offset && ret) {
> > +	if (!partial_page && ret) {
> >  		ret = try_to_release_page(page, 0);
> >  		/* maybe should BUG_ON(!ret); - neilb */
> >  	}
> > -- 
> > 1.7.7.6
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

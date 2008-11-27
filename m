Date: Thu, 27 Nov 2008 12:14:29 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/2] fs: symlink write_begin allocation context fix
Message-ID: <20081127111429.GL28285@wotan.suse.de>
References: <20081127093401.GE28285@wotan.suse.de> <20081127093504.GF28285@wotan.suse.de> <20081127200014.3CF6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081127200014.3CF6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 27, 2008 at 08:02:32PM +0900, KOSAKI Motohiro wrote:
> > -int __page_symlink(struct inode *inode, const char *symname, int len,
> > -		gfp_t gfp_mask)
> > +/*
> > + * The nofs argument instructs pagecache_write_begin to pass AOP_FLAG_NOFS
> > + */
> > +int __page_symlink(struct inode *inode, const char *symname, int len, int nofs)
> >  {
> >  	struct address_space *mapping = inode->i_mapping;
> >  	struct page *page;
> >  	void *fsdata;
> >  	int err;
> >  	char *kaddr;
> > +	unsigned int flags = AOP_FLAG_UNINTERRUPTIBLE;
> > +	if (nofs)
> > +		flags |= AOP_FLAG_NOFS;
> >  
> >  retry:
> >  	err = pagecache_write_begin(NULL, mapping, 0, len-1,
> > -				AOP_FLAG_UNINTERRUPTIBLE, &page, &fsdata);
> > +				flags, &page, &fsdata);
> >  	if (err)
> >  		goto fail;
> >  
> > @@ -2820,8 +2825,7 @@ fail:
> >  
> >  int page_symlink(struct inode *inode, const char *symname, int len)
> >  {
> > -	return __page_symlink(inode, symname, len,
> > -			mapping_gfp_mask(inode->i_mapping));
> > +	return __page_symlink(inode, symname, len, 0);
> >  }
> 
> your patch always pass 0 into __page_symlink().
> therefore it doesn't change any behavior.
> 
> right?

Ah, you're right I think. I misread the code: most filesystems can
tolerate GFP_FS here, and its just ext3/4 and a few others which require
nofs here.

Annoyingly, some filesystems put GFP_NOFS into their mapping_gfp_mask.
This may or may not get honoured depending on what core functions get
used (radix tree allocations shouldn't and don't allocate pages
with the mapping_gfp_mask).

Anyway, I'll set nofs=1 in the case that mapping_gfp_mask has __GFP_FS
cleared, in an attempt to minimise the chance of breakage...

Good spotting, thanks.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

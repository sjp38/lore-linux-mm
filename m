Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id BBC186B0038
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 20:13:26 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id h9so1403546qtc.2
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 17:13:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d85sor1803572qkc.122.2017.11.16.17.13.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 Nov 2017 17:13:25 -0800 (PST)
Date: Thu, 16 Nov 2017 20:13:23 -0500
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 09/10] Btrfs: kill the btree_inode
Message-ID: <20171117011322.5nmz66joqaomr5j3@destiny>
References: <1510696616-8489-1-git-send-email-josef@toxicpanda.com>
 <1510696616-8489-9-git-send-email-josef@toxicpanda.com>
 <20171117010307.GF23614@dhcp-whq-twvpn-1-vpnpool-10-159-142-193.vpn.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171117010307.GF23614@dhcp-whq-twvpn-1-vpnpool-10-159-142-193.vpn.oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liu Bo <bo.li.liu@oracle.com>
Cc: Josef Bacik <josef@toxicpanda.com>, hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Thu, Nov 16, 2017 at 05:03:08PM -0800, Liu Bo wrote:
> On Tue, Nov 14, 2017 at 04:56:55PM -0500, Josef Bacik wrote:
> > From: Josef Bacik <jbacik@fb.com>
> > 
> > In order to more efficiently support sub-page blocksizes we need to stop
> > allocating pages from pagecache for our metadata.  Instead switch to using the
> > account_metadata* counters for making sure we are keeping the system aware of
> > how much dirty metadata we have, and use the ->free_cached_objects super
> > operation in order to handle freeing up extent buffers.  This greatly simplifies
> > how we deal with extent buffers as now we no longer have to tie the page cache
> > reclaimation stuff to the extent buffer stuff.  This will also allow us to
> > simply kmalloc() our data for sub-page blocksizes.
> >
> 
> The patch is too big for one to review, but so far it looks good to
> me, a few comments.
>

Yeah unfortunately I already did all the prep work I could in previous series,
this stuff has to all be done whole hog otherwise things won't compile.
 
> > Signed-off-by: Josef Bacik <jbacik@fb.com>
> > ---
> ...
> >  
> > -static int check_async_write(struct btrfs_inode *bi)
> > +static int check_async_write(void)
> >  {
> > -	if (atomic_read(&bi->sync_writers))
> > +	if (current->journal_info)
> 
> Please add a comment that explains we're called from commit
> transaction.
> 

Yup.

> >  		return 0;
> >  #ifdef CONFIG_X86
> >  	if (static_cpu_has(X86_FEATURE_XMM4_2))
> ...
> > @@ -4977,12 +5054,12 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
> >  	unsigned long len = fs_info->nodesize;
> >  	unsigned long num_pages = num_extent_pages(start, len);
> >  	unsigned long i;
> > -	unsigned long index = start >> PAGE_SHIFT;
> >  	struct extent_buffer *eb;
> >  	struct extent_buffer *exists = NULL;
> >  	struct page *p;
> > -	struct address_space *mapping = fs_info->btree_inode->i_mapping;
> > -	int uptodate = 1;
> > +	struct btrfs_eb_info *eb_info = fs_info->eb_info;
> > +//	struct zone *last_zone = NULL;
> > +//	struct pg_data_t *last_pgdata = NULL;
> 
> hmm, a typo?
> 

Oops.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

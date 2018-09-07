Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id BFE476B7DDB
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 06:26:52 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id a23-v6so7314231pfo.23
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 03:26:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r24-v6si7794834pgo.605.2018.09.07.03.26.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 03:26:51 -0700 (PDT)
Date: Fri, 7 Sep 2018 12:26:33 +0200
From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH v6 5/6] Btrfs: rename get_chunk_map() and make it
 non-static
Message-ID: <20180907102633.GJ24025@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <cover.1536305017.git.osandov@fb.com>
 <cc582e9c138dd317ed6d1a8cb8491e367965b216.1536305017.git.osandov@fb.com>
 <74d4bc3d-7a02-a1d4-e9d7-38c503f6d5b9@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <74d4bc3d-7a02-a1d4-e9d7-38c503f6d5b9@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <nborisov@suse.com>
Cc: Omar Sandoval <osandov@osandov.com>, linux-btrfs@vger.kernel.org, kernel-team@fb.com, linux-mm@kvack.org

On Fri, Sep 07, 2018 at 10:54:52AM +0300, Nikolay Borisov wrote:
> 
> 
> On  7.09.2018 10:39, Omar Sandoval wrote:
> > From: Omar Sandoval <osandov@fb.com>
> > 
> > The Btrfs swap code is going to need it, so give it a btrfs_ prefix and
> > make it non-static.
> > 
> > Signed-off-by: Omar Sandoval <osandov@fb.com>
> 
> One minor nit but otherwise:
> 
> Reviewed-by: Nikolay Borisov <nborisov@suse.com>
> 
> > ---
> >  fs/btrfs/volumes.c | 22 +++++++++++-----------
> >  fs/btrfs/volumes.h |  9 +++++++++
> >  2 files changed, 20 insertions(+), 11 deletions(-)
> > 
> > diff --git a/fs/btrfs/volumes.c b/fs/btrfs/volumes.c
> > index 207e36b70d9b..514932c47bcd 100644
> > --- a/fs/btrfs/volumes.c
> > +++ b/fs/btrfs/volumes.c
> > @@ -2714,8 +2714,8 @@ static int btrfs_del_sys_chunk(struct btrfs_fs_info *fs_info, u64 chunk_offset)
> >  	return ret;
> >  }
> >  
> > -static struct extent_map *get_chunk_map(struct btrfs_fs_info *fs_info,
> > -					u64 logical, u64 length)
> > +struct extent_map *btrfs_get_chunk_map(struct btrfs_fs_info *fs_info,
> > +				       u64 logical, u64 length)
> >  {
> >  	struct extent_map_tree *em_tree;
> >  	struct extent_map *em;
> > @@ -2752,7 +2752,7 @@ int btrfs_remove_chunk(struct btrfs_trans_handle *trans, u64 chunk_offset)
> >  	int i, ret = 0;
> >  	struct btrfs_fs_devices *fs_devices = fs_info->fs_devices;
> >  
> > -	em = get_chunk_map(fs_info, chunk_offset, 1);
> > +	em = btrfs_get_chunk_map(fs_info, chunk_offset, 1);
> >  	if (IS_ERR(em)) {
> >  		/*
> >  		 * This is a logic error, but we don't want to just rely on the
> > @@ -4897,7 +4897,7 @@ int btrfs_finish_chunk_alloc(struct btrfs_trans_handle *trans,
> >  	int i = 0;
> >  	int ret = 0;
> >  
> > -	em = get_chunk_map(fs_info, chunk_offset, chunk_size);
> > +	em = btrfs_get_chunk_map(fs_info, chunk_offset, chunk_size);
> >  	if (IS_ERR(em))
> >  		return PTR_ERR(em);
> >  
> > @@ -5039,7 +5039,7 @@ int btrfs_chunk_readonly(struct btrfs_fs_info *fs_info, u64 chunk_offset)
> >  	int miss_ndevs = 0;
> >  	int i;
> >  
> > -	em = get_chunk_map(fs_info, chunk_offset, 1);
> > +	em = btrfs_get_chunk_map(fs_info, chunk_offset, 1);
> >  	if (IS_ERR(em))
> >  		return 1;
> >  
> > @@ -5099,7 +5099,7 @@ int btrfs_num_copies(struct btrfs_fs_info *fs_info, u64 logical, u64 len)
> >  	struct map_lookup *map;
> >  	int ret;
> >  
> > -	em = get_chunk_map(fs_info, logical, len);
> > +	em = btrfs_get_chunk_map(fs_info, logical, len);
> >  	if (IS_ERR(em))
> >  		/*
> >  		 * We could return errors for these cases, but that could get
> > @@ -5145,7 +5145,7 @@ unsigned long btrfs_full_stripe_len(struct btrfs_fs_info *fs_info,
> >  	struct map_lookup *map;
> >  	unsigned long len = fs_info->sectorsize;
> >  
> > -	em = get_chunk_map(fs_info, logical, len);
> > +	em = btrfs_get_chunk_map(fs_info, logical, len);
> >  
> >  	if (!WARN_ON(IS_ERR(em))) {
> >  		map = em->map_lookup;
> > @@ -5162,7 +5162,7 @@ int btrfs_is_parity_mirror(struct btrfs_fs_info *fs_info, u64 logical, u64 len)
> >  	struct map_lookup *map;
> >  	int ret = 0;
> >  
> > -	em = get_chunk_map(fs_info, logical, len);
> > +	em = btrfs_get_chunk_map(fs_info, logical, len);
> >  
> >  	if(!WARN_ON(IS_ERR(em))) {
> >  		map = em->map_lookup;
> > @@ -5321,7 +5321,7 @@ static int __btrfs_map_block_for_discard(struct btrfs_fs_info *fs_info,
> >  	/* discard always return a bbio */
> >  	ASSERT(bbio_ret);
> >  
> > -	em = get_chunk_map(fs_info, logical, length);
> > +	em = btrfs_get_chunk_map(fs_info, logical, length);
> >  	if (IS_ERR(em))
> >  		return PTR_ERR(em);
> >  
> > @@ -5647,7 +5647,7 @@ static int __btrfs_map_block(struct btrfs_fs_info *fs_info,
> >  		return __btrfs_map_block_for_discard(fs_info, logical,
> >  						     *length, bbio_ret);
> >  
> > -	em = get_chunk_map(fs_info, logical, *length);
> > +	em = btrfs_get_chunk_map(fs_info, logical, *length);
> >  	if (IS_ERR(em))
> >  		return PTR_ERR(em);
> >  
> > @@ -5946,7 +5946,7 @@ int btrfs_rmap_block(struct btrfs_fs_info *fs_info, u64 chunk_start,
> >  	u64 rmap_len;
> >  	int i, j, nr = 0;
> >  
> > -	em = get_chunk_map(fs_info, chunk_start, 1);
> > +	em = btrfs_get_chunk_map(fs_info, chunk_start, 1);
> >  	if (IS_ERR(em))
> >  		return -EIO;
> >  
> > diff --git a/fs/btrfs/volumes.h b/fs/btrfs/volumes.h
> > index 23e9285d88de..d68c8a05a774 100644
> > --- a/fs/btrfs/volumes.h
> > +++ b/fs/btrfs/volumes.h
> > @@ -465,6 +465,15 @@ unsigned long btrfs_full_stripe_len(struct btrfs_fs_info *fs_info,
> >  int btrfs_finish_chunk_alloc(struct btrfs_trans_handle *trans,
> >  			     u64 chunk_offset, u64 chunk_size);
> >  int btrfs_remove_chunk(struct btrfs_trans_handle *trans, u64 chunk_offset);
> > +/**
> > + * btrfs_get_chunk_map() - Find the mapping containing the given logical extent.
> > + * @logical: Logical block offset in bytes.
> > + * @length: Length of extent in bytes.
> > + *
> > + * Return: Chunk mapping or ERR_PTR.
> > + */
> 
> nit: I think the accepted style is to have the documentation before the
> definition and not declaration of the function. I guess David can fix
> that when the patch is being merged.

Yes the comment should be at the function body, I can fix that.

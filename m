Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id CFC928E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 11:01:23 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id v4so1333518edm.18
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 08:01:23 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t39si335592edd.319.2018.12.13.08.01.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 08:01:22 -0800 (PST)
Date: Thu, 13 Dec 2018 17:01:18 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH][v6] filemap: drop the mmap_sem for all blocking
 operations
Message-ID: <20181213160118.GA27517@quack2.suse.cz>
References: <20181211173801.29535-4-josef@toxicpanda.com>
 <20181212152757.10017-1-josef@toxicpanda.com>
 <20181212155536.5fb770a0c9b4f2399d4794e4@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181212155536.5fb770a0c9b4f2399d4794e4@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Josef Bacik <josef@toxicpanda.com>, kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, jack@suse.cz

On Wed 12-12-18 15:55:36, Andrew Morton wrote:
> On Wed, 12 Dec 2018 10:27:57 -0500 Josef Bacik <josef@toxicpanda.com> wrote:
> 
> > v5->v6:
> > - added more comments as per Andrew's suggestion.
> > - fixed the fpin leaks in the two error paths that were pointed out.
> > 
> 
> hm,
> 
> > --- a/mm/filemap.c~filemap-drop-the-mmap_sem-for-all-blocking-operations-v6
> > +++ a/mm/filemap.c
> > @@ -2461,7 +2476,8 @@ static struct file *do_sync_mmap_readahe
> >  
> >  /*
> >   * Asynchronous readahead happens when we find the page and PG_readahead,
> > - * so we want to possibly extend the readahead further..
> > + * so we want to possibly extend the readahead further.  We return the file that
> > + * was pinned if we have to drop the mmap_sem in order to do IO.
> >   */
> >  static struct file *do_async_mmap_readahead(struct vm_fault *vmf,
> >  					    struct page *page)
> > @@ -2545,14 +2561,15 @@ retry_find:
> >  		page = pagecache_get_page(mapping, offset,
> >  					  FGP_CREAT|FGP_FOR_MMAP,
> >  					  vmf->gfp_mask);
> > -		if (!page)
> > +		if (!page) {
> > +			if (fpin)
> > +				goto out_retry;
> 
> Is this right?  If pagecache_get_page() returns NULL we can now return
> VM_FAULT_MAJOR|VM_FAULT_RETRY whereas we used to return ENOMEM.

Yes, but once we've dropped mmap_sem, there's no way safely return -ENOMEM.
So VM_FAULT_RETRY is really the only option to tell the caller that
mmap_sem is not held anymore...

So the patch looks good to me now. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>


								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

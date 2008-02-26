Subject: Re: [PATCH 22/28] mm: add support for non block device backed swap
	files
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1JTzBV-0001aO-R3@pomaz-ex.szeredi.hu>
References: <20080220144610.548202000@chello.nl>
	 <20080220150308.142619000@chello.nl>
	 <E1JTzBV-0001aO-R3@pomaz-ex.szeredi.hu>
Content-Type: text/plain
Date: Tue, 26 Feb 2008 13:58:03 +0100
Message-Id: <1204030683.6242.319.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-02-26 at 13:45 +0100, Miklos Szeredi wrote:
> Starting review in the middle, because this is the part I'm most
> familiar with.
> 
> > New addres_space_operations methods are added:
> >   int swapfile(struct address_space *, int);
> 
> Separate ->swapon() and ->swapoff() methods would be so much cleaner IMO.

I'm ok with that, but its a_ops bloat, do we care about that? I guess
since it has limited instances - typically one per filesystem - there is
no issue here.

> Also is there a reason why 'struct file *' cannot be supplied to these
> functions?

No real reason here. I guess its cleaner indeed. Thanks.

> > +int swap_set_page_dirty(struct page *page)
> > +{
> > +	struct swap_info_struct *sis = page_swap_info(page);
> > +
> > +	if (sis->flags & SWP_FILE) {
> > +		const struct address_space_operations *a_ops =
> > +			sis->swap_file->f_mapping->a_ops;
> > +		int (*spd)(struct page *) = a_ops->set_page_dirty;
> > +#ifdef CONFIG_BLOCK
> > +		if (!spd)
> > +			spd = __set_page_dirty_buffers;
> > +#endif
> 
> This ifdef is not really needed.  Just require ->set_page_dirty() be
> filled in by filesystems which want swapfiles (and others too, in the
> longer term, the fallback is just historical crud).

Agreed. This is a good motivation to clean up that stuff.

> Here's an incremental patch addressing these issues and beautifying
> the new code.

Thanks, I'll fold it into the patch and update the documentation. I'll
put your creds in akpm style.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

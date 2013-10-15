Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9FC9C6B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 05:56:35 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so8583570pbc.9
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 02:56:35 -0700 (PDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so8621249pdj.3
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 02:56:32 -0700 (PDT)
Date: Tue, 15 Oct 2013 02:56:20 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] swap: fix set_blocksize race during swapon/swapoff
In-Reply-To: <20131011120226.1f4bb32569f370b57b841e79@linux-foundation.org>
Message-ID: <alpine.LNX.2.00.1310150246080.6194@eggly.anvils>
References: <1381485262-16792-1-git-send-email-k.kozlowski@samsung.com> <20131011120226.1f4bb32569f370b57b841e79@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Weijie Yang <weijie.yang.kh@gmail.com>, Bob Liu <bob.liu@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Shaohua Li <shli@fusionio.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>

On Fri, 11 Oct 2013, Andrew Morton wrote:
> (cc Hugh)

Thank you: I'm sorry, but I have difficulty finding a moment to look.

> 
> On Fri, 11 Oct 2013 11:54:22 +0200 Krzysztof Kozlowski <k.kozlowski@samsung.com> wrote:
> 
> > Swapoff used old_block_size from swap_info which could be overwritten by
> > concurrent swapon.
> > 
> > Reported-by: Weijie Yang <weijie.yang.kh@gmail.com>
> > Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
> > ---
> >  mm/swapfile.c |    4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/swapfile.c b/mm/swapfile.c
> > index 3963fc2..de7c904 100644
> > --- a/mm/swapfile.c
> > +++ b/mm/swapfile.c
> > @@ -1824,6 +1824,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
> >  	struct filename *pathname;
> >  	int i, type, prev;
> >  	int err;
> > +	unsigned int old_block_size;
> >  
> >  	if (!capable(CAP_SYS_ADMIN))
> >  		return -EPERM;
> > @@ -1914,6 +1915,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
> >  	}
> >  
> >  	swap_file = p->swap_file;
> > +	old_block_size = p->old_block_size;
> >  	p->swap_file = NULL;
> >  	p->max = 0;
> >  	swap_map = p->swap_map;
> > @@ -1938,7 +1940,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
> >  	inode = mapping->host;
> >  	if (S_ISBLK(inode->i_mode)) {
> >  		struct block_device *bdev = I_BDEV(inode);
> > -		set_blocksize(bdev, p->old_block_size);
> > +		set_blocksize(bdev, old_block_size);
> >  		blkdev_put(bdev, FMODE_READ | FMODE_WRITE | FMODE_EXCL);
> >  	} else {
> >  		mutex_lock(&inode->i_mutex);
> 
> I find it worrying that a swapon can run concurrently with any of this
> swapoff code.  It just seem to be asking for trouble and the code
> really isn't set up for this and races here will be poorly tested for
> 
> I'm wondering if we should just extend swapon_mutex a lot and eliminate
> the concurrency?

I have to disagree with you on this.  We do not hold swapon_mutex from 
start to finish of usage of a swap_info_struct, and there's no call to
rearrange swapon_mutex usage for this case.  It's just a straightforward
use of p->old_block_size shortly after *p was freed, and Krzysztof's
original patch was the appropriate one.  As for more verbiage, well,
I'm not so sure that more is better in this case: whichever you find
easier to understand.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
